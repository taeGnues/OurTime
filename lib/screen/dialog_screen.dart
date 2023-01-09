import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Did {
  String title = '';
  String content = '';
  String url = '';
  Timestamp timeStamp = Timestamp.now();

  Did(this.title, this.content, this.url);
}

class DialogScreen extends StatefulWidget {
  const DialogScreen({Key? key}) : super(key: key);

  @override
  State<DialogScreen> createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen> {
  void _deleteDid(DocumentSnapshot doc) {

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder( //버튼을 둥글게 처리
                borderRadius: BorderRadius.circular(15)),
            content: Text('정말로 삭제하실건가요? \n삭제된 이후에는 복구할 수 없습니다.',
            style: TextStyle(fontSize: 16, fontFamily: 'himelody'),),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('아니요', style: TextStyle(color: Color(0xffbcb78f)),)),
              TextButton(onPressed: (){
                Navigator.pop(context);
                String filePath = doc['filePath'];
                _deleteStorageImage(filePath);
                FirebaseFirestore.instance.collection('did').doc(doc.id).delete();
              }, child: Text('네', style: TextStyle(color: Color(0xffbcb78f),),)),
            ],
          );
        },
    );
  }

  Future<void> _deleteStorageImage(String filePath) async {
    final ref = FirebaseStorage.instance.ref().child(filePath);
    await ref.delete();
  }


  Widget _buildItemWidget(DocumentSnapshot doc) {
    final did = Did(doc['title'], doc['content'], doc['url']);

    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  did.title,
                  style: TextStyle(fontFamily: 'himelody'),
                ),
                content: SingleChildScrollView(
                    child: Column(
                  children: [
                    Image.network(did.url),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            child: Text(
                          DateFormat("📌 yyyy년 MM월 dd일")
                              .format(did.timeStamp.toDate()),
                          style: TextStyle(fontFamily: 'himelody',
                          fontSize: 20),
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    did.content == ''
                        ? Container()
                        : Container(
                            width: 240,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xfff0f2f0),
                            ),
                            child: Text(
                              did.content,
                              style: TextStyle(fontFamily: 'himelody'),
                            ),
                          ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(onPressed: () => _deleteDid(doc), icon: Icon(Icons.delete, size: 20,)),
                      ],
                    ),
                  ],
                )),
              );
            });
        //Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(did)));
      },
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: NetworkImage(did.url),
              fit: BoxFit.cover,
            )),
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            did.title,
            style: TextStyle(fontSize: 15, fontFamily: 'nanumgothic'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Our Memories', style: TextStyle(fontSize: 30, fontFamily: 'parisienne'),),
                ],
              ),
              SizedBox(height: 15,),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('did')
                    .orderBy('timeStamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  final documents = snapshot.data?.docs;
                  var size = MediaQuery.of(context).size;

                  /*24 is for notification bar on Android*/
                  final double itemHeight = size.height / 4;
                  final double itemWidth = size.width / 2;

                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return Expanded(
                    child: GridView.count(
                      childAspectRatio: (itemWidth / itemHeight),
                      crossAxisCount: 2,
                      children: documents!
                          .map((doc) => _buildItemWidget(doc))
                          .toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
