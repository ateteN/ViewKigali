import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/listing/listing_bloc.dart';
import '../../blocs/listing/listing_event.dart';
import '../../blocs/listing/listing_state.dart';
import '../../blocs/my_listings/my_listings_bloc.dart';
import '../../widgets/listing_card.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;

    if (user != null) {
      context.read<MyListingsBloc>().add(LoadMyListingsRequested(user.uid));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<MyListingsBloc, ListingState>(
        builder: (context, state) {
          if (state.status == ListingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ListingStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error'));
          }

          if (state.listings.isEmpty) {
            return const Center(child: Text('You haven\'t created any listings yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.listings.length,
            itemBuilder: (context, index) {
              final listing = state.listings[index];
              return Dismissible(
                key: Key(listing.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  context.read<ListingBloc>().add(DeleteListingRequested(listing.id));
                },
                child: ListingCard(listing: listing),
              );
            },
          );
        },
      ),
    );
  }
}
