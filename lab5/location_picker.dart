import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  final LatLng initialLocation;
  final ValueChanged<LatLng> onLocationSelected;

  LocationPicker({required this.initialLocation, required this.onLocationSelected});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController _mapController;
  LatLng _selectedLocation = LatLng(42.004682, 21.408357);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 15.0,
        ),
        onTap: (position) {
          setState(() {
            _selectedLocation = position;
          });
        },
        markers: {
          Marker(
            markerId: MarkerId('selected_location'),
            position: _selectedLocation,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onLocationSelected(_selectedLocation);
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
