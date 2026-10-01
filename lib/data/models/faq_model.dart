class FaqModel {
  final String? id;
  final String? question;
  final String? answer;
  final String? category; // 'Customer', 'Vendor', etc.

  FaqModel({
    this.id,
    this.question,
    this.answer,
    this.category,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      question: json['question']?.toString(),
      answer: json['answer']?.toString(),
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (question != null) 'question': question,
      if (answer != null) 'answer': answer,
      if (category != null) 'category': category,
    };
  }
}
