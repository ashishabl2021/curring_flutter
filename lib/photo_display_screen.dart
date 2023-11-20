import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhotoScreen extends StatefulWidget {
  final List<String> imageUrls;
  final String username;
  final String password;

  PhotoScreen({
    required this.imageUrls,
    required this.username,
    required this.password,
  });

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late Future<List<Uint8List>> imagesFuture;

  @override
  void initState() {
    super.initState();
    imagesFuture = loadImages();
  }

  Future<List<Uint8List>> loadImages() async {
    final username = widget.username;
    final password = widget.password;
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final imageFutures = widget.imageUrls.map((imageUrl) async {
      final imageResponse = await http.get(Uri.parse(imageUrl), headers: {
        'Authorization': basicAuth,
      });

      if (imageResponse.statusCode == 200) {
        return Uint8List.fromList(imageResponse.bodyBytes);
      } else {
        print('Failed to fetch image: Status code ${imageResponse.statusCode}');
        throw Exception('Failed to fetch image');
      }
    });

    return Future.wait(imageFutures);
  }

  String getImageNameFromUrl(String imageUrl) {
    // Split the URL using '/' and remove any empty segments
    final segments =
        imageUrl.split('/').where((segment) => segment.isNotEmpty).toList();

    // If there are segments left after filtering, use the last one as the image name
    if (segments.isNotEmpty) {
      return segments.last;
    }

    // If no segments are found, return a default name or an empty string
    return 'UnknownImageName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
      ),
      body: FutureBuilder<List<Uint8List>>(
        future: imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final imageBytes = snapshot.data![index];
                final imageName = getImageNameFromUrl(widget.imageUrls[index]);
                return GestureDetector(
                  onTap: () {
                    _showImageDialog(imageName, imageBytes);
                  },
                  child: Card(
                    elevation: 3,
                    child: Column(
                      children: [
                        Image.memory(imageBytes),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading images'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _showImageDialog(String imageName, Uint8List imageBytes) async {
    final username = widget.username;
    final password = widget.password;
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final apiUrl = 'http://114.143.219.69:8882/curing/imageinfo/$imageName/';
    final response = await http.get(Uri.parse(apiUrl), headers: {
      'Authorization': basicAuth,
    });

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      final latitude = responseBody[0]['latitude'];
      final longitude = responseBody[0]['longitude'];
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.memory(imageBytes),
                  Text('latitude : $latitude'),
                  Text('longitude : $longitude'),
                  ElevatedButton(
                    onPressed: () {
                      openGoogleMaps('$latitude', '$longitude');
                    },
                    child: const Text('See Image Location'),
                  )
                ],
              ),
            ),
          );
        },
      );
    } else {
      print('Failed to fetch API data: Status code ${response.statusCode}');
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch API data'),
          );
        },
      );
    }
  }

  void openGoogleMaps(String _latitude, String _longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    }
  }
}
