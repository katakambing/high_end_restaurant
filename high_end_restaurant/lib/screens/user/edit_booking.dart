import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/menu_model.dart';
import '../../services/booking_service.dart';
import '../../services/menu_service.dart';

class EditBookingPage extends StatefulWidget {
  final BookingModel booking;
  const EditBookingPage({super.key, required this.booking});

  @override
  State<EditBookingPage> createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  late DateTime selectedDate;
  TimeOfDay selectedTime = const TimeOfDay(hour: 12, minute: 0);
  int guests = 0;

  List<MenuModel> menus = [];
  MenuModel? selectedMenu;

  static const double serviceChargePercent = 10.0;

  double get baseTotal => (selectedMenu?.price ?? 0) * guests;
  double get serviceCharge => baseTotal * (serviceChargePercent / 100);
  double get grandTotal => baseTotal + serviceCharge;

  @override
  void initState() {
    super.initState();

    selectedDate = DateTime.parse(widget.booking.eventDate);
    guests = widget.booking.numGuests;

    final timeParts = widget.booking.eventTime.split(":");
    if (timeParts.length >= 2) {
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    loadMenus();
  }

  Future<void> loadMenus() async {
    final menuService = MenuService();
    final data = await menuService.getMenus();

    setState(() {
      menus = data;
      selectedMenu = data.firstWhere(
        (m) => m.id == widget.booking.menuId,
        orElse: () => data.first,
      );
    });
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> updateBooking() async {
    if (selectedMenu == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final timeStr =
        "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}";

    final updatedBooking = BookingModel(
      id: widget.booking.id,
      userId: widget.booking.userId,
      menuId: selectedMenu!.id,
      menuName: selectedMenu!.name,
      eventDate: dateStr,
      eventTime: timeStr,
      numGuests: guests,
      totalPrice: grandTotal,
      status: 'pending',
    );

    await BookingService.updateBooking(updatedBooking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reservation updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Reservation")),
      body: menus.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MENU PACKAGE SELECTOR
                  const Text(
                    "Menu Package",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<MenuModel>(
                        isExpanded: true,
                        value: selectedMenu,
                        items: menus.map((menu) {
                          return DropdownMenuItem<MenuModel>(
                            value: menu,
                            child: Text(
                              "${menu.name} - RM ${menu.price.toStringAsFixed(2)}/guest",
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedMenu = value);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DATE PICKER
                  ListTile(
                    title: const Text("Event Date"),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onTap: pickDate,
                  ),

                  const SizedBox(height: 12),

                  // TIME PICKER
                  ListTile(
                    title: const Text("Event Time"),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onTap: pickTime,
                  ),

                  const SizedBox(height: 20),

                  // GUEST COUNTER
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
                          if (guests > 1) {
                            setState(() => guests--);
                          }
                        },
                      ),
                      Text(
                        "$guests",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => guests++);
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
                            "RM ${(selectedMenu?.price ?? 0).toStringAsFixed(2)} x $guests guests",
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

                  const SizedBox(height: 30),

                  // SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: updateBooking,
                      icon: const Icon(Icons.save),
                      label: const Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
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
