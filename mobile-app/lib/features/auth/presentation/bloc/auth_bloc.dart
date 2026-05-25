import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource _dataSource;

  AuthBloc(this._dataSource) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _dataSource.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _dataSource.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _dataSource.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final user = await _dataSource.getMe();
        emit(AuthAuthenticated(user));
      } catch (_) {
        // Token might be expired, getMe failed
        final role = await _dataSource.getSavedRole();
        final name = await _dataSource.getSavedUserName();
        emit(AuthAuthenticated(
          UserModel(
            id: '',
            name: name ?? '',
            email: '',
            role: role ?? '',
          ),
        ));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
