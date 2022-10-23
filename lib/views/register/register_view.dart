import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/miscellaneous/localizations/loc.dart';
import 'package:test/services/auth/auth_exceptions.dart';
import 'package:test/services/auth/bloc/auth_bloc.dart';
import 'package:test/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _displayName;
  late final TextEditingController _phoneController;
  late final TextEditingController _email;
  late final TextEditingController _password;

  late final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController();
    _phoneController = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _displayName.dispose();
    _phoneController.dispose();
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateRegistering) {
            if (state.exception is WeakPasswordAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_weak_password,
              );
            } else if (state.exception is EmailAlreadyInUseAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_email_already_in_use,
              );
            } else if (state.exception is GenericAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_generic,
              );
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_invalid_email,
              );
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Register'),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: Column(children: [
                  const SizedBox(
                    height: 75,
                  ),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: _displayName,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        hintText: "enter your name",
                      ),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 15,
                  // ),
                  // SizedBox(
                  //   width: 250,
                  //   child: TextFormField(
                  //     controller: _phoneController,
                  //     enableSuggestions: false,
                  //     autocorrect: false,
                  //     keyboardType: TextInputType.phone,
                  //     decoration: const InputDecoration(
                  //       hintText: "enter your phone",
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 15,
                  // ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
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
                    child: TextFormField(
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
                      final displayName = _displayName.text;
                      // final phoneNumber = _phoneController.text;
                      final email = _email.text;
                      final password = _password.text;

                      context.read<AuthBloc>().add(
                            AuthEventRegister(
                              displayName,
                              // phoneNumber,
                              email,
                              password,
                            ),
                          );
                    },
                    child: const Text("CREATE"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () => context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        ),
                    child: const Text(
                      'Click here to login',
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
        ));
  }
}
