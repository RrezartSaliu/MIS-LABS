import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'main.dart';

class MapScreen extends StatefulWidget {
  final Exam exam;

  MapScreen({required this.exam});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late Location _location;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Location'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
          _addMarkers();
          _getPolylines();
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.exam.latitude, widget.exam.longitude),
          zoom: 15.0,
        ),
        markers: _markers,
        polylines: _polylines,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showClosestRoute();
        },
        child: Icon(Icons.directions),
      ),
    );
  }

  Future<void> _getPolylines() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyBh_dad6WOIdEcVbLvLOxV1Rk4EsjYgki8',
      PointLatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      PointLatLng(widget.exam.latitude, widget.exam.longitude),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.blue,
            points: polylineCoordinates,
          ),
        );
      });
    }
  }


  void _addMarkers() {
    _markers.add(
      Marker(
        markerId: MarkerId('exam_location'),
        position: LatLng(widget.exam.latitude, widget.exam.longitude),
        infoWindow: InfoWindow(
          title: 'Exam Location',
        ),
      ),
    );
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: InfoWindow(
            title: 'Your Location',
          ),
        ),
      );
    }
  }

  Future<void> _showClosestRoute() async {
    if (_currentLocation == null) {
      return;
    }

    String origin = '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    String destination = '${widget.exam.latitude},${widget.exam.longitude}';
    String apiKey = 'AIzaSyBh_dad6WOIdEcVbLvLOxV1Rk4EsjYgki8';

    String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);

      List<LatLng> routePoints =
      _decodePoly(encodedPolyline: decodedResponse['routes'][0]['overview_polyline']['points']);

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.blue,
            points: routePoints,
            width: 5,
          ),
        );

        double distance = calculateDistance(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
          widget.exam.latitude,
          widget.exam.longitude,
        );

        _scheduleNotification(widget.exam, distance);
      });
    } else {
      print('Error fetching route: ${response.reasonPhrase}');
    }
  }

  Future<void> _scheduleNotification(Exam exam, double distance) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    String distanceText;
    if (distance < 1.0) {
      int meters = (distance * 1000).round();
      distanceText = '$meters meters';
    } else {
      distanceText = '${distance.toStringAsFixed(2)} km';
    }

    await flutterLocalNotificationsPlugin.show(
      0,
      'Distance Reminder',
      'Your distance to the exam (${exam.title}) is $distanceText',
      platformChannelSpecifics,
    );
  }


  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    const int radiusOfEarth = 6371;

    double startLatRad = degreesToRadians(startLat);
    double endLatRad = degreesToRadians(endLat);
    double startLngRad = degreesToRadians(startLng);
    double endLngRad = degreesToRadians(endLng);

    double latDiff = endLatRad - startLatRad;
    double lngDiff = endLngRad - startLngRad;

    double a = pow(sin(latDiff / 2), 2) +
        cos(startLatRad) * cos(endLatRad) * pow(sin(lngDiff / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radiusOfEarth * c;

    return distance;
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }



  List<LatLng> _decodePoly({required String encodedPolyline}) {
    List<PointLatLng> points = PolylinePoints().decodePolyline(encodedPolyline);
    return points.map((point) => LatLng(point.latitude, point.longitude)).toList();
  }

  void _getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          return;
        }
      }

      _currentLocation = await _location.getLocation();
      setState(() {
        _addMarkers();
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

}
