import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sport/helpers/mapHelper.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFF145bcc),
        accentColor: Colors.red,
        textTheme: TextTheme(
          bodyText1: TextStyle(
            fontSize: 16,
            color: Colors.red
          ),
          headline1: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black
          )
        )
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  List<Map<String, dynamic>> allLocations = [];
  Position _myLocation;
  int activeLocationIndex = 0;

  final _mapHelper = MapHelper();
  final _controller = Completer<GoogleMapController>();
    
  @override
  void initState() {
    super.initState();
    _initMap();
  }

  @override
  void dispose() async {
    super.dispose();
    (await _controller.future).dispose();
  }

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(13.7419726, 100.4667253),
    zoom: 18,
  );

  _initMap() async {

    try {

      // # load all location 
      allLocations = [{
        'id':             0,
        'name':           'Wong wean yai',
        'latitude':       13.726352,
        'longitude':      100.493170,
        'polyline':       {}
      }, {
        'id':             1,
        'name':           'BTS Wong wean yai',
        'latitude':       13.724591,
        'longitude':      100.491924,
        'polyline':       {}
      }];

      if(await Geolocator.isLocationServiceEnabled()) {

        _myLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation
        );

        List<LatLng> locations = [
          LatLng(_myLocation.latitude, _myLocation.longitude)

        ]..addAll(allLocations.map((_location) => 
          LatLng(_location['latitude'], _location['longitude'])
        ).toList());

        _markers = await _mapHelper.getMarkerList(context, locations);
        
        for (var _location in allLocations) {
          _location['polyline'] = await _mapHelper.getPolylineList(
            LatLng(_myLocation.latitude, _myLocation.longitude), 
            LatLng(_location['latitude'], _location['longitude']),
            polyColor: Colors.red
          );
        }

        final ctrlMap = await _controller.future;
        ctrlMap.animateCamera(CameraUpdate.newLatLng(LatLng(_myLocation.latitude, _myLocation.longitude)));

        if (allLocations.isNotEmpty) {
          _setDirection(0);
        } else {
          setState(() {});
        }

      } else {
        print('location i\'st allow');
      }
    } catch (e) {
      print("Exception : $e");
    }
  }

  _setDirection(int indexLocation) {
    setState(() { 
      _polylines = allLocations[indexLocation]['polyline'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps", style: TextStyle(
          fontSize: 24
        )),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: Set<Marker>.from(_markers),
            polylines: Set<Polyline>.from(_polylines),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            }
          ),
          _panelMapDirection(),
        ],
      )
    );
  }


  Widget _panelMapDirection() {
    return Positioned(
      top: 25,
      child: Opacity(
        opacity: 0.9,
        child: Container(
          padding: EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Direction To', 
                style: Theme.of(context).textTheme.headline1,
                textAlign: TextAlign.center,
              ),
              DropdownButton<int>(
                value: activeLocationIndex,
                elevation: 16,
                onChanged: _setDirection,
                items: allLocations.map((_location) => DropdownMenuItem(
                  value: _location['id'] as int,
                  child: Text(_location['name']),
                )).toList()),
            ],
          ),
        ),
      ),
    );
  }
}