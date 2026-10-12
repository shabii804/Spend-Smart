import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/success_overlay.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<UserProvider>().user;
    _nameCtrl = TextEditingController(text: u.fullName);
    _emailCtrl = TextEditingController(text: u.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    context.read<UserProvider>().updateUser(UserProfile(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
        ));
    setState(() => _saving = false);
    if (!mounted) return;
    await SuccessOverlay.show(
      context,
      label: AppStrings.profileUpdated,
      icon: Icons.check_rounded,
    );
    if (!mounted) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.fullName,
                  controller: _nameCtrl,
                  validator: Validators.required,
                  prefix: const Icon(Icons.person_outline_rounded, size: 20),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.email,
                  controller: _emailCtrl,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.alternate_email_rounded, size: 20),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: AppStrings.save,
                  icon: Icons.check_rounded,
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
