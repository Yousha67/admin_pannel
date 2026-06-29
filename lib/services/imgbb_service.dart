import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgBBService {
  static const String _apiKey = 'e17751ff7fc53a61de7839fdb73d5f80'; // Using a placeholder or existing key if found
  static const String _url = 'https://api.imgbb.com/1/upload';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields['key'] = _apiKey;
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['data']['url'];
      } else {
        print('ImgBB upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      return null;
    }
  }
}
