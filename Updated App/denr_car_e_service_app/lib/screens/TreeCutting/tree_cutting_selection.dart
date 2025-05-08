import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/goverment.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/private_land.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/pruning.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/public_safety.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/special_tree.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart'; // Assuming this is the correct import

class TreeCuttingForm extends StatefulWidget {
  final LatLng geoP;
  final String address;
  final Map<String, dynamic> polygonName;
  final String inside;
  const TreeCuttingForm({
    super.key,
    required this.address,
    required this.geoP,
    required this.polygonName,
    required this.inside,
  });

  @override
  _TreeCuttingFormState createState() => _TreeCuttingFormState();
}

class _TreeCuttingFormState extends State<TreeCuttingForm> {
  String? _purpose;
  String? _landStatus;
  String? _treeCategory;
  final _treeCountController = TextEditingController();
  final _speciesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _showInfoDialog();
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
                "Please select 'None' in Land Status and Tree Category if your applying for Prunning.",
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

  final List<String> _purposes = [
    'Affected by development',
    'Public Safety-Cutting/Removal',
    'Public Safety-Pruning',
  ];

  final List<String> _landStatuses = [
    'Private Lot (Titled only)',
    'Public places',
    'Resettlement areas and economic zones',
    'Tenured Areas',
    'Other public lands / forestlands',
    'None',
  ];

