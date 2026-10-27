import 'dart:convert';

enum WishStatus { pending, bought, passed }
enum DesireLevel { low, medium, high }

class WishItem {
  final String id;
  final String title;
  final double amount;
  final DateTime createdAt;
  final WishStatus status;
  final String? imageUrl;
  final DesireLevel desireLevel;
  final int lockDurationHours;
  final double? workHoursEquivalent;
  final String? category;

  WishItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
    this.status = WishStatus.pending,
    this.imageUrl,
    this.desireLevel = DesireLevel.medium,
    this.lockDurationHours = 48,
    this.workHoursEquivalent,
    this.category,
  });

  /// The exact moment this item's cooling timer expires
  DateTime get unlockAt => createdAt.add(Duration(hours: lockDurationHours));

  /// Whether the cooling period has finished
  bool get isUnlocked => DateTime.now().isAfter(unlockAt);

  /// Time remaining in the cooling-off queue
  Duration get remainingTime {
    if (isUnlocked) return Duration.zero;
    return unlockAt.difference(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'status': status.index,
      'imageUrl': imageUrl,
      'desireLevel': desireLevel.index,
      'lockDurationHours': lockDurationHours,
      'workHoursEquivalent': workHoursEquivalent,
      'category': category,
    };
  }

  factory WishItem.fromMap(Map<String, dynamic> map) {
    return WishItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      status: map['status'] != null ? WishStatus.values[map['status']] : WishStatus.pending,
      imageUrl: map['imageUrl'],
      desireLevel: map['desireLevel'] != null ? DesireLevel.values[map['desireLevel']] : DesireLevel.medium,
      lockDurationHours: map['lockDurationHours'] ?? 48,
      workHoursEquivalent: map['workHoursEquivalent'] != null ? (map['workHoursEquivalent'] as num).toDouble() : null,
      category: map['category'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WishItem.fromJson(String source) =>
      WishItem.fromMap(json.decode(source));

  WishItem copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? createdAt,
    WishStatus? status,
    String? imageUrl,
    DesireLevel? desireLevel,
    int? lockDurationHours,
    double? workHoursEquivalent,
    String? category,
  }) {
    return WishItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      desireLevel: desireLevel ?? this.desireLevel,
      lockDurationHours: lockDurationHours ?? this.lockDurationHours,
      workHoursEquivalent: workHoursEquivalent ?? this.workHoursEquivalent,
      category: category ?? this.category,
    );
  }
}
