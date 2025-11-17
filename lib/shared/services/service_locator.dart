// C:/dev/flutter_projects/deluxe/lib/shared/services/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Services
  sl.registerLazySingleton(() => AuthService());

  // BLoCs
  sl.registerFactory(() => AuthBloc(authService: sl<AuthService>()));
}
