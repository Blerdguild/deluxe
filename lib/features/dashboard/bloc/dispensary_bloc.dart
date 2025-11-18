import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deluxe/core/firebase/firestore_service.dart';
import 'package:deluxe/shared/models/dispensary_model.dart';
import 'package:equatable/equatable.dart';

part 'dispensary_event.dart';
part 'dispensary_state.dart';

class DispensaryBloc extends Bloc<DispensaryEvent, DispensaryState> {
  final FirestoreService _firestoreService;
  StreamSubscription? _dispensarySubscription;

  DispensaryBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(DispensaryInitial()) {
    on<LoadDispensaries>(_onLoadDispensaries);
    on<DispensaryUpdate>(_onDispensaryUpdate);
    on<_DispensariesUpdateFailed>(_onDispensariesUpdateFailed);
  }

  void _onLoadDispensaries(
    LoadDispensaries event,
    Emitter<DispensaryState> emit,
  ) {
    emit(DispensaryLoading());
    _dispensarySubscription?.cancel();
    _dispensarySubscription = _firestoreService.getDispensaries().listen(
          (dispensaries) => add(DispensaryUpdate(dispensaries: dispensaries)),
          onError: (error) =>
              add(_DispensariesUpdateFailed(message: error.toString())),
        );
  }

  void _onDispensaryUpdate(
    DispensaryUpdate event,
    Emitter<DispensaryState> emit,
  ) {
    emit(DispensaryLoaded(dispensaries: event.dispensaries));
  }

  void _onDispensariesUpdateFailed(
    _DispensariesUpdateFailed event,
    Emitter<DispensaryState> emit,
  ) {
    emit(DispensaryError(message: event.message));
  }

  @override
  Future<void> close() {
    _dispensarySubscription?.cancel();
    return super.close();
  }
}

class DispensaryUpdate extends DispensaryEvent {
  final List<Dispensary> dispensaries;

  const DispensaryUpdate({required this.dispensaries});

  @override
  List<Object> get props => [dispensaries];
}

class _DispensariesUpdateFailed extends DispensaryEvent {
  final String message;

  const _DispensariesUpdateFailed({required this.message});

  @override
  List<Object> get props => [message];
}
