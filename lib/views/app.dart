import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uniqart/main_navigator.dart';
import 'package:uniqart/miscellaneous/loading/loading_screen.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';

import 'package:uniqart/views/login/forgot_password.dart';
import 'package:uniqart/views/login/login_view.dart';
import 'package:uniqart/views/register/register_view.dart';
import 'package:uniqart/views/register/verification/email.dart';
import 'package:uniqart/views/register/verification/enter_code.dart';
import 'package:uniqart/views/register/verification/phone.dart';
import 'package:uniqart/views/register/verification/user_profile.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const MainNavigator();
        } else if (state is AuthStateVerifyEnterPhoneNumber ||
            state is AuthStateSendCodeFailed) {
          return const VerifyPhoneView();
        } else if (state is AuthStateEnterCode ||
            state is AuthStateInvalidCode) {
          return const EnterCodeView();
        } else if (state is StateAddUserProfile) {
          return const UserProfile();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut ||
            state is AuthStateReAuthRequired) {
          return const LogInView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering || state is AuthStateDelete) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
