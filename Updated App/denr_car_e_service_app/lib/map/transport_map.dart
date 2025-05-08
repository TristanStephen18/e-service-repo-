import 'package:denr_car_e_service_app/map/api.dart';

import 'package:denr_car_e_service_app/map/transport_const.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/TransportPermit/forest_form.dart';

import 'package:denr_car_e_service_app/screens/TransportPermit/wildlife_form.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

class TransportMap extends StatefulWidget {
  final String legal;
  final String type;
  TransportMap({required this.type, required this.legal});
  @override
  _TransportMapState createState() => _TransportMapState();
}

class _TransportMapState extends State<TransportMap> {
  GoogleMapController? mapController;
  final Set<Polygon> _polygons = {};
  TextEditingController _searchController = TextEditingController();

  LatLng? _startLocation;
  LatLng? _destinationLocation;
  String? _startAddress;
  String? _destinationAddress;
  Marker? _startMarker;
  Marker? _destinationMarker;
  Marker? selectedMarker;

  bool isStartLocationSelected = false;
  bool isStartLocationConfirmed = false;
  bool isDestinationLocationConfirmed = false;
  bool isDestinationSelected = false;

  Set<Polyline> _polylines = {};

  BitmapDescriptor? _car;
  BitmapDescriptor? flag;
  @override
  void initState() {
    super.initState();
    _showInfoDialog(); // <- Add this
    _setPolygon();
    _loadIcons();
  }

