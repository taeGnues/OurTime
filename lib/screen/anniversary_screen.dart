import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swipe/swipe.dart';
import 'package:page_transition/page_transition.dart';
import 'package:u_and_i/screen/home_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class Dday {
  Timestamp? selectedDay;
  String title = '';

  Dday(this.title, this.selectedDay);
} // dday 모

class AnniversaryScreen extends StatefulWidget {
  const AnniversaryScreen({Key? key}) : super(key: key);

  @override
  State<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends State<AnniversaryScreen> {
  var _ddayController = TextEditingController();

  @override
  void dispose() {
    _ddayController.dispose();
    super.dispose();
  }

  void _addTotalDday(String value1, Timestamp value2) {
    FirebaseFirestore.instance
        .collection('ddaylists')
        .add({'title': value1, 'selectedDay': value2});

    _ddayController.text = ''; // 할일 입력필드 비움
  }

  void _deleteTodo(DocumentSnapshot doc) {
    Dday dday = Dday(doc['title'], doc['selectedDay']);
    FirebaseFirestore.instance.collection('ddaylists').doc(doc.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: const Text('아이코😅, 실수로 지우셨나요?'),
          action: SnackBarAction(label: '복구', textColor: Colors.white, onPressed: () {
            FirebaseFirestore.instance.collection('ddaylists').add({
              'title': dday.title,
              'selectedDay': dday.selectedDay,
            });
          },),

        )
    );
  }

  Widget _buildItemWidget(DocumentSnapshot doc) {
    final dday = Dday(doc['title'], doc['selectedDay']);
    DateTime selectedDateDay = dday.selectedDay!.toDate();

    String? _ddaymandp(DateTime selectedDate, DateTime nowDate) {
      Duration diff = nowDate.difference(selectedDate);
      if(diff.inDays == 0 && nowDate.day == selectedDate.day){
        return 'D-Day';
      }

      if (diff.inDays > 0) {
        return 'D+${diff.inDays+1}';
      }
      if (diff.inDays < 0) {
        return 'D${diff.inDays-1}';
      }
      if (diff.inDays == 0) {
        return 'D-1';
      }

    }

    return Slidable(
      key: ValueKey(doc.id),
      startActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: () => _deleteTodo(doc)),
          children: const [
            SlidableAction(
              backgroundColor: Colors.black26,
              onPressed: null,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '밀어서 지우기',
            )
          ]),
      child: Card(
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dday.title,
                    style: TextStyle(
                      fontFamily: 'sunflower',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '${DateFormat("yyyy년 MM월 dd일").format(selectedDateDay)}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Text(
                '${_ddaymandp(selectedDateDay, DateTime.now())}',
                style: TextStyle(
                  fontFamily: 'sunflower',
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Swipe(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 20,
                width: 10,
              ),
              _buildTop(),
              SizedBox(
                height: 20,
                width: 10,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      textInputAction: TextInputAction.go,
                      controller: _ddayController,
                      decoration: InputDecoration(
                        labelText: '우리의 특별한날을 적어주세요.',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              BorderSide(width: 1, color: Colors.blueAccent),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    )),
                    IconButton(
                      onPressed: () async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.black,
                                  // header background color
                                  onPrimary: Colors.white,
                                  // header text color
                                  onSurface: Colors.black, // body text color
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Colors.black, // button text color
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (newDate == null) return;

                        Timestamp newDateTs = Timestamp.fromDate(newDate);
                        _addTotalDday(_ddayController.text, newDateTs);
                      },
                      icon: Icon(Icons.calendar_month_outlined),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('ddaylists')
                      .orderBy('selectedDay', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final documents = snapshot.data?.docs;
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return Expanded(
                      child: ListView(
                        children: documents!
                            .map((doc) => _buildItemWidget(doc))
                            .toList(),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
      onSwipeRight: () {
        Navigator.pop(
          context,
          PageTransition(
            type: PageTransitionType.leftToRight,
            isIos: true,
            child: HomeScreen(),
          ),
        );
      },
    );
  }
}

class _buildTop extends StatefulWidget {
  const _buildTop({Key? key}) : super(key: key);

  @override
  State<_buildTop> createState() => _buildTopState();
}

class _buildTopState extends State<_buildTop> {
  DateTime selectedDate = DateTime.utc(2022, 10, 29);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('firstwemet')
                    .doc('ZDVahPliLNOIy4DNOS6R')
                    .snapshots(),
                builder: (context, snapshot) {
                  final documents = snapshot.data;
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  Timestamp timestamp = documents!['metday'];
                  selectedDate = timestamp.toDate();
                  return Text(
                    'D+${DateTime.now().difference(selectedDate).inDays+1}',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  );
                },
              ),
              SizedBox(
                width: 7,
              ),
              Text(
                '우리가 만난지',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('firstwemet')
                .doc('ZDVahPliLNOIy4DNOS6R')
                .snapshots(),
            builder: (context, snapshot) {
              final documents = snapshot.data;
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              Timestamp timestamp = documents!['metday'];
              selectedDate = timestamp.toDate();
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 15,
                  ),
                  Text(' ${DateFormat("yyyy년 MM월 dd일").format(selectedDate)}'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
