// ignore_for_file: avoid_web_libraries_in_flutter, body_might_complete_normally_catch_error

import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jnvst_admin/model/question.dart';

class AddTextQuestion extends StatefulWidget {
  static const String route = '/addTextQuestion';
  const AddTextQuestion({super.key});

  @override
  State<AddTextQuestion> createState() => _AddTextQuestionState();
}

class _AddTextQuestionState extends State<AddTextQuestion> {
  String testTitle = '';
  int numberOfQuestions = 0;
  int currIndex = 0;
  List<Question> questions = [];
  final TextEditingController _questionTextEditingController =
      TextEditingController();
  final TextEditingController _option1TextEditingController =
      TextEditingController();
  final TextEditingController _option2TextEditingController =
      TextEditingController();
  final TextEditingController _option3TextEditingController =
      TextEditingController();
  final TextEditingController _option4TextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: testTitle.isEmpty
            ? const Text('Add Text Question')
            : Text(testTitle),
      ),
      body: Center(
        child:
            testTitle.isEmpty ? _testTitleInput() : _addQuestionsController(),
      ),
    );
  }

  Widget _testTitleInput() {
    String tempTitle = '';
    int tempNumberOfQuestions = 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            onChanged: (value) {
              tempTitle = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter the title of the question',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              tempNumberOfQuestions = int.parse(value);
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter Number of Questions',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                testTitle = tempTitle;
                numberOfQuestions = tempNumberOfQuestions;
              });
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget showDemo(int index, Question question) {
    return Column(
      children: [
        Text('Q$index: ${question.questionText}'),
        Text(question.options[0]),
        Text(question.options[1]),
        Text(question.options[2]),
        Text(question.options[3]),
        Text('Correct Option: ${question.correctIndex}'),
      ],
    );
  }

  _addQuestionsController() {
    if (currIndex == numberOfQuestions) {
      return Column(
        children: [
          ...questions.map(
            (question) => showDemo(questions.indexOf(question) + 1, question),
          ),
          ElevatedButton(
            onPressed: () async {
              debugPrint('Questions: $questions');
              await saveTest();
            },
            child: const Text('Submit'),
          ),
        ],
      );
    }
    return _addQuestion();
  }

  Widget _addQuestion() {
    String question = '';
    String option1 = '';
    String option2 = '';
    String option3 = '';
    String option4 = '';
    String correctOption = '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Text('Question ${currIndex + 1}'),
          TextField(
            controller: _questionTextEditingController,
            onChanged: (value) => question = value,
            decoration: const InputDecoration(
              hintText: 'Enter the question',
            ),
          ),
          TextField(
            controller: _option1TextEditingController,
            onChanged: (value) => option1 = value,
            decoration: const InputDecoration(
              hintText: 'Enter Option 1',
            ),
          ),
          TextField(
            controller: _option2TextEditingController,
            onChanged: (value) => option2 = value,
            decoration: const InputDecoration(
              hintText: 'Enter Option 2',
            ),
          ),
          TextField(
            controller: _option3TextEditingController,
            onChanged: (value) => option3 = value,
            decoration: const InputDecoration(
              hintText: 'Enter Option 3',
            ),
          ),
          TextField(
            controller: _option4TextEditingController,
            onChanged: (value) => option4 = value,
            decoration: const InputDecoration(
              hintText: 'Enter Option 4',
            ),
          ),
          DropdownButtonFormField(
            validator: (value) {
              if (value == null) {
                return 'Please select the correct option';
              }
              return null;
            },
            value: correctOption.isEmpty ? null : int.parse(correctOption),
            onChanged: (value) => correctOption = value.toString(),
            onSaved: (newValue) => correctOption = newValue.toString(),
            items: const [
              DropdownMenuItem(
                child: Text('Select Correct Option'),
              ),
              DropdownMenuItem(value: 1, child: Text('1')),
              DropdownMenuItem(value: 2, child: Text('2')),
              DropdownMenuItem(value: 3, child: Text('3')),
              DropdownMenuItem(value: 4, child: Text('4')),
            ],
            decoration: const InputDecoration(
              hintText: 'Enter Correct Option',
            ),
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  questions.add(Question(
                      title: testTitle,
                      questionText: question,
                      options: [
                        option1,
                        option2,
                        option3,
                        option4,
                      ],
                      correctIndex: int.parse(correctOption) - 1));
                  if (currIndex < numberOfQuestions) {
                    currIndex++;
                  }
                  _questionTextEditingController.clear();
                  _option1TextEditingController.clear();
                  _option2TextEditingController.clear();
                  _option3TextEditingController.clear();
                  _option4TextEditingController.clear();
                });
              },
              child: const Text("Submit"))
        ],
      ),
    );
  }

  Future<void> saveTest() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference questions = firestore.collection('questions');
    for (var question in this.questions) {
      await questions.add(question.toMap()).catchError((error) {
        html.window.alert('Failed to add test: $error');
      }).whenComplete(() => html.window.alert('Test added successfully'));
    }
  }
}
