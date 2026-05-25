import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/courses/data/repositories/course_repository.dart';
import '../features/courses/presentation/bloc/course_bloc.dart';
import '../features/announcements/data/repositories/announcement_repository.dart';
import '../features/announcements/presentation/bloc/announcement_bloc.dart';
import '../features/assignments/data/repositories/assignment_repository.dart';
import '../features/assignments/presentation/bloc/assignment_bloc.dart';
import '../features/files/data/repositories/file_repository.dart';
import '../features/files/presentation/bloc/file_bloc.dart';
import '../features/forum/data/repositories/forum_repository.dart';
import '../features/forum/presentation/bloc/forum_bloc.dart';
import '../features/messaging/data/repositories/message_repository.dart';
import '../features/messaging/presentation/bloc/message_bloc.dart';
import '../features/notifications/data/repositories/notification_repository.dart';
import '../features/notifications/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Repositories
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepository(sl()),
  );
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepository(sl()),
  );
  sl.registerLazySingleton<AssignmentRepository>(
    () => AssignmentRepository(sl()),
  );
  sl.registerLazySingleton<FileRepository>(
    () => FileRepository(sl()),
  );
  sl.registerLazySingleton<ForumRepository>(
    () => ForumRepository(sl()),
  );
  sl.registerLazySingleton<MessageRepository>(
    () => MessageRepository(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(sl()),
  );

  // BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl()),
  );
  sl.registerFactory<CourseBloc>(
    () => CourseBloc(sl()),
  );
  sl.registerFactory<AnnouncementBloc>(
    () => AnnouncementBloc(sl()),
  );
  sl.registerFactory<AssignmentBloc>(
    () => AssignmentBloc(sl()),
  );
  sl.registerFactory<FileBloc>(
    () => FileBloc(sl()),
  );
  sl.registerFactory<ForumBloc>(
    () => ForumBloc(sl()),
  );
  sl.registerFactory<MessageBloc>(
    () => MessageBloc(sl()),
  );
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(sl()),
  );
}
