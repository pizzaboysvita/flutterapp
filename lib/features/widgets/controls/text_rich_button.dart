import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/helpers/device_helper.dart';

class TextRichButton extends StatelessWidget {
  final String normalText;
  final String actionText;
  final TextStyle? normalTextStyle;
  final TextStyle? actionTextStyle;
  final Function()? onActionTap;

  const TextRichButton({
    super.key,
    required this.normalText,
    required this.actionText,
    this.normalTextStyle,
    this.actionTextStyle,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = DeviceHelper.textTheme(context);

    return Text.rich(
      TextSpan(
        text: normalText,
        style:
            normalTextStyle ??
            textTheme.titleSmall?.copyWith(color: AppColors.blackColor),
        children: [
          TextSpan(
            text: actionText,
            style:
                actionTextStyle ??
                textTheme.titleMedium?.copyWith(color: AppColors.redPrimary),
            recognizer: TapGestureRecognizer()..onTap = onActionTap,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
