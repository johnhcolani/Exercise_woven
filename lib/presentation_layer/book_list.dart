import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data_layer/book.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  List<Book> books = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController pagesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedBooks = prefs.getString('books');
    if (storedBooks != null) {
      setState(() {
        books = (jsonDecode(storedBooks) as List)
            .map((item) => Book.fromJson(item))
            .toList();
      });
    }
  }

  Future<void> saveBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('books', jsonEncode(books));
  }

  void createBook() {
    if (_formKey.currentState!.validate()) {
      final pagesText = pagesController.text.trim();
      final pages = int.parse(pagesText);
      setState(() {
        books.add(Book(
          id: books.length + 1,
          title: titleController.text,
          author: authorController.text,
          pages: pages,
        ));
        saveBooks();
        titleController.clear();
        authorController.clear();
        pagesController.clear();
      });
    }
  }

  void deleteBook(int id) {
    setState(() {
      books.removeWhere((book) => book.id == id);
      saveBooks();
    });
  }

  void editBook(int id, Book newBook) {
    setState(() {
      final index = books.indexWhere((book) => book.id == id);
      if (index != -1) {
        books[index] = newBook;
        saveBooks();
      }
    });
  }

  void _showEditDialog(Book book) {
    titleController.text = book.title;
    authorController.text = book.author;
    pagesController.text = book.pages.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Book'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextFormField(
                controller: authorController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter author';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Author',
                ),
              ),
              TextFormField(
                controller: pagesController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pages';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pages',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newBook = Book(
                  id: book.id,
                  title: titleController.text,
                  author: authorController.text,
                  pages: int.parse(pagesController.text),
                );
                editBook(book.id, newBook);
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.blue.shade400,
      child: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Book Manager',style: TextStyle(color: Colors.white70),),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.shade100,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: titleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter title';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.black87),
                          decoration: const InputDecoration(

                            labelText: 'Title',
                            border: OutlineInputBorder(

                              borderSide: BorderSide(color: Colors.white,width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: authorController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter author';
                            }
                            return null;
                          },
                          style: const TextStyle(color:  Colors.black87),
                          decoration: const InputDecoration(
                            labelText: 'Author',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white,width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: pagesController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter pages';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color:  Colors.black87),
                          decoration: const InputDecoration(
                            labelText: 'Pages',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white,width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: createBook,
              child: Text('Create Book'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (BuildContext context, int index) {
                  final book = books[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text(book.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Author: ${book.author}'),
                            Text('Pages: ${book.pages}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(book);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteBook(book.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
