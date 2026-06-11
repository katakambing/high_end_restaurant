import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/menu_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import 'booking_confirmation.dart';

class BookingPage extends StatefulWidget {
  final MenuModel menu;

  const BookingPage({super.key, required this.menu});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int numGuests = 0;

  static const double serviceChargePercent = 10.0; // 10% service charge
  static const double basePricePerGuest = 0; // overridden by menu price

  double get baseTotal => widget.menu.price * numGuests;
  double get serviceCharge => baseTotal * (serviceChargePercent / 100);
  double get grandTotal => baseTotal + serviceCharge;

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (selectedDate == null || selectedTime == null || numGuests < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please fill in all fields and select at least 1 guest"),
        ),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
    final timeStr =
        "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    final booking = BookingModel(
      id: '',
      userId: user.uid,
      menuId: widget.menu.id,
      menuName: widget.menu.name,
      eventDate: dateStr,
      eventTime: timeStr,
      numGuests: numGuests,
      totalPrice: grandTotal,
      status: 'pending',
    );

    await BookingService.createBooking(booking);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationPage(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Event")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PACKAGE INFO CARD
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.menu.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.menu.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "RM ${widget.menu.price.toStringAsFixed(2)} / guest",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // EVENT DATE
            ListTile(
              title: const Text("Event Date"),
              subtitle: Text(
                selectedDate != null
                    ? DateFormat('dd MMM yyyy').format(selectedDate!)
                    : "Select date",
              ),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: pickDate,
            ),

            const SizedBox(height: 12),

            // EVENT TIME
            ListTile(
              title: const Text("Event Time"),
              subtitle: Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : "Select time",
              ),
              trailing: const Icon(Icons.access_time),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: pickTime,
            ),

            const SizedBox(height: 20),

            // NUMBER OF GUESTS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Number of Guests: ",
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (numGuests > 0) {
                      setState(() => numGuests--);
                    }
                  },
                ),
                Text(
                  "$numGuests",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() => numGuests++);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // PRICE BREAKDOWN
            Card(
              color: Colors.grey.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _priceRow(
                      "Base Price",
                      "RM ${widget.menu.price.toStringAsFixed(2)} x $numGuests guests",
                    ),
                    _priceRow(
                      "Subtotal",
                      "RM ${baseTotal.toStringAsFixed(2)}",
                    ),
                    _priceRow(
                      "Service Charge (${serviceChargePercent.toStringAsFixed(0)}%)",
                      "RM ${serviceCharge.toStringAsFixed(2)}",
                    ),
                    const Divider(thickness: 2),
                    _priceRow(
                      "Grand Total",
                      "RM ${grandTotal.toStringAsFixed(2)}",
                      isBold: true,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // CONFIRM BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: confirmBooking,
                icon: const Icon(Icons.check_circle),
                label: const Text("Confirm Booking"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
