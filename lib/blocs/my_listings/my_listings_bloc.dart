import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/listing_service.dart';
import '../listing/listing_event.dart';
import '../listing/listing_state.dart';

class LoadMyListingsRequested extends ListingEvent {
  final String uid;
  const LoadMyListingsRequested(this.uid);
  @override
  List<Object?> get props => [uid];
}

class MyListingsBloc extends Bloc<ListingEvent, ListingState> {
  final ListingService _listingService;
  StreamSubscription? _listingsSubscription;

  MyListingsBloc({required ListingService listingService})
      : _listingService = listingService,
        super(const ListingState()) {
    on<LoadMyListingsRequested>(_onLoadMyListingsRequested);
    on<ListingsUpdated>(_onListingsUpdated);
  }

  Future<void> _onLoadMyListingsRequested(
    LoadMyListingsRequested event,
    Emitter<ListingState> emit,
  ) async {
    emit(ListingState(status: ListingStatus.loading, listings: state.listings));
    _listingsSubscription?.cancel();
    _listingsSubscription = _listingService.getMyListingsStream(event.uid).listen(
      (listings) => add(ListingsUpdated(listings)),
      onError: (error) => emit(ListingState(
        status: ListingStatus.error,
        listings: state.listings,
        errorMessage: error.toString(),
      )),
    );
  }

  void _onListingsUpdated(
    ListingsUpdated event,
    Emitter<ListingState> emit,
  ) {
    emit(ListingState(status: ListingStatus.loaded, listings: event.listings));
  }

  @override
  Future<void> close() {
    _listingsSubscription?.cancel();
    return super.close();
  }
}
