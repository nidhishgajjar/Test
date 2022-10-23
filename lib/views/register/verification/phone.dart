import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/services/auth/bloc/auth_bloc.dart';

class VerifyPhoneView extends StatefulWidget {
  const VerifyPhoneView({super.key});

  @override
  State<VerifyPhoneView> createState() => _VerifyPhoneViewState();
}

class _VerifyPhoneViewState extends State<VerifyPhoneView> {
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _enterCodeController;

  @override
  void initState() {
    _phoneNumberController = TextEditingController();
    _enterCodeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
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
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(
                  label: Text("enter phone number"),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
              ),
              TextButton(
                onPressed: () {
                  final phone = _phoneNumberController.text;

                  context.read<AuthBloc>().add(
                        AuthEventSendCode(phone),
                      );
                  // Navigator.of(context).pushNamed(phoneVerifyRoute);
                },
                child: const Text("Send Code"),
              ),
            ],
          ),
        ));
  }
}
