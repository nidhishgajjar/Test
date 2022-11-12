import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uniqart/consants/routes.dart';
import 'package:uniqart/design/theme_data.dart';
import 'package:uniqart/main_navigator.dart';
import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
import 'package:uniqart/services/auth/firebase_auth_provider.dart';
import 'package:uniqart/services/place/bloc/application_bloc.dart';
import 'package:uniqart/views/app.dart';
import 'package:uniqart/views/home/booking_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationBloc(),
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        title: 'Uniqart',
        debugShowCheckedModeBanner: false,
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const HomePage(),
        ),
        routes: {
          createABookingRoute: (context) => const BookingView(),
          homeRoute: (context) => const MainNavigator(),
          // reAuthRoute: (context) => const ReAuthView(),
        },
        theme: uniqartTheme,
        // darkTheme: ThemeData.dark(),
      ),
    ),
  );
}
