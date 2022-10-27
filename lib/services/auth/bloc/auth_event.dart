part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn(
    this.email,
    this.password,
  );
}

class AuthEventRegister extends AuthEvent {
  final String displayName;
  final String email;
  final String password;
  const AuthEventRegister(
    this.displayName,
    this.email,
    this.password,
  );
}

class AddUserProfile extends AuthEvent {
  const AddUserProfile();
}

class AuthEventSendCode extends AuthEvent {
  final String phoneNumber;
  const AuthEventSendCode(
    this.phoneNumber,
  );
}

class AuthEventVerifyCode extends AuthEvent {
  final String otp;
  const AuthEventVerifyCode(
    this.otp,
  );
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
