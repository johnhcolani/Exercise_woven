class Book {
  final int id;
  final String title;
  final String author;
  final int pages;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.pages,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      pages: json['pages'],
    );
  }
}
