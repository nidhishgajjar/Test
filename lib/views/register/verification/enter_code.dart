import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';

class EnterCodeView extends StatefulWidget {
  const EnterCodeView({super.key});

  @override
  State<EnterCodeView> createState() => _EnterCodeViewState();
}

class _EnterCodeViewState extends State<EnterCodeView> {
  late final TextEditingController _enterCodeController;

  bool _code = false;

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
        backgroundColor: uniqartBackgroundWhite,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            const SizedBox(
              width: 300,
              child: Text(
                "Please enter verification code that you recieved via text message.",
                style: TextStyle(
                  fontSize: 14,
                  color: uniqartPrimary,
                  height: 2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoTextFormFieldRow(
                controller: _enterCodeController,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                placeholder: "enter 6 digit code",
                placeholderStyle: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.inactiveGray,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: uniqartTextField,
                ),
                padding: const EdgeInsets.fromLTRB(100, 55, 100, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: CupertinoColors.lightBackgroundGray,
                ),
                onChanged: (value) {
                  setState(() {
                    _code = value.length >= 6 ? true : false;
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
                onPressed: _code == true
                    ? () async {
                        final otp = _enterCodeController.text;
                        context.read<AuthBloc>().add(
                              AuthEventVerifyCode(otp),
                            );
                      }
                    : null,
                child: const Text(
                  "Verify Code",
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
      ),
    );
  }
}
