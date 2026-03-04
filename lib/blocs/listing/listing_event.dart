import 'package:equatable/equatable.dart';
import '../../models/listing_model.dart';

abstract class ListingEvent extends Equatable {
  const ListingEvent();
  @override
  List<Object?> get props => [];
}

class LoadListingsRequested extends ListingEvent {}

class ListingsUpdated extends ListingEvent {
  final List<ListingModel> listings;
  const ListingsUpdated(this.listings);
  @override
  List<Object?> get props => [listings];
}

class CreateListingRequested extends ListingEvent {
  final ListingModel listing;
  const CreateListingRequested(this.listing);
  @override
  List<Object?> get props => [listing];
}

class UpdateListingRequested extends ListingEvent {
  final ListingModel listing;
  const UpdateListingRequested(this.listing);
  @override
  List<Object?> get props => [listing];
}

class DeleteListingRequested extends ListingEvent {
  final String listingId;
  const DeleteListingRequested(this.listingId);
  @override
  List<Object?> get props => [listingId];
}
