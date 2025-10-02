import 'dart:convert';
import 'package:http/http.dart' as http;

class Market {
  final String state;
  final String district;
  final String commodity;
  final String variety;
  final String market;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String date;

  Market({
    required this.state,
    required this.district,
    required this.commodity,
    required this.variety,
    required this.market,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.date,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      commodity: json['commodity'] ?? '',
      variety: json['variety'] ?? '',
      market: json['market'] ?? '',
      minPrice: double.tryParse(json['min_price'].toString()) ?? 0.0,
      maxPrice: double.tryParse(json['max_price'].toString()) ?? 0.0,
      modalPrice: double.tryParse(json['modal_price'].toString()) ?? 0.0,
      date: json['arrival_date'] ?? '',
    );
  }
}

class MarketService {
  static const String _apiKey = '579b464db66ec23bdd0000012277b67695ab4474619e36d7d7269c18';
  static const String _baseUrl = 'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070';

  Future<Map<String, dynamic>> getMarketPrices({
    String? state,
    String? district,
    String? commodity,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'api-key': _apiKey,
        'format': 'json',
        'limit': limit.toString(),
        'offset': '0',
      };
      if (state != null) queryParams['filters[state]'] = state.trim();
      if (district != null) queryParams['filters[district]'] = district.trim();
      if (commodity != null) queryParams['filters[commodity]'] = commodity.trim();

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['records'] != null) {
          return data;
        }
        return {'records': []};
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      return {'records': []};
    }
  }

  Future<List<String>> getStates() async {
    final data = await getMarketPrices(limit: 1000);
    final records = List<Map<String, dynamic>>.from(data['records']);
    return records
        .map((record) => record['state'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<String>> getDistricts(String state) async {
    final data = await getMarketPrices(state: state, limit: 1000);
    final records = List<Map<String, dynamic>>.from(data['records']);
    return records
        .map((record) => record['district'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<String>> getCommodities() async {
    final data = await getMarketPrices(limit: 1000);
    final records = List<Map<String, dynamic>>.from(data['records']);
    return records
        .map((record) => record['commodity'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<Market>> getFormattedMarketPrices({
    String? state,
    String? district,
    String? commodity,
    int limit = 10,
  }) async {
    final data = await getMarketPrices(
      state: state,
      district: district,
      commodity: commodity,
      limit: limit,
    );

    final records = List<Map<String, dynamic>>.from(data['records']);
    return records.map((record) => Market.fromJson(record)).toList();
  }

  Future<Map<String, List<String>>> getStateDistrictMap() async {
    final data = await getMarketPrices(limit: 1000);
    final records = List<Map<String, dynamic>>.from(data['records']);
    
    Map<String, List<String>> stateDistrictMap = {};
    for (var record in records) {
      final state = record['state'] as String;
      final district = record['district'] as String;
      
      if (!stateDistrictMap.containsKey(state)) {
        stateDistrictMap[state] = [];
      }
      if (!stateDistrictMap[state]!.contains(district)) {
        stateDistrictMap[state]!.add(district);
      }
    }

    // Sort districts for each state
    stateDistrictMap.forEach((key, value) => value.sort());
    return stateDistrictMap;
  }

  Future<Map<String, List<String>>> getCommodityVarietyMap() async {
    final data = await getMarketPrices(limit: 1000);
    final records = List<Map<String, dynamic>>.from(data['records']);
    
    Map<String, List<String>> commodityVarietyMap = {};
    for (var record in records) {
      final commodity = record['commodity'] as String;
      final variety = record['variety'] as String;
      
      if (!commodityVarietyMap.containsKey(commodity)) {
        commodityVarietyMap[commodity] = [];
      }
      if (!commodityVarietyMap[commodity]!.contains(variety)) {
        commodityVarietyMap[commodity]!.add(variety);
      }
    }

    // Sort varieties for each commodity
    commodityVarietyMap.forEach((key, value) => value.sort());
    return commodityVarietyMap;
  }

  Future<List<String>> getCommoditiesForState(String? state) async {
    final data = await getMarketPrices(state: state, limit: 1000);
    final records = List<Map<String, dynamic>>.from(data['records']);
    return records
        .map((record) => record['commodity'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<String>> getCommoditiesForStateDistrict(String? state, String? district) async {
    final data = await getMarketPrices(state: state, district: district, limit: 1000);
    final records = List<Map<String, dynamic>>.from(data['records']);
    return records
        .map((record) => record['commodity'] as String)
        .toSet()
        .toList()
      ..sort();
  }
}