  void _showInfoDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text("Important Notice"),
              content: Text(
                "Please select a start location within the CENRO Baguio jurisdiction. "
                "Once confirmed, you can select a destination location.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Got it"),
                ),
              ],
            ),
      );
    });
  }

  void _showDestinationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text("Destination Location"),
            content: Text(
              "Please select a destination location within or outside the CENRO Baguio jurisdiction. "
              "Once confirmed, you can upload your requirements.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Got it"),
              ),
            ],
          ),
    );
  }

  void _loadIcons() async {
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(30, 30)),
        'lib/images/car.png',
      );
      final _icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(35, 35)),
        'lib/images/flag.png',
      );
      setState(() {
        _car = icon;
        flag = _icon;
      });
    } catch (e) {
      print("May erRRRRRR: $e");
    }
  }

  void _setPolygon() {
    setState(() {
      _polygons.addAll({
        Polygon(
          polygonId: PolygonId("baguioCity"),
          points: TransportConstants.baguioCity,
          strokeColor: Colors.red,
          strokeWidth: 2,
          fillColor: Colors.red.withOpacity(0.35),
        ),
        Polygon(
          polygonId: PolygonId("sablan"),
          points: TransportConstants.sablan,
          strokeColor: Colors.green,
          strokeWidth: 2,
          fillColor: Colors.green.withOpacity(0.35),
        ),
        Polygon(
          polygonId: PolygonId("tuba"),
          points: TransportConstants.tuba,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.35),
        ),
        Polygon(
          polygonId: PolygonId("itogon"),
          points: TransportConstants.itogon,
          strokeColor: Colors.yellow,
          strokeWidth: 2,
          fillColor: Colors.yellow.withOpacity(0.35),
        ),
        Polygon(
          polygonId: PolygonId("laTrinidad"),
          points: TransportConstants.laTrinidad,
          strokeColor: Colors.purple,
          strokeWidth: 2,
          fillColor: Colors.purple.withOpacity(0.35),
        ),
        Polygon(
          polygonId: PolygonId("bokod"),
          points: TransportConstants.bokod,
          strokeColor: Colors.orange,
          strokeWidth: 2,
          fillColor: Colors.orange.withOpacity(0.35),
        ),
        Polygon(
          polygonId: PolygonId("kabayan"),
          points: TransportConstants.kabayan,
          strokeColor: Colors.grey,
          strokeWidth: 2,
          fillColor: Colors.grey.withOpacity(0.35),
        ),
      });
    });
  }

  void _updatePolyline() {
    if (_startLocation != null && _destinationLocation != null) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: PolylineId("route"),
            color: Colors.green,
            width: 5,
            points: [_startLocation!, _destinationLocation!],
          ),
        };
      });
    }
  }

  void _handleMapTap(LatLng position) async {
    String address = await ApiCalls().reverseGeocode(
      position.latitude,
      position.longitude,
    );

    if (!isStartLocationConfirmed) {
      if (!isStartLocationSelected) {
        String polygonName = "";
        bool isInsidePolygon = false;

        if (_isPointInsidePolygon(position, TransportConstants.itogon)) {
          polygonName = "Itogon";
          isInsidePolygon = true;
        } else if (_isPointInsidePolygon(position, TransportConstants.tuba)) {
          polygonName = "Tuba";
          isInsidePolygon = true;
        } else if (_isPointInsidePolygon(
          position,
          TransportConstants.kabayan,
        )) {
          polygonName = "Kabayan";
          isInsidePolygon = true;
        } else if (_isPointInsidePolygon(
          position,
          TransportConstants.baguioCity,
        )) {
          polygonName = "Baguio City";
          isInsidePolygon = true;
        } else if (_isPointInsidePolygon(position, TransportConstants.sablan)) {
          polygonName = "Sablan";
          isInsidePolygon = true;
        } else if (_isPointInsidePolygon(
          position,
          TransportConstants.laTrinidad,
        )) {
          polygonName = "La Trinidad";
          isInsidePolygon = true;
        } else if (_isPointInsidePolygon(position, TransportConstants.bokod)) {
          polygonName = "Bokod";
          isInsidePolygon = true;
        }

        if (isInsidePolygon) {
          setState(() {
            _startLocation = position;
            _startAddress = address;
            isStartLocationSelected = true;
          });
          _updatePolyline();
          _showStartLocationDetails(polygonName);
        } else {
          _showOutsidePolygonDialog(address);
        }
      }
      return; // Prevent destination selection before confirmation
    }

    // After confirming the start location
    if (isStartLocationConfirmed && !isDestinationLocationConfirmed) {
      // Get polygon name for destination too
      String polygonName = "";

      if (_isPointInsidePolygon(position, TransportConstants.itogon)) {
        polygonName = "Itogon";
      } else if (_isPointInsidePolygon(position, TransportConstants.tuba)) {
        polygonName = "Tuba";
      } else if (_isPointInsidePolygon(position, TransportConstants.kabayan)) {
        polygonName = "Kabayan";
      } else if (_isPointInsidePolygon(
        position,
        TransportConstants.baguioCity,
      )) {
        polygonName = "Baguio City";
      } else if (_isPointInsidePolygon(position, TransportConstants.sablan)) {
        polygonName = "Sablan";
      } else if (_isPointInsidePolygon(
        position,
        TransportConstants.laTrinidad,
      )) {
        polygonName = "La Trinidad";
      } else if (_isPointInsidePolygon(position, TransportConstants.bokod)) {
        polygonName = "Bokod";
      }

      setState(() {
        _destinationLocation = position;
        _destinationAddress = address;
      });
      _updatePolyline();

      _showDestinationLocationDetails(polygonName);
    }
  }

  void _showStartLocationDetails(String polygonName) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(Responsive.getWidthScale(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Start Location Details",
                style: TextStyle(
                  fontSize: Responsive.getTextScale(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.getHeightScale(10)),
              Text(_startAddress ?? "", textAlign: TextAlign.center),
              SizedBox(height: Responsive.getHeightScale(20)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isStartLocationConfirmed = true;
                    _updateStartMarker(_startLocation!);
                  });
                  Navigator.pop(context);
                  _showDestinationDialog();
                },
                child: Text(
                  "Confirm Start Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isStartLocationConfirmed = false;
                    isStartLocationSelected = false;
                  });
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDestinationLocationDetails(String polygonName) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(Responsive.getWidthScale(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Destination Location Details",
                style: TextStyle(
                  fontSize: Responsive.getTextScale(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.getHeightScale(10)),
              Text(_destinationAddress ?? "", textAlign: TextAlign.center),
              SizedBox(height: Responsive.getHeightScale(20)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isDestinationLocationConfirmed = true;
                    _updateDestinationMarker(_destinationLocation!);
                  });
                  Navigator.pop(context);

                  if (widget.type == 'Fauna') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WildlifeForm(
                              startLocation: _startLocation!,
                              destinationLocation: _destinationLocation!,
                              startAddress: _startAddress!,
                              destinationAddress: _destinationAddress!,
                              polygonName: polygonName,
                              type: 'Fauna',
                            ),
                      ),
                    );
                  } else if (widget.type == 'Flora') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WildlifeForm(
                              startLocation: _startLocation!,
                              destinationLocation: _destinationLocation!,
                              startAddress: _startAddress!,
                              destinationAddress: _destinationAddress!,
                              polygonName: polygonName,
                              type: 'Flora',
                            ),
                      ),
                    );
                  } else if (widget.type == 'Timber or Lumber' ||
                      widget.type == 'Non-Timber' ||
                      widget.type == 'Charcoal') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ForestForm(
                              startLocation: _startLocation!,
                              destinationLocation: _destinationLocation!,
                              startAddress: _startAddress!,
                              destinationAddress: _destinationAddress!,
                              polygonName: polygonName,
                              type: widget.type,
                              legal: widget.legal,
                            ),
                      ),
                    );
                  }
                },
                child: Text(
                  "Confirm Destination Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  // If the user closes the modal without confirming
                  setState(() {
                    // Reset the start location confirmation flag
                    isDestinationLocationConfirmed = false;
                    isDestinationSelected = false;
                  });
                  Navigator.pop(context); // Close the modal
                },
                child: Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOutsidePolygonDialog(String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Outside The Area"),
          content: Text(
            "The selected location is outside Cenro Baguio Jurisdiction.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _updateStartMarker(LatLng position) {
    setState(() {
      _startMarker = Marker(
        markerId: MarkerId("start_location"),
        position: position,
        infoWindow: InfoWindow(title: "Start Location"),
        icon: _car ?? BitmapDescriptor.defaultMarker,
      );
    });
  }

  void _updateDestinationMarker(LatLng position) {
    setState(() {
      _destinationMarker = Marker(
        markerId: MarkerId("destination_location"),
        position: position,
        infoWindow: InfoWindow(title: "Destination Location"),
        icon: flag ?? BitmapDescriptor.defaultMarker,
      );
    });
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
      _updateStartMarker(location);
      _updateDestinationMarker(location);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              target: TransportConstants.center,
              zoom: 10.0,
            ),
            polygons: _polygons,
            markers: {
              if (isStartLocationConfirmed && _startMarker != null)
                _startMarker!,
              if (isDestinationLocationConfirmed && _destinationMarker != null)
                _destinationMarker!,
            },
            polylines: _polylines,
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
                  _legendItem(Colors.red, "La Trinidad"),
                  _legendItem(Colors.green, "Sablan"),
                  _legendItem(Colors.blue, "Tuba"),
                  _legendItem(Colors.yellow, "Itogon"),
                  _legendItem(Colors.orange, "Bokod"),
                  _legendItem(Colors.purple, "Baguio City"),
                  _legendItem(Colors.grey, "Kabayan"),
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
