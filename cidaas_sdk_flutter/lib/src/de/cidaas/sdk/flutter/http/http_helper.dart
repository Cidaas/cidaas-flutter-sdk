import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class HTTPHelper {
  static Future<dynamic> postData({
    String url,
    Map<String, Object> data,
    Map<String, String> headers,
  }) async {
    try {
      Map<String, String> _headers = {
        'content-type': 'application/json',
      };

      if (headers != null && headers.isNotEmpty) {
        for (var header in headers.keys) {
          _headers[header] = headers[header];
        }
      }

      final response = await http.post(
        url,
        body: data == null ? null : json.encode(data),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<dynamic> getData({
    String url,
    Map<String, String> headers,
  }) async {
    try {
      Map<String, String> _headers = {
        'content-type': 'application/json',
      };

      if (headers != null && headers.isNotEmpty) {
        for (var header in headers.keys) {
          _headers[header] = headers[header];
        }
      }

      final response = await http.get(
        url,
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
