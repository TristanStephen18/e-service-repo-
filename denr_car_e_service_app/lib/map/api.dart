import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

String apiKeyDistance =
    'VfHc9kUw28RcmWFLqCVZemKw7wGWqY2EDNNJOh4f3gYdiM0A8E4OF66ra7MhYDSh';

//32OQ6PekD6m1FLGbx3KHHIF21E7sRGpuk9CU3urbZMsDPzaCvDTfTuqjaS2o24fF
const String apiKey = "pk.b1172a5bd0a53f7260d0cca6f5ebb71a";

class ApiCalls {
  Future<String> reverseGeocode(double lat, double lon) async {
    final String url =
        "https://us1.locationiq.com/v1/reverse.php?key=$apiKey&lat=$lat&lon=$lon&format=json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name']; // Return the address from the response
      } else {
        return "Address not available";
      }
    } catch (error) {
      print("Error fetching address: $error");
      return "Address not available";
    }
  }

  Future<LatLng?> getCoordinates(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    LatLng? coordinates;
    print('fetching response from api');

    final String url =
        "https://us1.locationiq.com/v1/search?key=${apiKey}&q=${encodedAddress}&format=json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Access the first result in the array
        if (data is List && data.isNotEmpty) {
          final firstResult = data[0];
          coordinates = LatLng(
            double.parse(firstResult['lat']),
            double.parse(firstResult['lon']),
          );
          print(coordinates);
          return coordinates;
        } else {
          print("No results found for the address.");
          return null;
        }
      } else {
        print("Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error fetching address: $error");
      return null;
    }
  }

  Future<String> getBarangay(double lat, double lon) async {
    final String url =
        "https://us1.locationiq.com/v1/reverse.php?key=$apiKey&lat=$lat&lon=$lon&format=json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name']; // Return the address from the response
      } else {
        return "Address not available";
      }
    } catch (error) {
      print("Error fetching address: $error");
      return "Address not available";
    }
  }

  Future<String> fetchPolyline(LatLng origin, LatLng destination) async {
    // Define the HERE API key
    const String apiKey = 'JS01D6eK9YAqYsGFnKkzT6mYhyWu_hLL3XdkDRSSswM';

    // Build the HERE API URL with the origin and destination
    final String url =
        'https://router.hereapi.com/v8/routes?transportMode=car&return=polyline,summary&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&apiKey=$apiKey';

    // Send the GET request
    final response = await http.get(Uri.parse(url));

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = json.decode(response.body);

      // Extract the polyline string from the response
      String polyline = data['routes'][0]['sections'][0]['polyline'];
      print(polyline);
      return polyline;
    } else {
      throw Exception('Failed to fetch polyline');
    }
  }
}
