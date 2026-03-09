import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  // 不设置 UA，用 Dart 默认
  try {
    final req = await client.getUrl(Uri.parse('https://news.iwara.tv/'));
    final resp = await req.close();
    print('Dart HttpClient Status: ${resp.statusCode}');
    final body = await resp.transform(utf8.decoder).join();
    print('Preview: ${body.substring(0, body.length > 400 ? 400 : body.length)}...');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
