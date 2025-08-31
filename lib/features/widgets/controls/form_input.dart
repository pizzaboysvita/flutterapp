import 'package:flutter/material.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/validations/validation_rules.dart';
import 'package:pizza_boys/core/validations/validator_factory.dart';

class FormInput extends StatefulWidget {
  final String? labelText;
  final String? placeHolderText;
  final bool showLabel;
  final bool showPrefixIcon;
  final bool isRequired;
  final TextInputType inputType;
  final Widget? suffixIcon;
  final bool isVisible;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autoValidate;
  final List<ValidationRules>? validationRules;
  final String? initialValue;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final double? contentPadding;
  final bool isFillColorChange;
  final Color fillColor;
  final bool isOutlinedBorder;
  final bool submitted; // 👈 Add this

  const FormInput({
    super.key,
    this.labelText,
    this.placeHolderText,
    this.showLabel = false,
    this.showPrefixIcon = false,
    this.isRequired = false,
    this.inputType = TextInputType.text,
    this.suffixIcon,
    this.isVisible = false,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autoValidate = false,
    this.validationRules,
    this.initialValue,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.contentPadding,
    this.isFillColorChange = false,
    this.fillColor = AppColors.redPrimary,
    this.isOutlinedBorder = true,
    this.submitted = false, // 👈 Default to false
  });

  @override
  State<FormInput> createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  final _isFormHasError = ValueNotifier(false);
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? "");
    _controller.addListener(_handleTextChange);
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        final isValid = _validate(_controller.text) == null;
        _isFormHasError.value = !isValid;
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (widget.focusNode == null) _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    widget.onChanged?.call(_controller.text);

    // 🔥 Only validate if form has been submitted
    if (widget.submitted) {
      setState(() {
        _errorMessage = _validate(_controller.text);
      });
    }
  }

  String? _validate(String? value) {
    if (widget.isRequired) {
      final requiredValidation = ValidatorFactory.validate(
        rule: ValidationRules.Required,
        value: value ?? "",
      );
      if (!requiredValidation.isValid) return requiredValidation.message;
    }

    for (final rule in widget.validationRules ?? []) {
      final result = ValidatorFactory.validate(rule: rule, value: value ?? "");
      if (!result.isValid) return result.message;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isFormHasError,
      builder: (_, bool isError, __) {
        return TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: widget.isVisible,
          keyboardType: widget.inputType,
          textInputAction: widget.textInputAction,
          validator: _validate,
          autovalidateMode: widget.autoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.placeHolderText,
            errorText: _errorMessage,
            filled: true,
            fillColor: widget.isFillColorChange
                ? widget.fillColor
                : Colors.white,
            prefixIcon: widget.showPrefixIcon
                ? widget.prefixIcon ?? _getPrefixIcon(!isError)
                : null,
            suffixIcon: widget.suffixIcon,
            contentPadding: widget.contentPadding != null
                ? EdgeInsets.all(widget.contentPadding!)
                : null,
            border: widget.isOutlinedBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  )
                : InputBorder.none,
          ),
        );
      },
    );
  }

  Widget _getPrefixIcon(bool isValid) {
    return Container(
      height: 55,
      margin: const EdgeInsets.only(left: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: widget.prefixIcon ?? const SizedBox(),
    );
  }

  String getCurrentValue() => _controller.text;
}
