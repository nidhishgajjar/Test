import 'package:uniqart/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> sendCode({
    required String phoneNumber,
  });

  Future<void> verifyCode({
    required String otp,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();

  Future<void> sendPasswordReset({required String toEmail});
}
