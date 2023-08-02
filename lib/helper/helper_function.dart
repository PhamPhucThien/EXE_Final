import 'package:flutter/material.dart';
import 'package:project/pages/booking_notify_dialog.dart';
import 'package:project/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HelperFunctions {
  //keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String tokenKey = "TOKENKEY";
  static String? userRole;
  static GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
  // saving the data to SF

  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  static Future<bool> saveAccessToken(String token) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(tokenKey, token);
  }

  // getting the data from SF
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserNameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

  static Future<String?> getTokenFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(tokenKey);
  }

  static Future<void> showRequireBooking(
    String msg,
    String clientId,
  ) async {
    IO.Socket socket = IO.io(
        'https://hah-booking-service-cec4d94fa331.herokuapp.com/$clientId',
        <String, dynamic>{
          'transports': ['websocket'],
          'query': 'clientId=$clientId',
        });
    socket.onConnect(
      (data) {
        //  NavigationService.navigateWithArgumentsTo(routes.BookingDialogNotifyRoute, arguments: {
        //   "socket": socket,
        //   "message": msg
        //  });
        nextScreenReplace(
            navigator.currentContext,
            BookingDialogNotify(
              socket: socket,
              message: msg,
            ));
      },
    );
  }
}
