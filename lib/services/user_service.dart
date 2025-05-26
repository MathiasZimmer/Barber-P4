// services/user_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
// import 'package:cloud_firestore/cloud_firestore.dart'; // Uncomment if saving extra user data to Firestore

// Represents the application's user, derived from Firebase Auth user.
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isAnonymous; // Tracks if the user is an anonymous one

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    required this.isAnonymous,
  });

  // Factory constructor to create an AppUser from a Firebase User
  factory AppUser.fromFirebaseUser(fb_auth.User firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      isAnonymous: firebaseUser.isAnonymous, // Get from Firebase user object
    );
  }
}

class UserService with ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Uncomment if saving extra user data

  AppUser? _currentUser;
  bool _isLoading =
      true; // Tracks initial auth state check and ongoing operations
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: Listen to Firebase auth state changes
  UserService() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    _initializeUser(); // Perform an initial check for the current user
  }

  Future<void> _initializeUser() async {
    _isLoading = true;
    // Don't notify here to prevent UI flicker if user is already determined quickly
    final fb_auth.User? firebaseUser = _firebaseAuth.currentUser;
    await _onAuthStateChanged(firebaseUser); // Process the current user state
  }

  // Callback for when Firebase auth state changes
  Future<void> _onAuthStateChanged(fb_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      print('UserService: User is currently signed out!');
    } else {
      print(
        'UserService: User signed in/state changed. UID: ${firebaseUser.uid}, Anonymous: ${firebaseUser.isAnonymous}, Name: ${firebaseUser.displayName}',
      );
      _currentUser = AppUser.fromFirebaseUser(firebaseUser);
    }
    _isLoading = false; // Auth state determined or updated
    // Only clear error if the auth state actually changed to a valid user or null
    // This prevents clearing an error message from a failed login/register attempt immediately
    // if _onAuthStateChanged is called multiple times without a successful state change.
    if ((firebaseUser != null && _currentUser?.uid == firebaseUser.uid) ||
        firebaseUser == null) {
      _errorMessage = null;
    }
    if (hasListeners) notifyListeners();
  }

  // Register user with email and password
  Future<bool> registerUser(
    String email,
    String password, {
    String? name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      print('UserService: Attempting to create Firebase user: $email');
      fb_auth.UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      print('UserService: Firebase user created: ${userCredential.user?.uid}');

      if (name != null && name.isNotEmpty && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        print(
          'UserService: Display name updated for user: ${userCredential.user?.uid} to $name',
        );
        // Manually update _currentUser to reflect the new display name immediately
        // as _onAuthStateChanged might not pick up displayName changes without a token refresh.
        if (_firebaseAuth.currentUser != null) {
          // currentUser should be the same as userCredential.user
          _currentUser = AppUser.fromFirebaseUser(_firebaseAuth.currentUser!);
        }
      }
      _isLoading = false; // Set loading to false after all operations
      notifyListeners(); // Notify for the new user state
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      print(
        'UserService: FirebaseAuthException during registration: ${e.code} - ${e.message}',
      );
      _errorMessage = e.message ?? "Registration failed.";
    } catch (e) {
      print('UserService: Generic error during registration: $e');
      _errorMessage = "An unexpected error occurred during registration.";
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Login user with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print('UserService LOGIN: Attempting to login user: $email');
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('UserService: User sign-in successful for: $email');
      // _onAuthStateChanged will update _currentUser.
      // We can ensure isLoading is false after successful operation before auth listener fires.
      _isLoading = false;
      notifyListeners(); // Notify for isLoading change
      // ... existing code ...
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      print(
        'UserService LOGIN: FirebaseAuthException: Code: ${e.code}, Message: ${e.message}, StackTrace: ${e.stackTrace}',
      );
      _errorMessage = e.message ?? "Login failed due to Firebase Auth error.";

      // More specific error messages in Danish
      if (e.code == 'user-not-found' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        _errorMessage = 'Forkert email eller adgangskode.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Forkert adgangskode.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'Ugyldigt email format.';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, s) {
      print('UserService LOGIN: GENERIC or PLATFORM error: $e');
      print('UserService LOGIN: StackTrace for generic error: $s');
      _errorMessage =
          "En uventet teknisk fejl opstod under login. Prøv igen senere.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in user anonymously
  Future<AppUser?> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      print('UserService: Attempting to sign in anonymously...');
      final userCredential = await _firebaseAuth.signInAnonymously();
      print(
        'UserService: Anonymous sign-in successful. UID: ${userCredential.user?.uid}',
      );
      if (userCredential.user != null) {
        // _onAuthStateChanged will fire, but update immediately for the caller
        _currentUser = AppUser.fromFirebaseUser(userCredential.user!);
        _isLoading = false;
        notifyListeners(); // Notify for the new user state
        return _currentUser;
      }
      // This part should ideally not be reached if signInAnonymously was successful
      _isLoading = false;
      notifyListeners();
      return null;
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = "Anonymous sign-in failed: ${e.message}";
      print(
        'UserService: FirebaseAuthException during anonymous sign-in: ${e.code} - ${e.message}',
      );
    } catch (e) {
      _errorMessage = "An unexpected error occurred during anonymous sign-in.";
      print('UserService: Generic error during anonymous sign-in: $e');
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // ADD THIS METHOD
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Future<void> updateUserDisplayName(String newName) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      // Optionally set a loading state specific to this operation if it's long
      // _isLoadingProfileUpdate = true; notifyListeners();
      try {
        print(
          'UserService: Attempting to update display name for UID: ${firebaseUser.uid} to "$newName"',
        );
        await firebaseUser.updateDisplayName(newName);
        // After updating, refresh the local _currentUser with the new info
        _currentUser = AppUser.fromFirebaseUser(
          firebaseUser,
        ); // Recreate AppUser with new displayName
        print('UserService: Display name updated successfully to "$newName"');
        notifyListeners(); // Notify UI about the change in _currentUser
      } on fb_auth.FirebaseAuthException catch (e) {
        print(
          'UserService: Error updating display name - FirebaseAuthException: ${e.message}',
        );
        _errorMessage = "Failed to update name: ${e.message}";
        notifyListeners();
      } catch (e) {
        print('UserService: Error updating display name - Generic: $e');
        _errorMessage = "An error occurred while updating name.";
        notifyListeners();
      }
      // _isLoadingProfileUpdate = false; notifyListeners();
    } else {
      _errorMessage = "No user logged in to update display name.";
      print('UserService: No current user to update display name for.');
      notifyListeners();
    }
  }
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // END OF ADDED METHOD
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  // Optional: Method to link anonymous account to permanent credentials
  Future<bool> linkAnonymousAccountToEmail(
    String email,
    String password,
  ) async {
    if (_currentUser == null || !_currentUser!.isAnonymous) {
      _errorMessage = "No anonymous user to link or user is not anonymous.";
      notifyListeners();
      return false;
    }
    // Use the actual firebase_auth.User for linking
    final fbUserToLink = _firebaseAuth.currentUser;
    if (fbUserToLink == null || !fbUserToLink.isAnonymous) {
      _errorMessage = "Internal error: Firebase user mismatch for linking.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      print(
        'UserService: Attempting to link anonymous account (UID: ${fbUserToLink.uid}) to email: $email',
      );
      final credential = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await fbUserToLink.linkWithCredential(credential);
      print('UserService: Anonymous account linked successfully.');
      // _onAuthStateChanged will update the user state (no longer anonymous).
      // We can set isLoading to false here.
      _isLoading = false;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = "Failed to link account: ${e.message}";
      print(
        'UserService: FirebaseAuthException during account linking: ${e.code} - ${e.message}',
      );
    } catch (e) {
      _errorMessage = "An unexpected error occurred during account linking.";
      print('UserService: Generic error during account linking: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Logout user
  Future<void> logout() async {
    print(
      'UserService LOGOUT: Attempting to sign out user: ${_currentUser?.uid}',
    );
    _isLoading = true; // Indicate an operation is in progress
    _errorMessage = null;
    notifyListeners(); // Let UI know logout has started

    try {
      await _firebaseAuth.signOut();
      print('UserService LOGOUT: Firebase signOut successful.');
      // _onAuthStateChanged will be called automatically.
      // It will set _currentUser to null, _isLoading to false, and call notifyListeners.
    } on fb_auth.FirebaseAuthException catch (e) {
      print(
        'UserService LOGOUT: FirebaseAuthException: ${e.code} - ${e.message}',
      );
      _errorMessage = "Logout fejlede: ${e.message}";
      _isLoading = false; // Reset loading on error
      if (hasListeners) notifyListeners();
    } catch (e, s) {
      print('UserService LOGOUT: GENERIC or PLATFORM error: $e');
      print('UserService LOGOUT: StackTrace for generic error: $s');
      _errorMessage = "En uventet teknisk fejl opstod under logout.";
      _isLoading = false; // Reset loading on error
      if (hasListeners) notifyListeners();
    }
    // _isLoading will be set to false by _onAuthStateChanged when the user state is null.
    // If an error occurred above, we've already set it.
  }

  // Clear any displayed error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
