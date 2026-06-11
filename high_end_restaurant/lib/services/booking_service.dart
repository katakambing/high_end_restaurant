import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  static final _db = FirebaseFirestore.instance;

  //CREATE
  static Future<void> createBooking(BookingModel booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }

  //READ
  static Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  //DELETE
  static Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }

  //UPDATE
  static Future<void> updateBooking(BookingModel booking) async {
    await _db
        .collection('bookings')
        .doc(booking.id)
        .update(booking.toMap());
  }
}