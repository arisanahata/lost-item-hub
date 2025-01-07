import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_repository.g.dart';

class ItemApiRepository {
  late final String baseUrl;

  ItemApiRepository() {
    print('\nAPIリポジトリ - 初期化:');
    print('  プラットフォーム: ${Platform.operatingSystem}');

    // iOSシミュレータ用のURLを強制的に使用
    baseUrl = 'http://127.0.0.1:8080';
    print('  選択されたURL: $baseUrl');
  }

  Future<void> createItem({
    required String name,
    String? color,
    String? description,
    bool? needsReceipt,
    required String routeName,
    required String vehicleNumber,
    String? otherLocation,
    required List<String> images,
    required String finderName,
    String? finderContact,
    String? finderPostalCode,
    String? finderAddress,
    int? cash,
  }) async {
    final requestBody = {
      'itemName': name,
      'color': color ?? '',
      'description': description ?? '',
      'needsReceipt': needsReceipt ?? false,
      'routeName': routeName,
      'vehicleNumber': vehicleNumber,
      'otherLocation': otherLocation,
      'images': images,
      'finderName': finderName,
      'finderContact': finderContact,
      'finderPostalCode': finderPostalCode,
      'finderAddress': finderAddress,
      'cash': cash,
    };

    print('\nAPIリポジトリ - createItem:');
    print('  URL: $baseUrl/items');
    print('  リクエストボディ: $requestBody');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/items'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 201) {
        throw Exception('API呼び出し失敗: ${response.body}');
      }
    } catch (e) {
      print('  エラー発生: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items'));

    if (response.statusCode == 200) {
      final List<dynamic> items = jsonDecode(response.body);
      return items.cast<Map<String, dynamic>>();
    }
    throw Exception('API呼び出し失敗: ${response.body}');
  }

  Future<Map<String, dynamic>> getItem(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/items/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('API呼び出し失敗: ${response.body}');
  }
}

@Riverpod(keepAlive: true)
ItemApiRepository itemApiRepository(ItemApiRepositoryRef ref) {
  return ItemApiRepository();
}
