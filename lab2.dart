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
  List<String> clothes = ['T-shirt', 'Nike Tech'];
  List<String> selectedClothes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('191521'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => _showSelectedClothes(),
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Selected clothes: ${selectedClothes.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Choose Clothes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: clothes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    clothes[index],
                    style: const TextStyle(color: Colors.red),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editItem(index),
                        color: Colors.green,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(index),
                        color: Colors.green,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addToSelectedClothes(index),
                        color: Colors.green,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Add Clothes',
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      clothes.removeAt(index);
    });
  }

  void _addToSelectedClothes(int index) {
    setState(() {
      selectedClothes.add(clothes[index]);
    });
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: clothes[index]);
        return AlertDialog(
          title: const Text('Edit Clothing'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter Clothing'),
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
                setState(() {
                  clothes[index] = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Clothing'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter Clothing'),
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
                setState(() {
                  clothes.add(controller.text);
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showSelectedClothes() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selected Clothes'),
          content: Text(selectedClothes.join(", ")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}