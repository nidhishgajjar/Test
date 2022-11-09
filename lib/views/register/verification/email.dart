import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.loc.verify_email),
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 60,
              ),

              // Title
              SizedBox(
                child: Text(
                  context.loc.verify_email_view_title,
                  style: const TextStyle(
                    fontSize: 25,
                    color: uniqartTextField,
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),

              // Body text
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 40),
                child: SizedBox(
                  child: Text(
                    context.loc.verify_email_view_body_text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: uniqartTextField,
                      height: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              // Resend verification button
              SizedBox(
                height: 35,
                width: 125,
                child: CupertinoButton(
                  color: uniqartThird,
                  disabledColor: uniqartBackgroundWhite,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(15),
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventSendEmailVerification());
                  },
                  child: Text(
                    context.loc.verify_email_resend_email_verification,
                    style: const TextStyle(
                      fontSize: 14,
                      color: uniqartTextField,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // Text already verified
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 150, 0, 25),
                child: SizedBox(
                  child: Text(
                    context.loc.verify_email_view_already_verified_text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: uniqartTextField,
                    ),
                  ),
                ),
              ),

              // Login button
              SizedBox(
                height: 35,
                width: 125,
                child: CupertinoButton(
                  color: uniqartPrimary,
                  disabledColor: uniqartBackgroundWhite,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(15),
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: Text(
                    context.loc.generic_login_button,
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
        ));
  }
}
