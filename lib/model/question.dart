class Question {
  String title;
  String questionText;
  List<dynamic> options;
  int correctIndex;

  Question(
      {required this.title,
      required this.questionText,
      required this.options,
      required this.correctIndex});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'questionText': questionText,
      'options': options,
      'correctIndex': correctIndex,
    };
  }

  Question.fromMap(Map<String, dynamic> item)
      : title = item['title'],
        questionText = item['questionText'],
        options = item['options'],
        correctIndex = item['correctIndex'];
}
