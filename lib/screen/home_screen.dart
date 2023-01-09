import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:u_and_i/screen/anniversary_screen.dart';
import 'package:u_and_i/screen/bucket_screen.dart';
import 'package:u_and_i/screen/chat/chat_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import 'package:u_and_i/screen/dialog_screen.dart';

class MetDate{
  Timestamp? metday;

  MetDate(this.metday);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _onHorizontalSwipe(SwipeDirection direction) {

      if (direction == SwipeDirection.left) {
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: AnniversaryScreen()));
      } else {
        Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: BucketScreen()));
      }
  }

  void _onVerticalSwipe(SwipeDirection direction){
    if(direction == SwipeDirection.up){
      //Navigator.push(context, PageTransition(child: ChatScreen(), type: PageTransitionType.bottomToTop));
    }else{
      Navigator.push(context, PageTransition(child: DialogScreen(), type: PageTransitionType.topToBottom));
    }

  }

  @override
  Widget build(BuildContext context) {
    return SimpleGestureDetector(
      onHorizontalSwipe: _onHorizontalSwipe,
      onVerticalSwipe: _onVerticalSwipe,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopPart(),
              _BottomPart(),
            ],
          ),
        )
      ),
    );
  }
}

class _TopPart extends StatefulWidget {
  const _TopPart({Key? key}) : super(key: key);

  @override
  State<_TopPart> createState() => _TopPartState();
}

class _TopPartState extends State<_TopPart> {

  void _updateDate(DocumentSnapshot doc, Timestamp timestamp) {
    FirebaseFirestore.instance.collection('firstwemet').doc(doc.id).update({
      'metday': timestamp,
    });
  }

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
        return Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('T&H',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'parisienne',
                    fontSize: 80,
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                    stream:
                      FirebaseFirestore.instance.collection('firstwemet').doc('ZDVahPliLNOIy4DNOS6R').snapshots(),
                    builder: (context, snapshot){
                      final documents = snapshot.data;
                      if(!snapshot.hasData){
                        return CircularProgressIndicator();
                      }
                      Timestamp timestamp = documents!['metday'];
                      selectedDate =  timestamp.toDate();
                      return Column(
                        children: [
                          Column(
                            children: [
                              Text('${selectedDate.year}.${selectedDate.month}.${selectedDate.day}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'sunflower',
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            iconSize: 60,
                            onPressed: (){
                              showCupertinoDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context){
                                    return Align(
                                      alignment: Alignment.bottomCenter,

                                      child: Container(
                                        color: Colors.white,
                                        height: 300,
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          initialDateTime: selectedDate,
                                          maximumDate: DateTime.now(),
                                          onDateTimeChanged: (DateTime date){
                                            Timestamp dateTs = Timestamp.fromDate(date);
                                            _updateDate(documents, dateTs);
                                          },
                                        ),
                                      ),
                                    );
                                  });
                            },
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.black,
                            ),
                          ),
                          Text('D+${DateTime.now().difference(selectedDate).inDays + 1}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'sunflower',
                              fontWeight: FontWeight.w700,
                              fontSize: 50,
                            ),
                          ),
                        ],
                      );
                    },
                ),



              ],
            ),
          ),
        );
      }

  }

class _BottomPart extends StatelessWidget {
  const _BottomPart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Image.asset('asset/img/middle_image.png'));
  }
}

