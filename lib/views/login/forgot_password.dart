import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
import 'package:uniqart/utilities/dialogs/change_password_email.dart';
import 'package:uniqart/utilities/dialogs/error_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _emailController.clear();
            await showResetPasswordDialog(context);
          } else if (state.exception != null) {
            await showErrorDialog(
              context,
              context.loc.forgot_password_view_generic_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.forgot_password),
          backgroundColor: uniqartPrimary,
          titleTextStyle: const TextStyle(
            color: uniqartOnSurface,
            fontSize: 13,
            letterSpacing: 1,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: uniqartOnSurface,
            onPressed: () => context.read<AuthBloc>().add(
                  const AuthEventLogOut(),
                ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Forgot password text
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: SizedBox(
                    child: Text(
                      context.loc.forgot_password_view_prompt,
                      style: const TextStyle(
                        fontSize: 14,
                        color: uniqartTextField,
                        height: 2,
                      ),
                    ),
                  ),
                ),

                // Enter email text field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoTextFormFieldRow(
                    controller: _emailController,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    placeholder: context.loc.login_email_text_field_placeholder,
                    placeholderStyle: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.inactiveGray,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: uniqartTextField,
                    ),
                    padding: const EdgeInsets.fromLTRB(50, 55, 50, 50),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: CupertinoColors.lightBackgroundGray,
                    ),
                  ),
                ),

                // Send link button
                SizedBox(
                  height: 35,
                  width: 125,
                  child: CupertinoButton(
                    color: uniqartPrimary,
                    disabledColor: uniqartBackgroundWhite,
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(15),
                    onPressed: () {
                      final email = _emailController.text;
                      context
                          .read<AuthBloc>()
                          .add(AuthEventForgotPassword(email: email));
                    },
                    child: Text(
                      context.loc.forgot_password_send_link,
                      style: const TextStyle(
                        fontSize: 14,
                        color: uniqartOnSurface,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
