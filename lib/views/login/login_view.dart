import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/services/auth/auth_exceptions.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
import 'package:uniqart/utilities/dialogs/error_dialog.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  var _passwordVisible = true;
  bool _logIn = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _passwordVisible;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_cannot_find_user,
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_wrong_credentials,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_auth_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: uniqartBackgroundWhite,
          elevation: 0.0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: Column(children: [
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/logo.png',
                width: 75,
                height: 75,
              ),
              email(),
              const SizedBox(
                height: 25,
              ),
              password(),
              logInButton(context),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () => context.read<AuthBloc>().add(
                      const AuthEventForgotPassword(),
                    ),
                child: const Text(
                  'forgot password?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    color: Colors.blue,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              registerButton(context),
              const SizedBox(
                height: 10,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  CupertinoTextFormFieldRow email() {
    return CupertinoTextFormFieldRow(
      controller: _email,
      textInputAction: TextInputAction.next,
      enableSuggestions: true,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      placeholder: "enter your email",

      placeholderStyle: const TextStyle(
        fontSize: 14,
        color: CupertinoColors.inactiveGray,
      ),
      style: const TextStyle(
        fontSize: 14,
        color: uniqartTextField,
      ),
      padding: const EdgeInsets.fromLTRB(60, 120, 60, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: CupertinoColors.lightBackgroundGray,
      ),
      // cursorColor: uniqartOnSurface,
    );
  }

  SizedBox registerButton(BuildContext context) {
    return SizedBox(
      height: 25,
      width: 150,
      child: CupertinoButton(
        color: uniqartPrimary,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(10),
        onPressed: () => context.read<AuthBloc>().add(
              const AuthEventShouldRegister(),
            ),
        child: const Text(
          'REGISTER',
          style: TextStyle(
            fontSize: 11,
            color: uniqartOnSurface,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  SizedBox logInButton(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 100,
      child: CupertinoButton(
        color: uniqartPrimary,
        disabledColor: uniqartBackgroundWhite,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(7),
        onPressed: _logIn == true
            ? () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(
                      AuthEventLogIn(
                        email,
                        password,
                      ),
                    );
              }
            : null,
        child: const Text(
          "ENTER IN",
          style: TextStyle(
            fontSize: 14,
            color: uniqartBackgroundWhite,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Stack password() {
    return Stack(
      children: [
        CupertinoTextFormFieldRow(
          controller: _password,
          enableSuggestions: false,
          obscureText: _passwordVisible,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          placeholder: "enter your password",
          placeholderStyle: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.inactiveGray,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: uniqartTextField,
          ),
          padding: const EdgeInsets.fromLTRB(60, 10, 105, 65),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: CupertinoColors.lightBackgroundGray,
          ),
          onChanged: (value) {
            setState(() {
              _logIn = value.length >= 8 ? true : false;
            });
          },
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.fromLTRB(0, 0, 55, 0),
          child: IconButton(
            icon: Icon(
              _passwordVisible
                  ? CupertinoIcons.eye_slash_fill
                  : CupertinoIcons.eye_fill,
            ),
            color: uniqartDisabled,
            onPressed: () {
              setState(
                () {
                  _passwordVisible = !_passwordVisible;
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
