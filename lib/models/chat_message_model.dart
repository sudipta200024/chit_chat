class ChatMessageModel {
  ChatMessageModel({
    required this.msg,
    required this.toId,
    required this.read,
    required this.type,
    required this.sent,
    required this.fromId,
  });
  late final String msg;
  late final String toId;
  late final String read;
  late final String type;
  late final String sent;
  late final String fromId;

  ChatMessageModel.fromJson(Map<String, dynamic> json){
    msg = json['msg'];
    toId = json['toId'];
    read = json['read'];
    type = json['type'];
    sent = json['sent'];
    fromId = json['fromId'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['msg'] = msg;
    _data['toId'] = toId;
    _data['read'] = read;
    _data['type'] = type;
    _data['sent'] = sent;
    _data['fromId'] = fromId;
    return _data;
  }
}