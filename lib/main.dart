// ignore_for_file: avoid_web_libraries_in_flutter, avoid_print
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jnvst_admin/views/add_text_question.dart';
import 'package:jnvst_admin/views/qia.dart';
import 'firebase_options.dart';
import 'views/admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        AdminView.route: (context) => const AdminView(),
        AIQ.route: (context) => const AIQ(),
        AddTextQuestion.route: (context) => const AddTextQuestion(),
      },
      home: const AdminView(),
    ),
  );
}
