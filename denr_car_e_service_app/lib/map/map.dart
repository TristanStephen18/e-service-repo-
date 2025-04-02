import 'package:denr_car_e_service_app/map/api.dart';
import 'package:denr_car_e_service_app/map/map_const.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/goverment.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/private_land.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/public_safety.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

class MapScreen extends StatefulWidget {
  final String type;
  MapScreen({required this.type});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final Set<Polygon> _polygons = {};
  LatLng? _selectedLocation;
  String? _selectedAddress;
  TextEditingController _searchController = TextEditingController();
  Marker? _selectedMarker; // Added: Store selected marker

  @override
  void initState() {
    super.initState();
    _setPolygon();
  }

  void _setPolygon() {
    setState(() {
      _polygons.addAll({
        Polygon(
          polygonId: PolygonId("marcos"),
          points: MapConstants.marcosHighway,
          strokeColor: Colors.red,
          strokeWidth: 2,
          fillColor: Colors.red.withOpacity(0.35),
        ),
        Polygon(
          polygonId: PolygonId("upperAgno"),
          points: MapConstants.upperAgno,
          strokeColor: Colors.green,
          strokeWidth: 2,
          fillColor: Colors.green.withOpacity(0.35),
        ),
        Polygon(
          polygonId: PolygonId("lowerAgno"),
          points: MapConstants.lowerAgno,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.35),
        ),
        Polygon(
          polygonId: PolygonId("mtPulag"),
          points: MapConstants.mtPulagCoords,
          strokeColor: Colors.yellow,
          strokeWidth: 2,
          fillColor: Colors.yellow.withOpacity(0.35),
        ),
      });
    });
  }

  void _handleMapTap(LatLng position) async {
    String address = await ApiCalls().reverseGeocode(
      position.latitude,
      position.longitude,
    );
    String? insidePolygon;

    if (_isPointInsidePolygon(position, MapConstants.marcosHighway)) {
      insidePolygon = "Marcos Highway";
    } else if (_isPointInsidePolygon(position, MapConstants.upperAgno)) {
      insidePolygon = "Upper Agno";
    } else if (_isPointInsidePolygon(position, MapConstants.lowerAgno)) {
      insidePolygon = "Lower Agno";
    } else if (_isPointInsidePolygon(position, MapConstants.mtPulagCoords)) {
      insidePolygon = "Mt. Pulag";
    }

    if (insidePolygon == null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Invalid Location"),
              content: Text("Selected location is outside the allowed areas."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    setState(() {
      _selectedLocation = position;
      _selectedAddress = address;
      _updateMarker(position); // Add marker when selecting a location
    });

    _showLocationDetails(insidePolygon);
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _selectedMarker = Marker(
        markerId: MarkerId("selected_location"),
        position: position,
        infoWindow: InfoWindow(title: "Selected Location"),
      );
    });
  }

  void _showLocationDetails(String polygonName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(
            Responsive.getWidthScale(16),
          ), // Responsive padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Location Details",
                style: TextStyle(
                  fontSize: Responsive.getTextScale(18), // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: Responsive.getHeightScale(10),
              ), // Responsive space
              Text(_selectedAddress ?? "", textAlign: TextAlign.center),
              SizedBox(
                height: Responsive.getHeightScale(20),
              ), // Responsive space
              ElevatedButton(
                onPressed: () {
                  if (widget.type == 'PLTP') {
                    if (_selectedLocation != null && _selectedAddress != null) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PrivateLandScreen(
                                geoP: _selectedLocation!,
                                address: _selectedAddress!,
                                polygonName: polygonName,
                              ),
                        ),
                      );
                    }
                  } else if (widget.type == 'PSP') {
                    if (_selectedLocation != null && _selectedAddress != null) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PublicSafetyScreen(
                                geoP: _selectedLocation!,
                                address: _selectedAddress!,
                                polygonName: polygonName,
                              ),
                        ),
                      );
                    }
                  } else if (widget.type == 'NGA') {
                    if (_selectedLocation != null && _selectedAddress != null) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GovermentScreen(
                                geoP: _selectedLocation!,
                                address: _selectedAddress!,
                                polygonName: polygonName,
                              ),
                        ),
                      );
                    }
                  }
                },
                child: Text("Confirm Location"),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length - 1; i++) {
      vector_math.Vector2 a = vector_math.Vector2(
        polygon[i].latitude,
        polygon[i].longitude,
      );
      vector_math.Vector2 b = vector_math.Vector2(
        polygon[i + 1].latitude,
        polygon[i + 1].longitude,
      );
      vector_math.Vector2 p = vector_math.Vector2(
        point.latitude,
        point.longitude,
      );

      if ((a.y > p.y && b.y < p.y) || (a.y < p.y && b.y > p.y)) {
        double x = a.x + (p.y - a.y) / (b.y - a.y) * (b.x - a.x);
        if (x > p.x) {
          intersectCount++;
        }
      }
    }
    return (intersectCount % 2) == 1;
  }

  Future<void> _searchLocation() async {
    String searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) return;

    LatLng? location = await ApiCalls().getCoordinates(searchQuery);

    if (location != null) {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
      _updateMarker(location); // Add marker when searching
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the responsive values
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Location", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
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
            markers: _selectedMarker != null ? {_selectedMarker!} : {},
          ),
          Positioned(
            top: Responsive.getHeightScale(10),
            left: Responsive.getWidthScale(15),
            right: Responsive.getWidthScale(15),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidthScale(10),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search location...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _searchLocation(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchLocation,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: Responsive.getWidthScale(20),
            top: Responsive.getHeightScale(60),
            child: Container(
              padding: EdgeInsets.all(Responsive.getWidthScale(10)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Legend:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(14),
                    ),
                  ),
                  _legendItem(Colors.red, "Marcos Highway"),
                  _legendItem(Colors.green, "Upper Agno"),
                  _legendItem(Colors.blue, "Lower Agno"),
                  _legendItem(Colors.yellow, "Mt. Pulag"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 20, height: 20, color: color),
        SizedBox(width: Responsive.getWidthScale(5)),
        Text(label),
      ],
    );
  }
}
