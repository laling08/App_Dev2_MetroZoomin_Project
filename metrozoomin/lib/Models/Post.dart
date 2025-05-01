import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String username;
  final String station;
  final String content;
  final String imageUrl;
  final int likes;
  final Timestamp time;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.username,
    required this.station,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.time,
    this.likedBy = const [],
  });

  factory Post.fromMap(Map<String, dynamic> data, {required String id}) {
    return Post(
      id: data['id'],
      username: data['username'] ?? 'Unknown User',
      station: data['station'] ?? 'Random Station',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      likes: data['likes'] ?? 0,
      time: data['time'],
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'station': station,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'time': time,
      'likedBy': likedBy,
    };
  }

  Post copyWith({
    String? id,
    String? username,
    String? station,
    String? content,
    String? imageUrl,
    int? likes,
    Timestamp? time,
    List<String>? likedBy,
  }) {
    return Post(
      id: id ?? this.id,
      username: username ?? this.username,
      station: station ?? this.station,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      time: time ?? this.time,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}