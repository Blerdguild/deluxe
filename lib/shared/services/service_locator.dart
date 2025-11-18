import 'package:deluxe/core/firebase/firestore_service.dart';
import 'package:deluxe/features/dashboard/bloc/dispensary_bloc.dart';
import 'package:deluxe/features/dashboard/bloc/product_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Services
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => FirestoreService());

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      authService: sl<AuthService>(),
      firestoreService: sl<FirestoreService>(),
    ),
  );
  sl.registerFactory(
    () => DispensaryBloc(
      firestoreService: sl<FirestoreService>(),
    ),
  );
  sl.registerFactory(
    () => ProductBloc(
      firestoreService: sl<FirestoreService>(),
    ),
  );
}
