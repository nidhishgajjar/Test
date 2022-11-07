import 'package:uniqart/services/auth/auth_provider.dart';
import 'package:uniqart/services/auth/auth_user.dart';
import 'package:uniqart/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String displayName,
    required String email,
    required String password,
  }) =>
      provider.createUser(
        displayName: displayName,
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> sendCode({
    required String phoneNumber,
  }) =>
      provider.sendCode(
        phoneNumber: phoneNumber,
      );

  @override
  Future<void> verifyCode({
    required String otp,
  }) =>
      provider.verifyCode(otp: otp);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);
}
