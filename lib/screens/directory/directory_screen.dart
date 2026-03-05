import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/listing/listing_bloc.dart';
import '../../blocs/listing/listing_event.dart';
import '../../blocs/listing/listing_state.dart';
import '../../blocs/search_filter/search_filter_cubit.dart';
import '../../models/listing_model.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/category_filter_chips.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search for a service',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    suffixIcon: Icon(Icons.search, color: Colors.grey.shade800),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    context.read<SearchFilterCubit>().updateSearchQuery(value);
                  },
                ),
              ),
              const CategoryFilterChips(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Near You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, listingState) {
          if (listingState.status == ListingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (listingState.status == ListingStatus.error) {
            return Center(child: Text(listingState.errorMessage ?? 'Error'));
          }

          return BlocBuilder<SearchFilterCubit, SearchFilterState>(
            builder: (context, filterState) {
              List<ListingModel> filteredListings = listingState.listings;

              // Filter by category
              if (filterState.selectedCategory != null) {
                filteredListings = filteredListings
                    .where((l) => l.category == filterState.selectedCategory)
                    .toList();
              }

              // Search by name
              if (filterState.searchQuery.isNotEmpty) {
                final query = filterState.searchQuery.toLowerCase();
                filteredListings = filteredListings
                    .where((l) => l.name.toLowerCase().contains(query))
                    .toList();
              }

              if (filteredListings.isEmpty) {
                return const Center(child: Text('No listings found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredListings.length,
                itemBuilder: (context, index) {
                  return ListingCard(listing: filteredListings[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
