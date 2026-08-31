import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// AES-256-GCM encryption service
/// Uses platform-backed secure storage for key management
/// Never hardcodes keys
class EncryptionService {
  final FlutterSecureStorage _secureStorage;
  
  EncryptionService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _keyStorageKey = AppConstants.keyEncryptionKey;

  /// Generate a new 256-bit key and store securely
  Future<String> generateAndStoreKey() async {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final keyBase64 = base64Encode(keyBytes);
    await _secureStorage.write(key: _keyStorageKey, value: keyBase64);
    return keyBase64;
  }

  /// Get or create encryption key
  Future<encrypt.Key> getOrCreateKey() async {
    String? keyBase64 = await _secureStorage.read(key: _keyStorageKey);
    if (keyBase64 == null) {
      keyBase64 = await generateAndStoreKey();
    }
    final keyBytes = base64Decode(keyBase64);
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }

  /// Get key from base64 string (for testing)
  encrypt.Key keyFromBase64(String base64Key) {
    final keyBytes = base64Decode(base64Key);
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }

  /// Encrypt plaintext using AES-256-GCM
  /// Returns base64 encoded: nonce(12) + ciphertext + tag(16)
  Future<String> encryptText(String plaintext, {encrypt.Key? key}) async {
    final encryptionKey = key ?? await getOrCreateKey();
    final iv = encrypt.IV.fromSecureRandom(12);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encryptionKey, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    // Combine IV + ciphertext
    final combined = iv.bytes + encrypted.bytes;
    return base64Encode(combined);
  }

  /// Decrypt ciphertext
  Future<String> decryptText(String ciphertextBase64, {encrypt.Key? key}) async {
    final encryptionKey = key ?? await getOrCreateKey();
    final combined = base64Decode(ciphertextBase64);
    final iv = encrypt.IV(Uint8List.fromList(combined.sublist(0, 12)));
    final encryptedBytes = combined.sublist(12);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encryptionKey, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypt.Encrypted(Uint8List.fromList(encryptedBytes));
    return encrypter.decrypt(encrypted, iv: iv);
  }

  /// Hash password using SHA256 + salt (for local verification, real auth uses bcrypt server side)
  /// For offline cache, we use bcrypt hash from server, not this.
  /// This is utility for checksum.
  String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate checksum for file integrity
  String generateChecksum(List<int> data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }

  /// Clear stored key (logout)
  Future<void> clearKey() async {
    await _secureStorage.delete(key: _keyStorageKey);
  }
}
