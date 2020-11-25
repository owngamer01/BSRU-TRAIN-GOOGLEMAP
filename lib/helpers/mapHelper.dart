import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:sport/config/config.dart';

class MapHelper {

  Future<Set<Polyline>> getPolylineList(LatLng origin, LatLng destination, {
    Color polyColor = Colors.red
  }) async {
    try {

      List<LatLng> polyList = [];
      Set<Polyline> polylines = {};

      final polyPoint = PolylinePoints();
      final resultPoint = await polyPoint.getRouteBetweenCoordinates(googleApiKey, 
        PointLatLng(origin.latitude, origin.longitude), 
        PointLatLng(destination.latitude, destination.longitude)
      );

      if (resultPoint.status == 'OK') {
        if (resultPoint.points.isNotEmpty) {
          for (PointLatLng point in resultPoint.points) {
            polyList.add(LatLng(point.latitude, point.longitude));
          }
          if (polyList.isNotEmpty) {
            polylines.add(Polyline(
              polylineId: PolylineId('poly'),
              color: polyColor,
              startCap: Cap.buttCap,
              points: polyList,
              width: 5,
            ));
            return polylines;
          }
          return null;
        } else {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Set<Marker>> getMarkerList(BuildContext context, List<LatLng> locations) async {
    try {
      final Set<Marker> markers = {};
      int indexMarker = 0;

      final customIcon = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/cat.png', 180));

      for (LatLng location in locations) {
        markers.add(Marker(
          markerId: MarkerId(indexMarker.toString()),
          position: LatLng(location.latitude, location.longitude),
          icon: customIcon,
          infoWindow: InfoWindow(
            title: indexMarker.toString()
          )
        ));
        indexMarker++;
      }
      return markers;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int size) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), 
      targetWidth: size,
      targetHeight: size
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }
}