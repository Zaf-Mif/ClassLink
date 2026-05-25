import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

abstract class MessageState extends Equatable {
  const MessageState();
  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<MessageModel> messages;
  final String? conversationUserId;
  const MessageLoaded(this.messages, {this.conversationUserId});
  @override
  List<Object?> get props => [messages, conversationUserId];
}

class MessageError extends MessageState {
  final String message;
  const MessageError(this.message);
  @override
  List<Object?> get props => [message];
}
