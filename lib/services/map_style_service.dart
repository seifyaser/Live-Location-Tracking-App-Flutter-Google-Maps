import 'package:flutter/material.dart';

class MapStyleService {
  static Future<String> loadMapStyle(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
  }
}
