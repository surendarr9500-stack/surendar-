import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'field_engineer');
  final _passwordController = TextEditingController(text: 'Field@123');
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _offlineMode = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate login - in production this would call backend API and cache for offline
    await Future.delayed(const Duration(seconds: 1));

    // Demo credentials check
    final validUsers = {
      'admin': {'password': 'Admin@123', 'role': 'administrator'},
      'field_engineer': {'password': 'Field@123', 'role': 'field_engineer'},
      'technician': {'password': 'Tech@123', 'role': 'technician'},
      'training_officer': {'password': 'Training@123', 'role': 'training_officer'},
      'supervisor': {'password': 'Supervisor@123', 'role': 'supervisor'},
    };

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (validUsers.containsKey(username) && validUsers[username]!['password'] == password) {
      // Save to secure storage simulation
      // In real app: await secureStorage.saveTokens(...)
      
      if (mounted) {
        context.go('/dashboard');
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid credentials. Try demo accounts:\nfield_engineer / Field@123\nadmin / Admin@123';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.waves, size: 32, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Capacity Connect',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MoES Secure Field Platform',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Offline indicator
                      if (_offlineMode)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade800),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'OFFLINE MODE - LOCAL ENGINE ACTIVE',
                                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      if (_offlineMode) const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Username required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password required';
                          if (value.length < 6) return 'Password too short';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                          ),
                        ),
                      
                      if (_errorMessage != null) const SizedBox(height: 16),
                      
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Demo accounts
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Demo Accounts:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                            const SizedBox(height: 4),
                            Text('field_engineer / Field@123 (Field Engineer)', style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
                            Text('admin / Admin@123 (Administrator)', style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
                            Text('technician / Tech@123 (Technician)', style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _offlineMode = !_offlineMode),
                            child: Text(_offlineMode ? 'Go Online' : 'Simulate Offline'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Show security info
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Security Policy'),
                                  content: const Text(
                                    'Offline authentication:\n'
                                    '- Requires prior online login\n'
                                    '- Device must be registered\n'
                                    '- Offline session max 72h\n'
                                    '- AES-256-GCM encrypted storage\n'
                                    '- Secure key in platform keystore',
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Security Info'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
