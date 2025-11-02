import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp; 
  final int durationInSeconds; 

  const Session({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.durationInSeconds,
  });

  @override
  List<Object?> get props => [id, userId, timestamp, durationInSeconds];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp), 
      'durationInSeconds': durationInSeconds,
    };
  }

  factory Session.fromJson(Map<String, dynamic> map) {
    return Session(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationInSeconds: map['durationInSeconds'] ?? 0,
    );
  }
}