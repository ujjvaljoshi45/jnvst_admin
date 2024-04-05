import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jnvst_admin/model/image_question.dart';

class TempImageQuestion {
  final String imageUrl;
  TempImageQuestion(this.imageUrl);
}

class AIQ extends StatefulWidget {
  static String route = '/add_image_question';

  const AIQ({super.key});

  @override
  State<AIQ> createState() => _AIQState();
}

class _AIQState extends State<AIQ> {
  String title = '';
  XFile? questionImage;
  List<XFile?> options = List.filled(4, null);
  int? correctOption;
  final List<ImageQuestionCache> _imageQuestions = [];

  bool check = false;
  bool showTitle = true;

  // Save Images to Storage and Questions to Firestore
  saveImageToStorage() async {
    debugPrint('saveImageToStorage');
    List<ImageQuestion> myImageQuestion = [];

    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      storage.bucket = 'gs://jnvst-74bb1.appspot.com';
      for (var imageQuestion in _imageQuestions) {
        Reference ref = storage.ref().child(imageQuestion.questionImage.name);
        TaskSnapshot ut =
            await ref.putData(await imageQuestion.questionImage.readAsBytes());
        String imageUrl = await ut.ref.getDownloadURL();
        List<String> optionUrls = [];
        for (var option in imageQuestion.options) {
          Reference ref = storage.ref().child(option!.name);
          TaskSnapshot ut = await ref.putData(await option.readAsBytes());
          String imageUrl = await ut.ref.getDownloadURL();
          optionUrls.add(imageUrl);
        }
        myImageQuestion.add(ImageQuestion(
            questionImage: imageUrl,
            optionImage: optionUrls,
            correctIndex: imageQuestion.correctOption,
            title: imageQuestion.title));
      }
      debugPrint('Image Questions: ${myImageQuestion.length}');
    } catch (e) {
      debugPrint('Error: $e');
    }
    // save to firestore
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference imageQuestions =
          firestore.collection('questionsImage');
      for (var imageQuestion in myImageQuestion) {
        await imageQuestions.add(imageQuestion.toMap());
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Show Title or TextField
          title: showTitle
              ? (Text(title.isEmpty ? 'Update Tile' : title))
              : (TextField(
                  onChanged: (value) => setState(() => title = value),
                  decoration: const InputDecoration(hintText: 'Enter Title'),
                )),
          actions: [
            // Show Edit or Save Button
            TextButton(
                onPressed: () => setState(() => showTitle = !showTitle),
                child: showTitle ? const Text('Edit') : const Text('Save'))
          ],
        ),
        // Check what to display inputs or demo
        body: check ? _buildDemo() : _buildInputTaker());
  }

  // Build Demo (It shows the list of questions along with options and correct option index)
  _buildDemo() => SingleChildScrollView(
        child: Column(
          children: [
            for (var question in _imageQuestions)
              Column(
                children: [
                  Text("Questions: ${_imageQuestions.indexOf(question) + 1}"),
                  Image.network(question.questionImage.path),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var i = 0; i < 4; i++)
                          SizedBox(
                            width: 100,
                            child: ListTile(
                              title: Image.network(question.options[i]!.path),
                              subtitle: Text('Option ${i + 1}'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text('Correct Option: ${question.correctOption}'),
                ],
              ),
            ElevatedButton(
                onPressed: () async {
                  await saveImageToStorage();
                },
                child: const Text('Save Test')),
          ],
        ),
      );

// Build Input Taker (It takes the input from the user)
  _buildInputTaker() => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Method to build Image Input takers
            ..._buildImageInputs(),
            // Dropdown to select correct option
            DropdownButtonFormField(
                value: 1, // Default Value
                items: [
                  // Loop over 4 options (no need to write 4 times same code)
                  for (var i = 1; i <= 4; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text('Option $i'),
                    )
                ],
                onChanged: (value) {
                  setState(() {
                    correctOption = value;
                  });
                }),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                ElevatedButton(
                    // Add Question to Cache Class
                    onPressed: () => setState(() {
                          _imageQuestions.add(ImageQuestionCache(
                              questionImage!, correctOption!, options, title));
                          questionImage = null;
                          options = [];
                          correctOption = null;
                        }),
                    child: const Text('Add Question')),
                ElevatedButton(
                    onPressed: () => setState(() => check = true),
                    child: const Text('Submit Test')),
              ],
            )
          ],
        ),
      );

  // Returns List of Image Input Takers
  List _buildImageInputs() => [
        // A Row contains String for Title, Button to take input, callback function and Text Widget to show selected file name
        // Building one for question input
        _buildInputRow(
          'Question Image',
          'Add Question Image',
          'Change Question Image',
          questionImage,
          () {
            ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
              setState(() {
                questionImage = value!;
              });
            });
          },
        ),
        // Looping 4 times to take 4 input optoins
        for (int i = 0; i < 4; i++)
          _buildInputRow(
            'Option ${i + 1} Image',
            'Add Option ${i + 1} Image',
            'Change Option ${i + 1} Image',
            options.length > i ? options[i] : null,
            () {
              ImagePicker()
                  .pickImage(source: ImageSource.gallery)
                  .then((value) {
                setState(() {
                  options[i] = value!;
                });
              });
            },
          ),
      ];

  // Input Row
  _buildInputRow(String hintText, String addImageText, String changeImageText,
          XFile? imageFile, Function() callbackFun) =>
      Row(
        children: [
          Text(
            hintText,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          TextButton(
            onPressed: callbackFun,
            child: Text(imageFile == null ? addImageText : changeImageText),
          ),
          if (imageFile != null)
            Text(
              imageFile.name,
            ),
        ],
      );
}

// Temp class to store the images and options
class ImageQuestionCache {
  final String title;
  final XFile questionImage;
  final List<XFile?> options;
  final int correctOption;
  ImageQuestionCache(
      this.questionImage, this.correctOption, this.options, this.title);
}
