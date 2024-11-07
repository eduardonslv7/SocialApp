import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rede_social/app.dart';
import 'package:rede_social/config/firebase_options.dart';

void main() async {
  // configura firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // run app
  runApp(MyApp());
}
