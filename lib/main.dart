import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:provider/provider.dart';
import 'package:test/consants/routes.dart';
import 'package:test/design/theme_data.dart';
import 'package:test/main_navigator.dart';
import 'package:test/miscellaneous/loading/loading_screen.dart';
import 'package:test/services/auth/bloc/auth_bloc.dart';
import 'package:test/services/auth/firebase_auth_provider.dart';
import 'package:test/services/place/bloc/application_bloc.dart';
import 'package:test/views/home/booking_view.dart';
import 'package:test/views/login/forgot_password.dart';
import 'package:test/views/login/login_view.dart';
import 'package:test/views/register/register_view.dart';
import 'package:test/views/register/verification/email.dart';
import 'package:test/views/register/verification/enter_code.dart';
import 'package:test/views/register/verification/phone.dart';

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
        },
        theme: unicartTheme,
        // darkTheme: ThemeData.dark(),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const MainNavigator();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateVerifyEnterPhoneNumber) {
          return const VerifyPhoneView();
        } else if (state is AuthStateEnterCode) {
          return const EnterCodeView();
        } else if (state is AuthStateLoggedOut) {
          return const LogInView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
