import 'package:flutter/material.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/utilities/dialogs/generic_dialog.dart';

Future<void> showResetPasswordDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.reset_password_dialog_titile,
    content: context.loc.forgot_password_dialog_prompt,
    optionsBuilder: () => {
      context.loc.generic_ok: null,
    },
  );
}
