import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditMenuPage extends StatefulWidget {
  final String id;
  final Map data;

  const EditMenuPage({
    super.key,
    required this.id,
    required this.data,
  });

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController imageController;
  late TextEditingController categoryController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    descController =
        TextEditingController(text: widget.data['description'] ?? '');
    priceController =
        TextEditingController(text: widget.data['price'].toString());
    imageController = TextEditingController(text: widget.data['image'] ?? '');
    categoryController =
        TextEditingController(text: widget.data['category'] ?? '');
  }

  Future<void> updateMenu() async {
    await FirebaseFirestore.instance.collection('menu').doc(widget.id).update({
      'name': nameController.text,
      'description': descController.text,
      'price': double.parse(priceController.text),
      'image': imageController.text,
      'category': categoryController.text,
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    imageController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Menu")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price (RM)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: "Image URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateMenu,
                child: const Text("Update Menu"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
