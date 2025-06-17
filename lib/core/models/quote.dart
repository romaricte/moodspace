class Quote {
  final String text;
  final String author;

  Quote({
    required this.text,
    required this.author,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'],
      author: json['author'],
    );
  }
} 