import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationRequest {
  final String phoneNumber;
  final void Function(String verificationId, int? resendToken) onCodeSent;
  final void Function(FirebaseAuthException e) onVerificationFailed;
  final void Function(PhoneAuthCredential credential) onVerificationCompleted;
  final void Function(String verificationId) onCodeAutoRetrievalTimeout;
  final Duration timeout;
  final int? forceResendingToken;

  PhoneVerificationRequest({
    required this.phoneNumber,
    required this.onCodeSent,
    required this.onVerificationFailed,
    required this.onVerificationCompleted,
    required this.onCodeAutoRetrievalTimeout,
    required this.timeout,
    required this.forceResendingToken,
  });
}
