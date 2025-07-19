import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:social_media_app/data/reel_model.dart';

class ReelsService {
  static const String baseUrl = 'http://10.20.61.166:5000/api'; // Your computer's IP address for physical device
  
  // Get all reels
  static Future<List<ReelModel>> getAllReels({int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reels?page=$page&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> reelsData = data['data'];
          return reelsData.map((reelJson) => ReelModel.fromBackend(reelJson)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch reels');
        }
      } else {
        throw Exception('Failed to fetch reels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create a new reel
  static Future<ReelModel> createReel({
    required File videoFile,
    String? caption,
    List<String>? hashtags,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reels'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      // Add video file
      request.files.add(
        await http.MultipartFile.fromPath('video', videoFile.path),
      );

      // Add other fields
      if (caption != null && caption.isNotEmpty) {
        request.fields['caption'] = caption;
      }
      if (hashtags != null && hashtags.isNotEmpty) {
        request.fields['hashtags'] = hashtags.join(',');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ReelModel.fromBackend(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create reel');
        }
      } else {
        throw Exception('Failed to create reel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Like/Unlike a reel
  static Future<Map<String, dynamic>> toggleLike({
    required String reelId,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reels/$reelId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to toggle like');
        }
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete a reel
  static Future<void> deleteReel({
    required String reelId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reels/$reelId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete reel');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get a specific reel
  static Future<ReelModel> getReel(String reelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reels/$reelId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ReelModel.fromBackend(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch reel');
        }
      } else {
        throw Exception('Failed to fetch reel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
