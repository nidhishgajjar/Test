import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/design/color_constants.dart';
import 'package:test/miscellaneous/localizations/loc.dart';
import 'package:test/services/auth/bloc/auth_bloc.dart';

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
          title: const Text("Verify Email"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
              const SizedBox(
                child: Text(
                  "Verification Code Sent",
                  style: TextStyle(
                    fontSize: 25,
                    color: uniqartOnSurface,
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(50, 0, 50, 40),
                child: SizedBox(
                  child: Text(
                    "Please check your inbox we have sent you a confirmation email. Check your junk/spam folder before resending the email.",
                    style: TextStyle(
                      fontSize: 14,
                      color: uniqartOnSurface,
                      height: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 35,
                width: 125,
                child: CupertinoButton(
                  color: uniqartPrimary,
                  disabledColor: uniqartBackgroundWhite,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(15),
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventSendEmailVerification());
                  },
                  child: const Text(
                    "Resend Link",
                    style: TextStyle(
                      fontSize: 14,
                      color: uniqartOnSurface,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 150, 0, 25),
                child: SizedBox(
                  child: Text(
                    "Verified email? Login to proceed.",
                    style: TextStyle(
                      fontSize: 16,
                      color: uniqartOnSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 35,
                width: 125,
                child: CupertinoButton(
                  color: uniqartSecondary,
                  disabledColor: uniqartBackgroundWhite,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(15),
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 14,
                      color: uniqartBackgroundWhite,
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
