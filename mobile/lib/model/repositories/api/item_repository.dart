import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'item_repository.g.dart';

class ItemApiRepository {
  static const _baseUrl = 'http://localhost:3000/api';

  String get baseUrl => _baseUrl;

  Future<void> submit(Map<String, dynamic> formData, List<String> imageIds) async {
    print('ItemApiRepository - フォームを送信:');
    print('  フォームデータ: $formData');
    print('  画像ID: ${imageIds.length}枚');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...formData,
          'images': imageIds,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('APIエラー: ${response.statusCode}');
      }

      print('  送信完了');
    } catch (e) {
      print('  送信エラー: $e');
      rethrow;
    }
  }

  Future<void> createItem({
    required String name,
    required String description,
    required String location,
    required DateTime date,
    required List<String> images,
  }) async {
    final requestBody = {
      'name': name,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'images': images,
    };

    print('\nAPIリポジトリ - createItem:');
    print('  URL: $_baseUrl/items');
    print('  リクエストボディ: $requestBody');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/items'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('APIエラー: ${response.statusCode}\n${response.body}');
      }

      print('  送信完了');
    } catch (e) {
      print('  送信エラー: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final response = await http.get(Uri.parse('$_baseUrl/items'));

    if (response.statusCode == 200) {
      final List<dynamic> items = jsonDecode(response.body);
      return items.cast<Map<String, dynamic>>();
    }
    throw Exception('APIエラー: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getItem(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/items/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('APIエラー: ${response.statusCode}');
  }
}

@Riverpod(keepAlive: true)
ItemApiRepository itemApiRepository(ItemApiRepositoryRef ref) {
  return ItemApiRepository();
}
