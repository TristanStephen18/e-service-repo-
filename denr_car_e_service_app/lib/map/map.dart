import 'package:denr_car_e_service_app/map/api.dart';
import 'package:denr_car_e_service_app/map/map_const.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {}; // Stores permanent markers
  Marker? _selectedMarker; // Stores the last selected marker
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setPolygon();
    _setMarkers();
  }

  void _setPolygon() {
    final polygons = {
      "marcos": Polygon(
        polygonId: PolygonId("marcos"),
        points: MapConstants.marcosHighway,
        strokeColor: Colors.red,
        strokeWidth: 2,
        fillColor: Colors.red.withOpacity(0.35),
      ),
      "upperAgno": Polygon(
        polygonId: PolygonId("upperAgno"),
        points: MapConstants.upperAgno,
        strokeColor: Colors.green,
        strokeWidth: 2,
        fillColor: Colors.green.withOpacity(0.35),
      ),
      "lowerAgno": Polygon(
        polygonId: PolygonId("lowerAgno"),
        points: MapConstants.lowerAgno,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withOpacity(0.35),
      ),
      "mtPulag": Polygon(
        polygonId: PolygonId("mtPulag"),
        points: MapConstants.mtPulagCoords,
        strokeColor: Colors.yellow,
        strokeWidth: 2,
        fillColor: Colors.yellow.withOpacity(0.35),
      ),
    };

    setState(() {
      _polygons.addAll(polygons.values);
    });
  }

  void _setMarkers() {
    setState(() {
      _markers.addAll(
        MapConstants.markers.entries.map(
          (entry) => Marker(
            markerId: MarkerId(entry.key),
            position: entry.value,
            infoWindow: InfoWindow(title: entry.key),
          ),
        ),
      );
    });
  }

  void _handleMapTap(LatLng position) async {
    String address = await ApiCalls().reverseGeocode(
      position.latitude,
      position.longitude,
    );

    if (_selectedMarker != null) {
      setState(() {
        _markers.remove(_selectedMarker);
      });
    }

    Marker newMarker = Marker(
      markerId: MarkerId("selected_location"),
      position: position,
      infoWindow: InfoWindow(title: "Selected Location", snippet: address),
    );

    setState(() {
      _selectedMarker = newMarker;
      _markers.add(newMarker);
    });

    _showLocationDetails(address);
  }

  void _showLocationDetails(String address) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Location Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(address, textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Confirm Location"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    LatLng? location = await ApiCalls().getCoordinates(query);

    if (location != null) {
      String address = await ApiCalls().reverseGeocode(
        location.latitude,
        location.longitude,
      );

      if (_selectedMarker != null) {
        setState(() {
          _markers.remove(_selectedMarker);
        });
      }

      Marker newMarker = Marker(
        markerId: MarkerId("search_location"),
        position: location,
        infoWindow: InfoWindow(title: "Search Result", snippet: address),
      );

      setState(() {
        _selectedMarker = newMarker;
        _markers.add(newMarker);
      });

      mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
      _showLocationDetails(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Map")),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: _handleMapTap,
            initialCameraPosition: CameraPosition(
              target: MapConstants.center,
              zoom: 10.0,
            ),
            polygons: _polygons,
            markers: _markers,
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search location...",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _searchLocation(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.blue),
                    onPressed: _searchLocation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
