import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:u_and_i/screen/chat/new_message.dart';
import 'package:u_and_i/screen/home_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_and_i/screen/chat/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _onVerticalSwipe(SwipeDirection direction){
    if (direction == SwipeDirection.down) {
      Navigator.pop(context, PageTransition(
          type: PageTransitionType.topToBottom, child: HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleGestureDetector(
      onVerticalSwipe: _onVerticalSwipe,
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.white,
            body: Column(
              children: [
                Expanded(child: Messages(),),
                NewMessage(),
              ],
            ),
      )),
    );
  }
}
