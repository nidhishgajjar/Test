import 'package:flutter/material.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.generic_cancel,
    content: context.loc.home_cancel_dialog_prompt,
    optionsBuilder: () => {
      context.loc.generic_no: false,
      context.loc.generic_yes: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
