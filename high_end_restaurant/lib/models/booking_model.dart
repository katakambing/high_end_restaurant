class BookingModel {
  final String id;
  final String userId;
  final String menuId;
  final String menuName;
  final String eventDate;
  final String eventTime;
  final int numGuests;
  final double totalPrice;
  final String status;

  BookingModel({
    required this.id,
    required this.userId,
    required this.menuId,
    required this.menuName,
    required this.eventDate,
    required this.eventTime,
    required this.numGuests,
    required this.totalPrice,
    required this.status,
  });

  factory BookingModel.fromMap(String id, Map<String, dynamic> data) {
    return BookingModel(
      id: id,
      userId: data['userId'] ?? '',
      menuId: data['menuId'] ?? '',
      menuName: data['menuName'] ?? '',
      eventDate: data['eventDate'] ?? '',
      eventTime: data['eventTime'] ?? '',
      numGuests: data['numGuests'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'menuId': menuId,
      'menuName': menuName,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'numGuests': numGuests,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}