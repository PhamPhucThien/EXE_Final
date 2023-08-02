import 'dart:convert';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:project/pages/home_page.dart';
import 'package:project/widgets/widgets.dart';

class WorkingHoursScreen extends StatefulWidget {

  Map<String, List<WorkingHours>> workingHours = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  @override
  _WorkingHoursScreenState createState() => _WorkingHoursScreenState();
}


class _WorkingHoursScreenState extends State<WorkingHoursScreen> {

  bool firstLoaded = false;

  @override
  void initState() {
    super.initState();
    initData();
  }


  initData() async {
     try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .where('userid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot document = snapshot.docs[0];
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      for (String day in widget.workingHours.keys) {
        if (data.containsKey(day)) {
          List<dynamic> hoursData = data[day];
          List<WorkingHours> hours = hoursData
              .map((hourData) => WorkingHours.fromMap(hourData))
              .toList();
          widget.workingHours[day] = hours;
        }
      }
      setState(() {});
    }
  } catch (e) {
    print('Error fetching working hours: $e');
  }
    finally{
      //Navigator.of(context).pop();
      firstLoaded = true;
    }
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Working Hours'),
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
      body: 
        !firstLoaded ? const Center(
            child: CircularProgressIndicator(), // Hiển thị màn hình tải
          ) :
        ListView.builder(
        itemCount: widget.workingHours.length,
        itemBuilder: (context, index) {
          String day = widget.workingHours.keys.elementAt(index);
          List<WorkingHours> hours = widget.workingHours[day]!;
          return ListTile(
            title: Text(day),
            subtitle: hours.isEmpty
                ? Text('Closed')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: hours
                        .map((hour) => ListTile(
                              title: Text(hour.startTime),
                              trailing: Text(hour.endTime),
                              onTap: () {
                                _showDeleteConfirmationDialog(day, hour, setState);
                              },
                            ))
                        .toList(),
                  ),
            onTap: () {
              _showTimePicker(day, setState);
            },
          );
        },
      ),
    );
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
  void _showTimePicker(String day, StateSetter setOutSideState) {
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Choose Working Hours'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Start Time'),
                    subtitle: selectedStartTime != null
                        ? Text(selectedStartTime!.format(context))
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            selectedStartTime = time;
                          });
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('End Time'),
                    subtitle: selectedEndTime != null
                        ? Text(selectedEndTime!.format(context))
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            selectedEndTime = time;
                          });
                        }
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedStartTime != null && selectedEndTime != null) {
                        if(compareTimeOfDate(selectedStartTime!, selectedEndTime!) >= 0){
                             _showInvalidTimeSelectionDialog(context, 'Thời gian không hợp lệ');
                             return;
                        }

                        if(!isValidTimeRange(widget.workingHours[day]!, selectedStartTime!, selectedEndTime!)){
                            _showInvalidTimeSelectionDialog(context, 'Mốc thời gian này nằm trong mốc thời gian đã có');
                             return;
                        }

                        WorkingHours w = WorkingHours(
                              startTime: selectedStartTime!.format(context),
                              endTime: selectedEndTime!.format(context),
                            );
                        bool ch = await addSchedularData(day, w);
                        if(!ch){
                           _showInvalidTimeSelectionDialog(context, 'Có lỗi xảy ra, hãy thử lại!');
                            return;
                        }
                        setState(() {
                          widget.workingHours[day]!.add(w);
                        });
                        setOutSideState((){});

                        selectedStartTime = null;
                        selectedEndTime = null;
                      }
                    },
                    child: Text('Add Time'),
                  ),
                  widget.workingHours[day]!.isEmpty
                      ? SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.workingHours[day]!
                              .map((hour) => ListTile(
                                    title: Text(hour.startTime),
                                    trailing: Text(hour.endTime),
                                    onTap: () {
                                      _showDeleteConfirmationDialog(day, hour, setState, setOutSideState: setOutSideState);
                                    },
                                  ))
                              .toList(),
                        ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String day, WorkingHours hour, StateSetter setState, {StateSetter? setOutSideState = null}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Time Slot'),
          content: Text('Are you sure you want to delete this time slot?'),
          actions: [
            TextButton(
              onPressed: () async {
                bool ch = await deleteSchedularData(day, hour);
                if(!ch){
                  _showInvalidTimeSelectionDialog(context, "Có lỗi xảy ra, không thể xóa!", title: "Thông báo");
                  return;
                }
                setState(() {
                  widget.workingHours[day]!.remove(hour);
                });
                if(setOutSideState != null) setOutSideState((){});
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  Future<bool> addSchedularData(String dayOfWeek, WorkingHours wh) async {
    CollectionReference  schedularCollection  = FirebaseFirestore.instance.collection("schedule");
    List<WorkingHours> hoursForDay = [...widget.workingHours[dayOfWeek]!];
    hoursForDay.add(wh);
    try{
      showLoadingDialog(context);
      final querySnapshot = await schedularCollection
      .where('userid', isEqualTo:FirebaseAuth.instance.currentUser?.uid)
      .get();

      DocumentSnapshot document = querySnapshot.docs[0];
     await schedularCollection.doc(document.id).update({
      dayOfWeek: hoursForDay.map((e) {
        return {
            "startTime": e.startTime,
            "endTime": e.endTime
        };
      })
     });
      return true;
    }catch(Exception){
      return false;
    }
    finally{
      Navigator.of(context).pop();
    }
  }

   Future<bool> deleteSchedularData(String dayOfWeek, WorkingHours wh) async {
    CollectionReference  schedularCollection  = FirebaseFirestore.instance.collection("schedule");
    List<WorkingHours> hoursForDay = [...widget.workingHours[dayOfWeek]!];
    hoursForDay.remove(wh);
    try{
      showLoadingDialog(context);
      final querySnapshot = await schedularCollection
      .where('userid', isEqualTo:FirebaseAuth.instance.currentUser?.uid)
      .get();

      DocumentSnapshot document = querySnapshot.docs[0];
     await schedularCollection.doc(document.id).update({
      dayOfWeek: hoursForDay.map((e) {
        return {
            "startTime": e.startTime,
            "endTime": e.endTime
            
        };
      })
     });
      return true;
    }catch(Exception){
      return false;
    }finally{
      Navigator.of(context).pop();
    }
  }
}
class WorkingHours {
  final String startTime;
  final String endTime;

  WorkingHours({required this.startTime, required this.endTime});

  factory WorkingHours.fromMap(Map<String, dynamic> map) {
    return WorkingHours(
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}

int compareTimeOfDate(TimeOfDay time1, TimeOfDay time2){
  if(time1.hour == time2.hour && time1.minute == time2.minute) return 0;

  if(time1.hour == time2.hour){
    if(time1.minute > time2.minute){
      return 1;
    }else{
      return -1;
    }
  }

  if(time1.hour > time2.hour){
    return 1;
  }

  return -1;
}

bool isValidTimeRange(List<WorkingHours> existingHours, TimeOfDay startTime, TimeOfDay endTime) {
  for (WorkingHours hours in existingHours) {
    TimeOfDay existingStartTime = _parseTimeOfDay(hours.startTime);
    TimeOfDay existingEndTime = _parseTimeOfDay(hours.endTime);

    if ((compareTimeOfDate(startTime,existingStartTime )>= 0 && compareTimeOfDate(startTime,existingEndTime) <= 0) ||
        (compareTimeOfDate(endTime,existingStartTime) >= 0 && compareTimeOfDate(endTime,existingEndTime) <= 0)) {
      return false;
    }
  }
  return true;
}

TimeOfDay _parseTimeOfDay(String time) {
  int hours = int.parse(time.split(':')[0]);
  int minutes = int.parse(time.split(':')[1].split(' ')[0]);
  String period = time.split(' ')[1];

  if (period == 'PM' && hours != 12) {
    hours += 12;
  } else if (period == 'AM' && hours == 12) {
    hours = 0;
  }

  return TimeOfDay(hour: hours, minute: minutes);
}

void _showInvalidTimeSelectionDialog(BuildContext context, String? message, {String title = 'Invalid Time Selection'}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message ?? 'Please select a valid time range.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}