import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as Http;

class HTTPHelper {
  static Http.Client httpClient = Http.Client();

  HTTPHelper({Http.Client http}) {
    HTTPHelper.httpClient = http ?? Http.Client();
  }

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

      final response = await httpClient.post(
        url,
        body: data == null ? null : json.encode(data),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      throw(e);
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

      final response = await httpClient.get(
        url,
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      throw(e);
    }
  }
}
