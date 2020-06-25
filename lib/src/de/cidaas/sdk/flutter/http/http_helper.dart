import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class HTTPHelper {
  static http.Client httpClient = http.Client();

  HTTPHelper({http.Client httpClient}) {
    HTTPHelper.httpClient = httpClient ?? http.Client();
  }

  static Future<dynamic> postData({
    String url,
    Map<String, Object> data,
    Map<String, String> headers,
  }) async {
    try {
      final Map<String, String> _headers = <String, String> {
        'content-type': 'application/json',
      };

      if (headers != null && headers.isNotEmpty) {
        for (final String header in headers.keys) {
          _headers[header] = headers[header];
        }
      }

      final http.Response response = await httpClient.post(
        url,
        body: data == null ? null : json.encode(data),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> getData({
    String url,
    Map<String, String> headers,
  }) async {
    try {
      final Map<String, String> _headers = <String, String> {
        'content-type': 'application/json',
      };

      if (headers != null && headers.isNotEmpty) {
        for (final String header in headers.keys) {
          _headers[header] = headers[header];
        }
      }

      final http.Response response = await httpClient.get(
        url,
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}
