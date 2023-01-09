import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:u_and_i/screen/home_screen.dart';
import 'package:image_picker/image_picker.dart';

class Todo {
  String title = '';
  Timestamp timeStamp = Timestamp.now();

  Todo(this.title);
} // 버킷리스트 관리

class BucketScreen extends StatefulWidget {
  const BucketScreen({Key? key}) : super(key: key);

  @override
  State<BucketScreen> createState() => _BucketScreenState();
}

class _BucketScreenState extends State<BucketScreen> {
  var _todoController = TextEditingController();
  var _didController = TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    _didController.dispose();
    super.dispose();
  }

  void _addTodo(Todo todo) {
    FirebaseFirestore.instance.collection('todo').add({
      'title': todo.title,
      'timeStamp': Timestamp.now()
    });
    _todoController.text = ''; // 할일 입력필드 비움
  }

  void _deleteTodo(DocumentSnapshot doc) {
    Todo todo = Todo(doc['title']);
    todo.timeStamp = doc['timeStamp'];
    FirebaseFirestore.instance.collection('todo').doc(doc.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.black,
      content: const Text('아이코😅, 실수로 지우셨나요?'),
      action: SnackBarAction(
        label: '복구',
        textColor: Colors.white,
        onPressed: () {
          FirebaseFirestore.instance.collection('todo').add({
            'title': todo.title,
            'timeStamp': todo.timeStamp,
          });
        },
      ),
    ));
  }


  StreamController<PickedFile?> streamImage = StreamController<PickedFile?>.broadcast();
  // 여러개의 stream을 동시에 처리, 여러곳에서 listen을 할 수 있음.
  String savedImageURL = '';
  String savedImageName = '';
  String urlDownload = '';

  Future getImageFromGallery() async {
    PickedFile? image =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    streamImage.add(image);
    savedImageURL = image!.path;
    savedImageName = savedImageURL.split('/').last; // 파일이름
  } // 이미지 처리

  Future uploadFile(Todo todo) async {
    final storagePath = 'did_images/${savedImageName}';
    final file = File(savedImageURL);

    final ref = FirebaseStorage.instance.ref().child(storagePath);
    UploadTask uploadTask = ref.putFile(file);

    final snapshot = await uploadTask.whenComplete(() => {});

    urlDownload = await snapshot.ref.getDownloadURL();
    // 파일 다운로드 링크

    FirebaseFirestore.instance.collection('did').add({
      'title': todo.title,
      'content': _didController.text,
      'filePath': storagePath,
      'timeStamp': todo.timeStamp,
      'url' : urlDownload,
    });

  }




  void saveDialogDid(DocumentSnapshot doc) {
    Todo todo = Todo(doc['title']);
    todo.timeStamp = doc['timeStamp'];

    FirebaseFirestore.instance.collection('todo').doc(doc.id).delete();

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('우리의 기록📝'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SimpleGestureDetector(
                    onTap: () => getImageFromGallery(),
                    child: StreamBuilder<PickedFile?>(
                      stream: streamImage.stream,
                      builder: (context, snapshot) {
                        return snapshot.data == null ?
                        Container(
                          width: 240,
                          height: 240,
                          alignment: Alignment.center,
                          child: Text(
                            '특별한 한장을 더하세요.',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        )
                            : Container(
                          width: 240,
                          height: 240,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: FileImage(
                                  File(snapshot.data!.path)),
                                  fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: _didController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: '우리의 이야기를 적어주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          },
                        icon: Icon(Icons.close),
                      ),
                      IconButton(
                          onPressed: () {
                            uploadFile(todo);

                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.calendar_month_outlined)),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
    _didController.text = '';
  }

  void _onHorizontalSwipe(SwipeDirection direction) {
    if (direction == SwipeDirection.left) {
      Navigator.pop(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft, child: HomeScreen()));
    }
  }

  Widget _buildItemWidget(DocumentSnapshot doc) {

    final todo = Todo(doc['title']);
    return Slidable(
      key: ValueKey(doc.id),
      startActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(
            onDismissed: () => _deleteTodo(doc),
          ),
          children: const [
            SlidableAction(
              backgroundColor: Colors.black26,
              onPressed: null,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '밀어서 지우기',
            )
          ]),
      endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: () => saveDialogDid(doc)),
          children: const [
            SlidableAction(
              backgroundColor: Colors.lightBlue,
              onPressed: null,
              foregroundColor: Colors.white,
              icon: Icons.check,
              label: '밀어서 완료!',
            )
          ]),
      child: Card(
        child: ListTile(
          title: Center(
            child: Text(
                    todo.title,
                    style: TextStyle(
                      fontFamily: 'nanumgothic',
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleGestureDetector(
      onHorizontalSwipe: _onHorizontalSwipe,
      child: Scaffold(
        backgroundColor: Color(0xffFFFFFF),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 20,
                width: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                    height: 10,
                  ),
                  Expanded(
                      child: TextField(
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) => _addTodo(Todo(value)),
                    controller: _todoController,
                    decoration: InputDecoration(
                      labelText: '무엇을 하고 싶나요?',
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
                  SizedBox(
                    width: 10,
                    height: 10,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('todo')
                      .orderBy('timeStamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final documents = snapshot.data?.docs;
                    var size = MediaQuery.of(context).size;

                    /*24 is for notification bar on Android*/
                    final double itemHeight = size.height / 28;
                    final double itemWidth = size.width / 2;

                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return Expanded(
                      child: GridView.count(
                        childAspectRatio: (itemWidth / itemHeight),
                        crossAxisCount: 1,
                        children: documents!
                            .map((doc) => _buildItemWidget(doc))
                            .toList(),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
