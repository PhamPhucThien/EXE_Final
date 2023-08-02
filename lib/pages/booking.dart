import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project/helper/helper_function.dart';
import 'package:project/pages/home_page.dart';
import 'package:project/shared/Enum.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project/widgets/widgets.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDateTime;
  int? _selectedOption;
  bool isSearching = false;

  void _selectDateTime(BuildContext context) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute),
      maxTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+7),
      onChanged: (date) {},
      onConfirm: (date) {
       setState(() {
          _selectedDateTime = date;
        });
      },
    );
  }

 void _submitAppointment() {
  if (_selectedDateTime == null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Please select a date and time.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  } else {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose Option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('20 minutes - 20000 VND'),
                  onTap: () {
                    setState(() {
                      _selectedOption = BookingOptions.Ops20m.index;
                    });
                    // Gửi thông báo đến bác sĩ
                    sendNotificationToDoctor(20, _selectedOption!);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('40 minutes - 35000 VND'),
                  onTap: () {
                    setState(() {
                      _selectedOption = BookingOptions.Ops40m.index;
                    });
                    // Gửi thông báo đến bác sĩ
                    sendNotificationToDoctor(40, _selectedOption!);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('60 minutes - 50000 VND'),
                  onTap: () {
                    setState(() {
                      _selectedOption = BookingOptions.Ops40m.index;
                    });
                    // Gửi thông báo đến bác sĩ
                    sendNotificationToDoctor(60, _selectedOption!);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
}

void sendNotificationToDoctor(int duration, int selectedOption) async {
  
  final url = Uri.parse('https://hah-booking-service-cec4d94fa331.herokuapp.com/api/search-doctors');
  String? accessToken;
  await HelperFunctions.getTokenFromSF().then((val) {
      setState(() {
        accessToken = val!;
      });
    });
  final headers = {'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };
  
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  final body = jsonEncode({
    "timeStart": _selectedDateTime.toString(),
    "duration":  duration,
    "userId": FirebaseAuth.instance.currentUser!.uid,
    "fmcToken": fcmToken
  });
  
  try {
    setState(() {
      isSearching = true;
    });
    final response = await http.post(url, headers: headers, body: body);

    setState(() {
      isSearching = false;
    });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Xử lý kết quả từ API
      final responseData = jsonDecode(response.body);
      print('API response: $responseData');
      Fluttertoast.showToast(
        msg: 'Booking thành công',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      // Xử lý lỗi khi gọi API
      final responseData = jsonDecode(response.body);
      print('API error: ${response.statusCode}');
      Fluttertoast.showToast(
        msg: 'Lỗi: ${responseData["message"]}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    // Xử lý lỗi khác
    print('Error: $error');
    Fluttertoast.showToast(
      msg: 'Đã xảy ra lỗi',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book a Doctor'),
         leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
          nextScreenReplace(
            context,
            const HomePage()
          );
        },
      ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'Select Date and Time'
                        : 'Date and Time: ${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDateTime(context),
                  child: Text('Choose Date and Time'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if(!isSearching)
            ElevatedButton(
              onPressed: _submitAppointment,
              child: Text('Submit Appointment'),
            ),
            if(isSearching)
            ElevatedButton(
              onPressed: null,
              child: Text('Đang tìm bác sĩ...'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}