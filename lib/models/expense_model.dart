// Data model representing a single expense record from Firebase.
class ExpenseModel {
  final String expenseId;
  final String projectCode;
  final String paymentStatus;
  final String expenseType;
  final String paymentMethod;
  final String currency;
  final String expenseDate;
  final String location;
  final String claimant;
  final String description;
  final double amount;
  final int updatedAt;

  const ExpenseModel({
    required this.expenseId,
    required this.projectCode,
    required this.paymentStatus,
    required this.expenseType,
    required this.paymentMethod,
    required this.currency,
    required this.expenseDate,
    required this.location,
    required this.claimant,
    required this.description,
    required this.amount,
    required this.updatedAt,
  });

  // Creates an ExpenseModel from a Firebase map with a fallback ID.
  factory ExpenseModel.fromMap(
    Map<dynamic, dynamic> map,
    String fallbackId,
  ) {
    return ExpenseModel(
      expenseId: (map['expenseId'] ?? fallbackId).toString(),
      projectCode: (map['projectCode'] ?? '').toString(),
      paymentStatus: (map['paymentStatus'] ?? 'Pending').toString(),
      expenseType: (map['expenseType'] ?? map['category'] ?? '').toString(),
      paymentMethod: (map['paymentMethod'] ?? '').toString(),
      currency: (map['currency'] ?? 'USD').toString(),
      expenseDate: (map['expenseDate'] ?? map['date'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      claimant: (map['claimant'] ?? map['claimantName'] ?? map['owner'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      amount: _parseAmount(map['amount']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  // Safely parses a dynamic value into an int timestamp.
  static int _parseTimestamp(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  // Safely parses a dynamic value into a double amount.
  static double _parseAmount(dynamic value) {
    // Return directly if the value is already a number.
    if (value is num) {
      return value.toDouble();
    }

    // Convert to string and try to parse.
    String text = (value ?? '').toString().trim();
    if (text.isEmpty) {
      return 0;
    }

    // Remove non-numeric characters except digits, dot, and minus.
    String sanitized = text.replaceAll(RegExp(r'[^0-9.-]'), '');
    double parsed = double.tryParse(sanitized) ?? 0;
    return parsed;
  }
}
