import 'dart:convert';
import 'dart:io';

import 'package:favorite_places/widgets/screen/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/model/place.dart';
import 'package:favorite_places/provider/places_provider.dart';

class LocationInput extends ConsumerStatefulWidget {
  const LocationInput({
    super.key,
    required this.onSelectedLocation,
  });

  final void Function(PlaceLocation location) onSelectedLocation;

  @override
  ConsumerState<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends ConsumerState<LocationInput> {
  PlaceLocation? _pickedLocation;
  bool _isGettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    final String mapsApiKey = dotenv.get('GOOGLE_MAPS_API_KEY');

    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap'
        '&markers=color:red%7Clabel:A%7C$lat,$lng&key=$mapsApiKey';
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    final String mapsApiKey = dotenv.get('GOOGLE_MAPS_API_KEY');
    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$mapsApiKey');

    try {
      final http.Response response = await http.get(url);
      if (response.statusCode != 200) {
        throw HttpException('Request Error: ${response.body}');
      }
      final resData = json.decode(response.body);
      final String address = resData['results'][0]['formatted_address'];

      print('{response: $resData}');
      setState(() {
        _pickedLocation =
            PlaceLocation(longitude: latitude, latitude: longitude, address: address);
        _isGettingLocation = false;
      });
      widget.onSelectedLocation(_pickedLocation!);
    } catch (err) {
      rethrow;
    }
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final double? lat = locationData.latitude;
    final double? lng = locationData.longitude;

    print('get location!: $lat, $lng');

    if (lat == null || lng == null) {
      return;
    }

    _savePlace(lat, lng);
  }

  Future<void> _selectOnMap() async {
    final LatLng? pickedLocation = await Navigator.of(context).push<LatLng?>(MaterialPageRoute(builder: (BuildContext ctx) =>
    const MapScreen()
    ));

    if (pickedLocation == null) {
      return;
    }
    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }
    if (_pickedLocation != null) {
      previewContent = Image.network(
        ref.read(placesProvider.notifier).getLocationImage(_pickedLocation!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Column(
      children: [
        Container(
            height: 170,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.2))),
            child: previewContent),
        Row(
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              label: const Text('Get Current Location'),
              icon: const Icon(Icons.location_on),
            ),
            TextButton.icon(
              onPressed: () {
                _selectOnMap();
              },
              label: const Text(
                'Selected on Map',
              ),
              icon: const Icon(Icons.map),
            )
          ],
        ),
      ],
    );
  }
}
