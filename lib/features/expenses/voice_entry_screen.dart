import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/expense.dart';
import 'add_expense_screen.dart';

/// Simulated voice entry screen. Shows a pulsing mic, "Listening…" state,
/// then after ~2.5s produces a fake pre-filled expense and pushes it to AddExpense.
class VoiceEntryScreen extends StatefulWidget {
  const VoiceEntryScreen({super.key});

  @override
  State<VoiceEntryScreen> createState() => _VoiceEntryScreenState();
}

enum _VoiceState { idle, listening, done }

class _VoiceEntryScreenState extends State<VoiceEntryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  _VoiceState _state = _VoiceState.idle;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _state = _VoiceState.listening);
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _state = _VoiceState.done);
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() => _state = _VoiceState.idle);
  }

  void _useResult() {
    // Simulated recognition result: pre-fill Add Expense with the parsed fields.
    final prefill = Expense(
      id: 'voice-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Lunch at cafe',
      amount: 320,
      categoryId: 'food',
      date: DateTime.now(),
      note: 'Logged via voice (simulated)',
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(prefill: prefill),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(AppStrings.voiceEntry),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.warning, size: 14),
                    const SizedBox(width: 6),
                    Text(AppStrings.voiceDemoLabel,
                        style: TextStyles.caption(context, weight: FontWeight.w600)
                            .copyWith(color: AppColors.warning)),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              GestureDetector(
                onTap: _state == _VoiceState.idle ? _start : null,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    final scale = _state == _VoiceState.listening
                        ? 1.0 + (_pulse.value * 0.15)
                        : 1.0;
                    final opacity = _state == _VoiceState.listening
                        ? 1.0 - (_pulse.value * 0.6)
                        : 0.4;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.primaryIndigo
                                .withOpacity(0.06 + (opacity * 0.16)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryIndigo
                                .withOpacity(0.10 + (opacity * 0.18)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: const BoxDecoration(
                              gradient: AppGradients.primaryButton,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x40635BFF),
                                  blurRadius: 24,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.mic_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _state == _VoiceState.listening
                    ? AppStrings.listening
                    : _state == _VoiceState.done
                        ? AppStrings.voiceResultTitle
                        : AppStrings.voiceStartPrompt,
                style: TextStyles.h3(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _state == _VoiceState.listening
                    ? 'Try saying "I spent Rs. 320 on lunch"'
                    : _state == _VoiceState.done
                        ? '"Lunch at cafe, 320 rupees, food"'
                        : AppStrings.voiceDemoLabel,
                style: TextStyles.body(context,
                    color: AppColorsOf.secondaryText(context)),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              if (_state == _VoiceState.done) ...[
                _ResultCard(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        child: Text(AppStrings.voiceTryAgain),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: AppStrings.voiceUse,
                        icon: Icons.check_rounded,
                        expand: true,
                        onPressed: _useResult,
                      ),
                    ),
                  ],
                ),
              ] else if (_state == _VoiceState.idle) ...[
                PrimaryButton(
                  label: 'Start Listening',
                  icon: Icons.mic_rounded,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _start();
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(AppStrings.cancel,
                    style: TextStyles.body(context,
                        weight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cat = _voiceCat();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        border: Border.all(color: AppColorsOf.border(context)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(cat.icon, color: cat.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lunch at cafe',
                    style: TextStyles.body(context, weight: FontWeight.w600)),
                Text(cat.name, style: TextStyles.caption(context)),
              ],
            ),
          ),
          const Text('Rs. 320',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryIndigo,
              )),
        ],
      ),
    );
  }
}

class VoiceResult {
  final String title;
  final String amount;
  final String categoryId;
  const VoiceResult({
    required this.title,
    required this.amount,
    required this.categoryId,
  });
}

// Helper to grab the demo category object
class _VoiceCat {
  final IconData icon;
  final Color color;
  final String name;
  const _VoiceCat(this.icon, this.color, this.name);
}

_VoiceCat _voiceCat() =>
    const _VoiceCat(Icons.restaurant_rounded, AppColors.catFood, 'Food & Dining');
