import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../dashboard/main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPage(
      icon: Icons.account_balance_wallet_rounded,
      title: AppStrings.onboardingPage1Title,
      subtitle: AppStrings.onboardingPage1Subtitle,
      color: AppColors.primaryIndigo,
    ),
    _OnboardPage(
      icon: Icons.savings_rounded,
      title: AppStrings.onboardingPage2Title,
      subtitle: AppStrings.onboardingPage2Subtitle,
      color: AppColors.blue,
    ),
    _OnboardPage(
      icon: Icons.flag_rounded,
      title: AppStrings.onboardingPage3Title,
      subtitle: AppStrings.onboardingPage3Subtitle,
      color: AppColors.mint,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyFirstLaunch, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(AppStrings.onboardingSkip,
                    style: TextStyles.body(context, weight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: _page == i
                              ? AppGradients.primaryButton
                              : null,
                          color: _page == i
                              ? null
                              : AppColorsOf.tertiaryText(context)
                                  .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _page == _pages.length - 1
                        ? AppStrings.onboardingGetStarted
                        : 'Next',
                    icon: _page == _pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : null,
                    onPressed: () {
                      if (_page == _pages.length - 1) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 64),
          ),
          const SizedBox(height: 36),
          Text(title, style: TextStyles.h1(context), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: TextStyles.body(context,
                color: AppColorsOf.secondaryText(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
