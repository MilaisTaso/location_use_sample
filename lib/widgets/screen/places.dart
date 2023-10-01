import 'package:favorite_places/model/place.dart';
import 'package:favorite_places/provider/places_provider.dart';
import 'package:favorite_places/widgets/components/place_items.dart';
import 'package:favorite_places/widgets/screen/new_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() {
    return _PlacesScreenState();
  }
}
class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  late Future<void> _placesFuture;

  void _addPlace(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext ctx) => const NewPlace()));
  }

  @override
  void initState() {
    super.initState();
    _placesFuture = ref.read(placesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final List<Place> placeList = ref.watch(placesProvider);

    Widget listContent = Center(
      child: Text(
        'No items added yet.',
        style: Theme.of(context).textTheme.titleLarge
      ),
    );

    if (placeList.isNotEmpty) {
      listContent = Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(future: _placesFuture, builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator(),)
              : ListView.builder(
                  itemCount: placeList.length,
                  itemBuilder: (BuildContext ctx, int index) =>
                      PlaceItems(place: placeList[index])),
          ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
            onPressed: () => _addPlace(context),
            icon: const Icon(Icons.add))
        ],
      ),
      body: listContent,
    );
  }
}
