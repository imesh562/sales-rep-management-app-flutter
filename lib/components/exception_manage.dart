import 'package:flutter/cupertino.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ExceptionManagement {
  static loginExceptions(
      {required BuildContext context, required String error}) {
    switch (error) {
      case '[firebase_auth/unknown] Given String is empty or null':
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'Please fill out the credentials.',
          ),
        );
        break;
      case '[firebase_auth/invalid-email] The email address is badly formatted.':
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'E-mail address format is wrong.',
          ),
        );
        break;
      case '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.':
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'User not found',
          ),
        );
        break;
      case '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.':
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'Invalid password',
          ),
        );
        break;
      case '[firebase_auth/unknown] com.google.firebase.FirebaseException: An internal error has occurred. [ Read error:ssl=0xb8ef6118: I/O error during system call, Connection reset by peer ]':
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'Network error.',
          ),
        );
        break;
      case '[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'Network error.',
          ),
        );
        break;
      default:
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: error,
          ),
        );
    }
  }

  static registerExceptions(
      {required BuildContext context, required String error}) {
    switch (error) {
      case '[firebase_auth/email-already-in-use] The email address is already in use by another account.':
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'The email is already registered.',
          ),
        );
        break;
      case '[firebase_auth/unknown] com.google.firebase.FirebaseException: An internal error has occurred. [ Read error:ssl=0xb8ef6118: I/O error during system call, Connection reset by peer ]':
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'Network error.',
          ),
        );
        break;
      case '[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'Network error.',
          ),
        );
        break;
      default:
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: error,
          ),
        );
    }
  }
}
