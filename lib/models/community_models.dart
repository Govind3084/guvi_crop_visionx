import 'dart:convert';

class CommunityPost {
  final String id;
  final String authorName;
  final String content;
  final String? imagePath;
  final int timestamp;
  final String category;
  final int likes;
  final int comments;
  final String commentList;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.content,
    this.imagePath,
    required this.timestamp,
    required this.category,
    this.likes = 0,
    this.comments = 0,
    this.commentList = '[]',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'content': content,
      'imagePath': imagePath,
      'timestamp': timestamp,
      'category': category,
      'likes': likes,
      'comments': comments,
      'commentList': commentList,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'] ?? '',
      authorName: map['authorName'] ?? 'Current User',
      content: map['content'] ?? '',
      imagePath: map['imagePath'],
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      category: map['category'] ?? '',
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      commentList: map['commentList'] ?? '[]',
    );
  }
}

class Comment {
  final String id;
  final String authorName;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      authorName: map['authorName'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
   