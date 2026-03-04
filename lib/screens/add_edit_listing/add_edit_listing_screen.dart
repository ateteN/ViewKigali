import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/listing/listing_bloc.dart';
import '../../blocs/listing/listing_event.dart';
import '../../blocs/listing/listing_state.dart';
import '../../models/listing_model.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class AddEditListingScreen extends StatefulWidget {
  final ListingModel? listing;

  const AddEditListingScreen({super.key, this.listing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.listing?.name);
    _addressController = TextEditingController(text: widget.listing?.address);
    _contactController = TextEditingController(text: widget.listing?.contactNumber);
    _descController = TextEditingController(text: widget.listing?.description);
    _latController = TextEditingController(text: widget.listing?.latitude.toString() ?? '');
    _lngController = TextEditingController(text: widget.listing?.longitude.toString() ?? '');
    _selectedCategory = widget.listing?.category ?? AppConstants.categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final user = context.read<AuthBloc>().state.user;
      if (user == null) return;

      final listing = ListingModel(
        id: widget.listing?.id ?? '',
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descController.text.trim(),
        latitude: double.parse(_latController.text),
        longitude: double.parse(_lngController.text),
        createdBy: user.uid,
        timestamp: widget.listing?.timestamp ?? DateTime.now(),
      );

      if (widget.listing == null) {
        context.read<ListingBloc>().add(CreateListingRequested(listing));
      } else {
        context.read<ListingBloc>().add(UpdateListingRequested(listing));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing == null ? 'Add Listing' : 'Edit Listing'),
      ),
      body: BlocListener<ListingBloc, ListingState>(
        listener: (context, state) {
          if (state.status == ListingStatus.success) {
            Navigator.pop(context);
          } else if (state.status == ListingStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Operation failed')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Place Name'),
                  validator: (value) => AppValidators.validateRequired(value, 'Name'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: AppConstants.categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) => AppValidators.validateRequired(value, 'Address'),
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact Number'),
                  validator: (value) => AppValidators.validateRequired(value, 'Contact'),
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => AppValidators.validateRequired(value, 'Description'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                        keyboardType: TextInputType.number,
                        validator: (value) => AppValidators.validateRequired(value, 'Lat'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                        keyboardType: TextInputType.number,
                        validator: (value) => AppValidators.validateRequired(value, 'Lng'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _onSave,
                  child: const Text('Save Listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
