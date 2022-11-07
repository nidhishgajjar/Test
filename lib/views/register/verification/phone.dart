import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/design/color_constants.dart';
import 'package:test/services/auth/auth_service.dart';
import 'package:test/services/auth/bloc/auth_bloc.dart';

class VerifyPhoneView extends StatefulWidget {
  const VerifyPhoneView({super.key});

  @override
  State<VerifyPhoneView> createState() => _VerifyPhoneViewState();
}

class _VerifyPhoneViewState extends State<VerifyPhoneView> {
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _enterCodeController;

  bool _phone = false;

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
    final currentUser = AuthService.firebase().currentUser!;
    final displayName = currentUser.displayName;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: uniqartBackgroundWhite,
          elevation: 0.0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 300,
                child: Text(
                  "Wlecome $displayName,",
                  style: const TextStyle(
                    fontSize: 25,
                    color: uniqartTextField,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const SizedBox(
                width: 300,
                child: Text(
                  "Please enter your phone number below to recieve a verification code",
                  style: TextStyle(
                    fontSize: 14,
                    color: uniqartTextField,
                    height: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextFormFieldRow(
                  controller: _phoneNumberController,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  placeholder: "enter your phone number",
                  prefix: const Text("+1   "),
                  placeholderStyle: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.inactiveGray,
                  ),
                  style: const TextStyle(fontSize: 14, color: uniqartTextField),
                  padding: const EdgeInsets.fromLTRB(60, 55, 75, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: CupertinoColors.lightBackgroundGray,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _phone = value.length >= 10 ? true : false;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 30,
                width: 100,
                child: CupertinoButton(
                  color: uniqartPrimary,
                  disabledColor: uniqartBackgroundWhite,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(7),
                  onPressed: _phone == true
                      ? () async {
                          final phone = "+1${_phoneNumberController.text}";

                          context.read<AuthBloc>().add(
                                AuthEventSendCode(phone),
                              );
                        }
                      : null,
                  child: const Text(
                    "Send Code",
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
