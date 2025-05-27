// services/user_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// This comment describes the purpose of the AppUser class.
// Represents the application's user, derived from Firebase Auth user.
// Defines a class named AppUser to represent a user within the application.
class AppUser {
  // A final String property to store the unique user ID (UID), typically from Firebase.
  final String uid;
  // A final, nullable String property to store the user's email.
  final String? email;
  // A final, nullable String property to store the user's display name.
  final String? displayName;
  // A final boolean property to track if the user is an anonymous Firebase user.
  final bool isAnonymous; // This comment clarifies the purpose of isAnonymous.

  // Constructor for the AppUser class.
  // It uses named parameters and requires 'uid' and 'isAnonymous'.
  AppUser({
    required this.uid, // 'uid' is a required parameter.
    this.email, // 'email' is an optional parameter.
    this.displayName, // 'displayName' is an optional parameter.
    required this.isAnonymous, // 'isAnonymous' is a required parameter.
  });

  // This comment describes the factory constructor.
  // Factory constructor to create an AppUser from a Firebase User
  // Defines a factory constructor named 'fromFirebaseUser'.
  // Factory constructors are used to create instances of a class, often with some logic or transformation.
  // It takes a Firebase User object (aliased as fb_auth.User) as input.
  factory AppUser.fromFirebaseUser(fb_auth.User firebaseUser) {
    // Returns a new instance of AppUser, populated with data from the Firebase User object.
    return AppUser(
      uid: firebaseUser.uid, // Sets the uid from the Firebase user's uid.
      email:
          firebaseUser.email, // Sets the email from the Firebase user's email.
      displayName:
          firebaseUser
              .displayName, // Sets the displayName from the Firebase user's displayName.
      isAnonymous:
          firebaseUser
              .isAnonymous, // This comment explains where isAnonymous comes from. // Get from Firebase user object
    );
  }
}

// Defines a class named UserService that uses the ChangeNotifier mixin.
// ChangeNotifier allows this class to notify its listeners (typically UI widgets) when its state changes.
class UserService with ChangeNotifier {
  // A final instance of FirebaseAuth, used for interacting with Firebase Authentication services.
  // 'fb_auth' is likely an alias for the firebase_auth package.
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  // This line is commented out. If uncommented, it would initialize an instance of FirebaseFirestore,
  // which is used for interacting with the Firestore database (e.g., for saving additional user data).
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Uncomment if saving extra user data

  // A private, nullable AppUser property to store the currently authenticated user.
  AppUser? _currentUser;
  // A private boolean property to track loading states.
  // It's true during initial auth state checks and other ongoing asynchronous operations.
  bool _isLoading = true; // This comment clarifies what _isLoading tracks.
  // A private, nullable String property to store any error messages related to user service operations.
  String? _errorMessage;

  // A public getter to access the current user (_currentUser).
  AppUser? get currentUser => _currentUser;
  // A public getter that returns true if _currentUser is not null (i.e., a user is logged in), false otherwise.
  bool get isLoggedIn => _currentUser != null;
  // A public getter to access the loading state (_isLoading).
  bool get isLoading => _isLoading;
  // A public getter to access any error message (_errorMessage).
  String? get errorMessage => _errorMessage;

  // This comment describes the constructor's purpose.
  // Constructor: Listen to Firebase auth state changes
  // Constructor for the UserService class.
  UserService() {
    // Subscribes to the authStateChanges stream from FirebaseAuth.
    // The _onAuthStateChanged method will be called whenever the user's authentication state changes (e.g., sign-in, sign-out).
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    // Calls _initializeUser to perform an initial check for the current user when the service is created.
    _initializeUser(); // This comment clarifies the purpose of this call.
  }

  // An asynchronous private method to initialize the user state.
  Future<void> _initializeUser() async {
    // Sets _isLoading to true, indicating an operation is in progress.
    _isLoading = true;
    // This comment explains why notifyListeners() is not called here immediately.
    // Don't notify here to prevent UI flicker if user is already determined quickly
    // Gets the current Firebase user directly from FirebaseAuth. This can be null if no user is signed in.
    final fb_auth.User? firebaseUser = _firebaseAuth.currentUser;
    // Calls _onAuthStateChanged with the fetched Firebase user to process the initial user state.
    await _onAuthStateChanged(
      firebaseUser,
    ); // This comment clarifies the purpose of this call.
  }

