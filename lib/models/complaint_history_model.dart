class ComplaintHistoryModel {
  final String id;
  final String complaintId;
  final String status;
  final String changedBy;
  final String message;
  final DateTime timestamp;

  ComplaintHistoryModel({
    required this.id,
    required this.complaintId,
    required this.status,
    required this.changedBy,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'complaintId': complaintId,
      'status': status,
      'changedBy': changedBy,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ComplaintHistoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ComplaintHistoryModel(
      id: id ?? map['id'] as String? ?? '',
      complaintId: map['complaintId'] as String? ?? '',
      status: map['status'] as String? ?? '',
      changedBy: map['changedBy'] as String? ?? 'System',
      message: map['message'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
