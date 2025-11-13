import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ✅ PHONE AUTHENTICATION - Send OTP
  Future<String?> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  }) async {
    try {
      // Phone number ko format karo (+91 prefix ke saath)
      String formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+91$formattedPhone'; // Indian numbers ke liye
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),

        // Auto-verification (OTP automatically detect ho gaya)
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },

        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            onVerificationFailed('Invalid phone number format');
          } else if (e.code == 'too-many-requests') {
            onVerificationFailed('Too many requests. Please try later');
          } else {
            onVerificationFailed(e.message ?? 'Verification failed');
          }
        },

        // OTP sent successfully
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },

        // Auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout ho gaya, user ko manually OTP enter karna padega
        },
      );

      return null; // Success
    } catch (e) {
      return "Error sending OTP: ${e.toString()}";
    }
  }

  // ✅ PHONE AUTHENTICATION - Verify OTP
  Future<String?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      // OTP se credential banao
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in karo
      await _auth.signInWithCredential(credential);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return 'Invalid OTP. Please check and try again';
      } else if (e.code == 'session-expired') {
        return 'OTP expired. Please request new OTP';
      }
      return e.message ?? 'OTP verification failed';
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // ✅ Sign Up with Email & Password
  Future<String?> signUpWithEmail(String email, String password, String confirmPassword) async {
    try {
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        return "All fields are required";
      }

      if (password.length < 6) {
        return "Password must be at least 6 characters";
      }

      if (password != confirmPassword) {
        return "Passwords do not match";
      }

      if (!email.contains('@')) {
        return "Please enter a valid email";
      }

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "Password is too weak";
      } else if (e.code == 'email-already-in-use') {
        return "Email already registered. Please login";
      } else if (e.code == 'invalid-email') {
        return "Invalid email format";
      }
      return e.message ?? "Sign up failed";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // ✅ Login with Email & Password
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Email and password are required";
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No account found. Please sign up first";
      } else if (e.code == 'wrong-password') {
        return "Incorrect password";
      } else if (e.code == 'invalid-email') {
        return "Invalid email format";
      } else if (e.code == 'user-disabled') {
        return "Account has been disabled";
      }
      return e.message ?? "Login failed";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // ✅ Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return "Google Sign-In cancelled";
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Google Sign-In failed";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // ✅ Logout (Complete cleanup)
  // Future<String?> logout() async {
  //   try {
  //     await _auth.signOut();
  //     await _googleSignIn.signOut();
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.remove('isLoggedIn');
  //     await prefs.remove('lastPeriodDate');
  //     await prefs.remove('dueDate');
  //     await prefs.remove('conceptionDate');
  //     await prefs.remove('babyNickname');
  //
  //     return null; // Success
  //   } catch (e) {
  //     return "Logout failed: ${e.toString()}";
  //   }
  // }
  // ✅ Improved Logout (Don't Clear Pregnancy Data)
