// email Login
import 'package:DreamStar/views/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../helpers/localCache.dart';

final _firebaseAuth = FirebaseAuth.instance;
void signInWithEmail(String email, String password) async {
  User? user;

  try {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    user = result.user!;
    if (user != null) {
      setLoggedIn(true);
      setId(user.uid);
      Get.snackbar('Welcome!', 'Please continue...');
      Get.offAll(() => HomeScreen());
    } else {

    }
  } catch (error) {
    Get.snackbar('Error!', error.toString());
  }
}