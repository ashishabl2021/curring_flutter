import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogoutPage extends StatefulWidget {
  final String username;
  final String password;

  const LogoutPage({Key? key, required this.username, required this.password})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LogoutPageState createState() => _LogoutPageState();

  static Future<void> logout(
      BuildContext context, String username, String password) async {
    // bool isLoading = true;

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final response = await http.post(
      Uri.parse('http://114.143.219.69:8882/curing/logoutapi/'),
      headers: {
        'Authorization': basicAuth,
      },
    );

    // isLoading = false;

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        final status = responseData['status'];
        final message = responseData['message'];
        if (kDebugMode) {
          print('Logout status: $status');
          print('Message: $message');
        }

        if (responseData.containsKey('message') &&
            responseData['message'] == 'Logout successful') {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Logout failed')));
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding response body: $e');
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error decoding response')));
      }
    } else {
      final responseData = json.decode(response.body);
      final status = responseData['status'];
      final message = responseData['message'];
      if (kDebugMode) {
        print('Logout status: $status');
        print('Error message: $message');
        print('Response body: ${response.body}');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Logout failed')));
    }
  }
}

class _LogoutPageState extends State<LogoutPage> {
  final _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 5.0,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                        ? const LinearProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => LogoutPage.logout(
                                  context, widget.username, widget.password),
                          child: _isLoading
                              ? const Text('Logging out...')
                              : const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
