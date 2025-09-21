class LoginCheckboxState {
  final bool rememberMe;
  final bool acceptTerms;

  LoginCheckboxState({
    this.rememberMe = false,
    this.acceptTerms = false,
  });

  LoginCheckboxState copyWith({
    bool? rememberMe,
    bool? acceptTerms,
  }) {
    return LoginCheckboxState(
      rememberMe: rememberMe ?? this.rememberMe,
      acceptTerms: acceptTerms ?? this.acceptTerms,
    );
  }
}