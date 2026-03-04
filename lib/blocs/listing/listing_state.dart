import 'package:equatable/equatable.dart';
import '../../models/listing_model.dart';

enum ListingStatus { initial, loading, loaded, error, success }

class ListingState extends Equatable {
  final ListingStatus status;
  final List<ListingModel> listings;
  final String? errorMessage;

  const ListingState({
    this.status = ListingStatus.initial,
    this.listings = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, listings, errorMessage];
}
