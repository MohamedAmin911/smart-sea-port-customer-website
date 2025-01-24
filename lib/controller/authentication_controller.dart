import 'package:final_project_customer_website/view/screens/authentication_screens/login_screen.dart';
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
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Registration successful
      print("User created: ${userCredential.user?.uid}");
      Get.snackbar("Success", "Registration successful!",
          snackPosition: SnackPosition.BOTTOM);

      //send email verification
      await sendEmailVerification(context);
      // Navigate to the next screen or perform other actions
      Get.off(const LogInScreen()); // Use GetX navigation
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is badly formatted.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'An error occurred during registration.';
          print(e.toString()); // Print the full error for debugging
      }
      Get.snackbar("Error", errorMessage, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print(e);
      Get.snackbar("Error", "An unexpected error occurred.",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

//send email verification
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
}
