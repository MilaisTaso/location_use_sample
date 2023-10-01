import 'package:favorite_places/model/place.dart';
import 'package:favorite_places/widgets/screen/place_detail.dart';
import 'package:flutter/material.dart';

class PlaceItems extends StatelessWidget {
  const PlaceItems({
    super.key,
    required this.place,
  });

  final Place place;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: FileImage(place.image),
      ),
      title: Text(place.title,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
        color: Theme.of(context).colorScheme.onBackground
      ),
      ),
      subtitle: Text(place.location.address,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.onBackground
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext ctx) =>
              PlaceDetailScreen(place: place))
        );
      },
    );
  }
}
