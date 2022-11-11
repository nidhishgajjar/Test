import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/services/auth/auth_exceptions.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
import 'package:uniqart/utilities/dialogs/delete_dialog.dart';
import 'package:uniqart/utilities/dialogs/error_dialog.dart';
import 'package:uniqart/utilities/dialogs/logout_dialog.dart';

import 'package:url_launcher/url_launcher.dart';

// Stripe user portal url
final Uri _customerPortalStripe =
    Uri.parse('https://checkout.uniqart.app/p/login/aEU9Dodlod5V9dS8ww');

// Contact support email
final Uri _supportEmail = Uri.parse('mailto:support@uniqart.app?');

// Future to redirect to url
Future<void> _portalLaunchUrl() async {
  try {
    if (!await launchUrl(
      _customerPortalStripe,
      mode: LaunchMode.inAppWebView,
    )) {
    } else {
      throw "could not launch $_customerPortalStripe";
    }
  } catch (_) {}
}

Future<void> _mailLaunch() async {
  try {
    if (!await launchUrl(
      _supportEmail,
    )) {
    } else {
      throw "unkown error occured please try to copy email and then send it";
    }
  } catch (_) {}
}

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateReAuthRequired) {
          if (state.exception is ReAuthException) {
            await showErrorDialog(
              context,
              context.loc.setting_delete_error_dialog,
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
          title: Text(context.loc.app_name),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(),
          child: ListView(children: [
            const SizedBox(
              height: 15,
            ),

            // Log out row
            GestureDetector(
              onTap: () async {
                final shouldLogout = showLogOutDialog(context);
                if (await shouldLogout) {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 30,
                    ),
                    const Icon(
                      Icons.logout_rounded,
                      color: uniqartPrimary,
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Text(context.loc.setting_logout_button)
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 0.5,
            ),

            // Mangage subscription row
            GestureDetector(
              onTap: _portalLaunchUrl,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 30,
                    ),
                    const Icon(
                      Icons.subscriptions_rounded,
                      color: uniqartPrimary,
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Text(context.loc.setting_manage_subscription)
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 0.5,
            ),
            const SizedBox(
              height: 250,
            ),
            Stack(
              children: [
                Center(
                  child: SizedBox(
                    height: 20,
                    width: 150,
                    child: CupertinoButton(
                      color: CupertinoColors.destructiveRed,
                      disabledColor: uniqartBackgroundWhite,
                      padding: const EdgeInsets.all(3),
                      borderRadius: BorderRadius.circular(15),
                      onPressed: () async {
                        final shouldDelete = showDeleteUserDialog(context);
                        if (await shouldDelete) {
                          context.read<AuthBloc>().add(
                                const AuthEventDelete(),
                              );
                        }
                      },
                      child: Text(
                        context.loc.setting_delete_user,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: uniqartBackgroundWhite,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
              child: Center(child: Text(context.loc.setting_support_title)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      height: 30,
                      width: 150,
                      child: CupertinoButton(
                        color: uniqartPrimary,
                        disabledColor: uniqartBackgroundWhite,
                        padding: const EdgeInsets.all(3),
                        borderRadius: BorderRadius.circular(7),
                        onPressed: _mailLaunch,
                        child: Text(
                          context.loc.setting_support_button,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: uniqartBackgroundWhite,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
