// lib/core/services/deep_link_service.dart

import 'package:flutter/material.dart';

class DeepLinkService {
  static void handleResetPasswordLink(BuildContext context, String url) {
    try {
      final uri = Uri.parse(url);

      // Extract access token from URL
      String? accessToken;

      // Check for access_token in fragment
      if (uri.fragment.isNotEmpty) {
        final fragmentParams = Uri.splitQueryString(uri.fragment);
        accessToken = fragmentParams['access_token'];
      }

      // Check for access_token in query parameters
      accessToken ??= uri.queryParameters['access_token'];

      if (accessToken != null) {
        // Navigate to reset password page with token
        Navigator.pushNamed(context, '/reset-password', arguments: accessToken);
      } else {
        // Navigate to forgot password page if no token
        Navigator.pushNamed(context, '/forgot-password');
      }
    } catch (e) {
      // If URL parsing fails, navigate to login
      Navigator.pushNamed(context, '/login');
    }
  }

  static bool isResetPasswordLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.path.contains('reset') ||
          uri.fragment.contains('access_token') ||
          uri.queryParameters.containsKey('access_token');
    } catch (e) {
      return false;
    }
  }
}
