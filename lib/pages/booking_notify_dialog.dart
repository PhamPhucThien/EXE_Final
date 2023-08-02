import 'dart:io';
import 'package:project/pages/home_page.dart';
import 'package:project/widgets/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class BookingDialogNotify extends StatefulWidget {
 
  final IO.Socket socket;
  final String? message;
  const BookingDialogNotify({Key? key, required this.socket, this.message}) : super(key: key);

  @override
  _BookingDialogNotifyState createState() => _BookingDialogNotifyState();
}

class _BookingDialogNotifyState extends State<BookingDialogNotify> {
   double? remainingTime;
  bool isAccept = false;
  @override
  void initState() {
    
    super.initState();
    handleSocket();
  }
  
  void handleSocket() async {
    
     widget.socket.on('timer', (data) {
        setState(() {
          remainingTime = double.tryParse(data.toString());
        });
    });

    widget.socket.onDisconnect((data) {
        nextScreenReplace(context, const HomePage());
    });
    await Future.delayed(Duration(seconds: 30));
    print('Wait completed. Continue...');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Thông báo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.message!),
          SizedBox(height: 16),
          CircularProgressIndicator(
            value: remainingTime == null ? 1 : remainingTime! / 30,
          ),
        ],
      ),
      actions: <Widget>[
        if(!isAccept)
        TextButton(
          child: Text('Đồng ý'),
          onPressed: () {
            widget.socket.emit("message", 1);
            setState(() {
                isAccept = true;
            });
          },
        ),
        if(!isAccept)
        TextButton(
          child: Text('Từ chối'),
          onPressed: () {
             widget.socket.emit("message", 0);
            setState(() {
                isAccept = true;
            });
          },
        ),
      ],
    );
  }
}