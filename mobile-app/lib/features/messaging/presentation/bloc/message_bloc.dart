import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/message_repository.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository _repository;

  MessageBloc(this._repository) : super(MessageInitial()) {
    on<LoadConversation>(_onLoadConversation);
    on<SendMessage>(_onSend);
  }

  Future<void> _onLoadConversation(LoadConversation event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    try {
      final messages = await _repository.getConversation(event.userId);
      emit(MessageLoaded(messages, conversationUserId: event.userId));
    } catch (e) {
      emit(MessageError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSend(SendMessage event, Emitter<MessageState> emit) async {
    try {
      final sentMessage = await _repository.sendMessage(event.receiverId, event.content);
      if (state is MessageLoaded) {
        final current = (state as MessageLoaded).messages;
        emit(MessageLoaded([...current, sentMessage], conversationUserId: (state as MessageLoaded).conversationUserId));
      }
    } catch (e) {
      emit(MessageError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
