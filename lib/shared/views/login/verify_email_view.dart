import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../cloud/services/auth/bloc/auth_bloc.dart';
import '../../../cloud/services/auth/bloc/auth_event.dart';
import '../../extensions/buildcontext/loc.dart';
import '../../services/crud/notes_services.dart';
import '../../providers/app_notifier.dart';
import '../../utilities/actions/online_status_icon.dart';
import '../../utilities/dialogs/resend_verification.dart';
import '../../../cloud/services/auth/firebase/auth_service.dart';
import '../../utilities/actions/popup_menu.dart';

class CloudVerifyEmailView extends StatefulWidget {
  const CloudVerifyEmailView({super.key});

  @override
  CloudVerifyEmailViewState createState() => CloudVerifyEmailViewState();
}

class CloudVerifyEmailViewState extends State<CloudVerifyEmailView> {
  late final LocalNotesService _notesService;
  bool isTimeToSendAgain = false;

  @override
  void initState() {
    _notesService = LocalNotesService();
    Future.delayed(const Duration(seconds: 20));
    setState(() => isTimeToSendAgain = true);
    // ? --------------------------------
    // debugPrint('|===> verify_email_view | initState() | isTimeToSendAgain: $isTimeToSendAgain ');
    super.initState();
  }

  Future sendVerificationEmailAgain() async {
    try {
      context.read<AuthBloc>().add(
            const AuthEventSendEmailVerification(),
          );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        context.loc.verify_email_view_notification,
      )));
      setState(() => isTimeToSendAgain = false);
      // ? --------------------------------
      // debugPrint('|===> verify_email_view | sendVerificationEmailAgain() | isTimeToSendAgain: $isTimeToSendAgain ');
      await Future.delayed(const Duration(seconds: 30));
      setState(() => isTimeToSendAgain = true);
      // ? --------------------------------
      // debugPrint('|===> verify_email_view | sendVerificationEmailAgain() | isTimeToSendAgain: $isTimeToSendAgain ');
    } catch (e) {
      // ? --------------------------------
      // debugPrint('|===> verify_email_view | sendVerificationEmailAgain() | isTimeToSendAgain: $isTimeToSendAgain ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const OnlineStatusIcon(),
              Text(
                context.loc.verify_email_view_title,
              ),
            ],
          ),
          actions: [
            popupMenuItems(context),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey.shade200,
                  child: const CircleAvatar(
                      radius: 62,
                      child: Icon(
                        Icons.mark_email_read,
                        size: 90.0,
                      )),
                ),
                const SizedBox(
                  height: 30,
                ),
                (!appStateNotifier.isOnline)
                    ? Text(
                        context.loc.verify_email_view_internet_prompt,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                    : const SizedBox(
                        height: 20,
                      ),
                Text(
                  context.loc.verify_email_view_prompt,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.outgoing_mail,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 28.0,
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  onPressed: () async {
                    if (appStateNotifier.isOnline) {
                      (isTimeToSendAgain)
                          ? sendVerificationEmailAgain()
                          : await showSentEmailConfirmationDialog(
                              context,
                              context.loc.dialog_email_verification_prompt,
                              context.loc.dialog_email_verification_title,
                              Icon(
                                Icons.hourglass_top,
                                size: 60,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            );
                    } else {
                      await showSentEmailConfirmationDialog(
                        context,
                        context.loc.dialog_no_internet_prompt,
                        context.loc.dialog_no_internet_title,
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 60,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  label: Text(
                    context.loc.verify_email_send_email_again,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.loc.verify_email_already_clicked,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final user = AuthService.firebase().currentUser;
                        if (user != null) {
                          bool isUserEmailVerified = user.isEmailVerified;
                          (isUserEmailVerified)
                              ? await _notesService.updateLocalUserIsEmailVerified(email: user.email)
                              : null;
                          context.read<AuthBloc>().add(
                                const AuthEventLogOut(),
                              );
                        } else {
                          context.read<AuthBloc>().add(
                                const AuthEventShouldRegister(),
                              );
                        }
                      },
                      child: Text(
                        context.loc.verify_email_login_here,
                        style: TextStyle(
                          shadows: [Shadow(color: Theme.of(context).colorScheme.primary, offset: const Offset(0, -2))],
                          fontSize: 16,
                          color: Colors.transparent,
                          decoration: TextDecoration.underline,
                          decorationColor: Theme.of(context).colorScheme.primary,
                          decorationThickness: 2,
                          decorationStyle: TextDecorationStyle.dashed,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
