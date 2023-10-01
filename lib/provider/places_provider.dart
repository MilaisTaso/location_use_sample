import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:favorite_places/model/place.dart';

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>(
    (ref) => PlacesNotifier());

class PlacesNotifier extends StateNotifier<List<Place>> {
  PlacesNotifier() : super(const []);

  Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(path.join(dbPath, 'places.db'),
        onCreate: (Database db, int version) {
          return db.execute(
              'CREATE TABLE places(id TEXT PRIMARY KEY, title TEXT, image_path TEXT, lat REAL, lng REAL, address TEXT)');
        }, version: 1);
    return db;
  }

  Future<void> loadPlaces() async {
    final Database db = await _getDatabase();
    final List<Map<String, Object?>> records = await db.query('places');

    final List<Place> places = records.map((Map<String, Object?> record) => Place(
        id: record['id'] as String,
        title: record['title'] as String,
        image: File(record['image'] as String),
        location: PlaceLocation(
            longitude: record['lat'] as double,
            latitude: record['lng'] as double,
            address: record['address'] as String
        ),
    )).toList();

    state = places;
  }

  Future<void> addPlace(String title, File image, PlaceLocation location) async {
    print('セーブ開始');
    final Directory appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final File copiedImage = await image.copy('${appDir.path}/$fileName');

    final newPlace  = Place(title: title, image: copiedImage, location: location);
    final Database db = await _getDatabase();

    db.insert('places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address
    });

    state = [...state, newPlace];


  }

  String getLocationImage(PlaceLocation location) {
    final lat = location.latitude;
    final lng = location.longitude;
    print('getLocation: $lat, $lng');
    final String mapsApiKey = dotenv.get('GOOGLE_MAPS_API_KEY');

    return 'https://maps.googleapis.com/maps/api/staticmap?center=139.6917,35.6894&zoom=16&size=600x300&maptype=roadmap'
        '&markers=color:red%7Clabel:A%7C$lat,$lng&key=$mapsApiKey';
  }
}