// ✅ Improved Logout (Don't Clear Pregnancy Data)
  Future<String?> logout() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google
      await _googleSignIn.signOut();

      // ✅ ONLY clear login state, NOT pregnancy data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false); // ← ONLY THIS

      // ❌ DON'T clear pregnancy data - YE COMMENT/REMOVE KAREIN
      // await prefs.remove('lastPeriodDate');
      // await prefs.remove('dueDate');
      // await prefs.remove('conceptionDate');
      // await prefs.remove('babyNickname');

      print('✅ Logout successful - Pregnancy data preserved');
      return null;
    } catch (e) {
      return "Logout failed: ${e.toString()}";
    }
  }
  // ✅ Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ✅ Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // ✅ Reset Password
  Future<String?> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return "Please enter your email";
      }

      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Failed to send reset email";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
}


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   // ✅ Sign Up with Email & Password
//   Future<String?> signUpWithEmail(String email, String password, String confirmPassword) async {
//     try {
//       if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
//         return "All fields are required";
//       }
//
//       if (password.length < 6) {
//         return "Password must be at least 6 characters";
//       }
//
//       if (password != confirmPassword) {
//         return "Passwords do not match";
//       }
//
//       if (!email.contains('@')) {
//         return "Please enter a valid email";
//       }
//
//       await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         return "Password is too weak";
//       } else if (e.code == 'email-already-in-use') {
//         return "Email already registered. Please login";
//       } else if (e.code == 'invalid-email') {
//         return "Invalid email format";
//       }
//       return e.message ?? "Sign up failed";
//     } catch (e) {
//       return "Error: ${e.toString()}";
//     }
//   }
//
//   // ✅ Login with Email & Password
//   Future<String?> loginWithEmail(String email, String password) async {
//     try {
//       if (email.isEmpty || password.isEmpty) {
//         return "Email and password are required";
//       }
//
//       await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         return "No account found. Please sign up first";
//       } else if (e.code == 'wrong-password') {
//         return "Incorrect password";
//       } else if (e.code == 'invalid-email') {
//         return "Invalid email format";
//       } else if (e.code == 'user-disabled') {
//         return "Account has been disabled";
//       }
//       return e.message ?? "Login failed";
//     } catch (e) {
//       return "Error: ${e.toString()}";
//     }
//   }
//
//   // ✅ Google Sign-In
//   Future<String?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         return "Google Sign-In cancelled";
//       }
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       await _auth.signInWithCredential(credential);
//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       return e.message ?? "Google Sign-In failed";
//     } catch (e) {
//       return "Error: ${e.toString()}";
//     }
//   }
//
//   // ✅ Logout (Complete cleanup)
//   Future<String?> logout() async {
//     try {
//       // Sign out from Firebase
//       await _auth.signOut();
//
//       // Sign out from Google
//       await _googleSignIn.signOut();
//
//       // ✅ Clear SharedPreferences (but keep onboarding flag)
//       final prefs = await SharedPreferences.getInstance();
//
//       // Remove login-related data
//       await prefs.remove('isLoggedIn');
//
//       // Clear pregnancy data
//       await prefs.remove('lastPeriodDate');
//       await prefs.remove('dueDate');
//       await prefs.remove('conceptionDate');
//       await prefs.remove('babyNickname');
//
//       // Keep 'seenOnboarding' flag so user doesn't see onboarding again
//
//       return null; // Success
//     } catch (e) {
//       return "Logout failed: ${e.toString()}";
//     }
//   }
//
//   // ✅ Get current user
//   User? getCurrentUser() {
//     return _auth.currentUser;
//   }
//
//   // ✅ Check if user is logged in
//   bool isUserLoggedIn() {
//     return _auth.currentUser != null;
//   }
//
//   // ✅ Reset Password
//   Future<String?> resetPassword(String email) async {
//     try {
//       if (email.isEmpty) {
//         return "Please enter your email";
//       }
//
//       await _auth.sendPasswordResetEmail(email: email);
//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       return e.message ?? "Failed to send reset email";
//     } catch (e) {
//       return "Error: ${e.toString()}";
//     }
//   }
// }
//
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// //
// // class AuthService {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final GoogleSignIn _googleSignIn = GoogleSignIn();
// //
// //   // ✅ Sign Up with Email & Password
// //   Future<String?> signUpWithEmail(String email, String password, String confirmPassword) async {
// //     try {
// //       // Validate inputs
// //       if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
// //         return "All fields are required";
// //       }
// //
// //       if (password.length < 6) {
// //         return "Password must be at least 6 characters";
// //       }
// //
// //       if (password != confirmPassword) {
// //         return "Passwords do not match";
// //       }
// //
// //       // Check if email is valid
// //       if (!email.contains('@')) {
// //         return "Please enter a valid email";
// //       }
// //
// //       // Create user
// //       await _auth.createUserWithEmailAndPassword(
// //         email: email,
// //         password: password,
// //       );
// //
// //       return null; // Success
// //     } on FirebaseAuthException catch (e) {
// //       if (e.code == 'weak-password') {
// //         return "Password is too weak. Use at least 6 characters with mix of letters";
// //       } else if (e.code == 'email-already-in-use') {
// //         return "This email is already registered. Please login instead";
// //       } else if (e.code == 'invalid-email') {
// //         return "Invalid email format";
// //       }
// //       return e.message ?? "Sign up failed";
// //     } catch (e) {
// //       return "Sign up failed: ${e.toString()}";
// //     }
// //   }
// //
// //   // ✅ Login with Email & Password
// //   Future<String?> loginWithEmail(String email, String password) async {
// //     try {
// //       if (email.isEmpty || password.isEmpty) {
// //         return "Email and password are required";
// //       }
// //
// //       await _auth.signInWithEmailAndPassword(
// //         email: email,
// //         password: password,
// //       );
// //       return null; // Success
// //     } on FirebaseAuthException catch (e) {
// //       if (e.code == 'user-not-found') {
// //         return "No account found with this email. Please sign up first";
// //       } else if (e.code == 'wrong-password') {
// //         return "Incorrect password";
// //       } else if (e.code == 'invalid-email') {
// //         return "Invalid email format";
// //       } else if (e.code == 'user-disabled') {
// //         return "This account has been disabled";
// //       }
// //       return e.message ?? "Login failed";
// //     } catch (e) {
// //       return "Login failed: ${e.toString()}";
// //     }
// //   }
// //
// //   // ✅ Google Sign-In
// //   Future<String?> signInWithGoogle() async {
// //     try {
// //       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
// //       if (googleUser == null) {
// //         return "Google Sign-In Cancelled";
// //       }
// //
// //       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
// //       final credential = GoogleAuthProvider.credential(
// //         accessToken: googleAuth.accessToken,
// //         idToken: googleAuth.idToken,
// //       );
// //
// //       await _auth.signInWithCredential(credential);
// //       return null; // Success
// //     } on FirebaseAuthException catch (e) {
// //       return e.message ?? "Google Sign-In failed";
// //     } catch (e) {
// //       return "Google Sign-In failed: ${e.toString()}";
// //     }
// //   }
// //
// //   // ✅ Logout
// //   Future<String?> logout() async {
// //     try {
// //       await _auth.signOut();
// //       await _googleSignIn.signOut();
// //       return null; // Success
// //     } catch (e) {
// //       return "Logout failed: ${e.toString()}";
// //     }
// //   }
// //
// //   // ✅ Get current user
// //   User? getCurrentUser() {
// //     return _auth.currentUser;
// //   }
// //
// //   // ✅ Check if user is logged in
// //   bool isUserLoggedIn() {
// //     return _auth.currentUser != null;
// //   }
// //
// //   // ✅ Reset Password
// //   Future<String?> resetPassword(String email) async {
// //     try {
// //       if (email.isEmpty) {
// //         return "Please enter your email";
// //       }
// //
// //       await _auth.sendPasswordResetEmail(email: email);
// //       return null; // Success
// //     } on FirebaseAuthException catch (e) {
// //       return e.message ?? "Failed to send reset email";
// //     } catch (e) {
// //       return "Error: ${e.toString()}";
// //     }
// //   }
// // }
// //
// //
// //
// //
// //
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:google_sign_in/google_sign_in.dart';
// // //
// // // class AuthService {
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //   final GoogleSignIn _googleSignIn = GoogleSignIn();
// // //
// // //   // ✅ Phone OTP
// // //   Future<void> sendOTP({
// // //     required String phone,
// // //     required Function(String verificationId) onCodeSent,
// // //     required Function(String error) onFailed,
// // //   }) async {
// // //     try {
// // //       await _auth.verifyPhoneNumber(
// // //         phoneNumber: phone,
// // //         verificationCompleted: (PhoneAuthCredential credential) async {
// // //           await _auth.signInWithCredential(credential);
// // //         },
// // //         verificationFailed: (FirebaseAuthException e) {
// // //           onFailed(e.message ?? "Phone verification failed");
// // //         },
// // //         codeSent: (String verificationId, int? resendToken) {
// // //           onCodeSent(verificationId);
// // //         },
// // //         codeAutoRetrievalTimeout: (String verificationId) {},
// // //       );
// // //     } catch (e) {
// // //       onFailed("Something went wrong: ${e.toString()}");
// // //     }
// // //   }
// // //
// // //   // ✅ Email & Password Login
// // //   Future<String?> loginWithEmail(String email, String password) async {
// // //     try {
// // //       await _auth.signInWithEmailAndPassword(email: email, password: password);
// // //       return null;
// // //     } on FirebaseAuthException catch (e) {
// // //       return e.message;
// // //     } catch (e) {
// // //       return "Email login failed: ${e.toString()}";
// // //     }
// // //   }
// // //
// // //   // ✅ Google Sign-In
// // //   Future<String?> signInWithGoogle() async {
// // //     try {
// // //       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
// // //       if (googleUser == null) return "Google Sign-In Cancelled";
// // //
// // //       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
// // //       final credential = GoogleAuthProvider.credential(
// // //         accessToken: googleAuth.accessToken,
// // //         idToken: googleAuth.idToken,
// // //       );
// // //
// // //       await _auth.signInWithCredential(credential);
// // //       return null;
// // //     } on FirebaseAuthException catch (e) {
// // //       return e.message;
// // //     } catch (e) {
// // //       return "Google Sign-In Failed: ${e.toString()}";
// // //     }
// // //   }
// // // }
