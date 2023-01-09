import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:u_and_i/screen/home_screen.dart';
import 'package:u_and_i/screen/bucket_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDefault();
  runApp(
    MaterialApp(
      home:HomeScreen(),
    ),
  );
}

Future<void> initializeDefault() async{
  FirebaseApp app = await Firebase.initializeApp();
}