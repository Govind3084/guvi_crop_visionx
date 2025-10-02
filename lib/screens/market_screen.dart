import 'package:flutter/material.dart';
import '../services/market_service.dart';

class MarketScreen extends StatefulWidget {
  static const String routeName = '/market';

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => MarketScreen(),
    );
  }

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _marketService = MarketService();
  String? selectedState;
  String? selectedDistrict;
  String? selectedCommodity;
  String? selectedCategory;
  List<dynamic> marketData = [];
  bool isLoading = false;

  List<String> states = [];
  List<String> districts = [];
  List<String> commodities = [];
  final List<String> categories = [
    'Grains', 'Fruits', 'Vegetables', 'Dairy', 'Pulses', 'Spices', 'Oilseeds', 'Others'
  ];

  final List<String> indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 
    'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 
    'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh', 
    'Dadra and Nagar Haveli', 'Daman and Diu', 'Delhi', 
    'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  Map<String, List<String>> categorizedCommodities = {
    'Grains': [
      'Rice', 'Wheat', 'Maize', 'Jowar', 'Bajra', 'Ragi',
      'Barley', 'Sorghum', 'Millet', 'Quinoa', 'Other Grains'
    ],
    'Fruits': [
      'Apple', 'Banana', 'Mango', 'Orange', 'Grapes',
      'Papaya', 'Pineapple', 'Pomegranate', 'Watermelon',
      'Guava', 'Litchi', 'Custard Apple', 'Other Fruits'
    ],
    'Vegetables': [
      'Tomato', 'Potato', 'Onion', 'Cabbage', 'Carrot',
      'Cauliflower', 'Brinjal', 'Lady Finger', 'Green Peas',
      'Spinach', 'Bitter Gourd', 'Bottle Gourd', 'Capsicum',
      'Green Chilli', 'Mushroom', 'Sweet Potato', 'Other Vegetables'
    ],
    'Dairy': [
      'Milk', 'Butter', 'Ghee', 'Cheese', 'Curd',
      'Paneer', 'Buttermilk', 'Cream', 'Khoya',
      'Condensed Milk', 'Other Dairy'
    ],
    'Pulses': [
      'Tur Dal', 'Moong Dal', 'Urad Dal', 'Masoor Dal',
      'Chana Dal', 'Rajma', 'Other Pulses'
    ],
    'Spices': [
      'Turmeric', 'Chilli', 'Coriander', 'Cumin',
      'Black Pepper', 'Cardamom', 'Cinnamon',
      'Clove', 'Other Spices'
    ],
    'Oilseeds': [
      'Groundnut', 'Soybean', 'Mustard', 'Sunflower',
      'Sesame', 'Coconut', 'Other Oilseeds'
    ],
    'Others': [
      'Sugar', 'Jaggery', 'Cotton', 'Tobacco',
      'Coffee', 'Tea', 'Other Items'
    ]
  };

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() => isLoading = true);
    try {
      // Always use hardcoded list for full coverage
      states = indianStates;
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        states = indianStates;
        isLoading = false;
      });
      _showError('Failed to load states: $e');
    }
  }

  Future<void> _onStateChanged(String? state) async {
    if (state == null) return;
    setState(() {
      selectedState = state;
      selectedDistrict = null;
      districts = [];
      selectedCommodity = null;
      commodities = [];
      isLoading = true;
    });
    try {
      districts = await _marketService.getDistricts(state);
      // Add default districts if API returns none
      if (districts.isEmpty) {
        if (state == 'Tamil Nadu') {
          districts = [
            'Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem', 'Vellore', 'Erode', 'Tirunelveli'
          ];
        } else if (state == 'Andhra Pradesh') {
          districts = [
            'Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool', 'Kadapa', 'Rajahmundry', 'Anantapur'
          ];
        } else if (state == 'Telangana') {
          districts = [
            'Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam', 'Mahbubnagar', 'Medak', 'Adilabad'
          ];
        }
      }
      commodities = await _marketService.getCommoditiesForState(state);
      // Fallback to default commodities if API returns none
      if (commodities.isEmpty) {
        if (state == 'Tamil Nadu') {
          commodities = ['Rice', 'Sugarcane', 'Cotton', 'Groundnut', 'Banana', 'Onion', 'Tomato'];
        } else if (state == 'Andhra Pradesh') {
          commodities = ['Paddy', 'Maize', 'Cotton', 'Chillies', 'Sugarcane', 'Banana', 'Tomato'];
        } else if (state == 'Telangana') {
          commodities = ['Paddy', 'Maize', 'Cotton', 'Chillies', 'Turmeric', 'Groundnut', 'Tomato'];
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to fetch districts/commodities: $e');
    }
  }

  Future<void> _onDistrictChanged(String? district) async {
    if (district == null) return;
    setState(() {
      selectedDistrict = district;
      selectedCommodity = null;
      commodities = [];
      isLoading = true;
    });
    try {
      commodities = await _marketService.getCommoditiesForStateDistrict(selectedState, district);
      // Fallback to default commodities if API returns none
      if (commodities.isEmpty) {
        if (selectedState == 'Tamil Nadu') {
          commodities = ['Rice', 'Sugarcane', 'Cotton', 'Groundnut', 'Banana', 'Onion', 'Tomato'];
        } else if (selectedState == 'Andhra Pradesh') {
          commodities = ['Paddy', 'Maize', 'Cotton', 'Chillies', 'Sugarcane', 'Banana', 'Tomato'];
        } else if (selectedState == 'Telangana') {
          commodities = ['Paddy', 'Maize', 'Cotton', 'Chillies', 'Turmeric', 'Groundnut', 'Tomato'];
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to fetch commodities: $e');
    }
  }

  bool get canFetchMarketData =>
      selectedCategory != null &&
      selectedState != null &&
      selectedCommodity != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Market Prices', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDropdown(
                        value: selectedCategory,
                        items: categories,
                        label: 'Select Category',
                        icon: Icon(Icons.category, color: Colors.green.shade700),
                        onChanged: _onCategoryChanged,
                      ),
                      const SizedBox(height: 16),
                      if (states.isNotEmpty)
                        _buildDropdown(
                          value: selectedState,
                          items: states,
                          label: 'Select State',
                          icon: Icon(Icons.location_on, color: Colors.green.shade700),
                          onChanged: _onStateChanged,
                        ),
                      if (selectedState != null && districts.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDropdown(
                          value: selectedDistrict,
                          items: districts,
                          label: 'Select District',
                          icon: Icon(Icons.location_city, color: Colors.green.shade700),
                          onChanged: _onDistrictChanged,
                        ),
                      ],
                      if (selectedState != null && selectedDistrict != null && commodities.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDropdown(
                          value: selectedCommodity,
                          items: commodities,
                          label: 'Select Commodity',
                          icon: Icon(Icons.shopping_basket, color: Colors.green.shade700),
                          onChanged: _onCommodityChanged,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchButton(),
              const SizedBox(height: 16),
              Expanded(child: _buildEnhancedMarketList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required Widget icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green.shade700),
          prefixIcon: icon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade200),
          ),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(isLoading ? Icons.hourglass_empty : Icons.search),
        label: Text(isLoading ? 'Fetching...' : 'Fetch Prices'),
        onPressed: canFetchMarketData && !isLoading ? _fetchMarketData : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMarketList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green.shade600),
            const SizedBox(height: 16),
            Text('Fetching market data...',
              style: TextStyle(color: Colors.green.shade700)),
          ],
        ),
      );
    }

    if (marketData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 64, color: Colors.green.shade200),
            const SizedBox(height: 16),
            Text(
              'No market data available\nTry different selections',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: marketData.length,
      itemBuilder: (context, index) {
        final item = marketData[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ExpansionTile(
              title: Text(
                item['market'] ?? 'Unknown Market',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'District: ${item['district'] ?? 'N/A'}',
                style: TextStyle(color: Colors.green.shade700),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPriceRow('Variety', item['variety'] ?? 'N/A'),
                      _buildPriceRow('Minimum Price', '₹${item['min_price'] ?? 'N/A'}'),
                      _buildPriceRow('Maximum Price', '₹${item['max_price'] ?? 'N/A'}'),
                      _buildPriceRow('Modal Price', '₹${item['modal_price'] ?? 'N/A'}'),
                      _buildPriceRow('Date', item['arrival_date'] ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _fetchMarketData() async {
    if (!canFetchMarketData) return;
    setState(() => isLoading = true);
    try {
      final response = await _marketService.getMarketPrices(
        state: selectedState,
        district: selectedDistrict,
        commodity: selectedCommodity,
        limit: 50,
      );

      setState(() {
        marketData = response['records'] ?? [];
        isLoading = false;
      });

      if (marketData.isEmpty) {
        _showMessage('No data available for selected criteria', isError: false);
      }
    } catch (e) {
      setState(() {
        marketData = [];
        isLoading = false;
      });
      _showMessage('Failed to fetch market data: ${e.toString()}', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue,
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Grains':
        return Icons.grass;
      case 'Fruits':
        return Icons.apple;
      case 'Vegetables':
        return Icons.eco;
      case 'Dairy':
        return Icons.water_drop;
      case 'Pulses':
        return Icons.grain;
      case 'Spices':
        return Icons.spa;
      case 'Oilseeds':
        return Icons.water_damage;
      case 'Others':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      selectedCategory = category;
      selectedCommodity = null;
      marketData = [];
    });
  }

  void _onCommodityChanged(String? commodity) {
    setState(() => selectedCommodity = commodity);
    if (selectedState != null && commodity != null) {
      _fetchMarketData();
    }
  }
}
