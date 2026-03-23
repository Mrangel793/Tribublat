import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  //- Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  //- Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign in was aborted.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    } catch (e) {
      // Cualquier otro error (configuración, red, etc.)
      throw AuthException('Error con Google: $e');
    }
  }

  //- Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  //- Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null) {
        await userCredential.user?.updateDisplayName(displayName);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  //- Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  //- Password reset
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  //- Handle authentication errors
  AuthException _handleAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return AuthException('El correo electrónico no es válido.');
      case 'user-disabled':
        return AuthException('Esta cuenta ha sido deshabilitada.');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        // Firebase moderno unifica estos errores en 'invalid-credential'
        // No especificamos cuál falló por seguridad
        return AuthException('Correo o contraseña incorrectos. Verifícalos e intenta de nuevo.');
      case 'email-already-in-use':
        return AuthException('Este correo ya está registrado. Intenta iniciar sesión.');
      case 'operation-not-allowed':
        return AuthException('Este método de inicio de sesión no está habilitado.');
      case 'weak-password':
        return AuthException('La contraseña es muy débil. Usa al menos 6 caracteres.');
      case 'too-many-requests':
        return AuthException('Demasiados intentos fallidos. Espera unos minutos e intenta de nuevo.');
      case 'network-request-failed':
        return AuthException('Sin conexión a internet. Verifica tu red e intenta de nuevo.');
      default:
        return AuthException('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
