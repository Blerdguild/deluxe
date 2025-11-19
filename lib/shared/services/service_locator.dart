import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/core/firebase/firestore_service.dart';
import 'package:deluxe/core/firebase/cloud_functions_service.dart';
import 'package:deluxe/features/consumer/data/datasources/consumer_order_datasource.dart';
import 'package:deluxe/features/consumer/data/repositories/consumer_order_repository_impl.dart';
import 'package:deluxe/features/consumer/domain/repositories/consumer_order_repository.dart';
import 'package:deluxe/features/consumer/presentation/bloc/consumer_order_bloc.dart';
import 'package:deluxe/features/dashboard/bloc/dispensary_bloc.dart';
import 'package:deluxe/features/dashboard/bloc/product_bloc.dart';
import 'package:deluxe/features/dispensary/presentation/bloc/order_creation_bloc.dart';
import 'package:deluxe/features/farmer/data/datasources/farmer_order_datasource.dart';
import 'package:deluxe/features/farmer/data/datasources/harvest_datasource.dart';
import 'package:deluxe/features/farmer/data/repositories/farmer_order_repository_impl.dart';
import 'package:deluxe/features/farmer/data/repositories/harvest_repository_impl.dart';
import 'package:deluxe/features/farmer/domain/repositories/farmer_order_repository.dart';
import 'package:deluxe/features/farmer/domain/repositories/harvest_repository.dart';
import 'package:deluxe/features/farmer/presentation/bloc/farmer_order_bloc.dart';
import 'package:deluxe/features/farmer/presentation/bloc/harvest_bloc.dart';
import 'package:deluxe/features/farmer/presentation/bloc/farmer_inventory_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/core/repositories/product_repository.dart';
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // --- Core External Services ---
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // --- App Services ---
  sl.registerLazySingleton(() => AuthService(
        firebaseAuth: sl<FirebaseAuth>(),
        googleSignIn: sl<GoogleSignIn>(),
      ));
  sl.registerLazySingleton(() => FirestoreService(
        firestore: sl<FirebaseFirestore>(),
      ));
  sl.registerLazySingleton(() => CloudFunctionsService());

  // --- Data Sources ---
  sl.registerLazySingleton<HarvestDataSource>(() => HarvestLocalDataSource());
  sl.registerLazySingleton<FarmerOrderDataSource>(
      () => FarmerOrderLocalDataSource());
  sl.registerLazySingleton<ConsumerOrderDataSource>(
      () => ConsumerOrderLocalDataSource());

  // --- Repositories ---
  sl.registerLazySingleton<HarvestRepository>(
      () => HarvestRepositoryImpl(sl<HarvestDataSource>()));
  sl.registerLazySingleton<FarmerOrderRepository>(
      () => FarmerOrderRepositoryImpl(
            firestore: sl<FirebaseFirestore>(),
            authService: sl<AuthService>(),
          ));
  sl.registerLazySingleton<ConsumerOrderRepository>(
      () => ConsumerOrderRepositoryImpl(
            firestore: sl<FirebaseFirestore>(),
            authService: sl<AuthService>(),
          ));
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(firestore: sl<FirebaseFirestore>()));

  // --- BLoCs ---
  sl.registerFactory(
    () => AuthBloc(
      authService: sl<AuthService>(),
      firestoreService: sl<FirestoreService>(),
      cloudFunctionsService: sl<CloudFunctionsService>(),
    ),
  );
  sl.registerFactory(
    () => DispensaryBloc(
      firestoreService: sl<FirestoreService>(),
    ),
  );
  sl.registerFactory(
    () => ProductBloc(
      productRepository: sl<ProductRepository>(),
    ),
  );
  sl.registerFactory(
    () => HarvestBloc(
      harvestRepository: sl<HarvestRepository>(),
      productRepository: sl<ProductRepository>(),
      authService: sl<AuthService>(),
      cloudFunctionsService: sl<CloudFunctionsService>(),
    ),
  );
  sl.registerFactory(
    () => FarmerInventoryBloc(
      productRepository: sl<ProductRepository>(),
      authService: sl<AuthService>(),
      cloudFunctionsService: sl<CloudFunctionsService>(),
    ),
  );
}
