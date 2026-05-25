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

  // Future<void> _onLoginRequested(
  //   LoginRequested event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   try {
  //     final user = await _dataSource.login(event.email, event.password);
  //     emit(AuthAuthenticated(user));
  //   } catch (e) {
  //     emit(AuthError(e.toString().replaceAll('Exception: ', '')));
  //   }
  // }
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TEMPORARY: test login bypass
      if (event.email == 'zaferan.miftah@astu.edu.et' &&
          event.password == '123456') {
        final user = UserModel(
          id: '1',
          name: 'Zaferan Miftah',
          email: 'zaferan.miftah@astu.edu.et',
          role: 'student',
          token: 'test_token',
        );
        await _dataSource.saveToken('test_token');
        await _dataSource.saveUser(user);
        emit(AuthAuthenticated(user));
        return;
      }
      // TEMPORARY: teacher test login  ← ADD THIS BLOCK
      if (event.email == 'teacher.test@astu.edu.et' &&
          event.password == '123456') {
        final user = UserModel(
          id: '2',
          name: 'Ahmed Ibrahim',
          email: 'teacher.test@astu.edu.et',
          role: 'teacher',
          token: 'test_token_teacher',
        );
        await _dataSource.saveToken('test_token_teacher');
        await _dataSource.saveUser(user);
        emit(AuthAuthenticated(user));
        return;
      }
      // Real API login
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
    await _dataSource.clearToken();
    emit(AuthUnauthenticated());
  }

  // Future<void> _onCheckAuthStatus(
  //   CheckAuthStatus event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   final token = await _dataSource.getToken();
  //   if (token != null && token.isNotEmpty) {
  //     final role = await _dataSource.getSavedRole();
  //     emit(AuthAuthenticated(
  //       UserModel(
  //         id: '',
  //         name: '',
  //         email: '',
  //         role: role ?? '',
  //       ),
  //     ));
  //   } else {
  //     emit(AuthUnauthenticated());
  //   }
  // }
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _dataSource.getToken();
    if (token != null && token.isNotEmpty) {
      final role = await _dataSource.getSavedRole();
      emit(AuthAuthenticated(
        UserModel(
          id: '1',
          name: 'Zaferan Miftah',
          email: 'zaferan.miftah@astu.edu.et',
          role: role ?? 'student',
        ),
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}