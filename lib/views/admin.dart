import 'package:flutter/material.dart';

import 'package:jnvst_admin/views/add_text_question.dart';

import 'qia.dart';

class AdminView extends StatelessWidget {
  static const String route = '/admin';
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin View'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AddTextQuestion.route),
            child: const Text('Add Text Question'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AIQ.route),
            child: const Text('Add Image Question'),
          ),
        ],
      )),
    );
  }
}
