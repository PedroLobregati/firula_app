
class NotificationModel{
  String content, forMatchId, notId, senderId, spId, username;

  NotificationModel({required this.content, required this.forMatchId, required this.notId, required this.senderId, required this.spId, required this.username});

  factory NotificationModel.fromMap(Map<dynamic, dynamic> map) {
    return NotificationModel(
      content: map['content'],
      forMatchId: map['forMatchId'],
      notId: map['notId'],
      senderId: map['senderId'],
      spId: map['spId'],
      username: map['username']
    );
  }
}