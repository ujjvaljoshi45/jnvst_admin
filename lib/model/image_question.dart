class ImageQuestion {
  String questionImage;
  List<String> optionImage;
  int correctIndex;
  String title;
  ImageQuestion(
      {required this.questionImage,
      required this.optionImage,
      required this.correctIndex,
      required this.title});

  ImageQuestion.fromMap(Map<String, dynamic> item)
      : questionImage = item['question'],
        optionImage = [
          item['option1'],
          item['option2'],
          item['option3'],
          item['option4']
        ],
        correctIndex = item['correctOption'] as int,
        title = item['title'];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'question': questionImage,
      'options': optionImage,
      'correctOption': correctIndex.toString(),
      'title': title,
    };
  }
}
