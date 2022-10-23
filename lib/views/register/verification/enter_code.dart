import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/services/auth/bloc/auth_bloc.dart';

class EnterCodeView extends StatefulWidget {
  const EnterCodeView({super.key});

  @override
  State<EnterCodeView> createState() => _EnterCodeViewState();
}

class _EnterCodeViewState extends State<EnterCodeView> {
  late final TextEditingController _enterCodeController;

  @override
  void initState() {
    _enterCodeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _enterCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Phone Verification"),
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
              TextFormField(
                controller: _enterCodeController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  label: Text("enter 6 digit code"),
                ),
              ),

              TextButton(
                onPressed: () {
                  final otp = _enterCodeController.text;
                  context.read<AuthBloc>().add(
                        AuthEventVerifyCode(otp),
                      );
                  // Navigator.of(context).pushNamed(homeRoute);
                },
                child: const Text("Verify Code"),
              ),
              // TextButton(
              //   onPressed: () async {
              //     context.read<AuthBloc>().add(
              //           const AuthEventSendCode(_phoneNumber),
              //         );
              //   },
              //   child: const Text(
              //     "Resend Code"
              //   ),
              // )
            ],
          ),
        ));
  }
}
