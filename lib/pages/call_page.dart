import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/meeting_rooms.dart';
import 'package:project/widgets/widgets.dart';


class CallPage extends StatefulWidget{
  final String channelName;
  final String token;
  final String appId;
  final ClientRoleType? role;
  int timeoutSeconds;
  CallPage({
    Key? key,
    required this.appId,
    required this.channelName,
    required this.token,
    required this.role,
    required this.timeoutSeconds,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage>{
  int? _user;
  bool _isJoined =false;
  final _infoStrings = <String>[];
  bool muted = true;
  bool cameraOff = false;
  bool viewPanel = false;
  late RtcEngine _engine ;


  @override
  void initState(){
    super.initState();
    initialize();
    meetingTimeout();
  }

  @override
  void dispose() {
    _user = null;
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> initialize() async {
    if(widget.appId.isEmpty) {
      setState(() {
        _infoStrings.add('App_ID missing, please provide your app id in settings.dart');
        _infoStrings.add('Agora Engine is not starting');
      
      });
      return;
    }
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: widget.appId,
    ));

     await _engine.startPreview();
    ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await _engine.enableVideo();  
    await _engine.setClientRole(role: widget.role!);
    _addAgoraEventHandlers();
    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: 0,
      options: options,
    );
  }

  void _addAgoraEventHandlers() {
   _engine.registerEventHandler(
    RtcEngineEventHandler(
       onError: (err, msg) => {
        setState(() {
          final info = 'Error: ' + msg;
          _infoStrings.add(info);
        })
       },
       
       onJoinChannelSuccess: (connection, elapsed) {
        setState(() {
          _isJoined = true;
          final info = 'Joint Channel: ${connection.channelId}, ${connection.localUid}';
          _infoStrings.add(info);
        });
       },
       onLeaveChannel: (connection, stats) {
        // setState(() {
        //   _infoStrings.add("Leave Chamnel");
        //   _user = null;
        // });

       },
       onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
            _user = remoteUid;
        });
        },
       onUserOffline: (connection, remoteUid, reason) {
        final info = 'User offline: ${remoteUid}';
        _infoStrings.add(info);
                  _user = null;
        setState(() {
          
        });
       },
       onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {
        setState(() {
          final info = 'First Remote Video: ${remoteUid} ${width} x ${height}';
          _infoStrings.add(info);
        });
       }
    ),
    );
  }

  Widget _viewRows() {
    final List<Widget> list =[];
    if(widget.role == ClientRoleType.clientRoleBroadcaster){
      list.add(AgoraVideoView(
        controller: VideoViewController(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: 0),
        ),
    ));
    }
    if(_user != null){
      list.add(AgoraVideoView(
        controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: _user),
        connection: RtcConnection(channelId: widget.channelName!),
        ),
    ));
    }

    final views = list;

    return Column(
      children: List.generate(
        views.length,
        (index) => Expanded(
          child: views[index],
        )
      ),
    );
    
  }

 

  Widget _toolbar() {

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              _engine.muteLocalAudioStream(muted);
            },
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
               _isJoined = false;
                Navigator.pop(context);
            },
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: () {
              setState(() {
                cameraOff = !cameraOff;
              });
              _engine.muteLocalVideoStream(cameraOff);
            },
            child: Icon(
              cameraOff ? Icons.videocam_off : Icons.videocam,
              color: cameraOff ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: cameraOff ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      )
    );
  }

  @override
  Widget build (BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                viewPanel = !viewPanel;
              });
            },
            icon: const Icon(Icons.info_outline),
          )
        ]
      ),
      backgroundColor: Colors.black,
      body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
            // Container for the local video
            Container(
                height: 240,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(child: _localPreview()),
            ),
            const SizedBox(height: 10),
            //Container for the Remote video
            Container(
                height: 240,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(child: _remoteVideo()),
            ),
            // Button Row

            _toolbar()
            ],
        ));
        
  }
  Widget _localPreview() {
    if (_isJoined) {
    return AgoraVideoView(
        controller: VideoViewController(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: 0),
        ),
    );
    } else {
    return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
    );
    }
}


// Display remote user's video
Widget _remoteVideo() {
    if (_user != null) {
    return AgoraVideoView(
        controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: _user),
        connection: RtcConnection(channelId: widget.channelName),
        ),
    );
    } else {
        String msg = '';
        return Text(
        msg,
        textAlign: TextAlign.center,
    );
    }
}

  void meetingTimeout() {
    bool isRemind = false;
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
    // Thực hiện hành động cần lặp lại ở đây
    widget.timeoutSeconds--;
    if(widget.timeoutSeconds < 0) {
      _isJoined = false;
      Navigator.pop(context);
    }else if (!isRemind && widget.timeoutSeconds < 300){
      isRemind = true; 
      showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Thông báo'),
                  content: Text('cuộc họp sẽ đóng trong 5 phút nữa'),
                  actions: [
                    TextButton(
                      child: Text('Đóng'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
    }
    });
    }
        
}