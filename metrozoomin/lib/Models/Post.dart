import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String username;
  final String station;
  final String content;
  final String imageUrl;
  final int likes;
  final Timestamp time;

  Post({
    required this.username,
    required this.station,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.time,
  });

  factory Post.fromMap(Map<String, dynamic> data, {required String id}) {
    return Post(
      username: data['username'] ?? 'Unknown User',
      station: data['station'] ?? 'Random Station',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      likes: data['likes'] ?? 0,
      time: data['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'station': station,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'time': time,
    };
  }
}