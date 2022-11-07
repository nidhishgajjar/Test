import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
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
          title: const Text("VERIFY EMAIL"),
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
              const SizedBox(
                child: Text(
                  "Verification Code Sent",
                  style: TextStyle(
                    fontSize: 25,
                    color: uniqartTextField,
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
                      color: uniqartTextField,
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
                  color: uniqartSecondary,
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
                      color: uniqartTextField,
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
                      color: uniqartTextField,
                    ),
                  ),
                ),
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
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
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
