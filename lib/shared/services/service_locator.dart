// C:/dev/flutter_projects/deluxe/lib/shared/services/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Register services, blocs, etc.
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc());
  print("Service locator setup called.");
}
