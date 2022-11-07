import 'package:flutter/material.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/utilities/dialogs/generic_dialog.dart';

Future<bool> showConfirmationDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.request_confirmation,
    content: context.loc.request_confirmation_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  ).then(
    (value) => value ?? false,
  );
}
