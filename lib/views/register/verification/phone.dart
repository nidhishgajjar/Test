import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/services/auth/auth_exceptions.dart';
import 'package:uniqart/services/auth/auth_service.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
import 'package:uniqart/utilities/dialogs/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateInvalidCode) {
          if (state.exception is InvalidPhoneNumberException) {
            await showErrorDialog(
              context,
              context.loc.enter_phone_error_invalid_number,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.generic_unknown_error_body,
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
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),

                // Greetings
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

                // Body text
                SizedBox(
                  width: 300,
                  child: Text(
                    context.loc.enter_phone_body_text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: uniqartTextField,
                      height: 2,
                    ),
                  ),
                ),

                // Enter phone text field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoTextFormFieldRow(
                    controller: _phoneNumberController,
                    maxLength: 10,
                    enableSuggestions: false,
                    autocorrect: false,
                    autofillHints: const [
                      AutofillHints.telephoneNumber,
                      AutofillHints.telephoneNumberDevice
                    ],
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    placeholder: context.loc.enter_phone_phone_field_text,
                    prefix: const Text("+1   "),
                    placeholderStyle: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.inactiveGray,
                    ),
                    style:
                        const TextStyle(fontSize: 14, color: uniqartTextField),
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

                // Send code button
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
                    child: Text(
                      context.loc.enter_phone_send_code,
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
          )),
    );
  }
}
