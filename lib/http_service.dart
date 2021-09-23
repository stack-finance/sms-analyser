import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class HttpService {
  static final String _baseUrl = '<API_URL>';
  static Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json'
  };

  static Future<dynamic> makePostReq(String url, dynamic payload) async {
    try {
      Response response = await post(
        (_baseUrl + url) as Uri,
        headers: headers,
        body: payload,
      );
      return _responseData(response);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e);
    }
  }

  static dynamic _responseData(Response response) {
    var responseJson = json.decode(response.body);
    switch (response.statusCode) {
      case 200:
        if (responseJson['error'] == null) {
          return responseJson['data'];
        }
        throw Exception(responseJson['message']);
      case 401:
      case 403:
        throw Exception(responseJson['message']);
      case 404:
      case 500:
        throw Exception(responseJson['message']);
      default:
        throw Exception(responseJson['message']);
    }
  }
}
