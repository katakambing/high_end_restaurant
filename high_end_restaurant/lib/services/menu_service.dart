import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_model.dart';

class MenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<MenuModel>> getMenus() async {
    final snapshot = await _db.collection('menu').get();

    return snapshot.docs.map((doc) {
      return MenuModel.fromMap(doc.id, doc.data());
    }).toList();
  }
}