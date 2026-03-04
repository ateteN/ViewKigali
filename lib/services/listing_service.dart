import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'listings';

  // Create
  Future<void> createListing(ListingModel listing) async {
    try {
      await _firestore.collection(_collection).add(listing.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  // Read (Stream all)
  Stream<List<ListingModel>> getListingsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromFirestore(doc))
            .toList());
  }

  // Read (Stream for specific user)
  Stream<List<ListingModel>> getMyListingsStream(String uid) {
    return _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromFirestore(doc))
            .toList());
  }

  // Update
  Future<void> updateListing(ListingModel listing) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(listing.id)
          .update(listing.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  // Delete
  Future<void> deleteListing(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
