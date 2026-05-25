abstract class MessageEvent {}

class LoadConversation extends MessageEvent {
  final String userId;
  LoadConversation(this.userId);
}

class SendMessage extends MessageEvent {
  final String receiverId;
  final String content;
  SendMessage({required this.receiverId, required this.content});
}
