// models/educational_content.dart
class Topic {
  final String title;
  final String content;
  final String imageUrl;
  
  Topic({
    required this.title,
    required this.content,
    required this.imageUrl,
  });
  
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class Term {
  final String term;
  final String definition;
  
  Term({
    required this.term,
    required this.definition,
  });
  
  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      term: json['term'] ?? '',
      definition: json['definition'] ?? '',
    );
  }
}

class Strategy {
  final String title;
  final String description;
  final String difficulty;
  final String risk;
  
  Strategy({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.risk,
  });
  
  factory Strategy.fromJson(Map<String, dynamic> json) {
    return Strategy(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? '',
      risk: json['risk'] ?? '',
    );
  }
}