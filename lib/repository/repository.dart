import 'dart:convert' show jsonDecode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_wandroid/models/models.dart';

import 'exceptions.dart';

final repositoryProvider = Provider((_) => Repository());

class Repository {
  Uri _buildUrl(String path) => Uri.parse('https://www.wanandroid.com$path');

  dynamic _obtainData(http.Response response) {
    final json = jsonDecode(response.body);
    int code = json['errorCode'];
    if (code != 0) {
      String message = json['errorMsg'];
      throw ApiException(code: code, message: message);
    }
    return json['data'];
  }

  Future<List<Article>> fetchArticles(int page, int cid) async {
    final response =
        await http.get(_buildUrl('/article/list/$page/json?cid=$cid'));
    final List<dynamic> dataList = _obtainData(response)['datas'];
    return dataList.map((data) => Article.fromJson(data)).toList();
  }

  Future<List<Chapter>> fetchChapters() async {
    final response = await http.get(_buildUrl('/tree/json'));
    final List<dynamic> dataList = _obtainData(response);
    return dataList.map((data) => Chapter.fromJson(data)).toList();
  }
}
