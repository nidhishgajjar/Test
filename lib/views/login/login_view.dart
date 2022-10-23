import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/miscellaneous/localizations/loc.dart';
import 'package:test/services/auth/auth_exceptions.dart';
import 'package:test/services/auth/bloc/auth_bloc.dart';
import 'package:test/utilities/dialogs/error_dialog.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
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
          title: const Text('LOGIN'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: Column(children: [
              const SizedBox(
                height: 75,
              ),
              // Image.asset(
              //   "assets/logo.png",
              //   height: 55,
              //   width: 55,
              // ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "enter your email",
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _password,
                  enableSuggestions: false,
                  obscureText: true,
                  autocorrect: false,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                    hintText: "enter your password",
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(
                        AuthEventLogIn(
                          email,
                          password,
                        ),
                      );
                },
                child: const Text("SUBMIT"),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () => context.read<AuthBloc>().add(
                      const AuthEventForgotPassword(),
                    ),
                child: const Text(
                  'forgot password?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () => context.read<AuthBloc>().add(
                      const AuthEventShouldRegister(),
                    ),
                child: const Text(
                  'Click here to register',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                    fontSize: 11,
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
