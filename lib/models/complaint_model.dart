class ComplaintModel {
  final String id;
  final String citizenId;
  final String citizenName;
  final String category;
  final String description;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final String address;
  final String status; // submitted, verified, assigned, inProgress, resolved, rejected, closed
  final String priority; // LOW, MEDIUM, HIGH, CRITICAL
  final String? departmentId;
  final String? departmentName;
  final String? officerId;
  final String? officerName;
  final int supportCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final List<String> resolutionImageUrls;
  final String? resolutionNotes;

  ComplaintModel({
    required this.id,
    required this.citizenId,
    required this.citizenName,
    required this.category,
    required this.description,
    this.imageUrls = const [],
    required this.latitude,
    required this.longitude,
    required this.address,
    this.status = 'submitted',
    this.priority = 'MEDIUM',
    this.departmentId,
    this.departmentName,
    this.officerId,
    this.officerName,
    this.supportCount = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.resolvedAt,
    this.resolutionImageUrls = const [],
    this.resolutionNotes,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ComplaintModel copyWith({
    String? id,
    String? citizenId,
    String? citizenName,
    String? category,
    String? description,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    String? address,
    String? status,
    String? priority,
    String? departmentId,
    String? departmentName,
    String? officerId,
    String? officerName,
    int? supportCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    List<String>? resolutionImageUrls,
    String? resolutionNotes,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      citizenId: citizenId ?? this.citizenId,
      citizenName: citizenName ?? this.citizenName,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      officerId: officerId ?? this.officerId,
      officerName: officerName ?? this.officerName,
      supportCount: supportCount ?? this.supportCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionImageUrls: resolutionImageUrls ?? this.resolutionImageUrls,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'citizenId': citizenId,
      'citizenName': citizenName,
      'category': category,
      'description': description,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': status,
      'priority': priority,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'officerId': officerId,
      'officerName': officerName,
      'supportCount': supportCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolutionImageUrls': resolutionImageUrls,
      'resolutionNotes': resolutionNotes,
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ComplaintModel(
      id: id ?? map['id'] as String? ?? '',
      citizenId: map['citizenId'] as String? ?? '',
      citizenName: map['citizenName'] as String? ?? 'Citizen',
      category: map['category'] as String? ?? 'Other',
      description: map['description'] as String? ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? 'Location unavailable',
      status: map['status'] as String? ?? 'submitted',
      priority: map['priority'] as String? ?? 'MEDIUM',
      departmentId: map['departmentId'] as String?,
      departmentName: map['departmentName'] as String?,
      officerId: map['officerId'] as String?,
      officerName: map['officerName'] as String?,
      supportCount: (map['supportCount'] as num?)?.toInt() ?? 1,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.tryParse(map['resolvedAt'].toString())
          : null,
      resolutionImageUrls: List<String>.from(map['resolutionImageUrls'] ?? []),
      resolutionNotes: map['resolutionNotes'] as String?,
    );
  }
}
