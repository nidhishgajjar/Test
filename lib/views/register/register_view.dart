import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/services/auth/auth_exceptions.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
import 'package:uniqart/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _displayName;
  late final TextEditingController _phoneController;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _domainController;

  var _passwordVisible = true;
  bool _registerPassword = false;

  late final _formKey = GlobalKey<FormState>();

  final domains = ["@uwaterloo.ca", "@mylaurier.ca"];
  int index = 0;

// Cupertino modal popup
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          Container(
            height: 175,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: true,
              child: child,
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            setState(() {
              _domainController.text = domains[index];
              Navigator.pop(context);
            });
          },
          child: Text(
            context.loc.generic_done,
            style: const TextStyle(color: uniqartTextField),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController();
    _phoneController = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _domainController = TextEditingController();
    _passwordVisible;
  }

  @override
  void dispose() {
    _displayName.dispose();
    _phoneController.dispose();
    _email.dispose();
    _domainController.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateRegistering) {
            if (state.exception is WeakPasswordAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_weak_password,
              );
            } else if (state.exception is EmailAlreadyInUseAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_email_already_in_use,
              );
            } else if (state.exception is GenericAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_generic,
              );
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_invalid_email,
              );
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: uniqartBackgroundWhite,
            elevation: 0.0,
            automaticallyImplyLeading: false,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: Column(children: [
                  const SizedBox(
                    height: 25,
                  ),

                  // Title register body
                  Center(
                    child: Text(
                      context.loc.register_view_title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: uniqartPrimary,
                      ),
                    ),
                  ),

                  // Textfields
                  displayNameField(),
                  emailField(),
                  passwordField(),
                  const SizedBox(
                    height: 50,
                  ),

                  // Buttons
                  registerButton(context),
                  const SizedBox(
                    height: 165,
                  ),
                  alreadyAUserButton(context),
                ]),
              ),
            ),
          ),
        ));
  }

// Already register button
  SizedBox alreadyAUserButton(BuildContext context) {
    return SizedBox(
      height: 25,
      width: 175,
      child: CupertinoButton(
        color: uniqartPrimary,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(10),
        onPressed: () async {
          context.read<AuthBloc>().add(
                const AuthEventLogOut(),
              );
        },
        child: Text(
          context.loc.register_view_already_registered,
          style: const TextStyle(
            fontSize: 11,
            color: uniqartOnSurface,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

// Join/register button
  SizedBox registerButton(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 100,
      child: CupertinoButton(
        color: uniqartPrimary,
        disabledColor: uniqartBackgroundWhite,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(7),
        onPressed: _registerPassword == true
            ? () async {
                final displayName = _displayName.text;

                final email = _email.text + _domainController.text;
                final password = _password.text;

                if (_formKey.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                        AuthEventRegister(
                          displayName,
                          email,
                          password,
                        ),
                      );
                }
              }
            : null,
        child: Text(
          context.loc.register_join,
          style: const TextStyle(
            fontSize: 14,
            color: uniqartBackgroundWhite,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

// Password textfield
  Stack passwordField() {
    return Stack(
      children: [
        CupertinoTextFormFieldRow(
          controller: _password,
          enableSuggestions: false,
          obscureText: _passwordVisible,
          autofillHints: const [AutofillHints.newPassword],
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          placeholder: context.loc.register_view_password,
          placeholderStyle: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.inactiveGray,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: uniqartTextField,
          ),
          padding: const EdgeInsets.fromLTRB(60, 35, 105, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: CupertinoColors.lightBackgroundGray,
          ),
          onChanged: (value) {
            setState(() {
              _registerPassword = value.length >= 8 ? true : false;
            });
          },
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.fromLTRB(0, 25, 55, 0),
          child: IconButton(
            icon: Icon(
              _passwordVisible
                  ? CupertinoIcons.eye_slash_fill
                  : CupertinoIcons.eye_fill,
            ),
            color: uniqartDisabled,
            onPressed: () {
              setState(
                () {
                  _passwordVisible = !_passwordVisible;
                },
              );
            },
          ),
        ),
      ],
    );
  }

// Email text field
  Stack emailField() {
    return Stack(
      children: [
        CupertinoTextFormFieldRow(
          controller: _email,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email, AutofillHints.username],
          enableSuggestions: true,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          placeholder: context.loc.register_view_username,
          placeholderStyle: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.inactiveGray,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: uniqartTextField,
          ),
          padding: const EdgeInsets.fromLTRB(60, 35, 190, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: CupertinoColors.lightBackgroundGray,
          ),
        ),
        Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.fromLTRB(0, 27, 55, 0),
            child: SizedBox(
              width: 150,
              child: CupertinoTextFormFieldRow(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.loc.register_view_empty_domain;
                  }
                  return null;
                },
                placeholder: context.loc.register_view_select_email,
                style: const TextStyle(
                  color: uniqartTextField,
                ),
                readOnly: true,
                controller: _domainController,
                onTap: () => _showDialog(CupertinoPicker(
                  itemExtent: 40,
                  children: domains
                      .map((domains) => Center(
                            child: Text(domains),
                          ))
                      .toList(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      this.index = index;
                    });
                    _domainController.text = domains[index];
                  },
                )),
              ),
            )),
      ],
    );
  }

// Displayname textfield
  CupertinoTextFormFieldRow displayNameField() {
    return CupertinoTextFormFieldRow(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.loc.register_view_empty_name;
        }
        return null;
      },
      controller: _displayName,
      textInputAction: TextInputAction.next,
      enableSuggestions: true,
      autocorrect: false,
      autofillHints: const [
        AutofillHints.name,
        AutofillHints.namePrefix,
      ],
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      placeholder: context.loc.register_view_displayname,
      placeholderStyle: const TextStyle(
        fontSize: 14,
        color: CupertinoColors.inactiveGray,
      ),
      style: const TextStyle(
        fontSize: 14,
        color: uniqartTextField,
      ),
      padding: const EdgeInsets.fromLTRB(60, 85, 60, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: CupertinoColors.lightBackgroundGray,
      ),
    );
  }
}
