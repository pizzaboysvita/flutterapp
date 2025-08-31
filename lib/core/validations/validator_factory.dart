import 'validation_response.dart';
import 'validation_rules.dart';

class ValidatorFactory {
  static ValidationResponse validate({
    required ValidationRules rule,
    required String value,
  }) {
    switch (rule) {
      case ValidationRules.Required:
        return value.trim().isEmpty
            ? ValidationResponse(false, "This field is required.")
            : ValidationResponse(true);
      case ValidationRules.Email:
        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
        return !emailRegex.hasMatch(value.trim())
            ? ValidationResponse(false, "Enter a valid email.")
            : ValidationResponse(true);
      case ValidationRules.Password:
        return value.length < 6
            ? ValidationResponse(
                false,
                "Password must be at least 6 characters.",
              )
            : ValidationResponse(true);
    }
  }
}
