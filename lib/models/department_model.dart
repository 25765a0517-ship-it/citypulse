class DepartmentModel {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int officerCount;
  final int activeComplaints;
  final int resolvedComplaints;
  final DateTime createdAt;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconName = 'business',
    this.officerCount = 0,
    this.activeComplaints = 0,
    this.resolvedComplaints = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'officerCount': officerCount,
      'activeComplaints': activeComplaints,
      'resolvedComplaints': resolvedComplaints,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DepartmentModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return DepartmentModel(
      id: id ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'business',
      officerCount: (map['officerCount'] as num?)?.toInt() ?? 0,
      activeComplaints: (map['activeComplaints'] as num?)?.toInt() ?? 0,
      resolvedComplaints: (map['resolvedComplaints'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
