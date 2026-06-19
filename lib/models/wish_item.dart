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

  WishItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
    this.status = WishStatus.pending,
    this.imageUrl,
    this.desireLevel = DesireLevel.medium,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'status': status.index,
      'imageUrl': imageUrl,
      'desireLevel': desireLevel.index,
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
  }) {
    return WishItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      desireLevel: desireLevel ?? this.desireLevel,
    );
  }
}
