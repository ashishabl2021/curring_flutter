// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:curring_flutter/create_schedule.dart';
import 'package:curring_flutter/userprofile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // _LoginPageState createState() => _LoginPageState();
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    try {
      final response = await http.post(
        Uri.parse('http://114.143.219.69:8882/curing/loginapi/'),
        headers: {
          'Authorization': basicAuth,
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        // Successful login
        final responseData = json.decode(response.body);
        // ignore: unused_local_variable
        final status = responseData['status'];
        // ignore: unused_local_variable
        final message = responseData['message'];

        if (responseData.containsKey('message') &&
            responseData['message'] == 'Login successful') {
          // Navigate to the CreateSchedulePage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfile(
                username: username,
                password: password,
              ),
            ),
          );
        } else {
          _showSnackbar(context, 'Incorrect credentials');
        }
      } else {
        // Handle non-200 status code
        final responseData = json.decode(response.body);
        // ignore: unused_local_variable
        final status = responseData['status'];
        // ignore: unused_local_variable
        final message = responseData['message'];

        _showSnackbar(context, 'Login failed');
      }
    } catch (e) {
      // Handle network or request error
      setState(() {
        _isLoading = false;
      });

      // _showSnackbar(context, 'Error: $e');
      _showSnackbar(context, 'Error: Network Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curring Appication'),
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
                          'Sign In',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _login(context),
                          child: _isLoading
                              ? const Text('Logging in...')
                              : const Text('Login'),
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
