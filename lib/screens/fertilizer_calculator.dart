import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:easy_localization/easy_localization.dart';

class FertilizerCalculatorScreen extends StatefulWidget {
  const FertilizerCalculatorScreen({super.key});

  @override
  _FertilizerCalculatorScreenState createState() => _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState extends State<FertilizerCalculatorScreen> {
  List<Map<String, String>> _cropData = [];
  String? _selectedCrop;
  String? _selectedSoilType;
  double _area = 0.0;
  Map<String, double> _fertilizerNeeds = {};
  String _pHRange = '';
  String _irrigationInterval = '';

  @override
  void initState() {
    super.initState();
    _loadCropData();
  }

  Future<void> _loadCropData() async {
    try {
      final String rawData = await rootBundle.loadString('assets/crop_manure_data.csv');
      List<String> lines = rawData.split('\n');
      List<String> headers = lines[0].split(',');

      setState(() {
        _cropData = lines.skip(1).where((line) => line.isNotEmpty).map((line) {
          List<String> values = line.split(',');
          return Map.fromIterables(
              headers.map((e) => e.trim()), values.map((e) => e.trim()));
        }).toList();
      });
      print('✅ Loaded ${_cropData.length} crop records');
    } catch (e) {
      print('❌ Error loading crop data: $e');
    }
  }

  void _calculateFertilizer() {
    if (_selectedCrop != null && _selectedSoilType != null && _area > 0) {
      final cropInfo = _cropData.firstWhere(
        (crop) =>
            crop['Crop_Name']?.trim() == _selectedCrop?.trim() &&
            crop['Soil_Type']?.trim() == _selectedSoilType?.trim(),
        orElse: () => {},
      );

      if (cropInfo.isNotEmpty) {
        setState(() {
          _fertilizerNeeds = {
            'Nitrogen (N)': double.parse(cropInfo['CurrentNPK_kg'] ?? '0') * _area * 0.03,
            'Phosphorus (P)': double.parse(cropInfo['CurrentNPK_kg'] ?? '0') * _area * 0.01,
            'Potassium (K)': double.parse(cropInfo['CurrentNPK_kg'] ?? '0') * _area * 0.01,
            'Farmyard Manure': double.parse(cropInfo['FYM_kg'] ?? '0') * _area,
            'Vermicompost': double.parse(cropInfo['Vermicompost_kg'] ?? '0') * _area,
            'Neem Cake': double.parse(cropInfo['Neem_Cake_kg'] ?? '0') * _area,
          };

          _pHRange = cropInfo['pH_Range'] ?? 'N/A';
          _irrigationInterval = cropInfo['Irrigation_Interval_Days'] ?? 'N/A';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calculate_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text("Fertilizer Calculator", style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'fertilizer.crop_type'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        hint: Text('fertilizer.select_crop'.tr()),
                        value: _selectedCrop,
                        isExpanded: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.grass, color: Color(0xFF2E7D32)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _cropData
                            .map((crop) => crop['Crop_Name']?.trim())
                            .where((cropName) => cropName != null && cropName.isNotEmpty)
                            .toSet()
                            .map((cropName) => DropdownMenuItem(
                                  value: cropName,
                                  child: Text(cropName ?? ''),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedCrop = value;
                            _selectedSoilType = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        hint: Text('fertilizer.select_soil'.tr()),
                        value: _selectedSoilType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.landscape, color: Color(0xFF2E7D32)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _cropData
                            .where((crop) => crop['Crop_Name']?.trim() == _selectedCrop)
                            .map((crop) => crop['Soil_Type']?.trim())
                            .where((soilType) => soilType != null && soilType.isNotEmpty)
                            .toSet()
                            .map((soilType) => DropdownMenuItem(
                                  value: soilType,
                                  child: Text(soilType ?? ''),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedSoilType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'fertilizer.area'.tr(),
                          prefixIcon: const Icon(Icons.area_chart, color: Color(0xFF2E7D32)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _area = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateFertilizer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calculate),
                    SizedBox(width: 8),
                    Text(
                      'Calculate Requirements',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_fertilizerNeeds.isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fertilizer Requirements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const Divider(height: 24),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            for (var entry in _fertilizerNeeds.entries)
                              _buildResultCard(
                                entry.key,
                                '${entry.value.toStringAsFixed(2)} kg',
                                _getIconForFertilizer(entry.key),
                              ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('pH Range', _pHRange, Icons.science),
                        const SizedBox(height: 8),
                        _buildInfoRow('Irrigation Interval', 
                          '$_irrigationInterval days', Icons.water_drop),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  IconData _getIconForFertilizer(String type) {
    switch (type) {
      case 'Nitrogen (N)':
        return Icons.eco;
      case 'Phosphorus (P)':
        return Icons.local_florist;
      case 'Potassium (K)':
        return Icons.spa;
      case 'Farmyard Manure':
        return Icons.compost;
      case 'Vermicompost':
        return Icons.recycling;
      case 'Neem Cake':
        return Icons.nature;
      default:
        return Icons.science;
    }
  }
}
