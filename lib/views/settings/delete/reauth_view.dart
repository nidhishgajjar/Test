// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:uniqart/design/color_constants.dart';
// import 'package:uniqart/miscellaneous/localizations/loc.dart';
// import 'package:uniqart/services/auth/auth_exceptions.dart';
// import 'package:uniqart/services/auth/auth_service.dart';
// import 'package:uniqart/services/auth/bloc/auth_bloc.dart';
// import 'package:uniqart/utilities/dialogs/delete_dialog.dart';
// import 'package:uniqart/utilities/dialogs/error_dialog.dart';

// class ReAuthView extends StatefulWidget {
//   const ReAuthView({super.key});

//   @override
//   State<ReAuthView> createState() => _ReAuthViewState();
// }

// class _ReAuthViewState extends State<ReAuthView> {
//   late final TextEditingController _password;
//   var _passwordVisible = true;
//   bool _logIn = false;
//   String get userEmail => AuthService.firebase().currentUser!.email;

//   @override
//   void initState() {
//     super.initState();
//     _password = TextEditingController();
//     _passwordVisible;
//   }

//   @override
//   void dispose() {
//     _password.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) async {
//         if (state is AuthStateDelete) {
//           if (state.exception is UserNotFoundAuthException) {
//             await showErrorDialog(
//               context,
//               context.loc.login_error_cannot_find_user,
//             );
//           } else if (state.exception is WrongPasswordAuthException) {
//             await showErrorDialog(
//               context,
//               context.loc.login_error_wrong_credentials,
//             );
//           } else if (state.exception is GenericAuthException) {
//             await showErrorDialog(
//               context,
//               context.loc.login_error_auth_error,
//             );
//           }
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: uniqartBackgroundWhite,
//           elevation: 0.0,
//           automaticallyImplyLeading: true,
//           title: Text(
//             context.loc.reauth_title,
//             style: const TextStyle(
//               color: uniqartTextField,
//             ),
//           ),
//         ),
//         body: SingleChildScrollView(
//           keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//           child: Center(
//             child: Column(children: [
//               const SizedBox(
//                 height: 30,
//               ),
//               password(),
//               reAuthButton(context),
//               const SizedBox(
//                 height: 15,
//               ),
//               InkWell(
//                 onTap: () => context.read<AuthBloc>().add(
//                       const AuthEventForgotPassword(),
//                     ),
//                 child: Text(
//                   context.loc.login_view_forgot_password,
//                   style: const TextStyle(
//                     decoration: TextDecoration.underline,
//                     decorationColor: Colors.blue,
//                     color: Colors.blue,
//                     fontSize: 11,
//                   ),
//                 ),
//               ),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

// // Login in button
//   SizedBox reAuthButton(BuildContext context) {
//     return SizedBox(
//       height: 30,
//       width: 100,
//       child: CupertinoButton(
//         color: CupertinoColors.destructiveRed,
//         disabledColor: uniqartBackgroundWhite,
//         padding: EdgeInsets.zero,
//         borderRadius: BorderRadius.circular(7),
//         onPressed: _logIn == true
//             ? () async {
//                 final shouldDelete = showDeleteUserDialog(context);
//                 final password = _password.text;
//                 if (await shouldDelete) {
//                   context.read<AuthBloc>().add(
//                         AuthEventDelete(
//                           userEmail,
//                           password,
//                         ),
//                       );
//                 }
//               }
//             : null,
//         child: Text(
//           context.loc.generic_delete,
//           style: const TextStyle(
//             fontSize: 14,
//             color: uniqartBackgroundWhite,
//             letterSpacing: 1,
//           ),
//         ),
//       ),
//     );
//   }

// // Password text field
//   Stack password() {
//     return Stack(
//       children: [
//         CupertinoTextFormFieldRow(
//           controller: _password,
//           enableSuggestions: false,
//           obscureText: _passwordVisible,
//           textInputAction: TextInputAction.done,
//           autofillHints: const [AutofillHints.password],
//           autocorrect: false,
//           keyboardType: TextInputType.visiblePassword,
//           placeholder: context.loc.login_password_text_field_placeholder,
//           placeholderStyle: const TextStyle(
//             fontSize: 14,
//             color: CupertinoColors.inactiveGray,
//           ),
//           style: const TextStyle(
//             fontSize: 14,
//             color: uniqartTextField,
//           ),
//           padding: const EdgeInsets.fromLTRB(60, 10, 105, 65),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(7),
//             color: CupertinoColors.lightBackgroundGray,
//           ),
//           onChanged: (value) {
//             setState(() {
//               _logIn = value.length >= 8 ? true : false;
//             });
//           },
//         ),
//         Container(
//           alignment: Alignment.topRight,
//           padding: const EdgeInsets.fromLTRB(0, 0, 55, 0),
//           child: IconButton(
//             icon: Icon(
//               _passwordVisible
//                   ? CupertinoIcons.eye_slash_fill
//                   : CupertinoIcons.eye_fill,
//             ),
//             color: uniqartDisabled,
//             onPressed: () {
//               setState(
//                 () {
//                   _passwordVisible = !_passwordVisible;
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
