import 'package:clinic_flutter/core/errors/app_exception.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../ui/features/shell/view_models/session_controller.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required SessionController session}) : _session = session;

  final SessionController _session;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = false;
  String? _errorCode;
  String? _errorDetail;

  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  String? get errorDetail => _errorDetail;

  Future<bool> submit() async {
    final emailErr = emailError(emailController.text);
    final passErr = passwordError(passwordController.text);
    if (emailErr != null || passErr != null) {
      _errorCode = passErr == 'tooShort' ? 'tooShort' : 'invalid';
      _errorDetail = null;
      notifyListeners();
      return false;
    }
    _loading = true;
    _errorCode = null;
    _errorDetail = null;
    notifyListeners();
    final ok = await _session.login(
      emailController.text.trim(),
      passwordController.text,
    );
    _loading = false;
    if (!ok) {
      final err = _session.lastLoginError;
      if (err is NetworkException) {
        _errorCode = 'network';
        _errorDetail = err.message;
      } else if (err is UnauthorizedException) {
        _errorCode = 'credentials';
      } else {
        _errorCode = 'login';
        _errorDetail = err is AppException ? err.message : err?.toString();
      }
    }
    notifyListeners();
    return ok;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
