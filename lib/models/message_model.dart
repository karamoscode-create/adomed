enum MessageType {
  text,
  image,
  audio,
  video,
  file,
  location,
  consultation
}

enum MessageStatus {
  sent,
  delivered,
  read,
  failed
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String receiverName;
  final String senderImage;
  final String receiverImage;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? mediaThumbnail;
  final int? mediaDuration;
  final String? replyToId;
  final Map<String, dynamic>? metadata;
  final bool isDeleted;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    this.senderImage = '',
    this.receiverImage = '',
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.mediaUrl,
    this.mediaThumbnail,
    this.mediaDuration,
    this.replyToId,
    this.metadata,
    this.isDeleted = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      senderName: json['senderName'] ?? '',
      receiverName: json['receiverName'] ?? '',
      senderImage: json['senderImage'] ?? '',
      receiverImage: json['receiverImage'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      mediaUrl: json['mediaUrl'],
      mediaThumbnail: json['mediaThumbnail'],
      mediaDuration: json['mediaDuration'],
      replyToId: json['replyToId'],
      metadata: json['metadata'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'receiverName': receiverName,
      'senderImage': senderImage,
      'receiverImage': receiverImage,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'mediaUrl': mediaUrl,
      'mediaThumbnail': mediaThumbnail,
      'mediaDuration': mediaDuration,
      'replyToId': replyToId,
      'metadata': metadata,
      'isDeleted': isDeleted,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? senderName,
    String? receiverName,
    String? senderImage,
    String? receiverImage,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? mediaUrl,
    String? mediaThumbnail,
    int? mediaDuration,
    String? replyToId,
    Map<String, dynamic>? metadata,
    bool? isDeleted,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      senderImage: senderImage ?? this.senderImage,
      receiverImage: receiverImage ?? this.receiverImage,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaThumbnail: mediaThumbnail ?? this.mediaThumbnail,
      mediaDuration: mediaDuration ?? this.mediaDuration,
      replyToId: replyToId ?? this.replyToId,
      metadata: metadata ?? this.metadata,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool get isText => type == MessageType.text;
  bool get isMedia => type != MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isAudio => type == MessageType.audio;
  bool get isVideo => type == MessageType.video;
  bool get isFile => type == MessageType.file;
  bool get isLocation => type == MessageType.location;
  bool get isConsultation => type == MessageType.consultation;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
    }
  }
}