  // This comment describes the _onAuthStateChanged callback.
  // Callback for when Firebase auth state changes
  // An asynchronous private method that is called when Firebase's authentication state changes.
  // It takes a nullable Firebase User object as input.
  Future<void> _onAuthStateChanged(fb_auth.User? firebaseUser) async {
    // Checks if the firebaseUser is null (meaning no user is signed in).
    if (firebaseUser == null) {
      // If no user is signed in, set _currentUser to null.
      _currentUser = null;
      // Prints a debug message to the console.
      print('UserService: User is currently signed out!');
    } else {
      // If a user is signed in (firebaseUser is not null), print user details.
      print(
        'UserService: User signed in/state changed. UID: ${firebaseUser.uid}, Anonymous: ${firebaseUser.isAnonymous}, Name: ${firebaseUser.displayName}',
      );
      // Creates an AppUser instance from the Firebase User object and assigns it to _currentUser.
      _currentUser = AppUser.fromFirebaseUser(firebaseUser);
    }
    // Sets _isLoading to false, as the authentication state has been determined or updated.
    _isLoading =
        false; // This comment clarifies when _isLoading is set to false.
    // This multi-line comment explains the logic for clearing the error message.
    // It aims to clear errors only when the auth state genuinely changes to a valid user or null,
    // preventing premature error clearing during multiple calls without a successful state change.
    // Only clear error if the auth state actually changed to a valid user or null
    // This prevents clearing an error message from a failed login/register attempt immediately
    // if _onAuthStateChanged is called multiple times without a successful state change.
    // Checks if (a new user is set and matches the firebaseUser) OR (the firebaseUser is null, indicating logout).
    if ((firebaseUser != null && _currentUser?.uid == firebaseUser.uid) ||
        firebaseUser == null) {
      // If the condition is true, clear any existing error message.
      _errorMessage = null;
    }
    // Checks if there are any active listeners for this ChangeNotifier.
    if (hasListeners)
      notifyListeners(); // Notifies listeners (e.g., UI widgets) that the state has changed.
  }

