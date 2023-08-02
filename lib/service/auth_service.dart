import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:project/helper/helper_function.dart';
import 'package:project/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // login
  Future loginWithUserNameandPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      String? accessToken = await user.getIdToken();
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print(fcmToken);
      if (user != null) {
        if (accessToken != null) {
        // Lưu trữ accessToken vào Firestore
        await  FirebaseFirestore.instance.collection("users").doc(user?.uid).update({
          'accessToken': accessToken,
          'fcmToken': fcmToken
        });
        HelperFunctions.saveAccessToken(accessToken);


        print('Access Token saved to Firestore');
      } else {
        print('Failed to get Access Token');
      }
        return true;
      }



      
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }


  // register
  Future registerUserWithEmailandPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        // call our database service to update the user data.
        await DatabaseService(uid: user.uid).savingUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // signout
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }

 
}