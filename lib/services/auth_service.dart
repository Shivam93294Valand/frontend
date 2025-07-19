import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.20.61.166:5000/api'; // For physical device
  // static const String baseUrl = 'http://localhost:5000/api'; // For web and development
  // static const String baseUrl = 'http://10.0.2.2:5000/api'; // For Android emulator
  
  final Dio _dio = Dio();
  
  AuthService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Add response interceptor for debugging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Request: ${options.method} ${options.path}');
          print('Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('Response: ${response.statusCode} ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('Error: ${error.response?.statusCode} ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Password validation
  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Username validation
  String? _validateUsername(String username) {
    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (username.contains(' ')) {
      return 'Username cannot contain spaces';
    }
    return null;
  }

  // Login function
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Save token and user data to local storage
        await _saveAuthData(data['token'], data['user']);
        
        return {
          'success': true,
          'data': data,
          'message': 'Login successful'
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed'
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? 'Login failed';
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Unable to connect to server. Please check your network connection.';
      }
      
      return {
        'success': false,
        'message': errorMessage
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred'
      };
    }
  }

  // Signup function
  Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        
        // Save token and user data to local storage
        await _saveAuthData(data['token'], data['user']);
        
        return {
          'success': true,
          'data': data,
          'message': 'Account created successfully'
        };
      } else {
        return {
          'success': false,
          'message': 'Signup failed'
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Signup failed';
      
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? 'Signup failed';
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Unable to connect to server. Please check your network connection.';
      }
      
      return {
        'success': false,
        'message': errorMessage
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred'
      };
    }
  }

  // Save authentication data to local storage
  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user));
  }

  // Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get saved user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // Get authorization header
  Future<Map<String, String>?> getAuthHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return null;
  }

  // Public validation methods
  bool isValidEmail(String email) => _isValidEmail(email);
  String? validatePassword(String password) => _validatePassword(password);
  String? validateUsername(String username) => _validateUsername(username);
}
