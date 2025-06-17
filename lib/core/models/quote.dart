class Quote {
  final String text;
  final String author;
  final DateTime? timestamp;
  final String? category;

  Quote({
    required this.text,
    required this.author,
    this.timestamp,
    this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] as String,
      author: json['author'] as String,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : null,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'timestamp': timestamp?.toIso8601String(),
      'category': category,
    };
  }

  @override
  String toString() => '"$text" - $author';
} 