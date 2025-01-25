import 'package:final_project_customer_website/view/screens/authentication_screens/login_screen.dart';
import 'package:final_project_customer_website/view/screens/authentication_screens/signup_or_login_screen.dart';
import 'package:final_project_customer_website/view/screens/home_screen/home_screen.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/getx_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  var isRememberMe = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRememberMe(); // Load saved value at app startup
  }

  // Registration
  Future<void> registerUser(
      String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      getxSnackbar(title: "Error", msg: "Please fill all fields");
      return;
    }

    _isLoading.value = true;

    try {
      // Check if the email is already registered
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty) {
        // Email already registered
        getxSnackbar(
            title: "Error", msg: "The email address is already in use.");
        return;
      }

      // If the email is not registered, proceed with registration
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Registration successful
      print("User created: ${userCredential.user?.uid}");
      getxSnackbar(title: "Success", msg: "Registration successful!");

      // Send email verification
      await sendEmailVerification(context);
      Get.off(const LogInScreen());
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      print("Error during registration: ${e.code}");
      getxSnackbar(
        title: "Error",
        msg: e.message ?? "An unexpected error occurred. Please try again.",
      );
    } catch (e) {
      // Handle any unexpected errors
      print("Unexpected error: $e");
      getxSnackbar(title: "Error", msg: "An unexpected error occurred.");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> sendEmailVerification(BuildContext context) async {
    _isLoading.value = true;
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        getxSnackbar(
            title: "Verification Email Sent",
            msg:
                "A verification link has been sent to your email. Please check your inbox (and spam folder).");
      } else if (user!.emailVerified) {
        getxSnackbar(
            title: "Email Verified", msg: "Your Email is already verified.");
      } else {
        getxSnackbar(title: "Error", msg: "No user is currently signed in.");
      }
    } catch (e) {
      print("Error sending verification email: $e");
      getxSnackbar(title: "Error", msg: "Failed to send verification email.");
    } finally {
      _isLoading.value = false;
    }
  }

//check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload(); // Reload user to get the latest info
      user = _auth.currentUser; // Update user reference
      return user!.emailVerified;
    }
    return false;
  }

  // Sign-in
  Future<void> signInUser(
      String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      getxSnackbar(title: "Error", msg: "Please fill all fields");

      return;
    }

    _isLoading.value = true;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Sign-in successful
      bool isVerified = await isEmailVerified();

      isVerified
          ? Get.off(const HomeScreen())
          : getxSnackbar(title: "Error", msg: "Email is not verified!");

      print("User signed in: ${userCredential.user?.uid}");
      isVerified
          ? getxSnackbar(title: "Success", msg: "Sign in successful!")
          : null;
    } on FirebaseAuthException catch (e) {
      getxSnackbar(title: "Error", msg: e.code);
    } catch (e) {
      print("General sign-in error: $e");
      getxSnackbar(title: "Error", msg: "An unexpected error occurred.");
    } finally {
      _isLoading.value = false;
    }
  }

  // Save "Remember Me" state
  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
    print("Saved Remember Me Value: $value"); // Debug log
  }

  // Load "Remember Me" state
  Future<void> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    isRememberMe.value = prefs.getBool('rememberMe') ?? false;
  }

  Future<void> signOut(BuildContext context) async {
    _isLoading.value = true;
    try {
      await _auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      Get.off(const SignUpOrLogInScreen());
      getxSnackbar(title: "Success", msg: "Signed out successfully!");
    } catch (e) {
      print("Sign-out error: $e");
      getxSnackbar(title: "Error", msg: "Failed to sign out.");
    } finally {
      _isLoading.value = false;
    }
  }
}
