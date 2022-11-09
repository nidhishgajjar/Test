import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
import 'package:uniqart/utilities/dialogs/logout_dialog.dart';

import 'package:url_launcher/url_launcher.dart';

// Stripe user portal url
final Uri _customerPortalStripe =
    Uri.parse('https://billing.stripe.com/p/login/aEU9Dodlod5V9dS8ww');

// Future to redirect to url
Future<void> _launchUrl() async {
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

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onTap: _launchUrl,
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
          // const ElevatedButton(
          //   onPressed: _launchUrl,
          //   child: Text("manage subscription"),
          // ),
        ]),
      ),
    );
  }
}