  final List<String> _treeCategories = ['Planted', 'Naturally grown', 'None'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tree Cutting Permit Form',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17), // Scale text size
          ),
        ),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDropdownField(
                      title: 'Select Purpose:',
                      value: _purpose,
                      hint: 'Choose Purpose',
                      items: _purposes,
                      onChanged: (value) => setState(() => _purpose = value),
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(
                      title: 'Select Land Status:',
                      value: _landStatus,
                      hint: 'Choose Land Status',
                      items: _landStatuses,
                      onChanged: (value) => setState(() => _landStatus = value),
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(
                      title: 'Select Tree Category:',
                      value: _treeCategory,
                      hint: 'Choose Tree Category',
                      items: _treeCategories,
                      onChanged:
                          (value) => setState(() => _treeCategory = value),
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      title: 'Number of Trees Applied for Cutting:',
                      controller: _treeCountController,
                      hint: 'Enter Number of Trees',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      title: 'Name of Tree Species Applied for Cutting:',
                      controller: _speciesController,
                      hint: 'Enter Tree Species',
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            hint: Text(hint),
            items:
                items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String title,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            labelText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    // Check if all fields are filled
    if (_purpose != null &&
        _landStatus != null &&
        _treeCategory != null &&
        _treeCountController.text.isNotEmpty &&
        _speciesController.text.isNotEmpty) {
      if (_purpose == 'Public Safety-Cutting/Removal') {
        if (_landStatus == 'Public places') {
          if (_treeCategory == 'Planted' ||
              _treeCategory == 'Naturally grown') {
            //1
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => PublicSafetyScreen(
                      geoP: widget.geoP,
                      address: widget.address,
                      polygonName: widget.polygonName,
                      purpose: _purpose!,
                      landStatus: _landStatus!,
                      treeCategory: _treeCategory!,
                      treeCount: _treeCountController.text.trim(),
                      treeSpecies: _speciesController.text.trim(),
                      authority: 'CENRO',
                    ),
              ),
            );
          }
        }
        if (_landStatus == 'Private Lot (Titled only)') {
          if (_treeCategory == 'Planted') {
            if (widget.inside == 'True') {
              //3
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PublicSafetyScreen(
                        geoP: widget.geoP,
                        address: widget.address,
                        polygonName: widget.polygonName,
                        purpose: _purpose!,
                        landStatus: _landStatus!,
                        treeCategory: _treeCategory!,
                        treeCount: _treeCountController.text.trim(),
                        treeSpecies: _speciesController.text.trim(),
                        authority: 'PENRO',
                      ),
                ),
              );
            } else {
              //2
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PublicSafetyScreen(
                        geoP: widget.geoP,
                        address: widget.address,
                        polygonName: widget.polygonName,
                        purpose: _purpose!,
                        landStatus: _landStatus!,
                        treeCategory: _treeCategory!,
                        treeCount: _treeCountController.text.trim(),
                        treeSpecies: _speciesController.text.trim(),
                        authority: 'CENRO',
                      ),
                ),
              );
            }
          } else if (_treeCategory == 'Naturally grown') {
            //4
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => PublicSafetyScreen(
                      geoP: widget.geoP,
                      address: widget.address,
                      polygonName: widget.polygonName,
                      purpose: _purpose!,
                      landStatus: _landStatus!,
                      treeCategory: _treeCategory!,
                      treeCount: _treeCountController.text.trim(),
                      treeSpecies: _speciesController.text.trim(),
                      authority: 'RED',
                    ),
              ),
            );
          }
        }
        if (_landStatus == 'Private Lot (Titled only) ' ||
            _landStatus == 'Public places ') {
          if (_treeCategory == 'Planted' ||
              _treeCategory == 'Naturally grown') {
            if (widget.inside == 'True' || widget.inside == 'False') {
              //5
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PublicSafetyScreen(
                        geoP: widget.geoP,
                        address: widget.address,
                        polygonName: widget.polygonName,
                        purpose: _purpose!,
                        landStatus: _landStatus!,
                        treeCategory: _treeCategory!,
                        treeCount: _treeCountController.text.trim(),
                        treeSpecies: _speciesController.text.trim(),
                        authority: 'RED',
                      ),
                ),
              );
            }
          }
        }
      } else if (_purpose == 'Affected by development') {
        if (_landStatus == 'Private Lot (Titled only)') {
          if (_treeCategory == 'Planted') {
            //7
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => PrivateLandScreen(
                      geoP: widget.geoP,
                      address: widget.address,
                      polygonName: widget.polygonName,
                      purpose: _purpose!,
                      landStatus: _landStatus!,
                      treeCategory: _treeCategory!,
                      treeCount: _treeCountController.text.trim(),
                      treeSpecies: _speciesController.text.trim(),
                      authority: 'CENRO',
                    ),
              ),
            );
          } else if (_treeCategory == 'Naturally grown') {
            //8
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => PrivateLandScreen(
                      geoP: widget.geoP,
                      address: widget.address,
                      polygonName: widget.polygonName,
                      purpose: _purpose!,
                      landStatus: _landStatus!,
                      treeCategory: _treeCategory!,
                      treeCount: _treeCountController.text.trim(),
                      treeSpecies: _speciesController.text.trim(),
                      authority: 'RED',
                    ),
              ),
            );
          } else if (_treeCategory == 'Naturally grown' ||
              _treeCategory == 'Planted') {
            if (widget.inside == 'True') {
              //9
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PrivateLandScreen(
                        geoP: widget.geoP,
                        address: widget.address,
                        polygonName: widget.polygonName,
                        purpose: _purpose!,
                        landStatus: _landStatus!,
                        treeCategory: _treeCategory!,
                        treeCount: _treeCountController.text.trim(),
                        treeSpecies: _speciesController.text.trim(),
                        authority: 'PENRO',
                      ),
                ),
              );
            }
          }
        } else if (_landStatus == 'Public places' ||
            _landStatus == 'Other public lands / forestlands') {
          if (_treeCategory == 'Planted' ||
              _treeCategory == 'Naturally grown') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => GovermentScreen(
                      geoP: widget.geoP,
                      address: widget.address,
                      polygonName: widget.polygonName,
                      purpose: _purpose!,
                      landStatus: _landStatus!,
                      treeCategory: _treeCategory!,
                      treeCount: _treeCountController.text.trim(),
                      treeSpecies: _speciesController.text.trim(),
                      authority: 'CENRO',
                    ),
              ),
            );
          }
        } else if (_landStatus == 'Resettlement areas and economic zones' ||
            _landStatus == 'Other public lands / forestlands' ||
            _landStatus == 'Tenured Areas') {
          if (_treeCategory == 'Naturally grown') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => SpecialTree(
                      geoP: widget.geoP,
                      address: widget.address,
                      polygonName: widget.polygonName,
                      purpose: _purpose!,
                      landStatus: _landStatus!,
                      treeCategory: _treeCategory!,
                      treeCount: _treeCountController.text.trim(),
                      treeSpecies: _speciesController.text.trim(),
                      authority: 'RED',
                    ),
              ),
            );
          }
        }
      } else if (_purpose == 'Public Safety-Pruning') {
        if (_landStatus == 'None') {
          if (_treeCategory == 'None') {
            //6
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => Pruning(
                      geoP: widget.geoP,
                      address: widget.address,
                      polygonName: widget.polygonName,
                      purpose: _purpose!,
                      landStatus: _landStatus!,
                      treeCategory: _treeCategory!,
                      treeCount: _treeCountController.text.trim(),
                      treeSpecies: _speciesController.text.trim(),
                      authority: 'CENRO',
                    ),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Select None if you want to choose Prunning Permit.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
    }
  }
}
