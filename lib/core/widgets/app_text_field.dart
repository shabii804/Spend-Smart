import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../utils/validators.dart';

/// Standard text field with label, optional prefix/suffix and validation.
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? initialValue;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.initialValue,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue ?? '');
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            widget.label,
            style: TextStyles.label(context),
          ),
        ),
        TextFormField(
          controller: _controller,
          validator: widget.validator ?? Validators.required,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: TextStyles.body(context),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefix,
            suffixIcon: widget.suffix,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

/// Convenience: show/hide password toggle field.
class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      validator: widget.validator ?? Validators.password,
      obscureText: !_show,
      suffix: IconButton(
        icon: Icon(
          _show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: AppColorsOf.secondaryText(context),
          size: 20,
        ),
        onPressed: () => setState(() => _show = !_show),
      ),
    );
  }
}
