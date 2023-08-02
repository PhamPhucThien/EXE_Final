import 'dart:convert';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/helper/helper_function.dart';
import 'package:project/pages/call_page.dart';
import 'package:project/pages/home_page.dart';
import 'package:project/widgets/widgets.dart';

class MeetingRoomScreen extends StatefulWidget {
  const MeetingRoomScreen({super.key});

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  bool firstLoaded = false;

  List<Meeting> meetings = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointment')
          .where('userid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot document = snapshot.docs[0];
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        List<dynamic> dataList = data["meetings"] as List<dynamic>;
        meetings = dataList.map((data) {
          return Meeting(
              meetingId: data["meetingId"],
              startDate: data["startDate"],
              duration: data["duration"]);
        }).toList();
        setState(() {
          firstLoaded = true;
        });
      }
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filteredMeetings = meetings.where((meeting) {
      final meetingDateTime = DateTime.parse(meeting.startDate);
      final difference = meetingDateTime.difference(now);
      return difference.inHours >= -24;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Danh Sách Cuộc Họp",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            nextScreenReplace(context, const HomePage());
          },
        ),
      ),
      body: !firstLoaded
          ? const Center(
              child: CircularProgressIndicator(), // Hiển thị màn hình tải
            )
          : ListView.builder(
              itemCount: filteredMeetings.length,
              itemBuilder: (context, index) {
                final meeting = filteredMeetings[index];
                return Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      "Meeting ${meeting.meetingId}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16.0),
                            SizedBox(width: 4.0),
                            Text(
                              'Ngày: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(meeting.startDate))}',
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16.0),
                            SizedBox(width: 4.0),
                            Text(
                              'Thời gian: ${DateTime.parse(meeting.startDate).toLocal().toString().split(' ')[1].substring(0, 5)} - ${DateTime.parse(meeting.startDate).add(Duration(minutes: meeting.duration)).toLocal().toString().split(' ')[1].substring(0, 5)}',
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      _handleRequestVideoCall(meeting.meetingId);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _handleRequestVideoCall(String meetingId) async {
    showLoadingDialog(context);
    final url = Uri.parse(
        'https://hah-booking-service-cec4d94fa331.herokuapp.com/api/meeting-active');
    String? accessToken;
    await HelperFunctions.getTokenFromSF().then((val) {
      setState(() {
        accessToken = val!;
      });
    });
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final body = jsonEncode({"meetingId": meetingId});

    try {
      final response = await http.post(url, headers: headers, body: body);
      Navigator.of(context).pop();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Xử lý kết quả từ API
        final responseData = jsonDecode(response.body);
        String appId = responseData["appId"];
        String channelName = responseData["channelName"];
        String token = responseData["token"];
        int time = responseData["timeOutSeconds"];
        await _handleCameraAndMic(Permission.camera);
        await _handleCameraAndMic(Permission.microphone);
        nextScreen(
            context,
            CallPage(
              appId: appId,
              channelName: channelName,
              token: token,
              role: ClientRoleType.clientRoleBroadcaster,
              timeoutSeconds: time,
            ));
      } else {
        // Xử lý lỗi khi gọi API
        final responseData = jsonDecode(response.body);
        print('API error: ${response.statusCode}');
        Fluttertoast.showToast(
          msg: '${responseData["message"]}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
    } finally {}
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
      // The user CANNOT close this dialog  by pressing outsite it
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return Dialog(
          // The background color
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                // The loading indicator
                CircularProgressIndicator(),
                SizedBox(
                  height: 15,
                ),
                // Some text
                Text('Loading...')
              ],
            ),
          ),
        );
      });
}

class Meeting {
  final String meetingId;
  final String startDate;
  final int duration;

  Meeting({
    required this.meetingId,
    required this.startDate,
    required this.duration,
  });
}
