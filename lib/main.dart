import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rede_social/firebase_options.dart';

void main() async {
  // configura firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
