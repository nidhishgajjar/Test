import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/services/auth/auth_exceptions.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
import 'package:uniqart/utilities/dialogs/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateInvalidCode) {
          if (state.exception is PhoneNumberAlreadyExistsException) {
            await showErrorDialog(
              context,
              context.loc.code_verify_error_already_registered,
            );
          } else if (state.exception is VerificationFailedException) {
            await showErrorDialog(
              context,
              context.loc.code_verify_error_invalid_code,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.code_verify_error_verification_failed,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            color: uniqartTextField,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventLogOut(),
                  );
            },
          ),
          backgroundColor: uniqartBackgroundWhite,
          elevation: 0.0,
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),

              // Title text
              SizedBox(
                width: 300,
                child: Text(
                  context.loc.code_verify_title_text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: uniqartPrimary,
                    height: 2,
                  ),
                ),
              ),

              // Enter code text field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextFormFieldRow(
                  controller: _enterCodeController,
                  maxLength: 6,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  placeholder: context.loc.code_verify_pin,
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

              // Verify code button
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
                  child: Text(
                    context.loc.code_verify_button,
                    style: const TextStyle(
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
      ),
    );
  }
}