  // This comment describes the registerUser method.
  // Register user with email and password
  // An asynchronous public method to register a new user with email, password, and an optional name.
  // It returns a Future<bool> indicating whether the registration was successful.
  Future<bool> registerUser(
    String email, // The email for the new user.
    String password, { // The password for the new user.
    String? name, // An optional display name for the new user.
  }) async {
    // Sets _isLoading to true, indicating an operation is in progress.
    _isLoading = true;
    // Clears any previous error message.
    _errorMessage = null;
    // Notifies listeners that the state (isLoading, errorMessage) has changed.
    notifyListeners();
    // Starts a 'try' block to handle potential exceptions that might occur during the Firebase user creation process.
    try {
      // Prints a debug message to the console indicating the attempt to create a Firebase user with the provided email.
      print('UserService: Attempting to create Firebase user: $email');
      // Asynchronously calls the 'createUserWithEmailAndPassword' method on the _firebaseAuth instance.
      // This Firebase SDK method attempts to create a new user account with the given email and password.
      // The 'await' keyword pauses execution until the Future returned by this method completes.
      // The result, a UserCredential object, is stored in 'userCredential'.
      fb_auth.UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      // Prints a debug message indicating successful Firebase user creation, including the new user's UID.
      // The '?.' null-aware operator is used because 'userCredential.user' could theoretically be null.
      print('UserService: Firebase user created: ${userCredential.user?.uid}');

      // Checks if a 'name' was provided, if it's not empty, and if 'userCredential.user' is not null.
      if (name != null && name.isNotEmpty && userCredential.user != null) {
        // If all conditions are true, asynchronously call 'updateDisplayName' on the Firebase user object.
        // The '!' non-null assertion operator is used on 'userCredential.user' because its nullity was checked in the 'if' condition.
        await userCredential.user!.updateDisplayName(name);
        // Prints a debug message indicating that the display name was updated for the user.
        print(
          'UserService: Display name updated for user: ${userCredential.user?.uid} to $name',
        );
        // This multi-line comment explains the rationale for manually updating _currentUser.
        // Firebase's _onAuthStateChanged listener might not immediately reflect display name changes
        // without a token refresh, so this ensures the local _currentUser object is up-to-date.
        // Manually update _currentUser to reflect the new display name immediately
        // as _onAuthStateChanged might not pick up displayName changes without a token refresh.
        // Checks if the current Firebase user (obtained directly from _firebaseAuth) is not null.
        if (_firebaseAuth.currentUser != null) {
          // This comment notes that _firebaseAuth.currentUser should be the same as userCredential.user at this point.
          // currentUser should be the same as userCredential.user
          // Updates the local _currentUser by creating a new AppUser instance from the (potentially updated) Firebase user.
          // The '!' is used on _firebaseAuth.currentUser as its nullity was just checked.
          _currentUser = AppUser.fromFirebaseUser(_firebaseAuth.currentUser!);
        }
      }
      // Sets _isLoading to false as all registration operations (user creation, display name update) are complete.
      _isLoading =
          false; // This comment clarifies when loading is set to false.
      // Notifies listeners (e.g., UI widgets) that the state has changed (new user might be available, isLoading is false).
      notifyListeners(); // This comment clarifies the purpose of this notification.
      // Returns true, indicating that the user registration process was successful.
      return true;
      // Catches exceptions specifically of type FirebaseAuthException that might occur during Firebase operations.
    } on fb_auth.FirebaseAuthException catch (e) {
      // Prints an error message to the console, including the Firebase error code and message.
      print(
        'UserService: FirebaseAuthException during registration: ${e.code} - ${e.message}',
      );
      // Sets the _errorMessage property to the message from the FirebaseAuthException.
      // If e.message is null, it defaults to "Registration failed.".
      _errorMessage = e.message ?? "Registration failed.";
      // Catches any other types of exceptions that might occur.
    } catch (e) {
      // Prints a generic error message to the console, including the exception details.
      print('UserService: Generic error during registration: $e');
      // Sets a generic error message for _errorMessage.
      _errorMessage = "An unexpected error occurred during registration.";
    }
    // This block executes regardless of whether an exception was caught or not (unless 'return true' was executed in 'try').
    // Sets _isLoading to false, as the registration attempt (successful or failed) has concluded.
    _isLoading = false;
    // Notifies listeners that the state has changed (isLoading is false, _errorMessage might be set).
    notifyListeners();
    // Returns false, indicating that the user registration process failed.
    return false;
    // Closes the registerUser method.
  }

