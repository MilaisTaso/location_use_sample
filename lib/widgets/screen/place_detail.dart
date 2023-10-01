import 'package:favorite_places/widgets/screen/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/model/place.dart';
import 'package:favorite_places/provider/places_provider.dart';

class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({super.key, required this.place});
  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text(place.title),
        ),
        body: Stack(
          children: [
            Image.file(
              place.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext ctx) => MapScreen(
                                  location: place.location,
                                  isSelecting: false,
                                )));
                      },
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(
                          ref
                              .read(placesProvider.notifier)
                              .getLocationImage(place.location),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black54],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                      ),
                      child: Text(
                        place.location.address,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    )
                  ],
                ))
          ],
        ));
  }
}
