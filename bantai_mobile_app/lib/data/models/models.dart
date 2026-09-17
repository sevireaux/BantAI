class ApiUser {
  final String id;
  final String name;
  final String email;
  final String role; // citizen | barangay_admin | lgu_official | lgu_admin | system_admin
  final String? lguId;
  final String? barangayId;

  ApiUser({required this.id, required this.name, required this.email, required this.role, this.lguId, this.barangayId});

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        lguId: json['lgu_id'] as String?,
        barangayId: json['barangay_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'lgu_id': lguId,
        'barangay_id': barangayId,
      };

  bool get isCitizen => role == 'citizen';
  bool get isBarangayAdmin => role == 'barangay_admin';
  bool get isLguStaff => role == 'lgu_official' || role == 'lgu_admin';
}

class Subcategory {
  final String id;
  final String name;
  Subcategory({required this.id, required this.name});
  factory Subcategory.fromJson(Map<String, dynamic> json) => Subcategory(id: json['id'], name: json['name']);
}

class ApiCategory {
  final String id;
  final String name;
  final List<Subcategory> subcategories;
  ApiCategory({required this.id, required this.name, required this.subcategories});

  factory ApiCategory.fromJson(Map<String, dynamic> json) => ApiCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        subcategories: (json['subcategories'] as List? ?? [])
            .map((e) => Subcategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PublicLgu {
  final String id;
  final String name;
  PublicLgu({required this.id, required this.name});
  factory PublicLgu.fromJson(Map<String, dynamic> json) => PublicLgu(id: json['id'], name: json['name']);
}

class PublicBarangay {
  final String id;
  final String name;
  PublicBarangay({required this.id, required this.name});
  factory PublicBarangay.fromJson(Map<String, dynamic> json) => PublicBarangay(id: json['id'], name: json['name']);
}

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime date;
  final bool read;
  final String? reportId;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.read,
    this.reportId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        date: DateTime.parse(json['created_at'] as String? ?? json['date'] as String),
        read: json['read'] as bool? ?? false,
        reportId: json['report_id'] as String?,
      );
}
