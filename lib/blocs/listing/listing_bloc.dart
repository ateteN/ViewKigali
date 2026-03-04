import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/listing_service.dart';
import 'listing_event.dart';
import 'listing_state.dart';

class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final ListingService _listingService;
  StreamSubscription? _listingsSubscription;

  ListingBloc({required ListingService listingService})
      : _listingService = listingService,
        super(const ListingState()) {
    on<LoadListingsRequested>(_onLoadListingsRequested);
    on<ListingsUpdated>(_onListingsUpdated);
    on<CreateListingRequested>(_onCreateListingRequested);
    on<UpdateListingRequested>(_onUpdateListingRequested);
    on<DeleteListingRequested>(_onDeleteListingRequested);
  }

  Future<void> _onLoadListingsRequested(
    LoadListingsRequested event,
    Emitter<ListingState> emit,
  ) async {
    emit(ListingState(status: ListingStatus.loading, listings: state.listings));
    _listingsSubscription?.cancel();
    _listingsSubscription = _listingService.getListingsStream().listen(
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

  Future<void> _onCreateListingRequested(
    CreateListingRequested event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingService.createListing(event.listing);
      emit(ListingState(status: ListingStatus.success, listings: state.listings));
      // Reset to loaded after success
      emit(ListingState(status: ListingStatus.loaded, listings: state.listings));
    } catch (e) {
      emit(ListingState(
        status: ListingStatus.error,
        listings: state.listings,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateListingRequested(
    UpdateListingRequested event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingService.updateListing(event.listing);
      emit(ListingState(status: ListingStatus.success, listings: state.listings));
      emit(ListingState(status: ListingStatus.loaded, listings: state.listings));
    } catch (e) {
      emit(ListingState(
        status: ListingStatus.error,
        listings: state.listings,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteListingRequested(
    DeleteListingRequested event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingService.deleteListing(event.listingId);
    } catch (e) {
      emit(ListingState(
        status: ListingStatus.error,
        listings: state.listings,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _listingsSubscription?.cancel();
    return super.close();
  }
}
