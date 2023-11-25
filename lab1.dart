import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Home()
  ));
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> subjects = ['Probability and Statistics', 'Mobile Information Systems', 'Team Project'];
  TextEditingController textController = TextEditingController();

  void addItemToList() {
    String subject = textController.text;
    if (subject.isNotEmpty) {
      setState(() {
        subjects.add(subject);
        textController.clear();
      });
    }
  }

  void removeItem(int index) {
    setState(() {
      subjects.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('191521'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.grey,
        child: ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                subjects[index],
                style: const TextStyle(color: Colors.black),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  removeItem(index);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add a new subject'),
                content: TextField(
                  controller: textController,
                  decoration: InputDecoration(labelText: 'New Subject'),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      addItemToList();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}



