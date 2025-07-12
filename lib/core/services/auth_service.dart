import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:whatsapp_clone/model/phone_verification_request.dart';

class AuthService {
  FirebaseAuth? _firebaseAuth;
  
  FirebaseAuth get firebaseAuth {
    _firebaseAuth ??= FirebaseAuth.instance;
    return _firebaseAuth!;
  }
  
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  User? get currentUser => firebaseAuth.currentUser;

  Future<void> verifyPhoneNumber({
    required PhoneVerificationRequest request,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: request.phoneNumber,
      verificationCompleted: request.onVerificationCompleted,
      verificationFailed: request.onVerificationFailed,
      codeSent: request.onCodeSent,
      codeAutoRetrievalTimeout: request.onCodeAutoRetrievalTimeout,
      timeout: request.timeout,
      forceResendingToken: request.forceResendingToken,
    );
  }

  Future<UserCredential?> signInWithOtp(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("❌ Error signing in with OTP: ${e.code} - ${e.message}");
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Unexpected error signing in with OTP: $e");
      }
      return null;
    }
  }

  Future<UserCredential> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    return await firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
