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

  // Seed Data
  Future<void> seedListings(String uid) async {
    final List<Map<String, dynamic>> samples = [
      {
        'name': 'King Faisal Hospital',
        'category': 'Hospital',
        'address': 'Kacyiru, Kigali',
        'contactNumber': '+250 252 588 888',
        'description': 'A leading multi-specialty hospital in Rwanda.',
        'latitude': -1.9447,
        'longitude': 30.0911,
        'createdBy': uid,
        'timestamp': Timestamp.now(),
      },
      {
        'name': 'Kigali Public Library',
        'category': 'Public Library',
        'address': 'Boulevard de l\'Umuganda, Kigali',
        'contactNumber': '+250 0788 333 333',
        'description': 'A modern public library with a vast collection of books.',
        'latitude': -1.9441,
        'longitude': 30.0898,
        'createdBy': uid,
        'timestamp': Timestamp.now(),
      },
      {
        'name': 'Heaven Restaurant',
        'category': 'Restaurant',
        'address': 'KN 29 St, Kigali',
        'contactNumber': '+250 788 486 535',
        'description': 'Upscale dining with beautiful views of the city.',
        'latitude': -1.9487,
        'longitude': 30.0619,
        'createdBy': uid,
        'timestamp': Timestamp.now(),
      },
    ];

    for (var sample in samples) {
      await _firestore.collection(_collection).add(sample);
    }
  }
}
