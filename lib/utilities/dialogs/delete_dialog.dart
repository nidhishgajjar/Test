import 'package:flutter/material.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteUserDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.setting_delete_user,
    content: context.loc.setting_delete_user_dialog_prompt,
    optionsBuilder: () => {
      context.loc.generic_no: false,
      context.loc.generic_delete: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
