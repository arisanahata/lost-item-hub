import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'item_repository.g.dart';

class ItemApiRepository {
  static const _baseUrl = 'http://127.0.0.1:8080';
  static const _itemsPath = '/items';

  String get baseUrl => _baseUrl;

  Future<void> submit(
      Map<String, dynamic> formData, List<String> imageIds) async {
    print('ItemApiRepository - フォームを送信:');
    print('  フォームデータ: $formData');
    print('  画像ID: ${imageIds.length}枚');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_itemsPath'),
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
    final url = '$_baseUrl$_itemsPath';
    final data = {
      'itemName': name,
      'itemDescription': description,
      'location': location,
      'date': date.toIso8601String(),
      'images': images,
    };

    final jsonData = jsonEncode(data);

    print('\n=== APIリクエスト ===');
    print('URL: $url');
    print('Method: POST');
    print('Headers: Content-Type: application/json');
    print('Body: $jsonData');
    print('\nCurl command:');
    print('curl -X POST \\');
    print('  $url \\');
    print('  -H "Content-Type: application/json" \\');
    print('  -d \'$jsonData\'');
    print('==================\n');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      print('\n=== APIレスポンス ===');
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================\n');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('APIエラー: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('APIリクエストエラー: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final response = await http.get(Uri.parse('$_baseUrl$_itemsPath'));

    if (response.statusCode == 200) {
      final List<dynamic> items = jsonDecode(response.body);
      return items.cast<Map<String, dynamic>>();
    }
    throw Exception('APIエラー: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getItem(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl$_itemsPath/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('APIエラー: ${response.statusCode}');
  }
}

@riverpod
ItemApiRepository itemApiRepository(ItemApiRepositoryRef ref) {
  return ItemApiRepository();
}
