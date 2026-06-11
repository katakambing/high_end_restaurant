import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({super.key});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final imageController = TextEditingController();
  final categoryController = TextEditingController();

  Future<void> addMenu() async {
    await FirebaseFirestore.instance.collection('menu').add({
      'name': nameController.text,
      'description': descController.text,
      'price': double.parse(priceController.text),
      'image': imageController.text,
      'category': categoryController.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Menu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price")),
            TextField(controller: imageController, decoration: const InputDecoration(labelText: "Image URL")),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: addMenu,
              child: const Text("Add"),
            )
          ],
        ),
      ),
    );
  }
}