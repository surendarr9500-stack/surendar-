import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/component_model.dart';
import '../../domain/usecases/troubleshoot_usecase.dart';

enum TroubleshootingStatus {
  initial,
  analyzing,
  success,
  error,
}

class TroubleshootingState {
  final TroubleshootingStatus status;
  final String inputText;
  final AIAnalysisResult? result;
  final String? errorMessage;

  const TroubleshootingState({
    this.status = TroubleshootingStatus.initial,
    this.inputText = '',
    this.result,
    this.errorMessage,
  });

  TroubleshootingState copyWith({
    TroubleshootingStatus? status,
    String? inputText,
    AIAnalysisResult? result,
    String? errorMessage,
  }) {
    return TroubleshootingState(
      status: status ?? this.status,
      inputText: inputText ?? this.inputText,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TroubleshootingNotifier extends StateNotifier<TroubleshootingState> {
  final TroubleshootUseCase _useCase;

  TroubleshootingNotifier(this._useCase) : super(const TroubleshootingState());

  Future<void> analyze(String text) async {
    if (text.trim().isEmpty) {
      state = state.copyWith(
        status: TroubleshootingStatus.error,
        errorMessage: 'Please enter fault description',
      );
      return;
    }

    state = state.copyWith(
      status: TroubleshootingStatus.analyzing,
      inputText: text,
      errorMessage: null,
    );

    try {
      final result = await _useCase.analyze(text);
      state = state.copyWith(
        status: TroubleshootingStatus.success,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: TroubleshootingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clear() {
    state = const TroubleshootingState();
  }
}

final troubleshootUseCaseProvider = Provider<TroubleshootUseCase>((ref) {
  return TroubleshootUseCase();
});

final troubleshootingProvider = StateNotifierProvider<TroubleshootingNotifier, TroubleshootingState>((ref) {
  final useCase = ref.watch(troubleshootUseCaseProvider);
  return TroubleshootingNotifier(useCase);
});
