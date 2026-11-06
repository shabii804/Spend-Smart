import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/text_styles.dart';
import '../../providers/user_provider.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _enteredPin = '';
  bool _error = false;
  late Timer _timer;
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('hh:mm a').format(now);
        _currentDate = DateFormat('EEEE, MMMM d').format(now);
      });
    }
  }

  void _onDigit(String digit) {
    HapticFeedback.lightImpact();
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _error = false;
      });
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _error = false;
      });
    }
  }

  void _verifyPin() {
    if (_enteredPin == '1234' || _enteredPin.length == 4) {
      HapticFeedback.mediumImpact();
      widget.onUnlocked();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = true;
        _enteredPin = '';
      });
    }
  }

  void _simulateBiometric() {
    HapticFeedback.heavyImpact();
    widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final isBiometric = user.biometricsEnabled;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Live Clock Header
              Text(
                _currentTime,
                style: TextStyles.displayMedium(context, color: Colors.white).copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currentDate,
                style: TextStyles.caption(context).copyWith(
                  color: AppColors.darkTextSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // Lock Icon Badge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryIndigo.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                'SpendSmart Protected',
                style: TextStyles.h2(context, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isBiometric
                    ? 'Verify with fingerprint or enter PIN (1234)'
                    : 'Enter 4-digit PIN to unlock',
                style: TextStyles.caption(context).copyWith(color: AppColors.darkTextSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // PIN Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? AppColors.primaryIndigo
                          : AppColors.darkSurfaceElevated,
                      border: Border.all(
                        color: _error ? AppColors.danger : AppColors.darkBorder,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              if (_error) ...[
                const SizedBox(height: 10),
                Text(
                  'Incorrect PIN (Try 1234)',
                  style: TextStyles.caption(context).copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              // Biometric Fingerprint Button if enabled
              if (isBiometric) ...[
                GestureDetector(
                  onTap: _simulateBiometric,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withOpacity(0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.mint.withOpacity(0.4), width: 1.5),
                    ),
                    child: const Icon(Icons.fingerprint_rounded, size: 40, color: AppColors.mint),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap for Biometrics',
                  style: TextStyles.caption(context).copyWith(
                    color: AppColors.mint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Number Pad
              for (var row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['', '0', 'DEL']
              ]) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((val) {
                    if (val.isEmpty) {
                      return const SizedBox(width: 68, height: 68);
                    }
                    return Container(
                      margin: const EdgeInsets.all(8),
                      width: 68,
                      height: 68,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkSurface,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const CircleBorder(
                            side: BorderSide(color: AppColors.darkBorder, width: 1),
                          ),
                        ),
                        onPressed: () {
                          if (val == 'DEL') {
                            _onDelete();
                          } else {
                            _onDigit(val);
                          }
                        },
                        child: val == 'DEL'
                            ? const Icon(Icons.backspace_outlined, size: 20, color: AppColors.darkTextSecondary)
                            : Text(
                                val,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
