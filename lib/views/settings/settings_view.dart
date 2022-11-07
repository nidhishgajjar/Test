import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
import 'package:uniqart/utilities/dialogs/logout_dialog.dart';

import 'package:url_launcher/url_launcher.dart';

final Uri _customerPortalStripe =
    Uri.parse('https://billing.stripe.com/p/login/test_6oE16jc4D5PD8PC288');

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
        title: const Text('UNIQART'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(),
        child: ListView(children: [
          const SizedBox(
            height: 15,
          ),
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
                children: const [
                  SizedBox(
                    width: 30,
                  ),
                  Icon(
                    Icons.logout_rounded,
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Text("Log Out")
                ],
              ),
            ),
          ),
          const Divider(
            thickness: 0.5,
          ),
          GestureDetector(
            onTap: _launchUrl,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: const [
                  SizedBox(
                    width: 30,
                  ),
                  Icon(
                    Icons.subscriptions_rounded,
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Text("Manage Subscription")
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
