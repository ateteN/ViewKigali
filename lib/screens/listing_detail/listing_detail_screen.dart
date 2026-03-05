// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/listing_model.dart';
import '../add_edit_listing/add_edit_listing_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';

const String _kGoogleMapsApiKey = 'AIzaSyB0QJMVMv9VymVMagjxI7oPzvcTcBlMqQs';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _showDirections = false;
  Position? _userPosition;
  bool _loadingLocation = false;
  String? _locationError;

  late final String _pinViewId;
  late final String _directionsViewId;
  bool _directionsRegistered = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _pinViewId = 'gmap-pin-${widget.listing.id}';
      _directionsViewId = 'gmap-dir-${widget.listing.id}';
      _registerPinView();
    }
  }

  void _registerPinView() {
    final lat = widget.listing.latitude;
    final lng = widget.listing.longitude;

    final embedUrl = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/embed/v1/place',
      queryParameters: {
        'key': _kGoogleMapsApiKey,
        'q': '$lat,$lng',
        'zoom': '15',
        'maptype': 'roadmap',
      },
    ).toString();

    ui.platformViewRegistry.registerViewFactory(_pinViewId, (_) {
      return html.IFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true
        ..setAttribute('loading', 'lazy')
        ..setAttribute('allow', 'geolocation; fullscreen');
    });
  }

  void _registerDirectionsView(Position origin) {
    if (_directionsRegistered) return;

    final destLat = widget.listing.latitude;
    final destLng = widget.listing.longitude;

    final embedUrl = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/embed/v1/directions',
      queryParameters: {
        'key': _kGoogleMapsApiKey,
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '$destLat,$destLng',
        'mode': 'driving',
        'zoom': '13',
      },
    ).toString();

    ui.platformViewRegistry.registerViewFactory(_directionsViewId, (_) {
      return html.IFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true
        ..setAttribute('loading', 'lazy')
        ..setAttribute('allow', 'geolocation; fullscreen');
    });

    _directionsRegistered = true;
  }

  Future<void> _getDirections() async {
    if (!kIsWeb) {
      // Mobile: launch Google Maps app
      final lat = widget.listing.latitude;
      final lng = widget.listing.longitude;
      final googleMapsUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri);
      } else {
        await launchUrl(
          Uri.parse(
            'https://www.google.com/maps/dir/?api=1'
            '&destination=$lat,$lng&travelmode=driving',
          ),
          mode: LaunchMode.externalApplication,
        );
      }
      return;
    }

    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled.';
          _loadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Location permission denied. Please allow it in your browser.';
          _loadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _registerDirectionsView(position);

      setState(() {
        _userPosition = position;
        _showDirections = true;
        _loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Could not get your location. Please try again.';
        _loadingLocation = false;
      });
    }
  }

  Widget _buildMap() {
    if (!kIsWeb) {
      // Mobile: flutter_map
      return FlutterMap(
        options: MapOptions(
          initialCenter:
              LatLng(widget.listing.latitude, widget.listing.longitude),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.viewkigali',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point:
                    LatLng(widget.listing.latitude, widget.listing.longitude),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin,
                    color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      );
    }

    // Web: Google Maps iframe
    if (_showDirections && _userPosition != null) {
      return HtmlElementView(viewType: _directionsViewId);
    }
    return HtmlElementView(viewType: _pinViewId);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;
    final isOwner = user?.uid == widget.listing.createdBy;

    return Scaffold(
      backgroundColor: const Color(0xFF010A26),
      appBar: AppBar(
        title: Text(widget.listing.name),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditListingScreen(listing: widget.listing),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Main card ──────────────────────────────────────────────
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Map with overlay controls ──────────────────────
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            _buildMap(),

                            // Loading overlay
                            if (_loadingLocation)
                              Container(
                                color: Colors.black38,
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                          color: Colors.white),
                                      SizedBox(height: 10),
                                      Text(
                                        'Getting your location…',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // "← Back to location" pill
                            if (_showDirections && !_loadingLocation)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _showDirections = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6)
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.arrow_back,
                                            size: 14,
                                            color: Colors.black87),
                                        SizedBox(width: 4),
                                        Text('Back to location',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ── Card details ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.listing.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Color(0xFFF7C35F), size: 20),
                              const SizedBox(width: 4),
                              Text(
                                widget.listing.category,
                                style: const TextStyle(
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.listing.description,
                            style:
                                const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFF7C35F),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                elevation: 0,
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Rate this service',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Location error banner ────────────────────────────────
              if (_locationError != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationError!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: _getDirections,
                        child: const Text('Retry',
                            style:
                                TextStyle(color: Color(0xFFF7C35F))),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // ── Contact Information ──────────────────────────────────
              const Text(
                'Contact Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on,
                    color: Color(0xFFF7C35F)),
                title: Text(widget.listing.address,
                    style: const TextStyle(color: Colors.white)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone,
                    color: Color(0xFFF7C35F)),
                title: Text(widget.listing.contactNumber,
                    style: const TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 24),

              // ── Get Directions button ────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loadingLocation ? null : _getDirections,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF7C35F),
                    side: const BorderSide(color: Color(0xFFF7C35F)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _loadingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFF7C35F),
                          ),
                        )
                      : Icon(_showDirections
                          ? Icons.check_circle_outline
                          : Icons.navigation),
                  label: Text(
                    _showDirections
                        ? 'Directions shown on map ↑'
                        : 'Get Directions',
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}