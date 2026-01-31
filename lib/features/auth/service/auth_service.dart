import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    debugPrint('🟡 REGISTER START');
    debugPrint('📧 Email: $email');
    debugPrint('🔑 Password length: ${password.length}');

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ REGISTER SUCCESS');
      debugPrint('👤 UID: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FIREBASE AUTH ERROR');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');
      rethrow;
    } catch (e, stack) {
      debugPrint('🔥 UNKNOWN ERROR');
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async => _auth.signOut();
}