  // This comment describes the login method.
  // Login user with email and password
  // An asynchronous public method to log in an existing user with their email and password.
  // It returns a Future<bool> indicating whether the login was successful.
  Future<bool> login(String email, String password) async {
    // Sets _isLoading to true, indicating an operation is in progress.
    _isLoading = true;
    // Clears any previous error message.
    _errorMessage = null;
    // Notifies listeners that the state (isLoading, errorMessage) has changed.
    notifyListeners();
    // Prints a debug message to the console indicating the attempt to log in the user.
    print('UserService LOGIN: Attempting to login user: $email');
    // Starts a 'try' block to handle potential exceptions during the sign-in process.
    try {
      // Asynchronously calls the 'signInWithEmailAndPassword' method on the _firebaseAuth instance.
      // This Firebase SDK method attempts to sign in the user with the provided credentials.
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email, // The user's email.
        password: password, // The user's password.
      );
      // Prints a debug message indicating successful user sign-in.
      print('UserService: User sign-in successful for: $email');
      // This comment explains that _onAuthStateChanged will handle updating _currentUser.
      // _onAuthStateChanged will update _currentUser.
      // This comment clarifies that isLoading is set to false before the auth listener might fire,
      // ensuring the UI can react to the loading state change promptly.
      // We can ensure isLoading is false after successful operation before auth listener fires.
      _isLoading = false;
      // Notifies listeners that the loading state has changed.
      notifyListeners(); // This comment clarifies the purpose of this notification.
      // This comment indicates where existing code (not shown in the snippet) might be.
      // ... existing code ...
      // Returns true, indicating that the login was successful.
      return true;
      // The 'catch' block for the login method's try-catch is not shown in this snippet but would typically handle login errors.
    } // Catches exceptions specifically of type FirebaseAuthException that might occur during the login process.
    // This block is part of the 'try-catch' structure within the 'login' method.
    on fb_auth.FirebaseAuthException catch (e) {
      // Prints a detailed error message to the console, including the Firebase error code, message, and stack trace.
      // This is helpful for debugging Firebase authentication issues.
      print(
        'UserService LOGIN: FirebaseAuthException: Code: ${e.code}, Message: ${e.message}, StackTrace: ${e.stackTrace}',
      );
      // Sets the _errorMessage property to the message from the FirebaseAuthException.
      // If e.message is null, it defaults to "Login failed due to Firebase Auth error.".
      _errorMessage = e.message ?? "Login failed due to Firebase Auth error.";

      // This comment indicates that more specific error messages in Danish are provided below.
      // More specific error messages in Danish
      // Checks the Firebase error code to provide more user-friendly, localized error messages.
      if (e.code == 'user-not-found' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        // If the error code indicates user not found or invalid credentials, set a specific Danish error message.
        // "Forkert email eller adgangskode." means "Incorrect email or password."
        _errorMessage = 'Forkert email eller adgangskode.';
      } else if (e.code == 'wrong-password') {
        // If the error code indicates a wrong password, set a specific Danish error message.
        // "Forkert adgangskode." means "Incorrect password."
        _errorMessage = 'Forkert adgangskode.';
      } else if (e.code == 'invalid-email') {
        // If the error code indicates an invalid email format, set a specific Danish error message.
        // "Ugyldigt email format." means "Invalid email format."
        _errorMessage = 'Ugyldigt email format.';
      }

      // Sets _isLoading to false, as the login attempt (failed in this case) has concluded.
      _isLoading = false;
      // Notifies listeners that the state has changed (isLoading is false, _errorMessage is set).
      notifyListeners();
      // Returns false, indicating that the login process failed.
      return false;
      // Catches any other types of exceptions (generic errors or platform-specific errors) that might occur.
      // 's' captures the stack trace associated with the exception 'e'.
    } catch (e, s) {
      // Prints a generic error message to the console.
      print('UserService LOGIN: GENERIC or PLATFORM error: $e');
      // Prints the stack trace for the generic error, which is useful for debugging.
      print('UserService LOGIN: StackTrace for generic error: $s');
      // Sets a generic, user-friendly error message in Danish.
      // "En uventet teknisk fejl opstod under login. Prøv igen senere." means
      // "An unexpected technical error occurred during login. Please try again later."
      _errorMessage =
          "En uventet teknisk fejl opstod under login. Prøv igen senere.";
      // Sets _isLoading to false, as the login attempt has concluded.
      _isLoading = false;
      // Notifies listeners that the state has changed.
      notifyListeners();
      // Returns false, indicating that the login process failed.
      return false;
    }
    // Closes the login method.
  }

  // This comment describes the signInAnonymously method.
  // Sign in user anonymously
  // An asynchronous public method to sign in a user anonymously.
  // It returns a Future<AppUser?>, which will be the anonymous AppUser if successful, or null otherwise.
  Future<AppUser?> signInAnonymously() async {
    // Sets _isLoading to true, indicating an operation is in progress.
    _isLoading = true;
    // Clears any previous error message.
    _errorMessage = null;
    // Notifies listeners that the state (isLoading, errorMessage) has changed.
    notifyListeners();
    // Starts a 'try' block to handle potential exceptions during the anonymous sign-in process.
    try {
      // Prints a debug message to the console indicating the attempt to sign in anonymously.
      print('UserService: Attempting to sign in anonymously...');
      // Asynchronously calls the 'signInAnonymously' method on the _firebaseAuth instance.
      // This Firebase SDK method signs in the user anonymously.
      final userCredential = await _firebaseAuth.signInAnonymously();
      // Prints a debug message indicating successful anonymous sign-in, including the new user's UID.
      print(
        'UserService: Anonymous sign-in successful. UID: ${userCredential.user?.uid}',
      );
      // Checks if the 'user' property of the 'userCredential' is not null (i.e., sign-in was successful and returned a user).
      if (userCredential.user != null) {
        // This comment explains that while _onAuthStateChanged will eventually update the state,
        // _currentUser is updated immediately here to provide a quicker response to the caller of this method.
        // _onAuthStateChanged will fire, but update immediately for the caller
        // Creates an AppUser instance from the anonymous Firebase User object and assigns it to _currentUser.
        // The '!' non-null assertion operator is used on 'userCredential.user' as its nullity was checked.
        _currentUser = AppUser.fromFirebaseUser(userCredential.user!);
        // Sets _isLoading to false as the anonymous sign-in operation is complete.
        _isLoading = false;
        // Notifies listeners that the state has changed (new anonymous user is available, isLoading is false).
        notifyListeners(); // This comment clarifies the purpose of this notification.
        // Returns the newly created anonymous AppUser.
        return _currentUser;
      }
      // The 'catch' block for the signInAnonymously method's try-catch is not shown in this snippet
      // but would typically handle errors related to anonymous sign-in.
      // This part should ideally not be reached if signInAnonymously was successful
      // This line is likely part of the 'if (userCredential.user != null)' block's 'else' case
      // or a path where 'userCredential.user' was null, meaning anonymous sign-in didn't effectively yield a user object.
      // Sets _isLoading to false as the anonymous sign-in attempt has concluded (unsuccessfully in this path).
      _isLoading = false;
      // Notifies listeners that the state has changed (isLoading is false).
      notifyListeners();
      // Returns null, indicating that anonymous sign-in failed or did not result in a usable AppUser.
      return null;
      // Catches exceptions specifically of type FirebaseAuthException that might occur during anonymous sign-in.
    } on fb_auth.FirebaseAuthException catch (e) {
      // Sets the _errorMessage property with a message indicating anonymous sign-in failure and the specific Firebase error.
      _errorMessage = "Anonymous sign-in failed: ${e.message}";
      // Prints a detailed error message to the console, including the Firebase error code and message.
      print(
        'UserService: FirebaseAuthException during anonymous sign-in: ${e.code} - ${e.message}',
      );
      // Catches any other types of exceptions that might occur during anonymous sign-in.
    } catch (e) {
      // Sets a generic error message for _errorMessage.
      _errorMessage = "An unexpected error occurred during anonymous sign-in.";
      // Prints a generic error message to the console, including the exception details.
      print('UserService: Generic error during anonymous sign-in: $e');
    }
    // This block executes if an exception was caught during the anonymous sign-in process.
    // Sets _isLoading to false, as the anonymous sign-in attempt (failed) has concluded.
    _isLoading = false;
    // Notifies listeners that the state has changed (isLoading is false, _errorMessage is set).
    notifyListeners();
    // Returns null, indicating that the anonymous sign-in process failed.
    return null;
    // Closes the signInAnonymously method.
  }

  // Defines an asynchronous public method to update the display name of the currently logged-in user.
  // It takes the 'newName' (a String) as input and returns a Future<void> (no specific return value).
  Future<void> updateUserDisplayName(String newName) async {
    // Retrieves the currently authenticated Firebase user from the _firebaseAuth instance.
    // This can be null if no user is currently signed in.
    final firebaseUser = _firebaseAuth.currentUser;
    // Checks if 'firebaseUser' is not null (i.e., a user is logged in).
    if (firebaseUser != null) {
      // This commented-out line suggests an optional way to manage a more specific loading state
      // for profile updates, if needed, to distinguish it from general loading states.
      // Optionally set a loading state specific to this operation if it's long
      // _isLoadingProfileUpdate = true; notifyListeners();
      // Starts a 'try' block to handle potential exceptions during the display name update.
      try {
        // Prints a debug message indicating the attempt to update the display name, including the UID and the new name.
        print(
          'UserService: Attempting to update display name for UID: ${firebaseUser.uid} to "$newName"',
        );
        // Asynchronously calls the 'updateDisplayName' method on the Firebase user object, passing the 'newName'.
        await firebaseUser.updateDisplayName(newName);
        // This comment explains the next step: refreshing the local _currentUser.
        // After updating, refresh the local _currentUser with the new info
        // Recreates the local _currentUser (AppUser instance) using the updated Firebase user object.
        // This ensures that the local representation of the user reflects the new display name.
        _currentUser = AppUser.fromFirebaseUser(
          firebaseUser, // The Firebase user object, which now has the updated display name.
        ); // This comment clarifies that AppUser is recreated.
        // Prints a success message to the console.
        print('UserService: Display name updated successfully to "$newName"');
        // Notifies listeners (e.g., UI widgets) that _currentUser has changed.
        notifyListeners(); // This comment clarifies the purpose of this notification.
        // Catches exceptions specifically of type FirebaseAuthException.
      } on fb_auth.FirebaseAuthException catch (e) {
        // Prints an error message to the console related to Firebase authentication issues.
        print(
          'UserService: Error updating display name - FirebaseAuthException: ${e.message}',
        );
        // Sets the _errorMessage property with a user-facing error message.
        _errorMessage = "Failed to update name: ${e.message}";
        // Notifies listeners about the error.
        notifyListeners();
        // Catches any other types of exceptions.
      } catch (e) {
        // Prints a generic error message to the console.
        print('UserService: Error updating display name - Generic: $e');
        // Sets a generic user-facing error message.
        _errorMessage = "An error occurred while updating name.";
        // Notifies listeners about the error.
        notifyListeners();
      }
      // This commented-out line corresponds to the optional specific loading state mentioned earlier.
      // It would be used to set the profile update loading state back to false.
      // _isLoadingProfileUpdate = false; notifyListeners();
      // This 'else' block executes if 'firebaseUser' was null (no user logged in).
    } else {
      // Sets an error message indicating that no user is logged in.
      _errorMessage = "No user logged in to update display name.";
      // Prints a corresponding message to the console.
      print('UserService: No current user to update display name for.');
      // Notifies listeners about the error/state.
      notifyListeners();
    }
    // Closes the updateUserDisplayName method.
  }

  // Defines an asynchronous public method to link an existing anonymous user account to an email and password.
  // It takes 'email' and 'password' (Strings) as input and returns a Future<bool> indicating success or failure.
  Future<bool> linkAnonymousAccountToEmail(
    String email, // The email to associate with the anonymous account.
    String password, // The password for the new email-based account.
  ) async {
    // Checks if there is a current AppUser and if that user is anonymous.
    // If not, it's not possible to link, so an error is set and false is returned.
    if (_currentUser == null || !_currentUser!.isAnonymous) {
      // Sets an error message indicating the precondition for linking is not met.
      _errorMessage = "No anonymous user to link or user is not anonymous.";
      // Notifies listeners about the state change (error message set).
      notifyListeners();
      // Returns false as linking cannot proceed.
      return false;
    }
    // This comment clarifies that the actual firebase_auth.User object is needed for the linking operation.
    // Use the actual firebase_auth.User for linking
    // Retrieves the current Firebase user directly from the _firebaseAuth instance.
    final fbUserToLink = _firebaseAuth.currentUser;
    // Performs an additional check on the Firebase user object to ensure it exists and is anonymous.
    // This is a safeguard against internal state inconsistencies.
    if (fbUserToLink == null || !fbUserToLink.isAnonymous) {
      // Sets an error message indicating an internal inconsistency.
      _errorMessage = "Internal error: Firebase user mismatch for linking.";
      // Notifies listeners about the state change.
      notifyListeners();
      // Returns false.
      return false;
    }

    // Sets _isLoading to true, indicating that an asynchronous operation is starting.
    _isLoading = true;
    // Clears any pre-existing error message.
    _errorMessage = null;
    // Notifies listeners about the state changes (isLoading is true, errorMessage is null).
    notifyListeners();
    // Starts a 'try' block to handle potential exceptions during the account linking process.
    try {
      // Prints a debug message to the console, including the UID of the anonymous account and the target email.
      print(
        'UserService: Attempting to link anonymous account (UID: ${fbUserToLink.uid}) to email: $email',
      );
      // Creates an EmailAuthCredential using the provided email and password.
      // This credential will be used to link the anonymous account.
      final credential = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      // Asynchronously calls the 'linkWithCredential' method on the 'fbUserToLink' (the anonymous Firebase user).
      // This attempts to associate the email/password credential with the existing anonymous account.
      await fbUserToLink.linkWithCredential(credential);
      // Prints a success message to the console.
      print('UserService: Anonymous account linked successfully.');
      // This comment explains that the _onAuthStateChanged listener will handle updating the user state
      // (e.g., the user will no longer be marked as anonymous).
      // _onAuthStateChanged will update the user state (no longer anonymous).
      // This comment clarifies that isLoading can be set to false here after the operation.
      // We can set isLoading to false here.
      // Sets _isLoading to false as the linking operation is complete.
      _isLoading = false;
      // Notifies listeners about the state change (isLoading is false).
      notifyListeners();
      // Returns true, indicating successful account linking.
      return true;
      // Catches exceptions specifically of type FirebaseAuthException.
    } on fb_auth.FirebaseAuthException catch (e) {
      // Sets an error message including the Firebase error details.
      _errorMessage = "Failed to link account: ${e.message}";
      // Prints a detailed error message to the console.
      print(
        'UserService: FirebaseAuthException during account linking: ${e.code} - ${e.message}',
      );
      // Catches any other types of exceptions.
    } catch (e) {
      // Sets a generic error message.
      _errorMessage = "An unexpected error occurred during account linking.";
      // Prints a generic error message to the console.
      print('UserService: Generic error during account linking: $e');
    }
    // This block executes if an exception was caught during the linking process.
    // Sets _isLoading to false as the linking attempt (failed) has concluded.
    _isLoading = false;
    // Notifies listeners about the state change.
    notifyListeners();
    // Returns false, indicating that account linking failed.
    return false;
    // Closes the linkAnonymousAccountToEmail method.
  }

  // This comment describes the logout method.
  // Logout user
  // An asynchronous public method to log out the currently signed-in user.
  // It returns a Future<void> (no specific return value).
  Future<void> logout() async {
    // Prints a debug message to the console, including the UID of the user being signed out (if available).
    print(
      'UserService LOGOUT: Attempting to sign out user: ${_currentUser?.uid}',
    );
    // Sets _isLoading to true, indicating an operation is in progress.
    _isLoading =
        true; // This comment clarifies the purpose of setting isLoading.
    // Clears any pre-existing error message.
    _errorMessage = null;
    // Notifies listeners that the logout process has started and the state has changed.
    notifyListeners(); // This comment clarifies the purpose of this notification.

    // Starts a 'try' block to handle potential exceptions during the sign-out process.
    try {
      // Asynchronously calls the 'signOut' method on the _firebaseAuth instance.
      // This Firebase SDK method signs out the current user.
      await _firebaseAuth.signOut();
      // Prints a success message to the console.
      print('UserService LOGOUT: Firebase signOut successful.');
      // This multi-line comment explains that the _onAuthStateChanged listener will handle
      // the necessary state updates (setting _currentUser to null, _isLoading to false, and notifying listeners)
      // automatically after a successful signOut.
      // _onAuthStateChanged will be called automatically.
      // It will set _currentUser to null, _isLoading to false, and call notifyListeners.
      // Catches exceptions specifically of type FirebaseAuthException.
    } on fb_auth.FirebaseAuthException catch (e) {
      // Prints a detailed error message to the console.
      print(
        'UserService LOGOUT: FirebaseAuthException: ${e.code} - ${e.message}',
      );
      // Sets a user-facing error message in Danish. "Logout fejlede:" means "Logout failed:".
      _errorMessage = "Logout fejlede: ${e.message}";
      // Sets _isLoading to false to reset the loading state on error.
      _isLoading = false; // This comment clarifies the action on error.
      // Notifies listeners if there are any, to update the UI with the error message and new loading state.
      if (hasListeners) notifyListeners();
      // Catches any other types of exceptions, capturing both the exception 'e' and its stack trace 's'.
    } catch (e, s) {
      // Prints a generic error message to the console.
      print('UserService LOGOUT: GENERIC or PLATFORM error: $e');
      // Prints the stack trace for the generic error.
      print('UserService LOGOUT: StackTrace for generic error: $s');
      // Sets a generic user-facing error message in Danish.
      // "En uventet teknisk fejl opstod under logout." means "An unexpected technical error occurred during logout."
      _errorMessage = "En uventet teknisk fejl opstod under logout.";
      // Sets _isLoading to false to reset the loading state on error.
      _isLoading = false; // This comment clarifies the action on error.
      // Notifies listeners if there are any.
      if (hasListeners) notifyListeners();
    }
    // This multi-line comment explains that _isLoading will be managed by _onAuthStateChanged
    // in the success case, and has already been handled in the error cases above.
    // _isLoading will be set to false by _onAuthStateChanged when the user state is null.
    // If an error occurred above, we've already set it.
    // Closes the logout method.
  }

  // This comment describes the clearError method.
  // Clear any displayed error message
  // A public method to clear the current error message.
  void clearError() {
    // Checks if there is currently an error message set.
    if (_errorMessage != null) {
      // If an error message exists, set _errorMessage to null.
      _errorMessage = null;
      // Notifies listeners that the error message state has changed.
      notifyListeners();
    }
  }
}
