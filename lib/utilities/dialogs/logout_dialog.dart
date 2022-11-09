import 'package:flutter/material.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.setting_logout_button,
    content: context.loc.logout_dialog_prompt,
    optionsBuilder: () => {
      context.loc.generic_no: false,
      context.loc.setting_logout_button: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
