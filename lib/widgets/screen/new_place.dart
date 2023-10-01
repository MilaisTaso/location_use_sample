import 'dart:io';
import 'package:favorite_places/model/place.dart';
import 'package:favorite_places/provider/places_provider.dart';
import 'package:favorite_places/widgets/components/image_input.dart';
import 'package:favorite_places/widgets/components/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewPlace extends ConsumerStatefulWidget {
  const NewPlace({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _NewPlaceState();
  }
}

class _NewPlaceState extends ConsumerState<NewPlace> {
  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void savePlace() {
      if (!_formKey.currentState!.validate() ||
          _selectedImage == null ||
          _selectedLocation == null) {
        showDialog(
            context: context,
            builder: (BuildContext ctx) => AlertDialog(
                  title: const Text('Invalid Input'),
                  content: const Text('Please make sure a valid title.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer),
                      child: Text(
                        'OK',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ));
        return;
      }
      ref
          .read(placesProvider.notifier)
          .addPlace(_titleController.text, _selectedImage!, _selectedLocation!);
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                TextFormField(
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                  controller: _titleController,
                  keyboardType: TextInputType.text,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    label: Text('Title'),
                  ),
                  validator: (String? value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 20) {
                      return 'Must be between 1 and 20 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ImageInput(
                  onPickImage: (File image) {
                    _selectedImage = image;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                LocationInput(
                  onSelectedLocation: (location) {
                    _selectedLocation = location;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton.icon(
                    onPressed: savePlace,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Place'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
