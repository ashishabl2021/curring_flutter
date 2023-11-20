import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart'; // Import MediaType class

// import Folder
import 'package:curring_flutter/photo_display_screen.dart';

class trans_concreating {
  final int trans_concreating_id;
  trans_concreating({
    required this.trans_concreating_id,
  });
  factory trans_concreating.fromJson(Map<String, dynamic> json) {
    return trans_concreating(
      trans_concreating_id: json['Transaction_Concreting'],
    );
  }
}

class SchedulTable extends StatefulWidget {
  final String username;
  final String password;
  final trans_concreating;

  const SchedulTable({
    Key? key,
    required this.username,
    required this.password,
    required this.trans_concreating,
  }) : super(key: key);

  @override
  _SchedulTableState createState() => _SchedulTableState();
}

class _SchedulTableState extends State<SchedulTable> {
  // ignore: unused_field
  File? _imageFile;
  List<String> imageUrls = [];
  List<String> filteredImageUrls =
      []; // Declare the filteredImageUrls list at the class level

  List<dynamic> scheduleconcreting = [];
  List<Map<String, dynamic>> tableData = [];
  Map<String, dynamic>? selectedRowData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<List<String>> _fetchlist(Map<String, dynamic> data) async {
    final String username = widget.username;
    final String password = widget.password;

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final url1 =
        Uri.parse('http://114.143.219.69:8882/curing/ImageListApiView/');

    final response = await http.get(url1, headers: {
      'Authorization': basicAuth,
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is Map && responseData.containsKey('image_urls')) {
        List<String> imageUrls = List<String>.from(responseData['image_urls']);

        // Extract schedule_curing_iD from the selected data
        String scheduleCuringID = '${data['Schedule_Curing_ID']}';

        // Filter image URLs based on the schedule_curing_iD
        List<String> filteredImageUrls = imageUrls
            .where((url) => url.contains('/$scheduleCuringID'))
            .toList();

        return filteredImageUrls;
      }
    }

    return []; // Return an empty list if no URLs were found
  }

  Future<void> _captureAndStoreImage(Map<String, dynamic> data) async {
    // Call _fetchlist to get the filteredImageUrls
    List<String> fetchedImageUrls = await _fetchlist(data);

    // Access fetchedImageUrls to check the count
    int clickedImageCount = fetchedImageUrls.length;
    // print('Number of images already clicked for ${data['Schedule_Curing_ID']}: $clickedImageCount');

    final imagePicker = ImagePicker();
    final imageFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (imageFile == null) {
      // Image capture canceled or failed
      return;
    }

    final permissionStatus = await Permission.camera.request();
    final locPermissionStatus = await Permission.location.request();

    if (permissionStatus != PermissionStatus.granted ||
        locPermissionStatus != PermissionStatus.granted) {
      // Handle permission denied case
      return;
    }

    final String username = widget.username;
    final String password = widget.password;
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final url =
        Uri.parse('http://114.143.219.69:8882/curing/your-upload-endpoint/');

    final request = http.MultipartRequest('POST', url);

    // Set Basic Authentication headers
    request.headers['Authorization'] = basicAuth;
    int add = clickedImageCount + 1;
    // Change the name of the file to 'aaa.jpg' before adding it to the request body
    String fileName = '${data['Schedule_Curing_ID']}_$add.jpg';
    request.files.add(
      await http.MultipartFile.fromPath(
        'snap',
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    // Add latitude, longitude, and selected data as fields in the request
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    final latitude = position.latitude;
    final longitude = position.longitude;

    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    request.fields['trans_concreating_id'] =
        data['trans_concreating_id'].toString();

    // print(request.fields['trans_concreating_id']);
    // Include current time
    final DateTime currentTime = DateTime.now();
    request.fields['current_time'] = currentTime.toIso8601String();
    // Include selected data in the request
    request.fields['Schedule_Curing_ID'] =
        data['Schedule_Curing_ID'].toString();
    request.fields['Project_Name'] = data['Project_Name'];
    request.fields['Site_Name'] = data['Site_Name'];
    request.fields['Structural_Element'] = data['Structural_Element'];

    // Conditionally include 'Schedule_Date_and_Time' or 'Custom_slot_date_time'
    if (data['Schedule_Date_and_Time'] != null) {
      request.fields['Schedule_Date_and_Time'] = data['Schedule_Date_and_Time'];
    } else if (data['Custom_slot_date_time'] != null) {
      request.fields['Custom_slot_date_time'] = data['Custom_slot_date_time'];
    } else {
      // Handle the case when both values are 'N/A' or null
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // final responseData = await response.stream.bytesToString();

        // print('Image uploaded successfully: $responseData');
        // print('Latitude: $latitude, Longitude: $longitude');

        // Show a message on the front end (UI) with the position
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Image uploaded successfully\nLatitude: $latitude, Longitude: $longitude'),
          ),
        );
      } else {
        print('Image upload failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void onRowTap(int index) {
    setState(() {
      selectedRowData = tableData[index];
    });
  }

  Future<void> fetchData() async {
    final basicAuth = 'Basic ' +
        base64Encode(utf8.encode('${widget.username}:${widget.password}'));

    final response = await http.get(
      Uri.parse(
          'http://114.143.219.69:8882/curing/transaction-concreting/${widget.trans_concreating}/'),
      headers: {
        'Authorization': basicAuth,
      },
    );

    if (!mounted) {
      // Check if the widget is still mounted
      return;
    }

    if (response.statusCode == 200) {
      setState(() {
        final scheduleconcreting = json.decode(response.body);
        if (scheduleconcreting is List) {
          // Check if the response is a list (as per your API output).
          for (var item in scheduleconcreting) {
            int scheduleCuringID = item['Schedule_Curing_ID'];
            String projectName = item['Project']['Project_Name'];
            String siteName = item['Site']['Site_Name'];
            String structuralElement =
                item['Structural_Element']['Structural_Element'];
            String? scheduleDateAndTime = item['Schedule_Date_and_Time'];
            String? customSlotDateTime = item['Custom_slot_date_time'];
            int transConcreatingID = item['Transaction_Concreting'];
            String? chainage = item['chainage'];
            String? idetification = item['idetification'];
            tableData.add({
              'Schedule_Curing_ID': scheduleCuringID,
              'Project_Name': projectName,
              'Site_Name': siteName,
              'Structural_Element': structuralElement,
              'Schedule_Date_and_Time': scheduleDateAndTime,
              'Custom_slot_date_time': customSlotDateTime,
              'trans_concreating_id': transConcreatingID,
              'chainage': chainage,
              'idetification': idetification,
            });
          }
        } else if (scheduleconcreting is Map) {}
      });
    }
  }

  Future<void> _fetchAndShowPhotos(Map<String, dynamic> data) async {
    final String username = widget.username;
    final String password = widget.password;

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final url =
        Uri.parse('http://114.143.219.69:8882/curing/ImageListApiView/');
    try {
      final response = await http.get(url, headers: {
        'Authorization': basicAuth,
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map && responseData.containsKey('image_urls')) {
          List<String> imageUrls =
              List<String>.from(responseData['image_urls']);

          // Extract schedule_curing_iD from the selected data
          String scheduleCuringID = '${data['Schedule_Curing_ID']}';

          // Filter image URLs based on the schedule_curing_iD
          List<String> filteredImageUrls = imageUrls
              .where((url) => url.contains('/$scheduleCuringID'))
              .toList();

          if (filteredImageUrls.isNotEmpty) {
            // Navigate to PhotoScreen with the filteredImageUrls parameter
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PhotoScreen(
                username: widget.username,
                password: widget.password,
                imageUrls: filteredImageUrls,
              ),
            ));
          } else {
            // Show a message if no images were found
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No images found for this $scheduleCuringID'),
              ),
            );
          }
        } else {
          print('Invalid API response format.');
        }
      } else {
        print('Failed to fetch photos. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

/***asdasdasdasdasdad */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Table"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'username',
                child: Text(widget.username),
              ),
            ],
          ),
        ],
      ),
      body: tableData.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tableData.isNotEmpty)
                    Text(
                        'Project Name: ${tableData[0]['Project_Name'] ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  if (tableData.isNotEmpty)
                    Text('Site Name: ${tableData[0]['Site_Name'] ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  if (tableData.isNotEmpty)
                    Text(
                        'Structural Element: ${tableData[0]['Structural_Element'] ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  if (tableData.isNotEmpty)
                    Text('Chainage: ${tableData[0]['chainage'] ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  if (tableData.isNotEmpty)
                    Text(
                        'Identification: ${tableData[0]['idetification'] ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        horizontalMargin: 0,
                        columnSpacing: 5,
                        border:
                            TableBorder.all(width: 1, style: BorderStyle.solid),
                        columns: [
                          const DataColumn(
                            label: Text('Schedule ID'),
                            // Set the column to have a fixed width
                          ),
                          if (!tableData.any((data) =>
                              data['Schedule_Date_and_Time'] != 'N/A' &&
                              data['Schedule_Date_and_Time'] != null))
                            const DataColumn(
                                label: Expanded(
                              child: Text(
                                'Custom slot date time',
                                textAlign: TextAlign.center,
                              ),
                            )),
                          if (!tableData.any((data) =>
                              data['Custom_slot_date_time'] != 'N/A' &&
                              data['Custom_slot_date_time'] != null))
                            const DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Schedule Date and Time',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          const DataColumn(label: Text('Click Photo')),
                          const DataColumn(label: Text('View Photo')),
                        ],
                        rows: tableData.map(
                          (data) {
                            // ignore: unused_local_variable
                            String fileName =
                                '${data['Schedule_Curing_ID']}.jpg';

                            if ((data['Schedule_Date_and_Time'] == 'N/A' ||
                                    data['Schedule_Date_and_Time'] == null) &&
                                (data['Custom_slot_date_time'] == 'N/A' ||
                                    data['Custom_slot_date_time'] == null)) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        data['Schedule_Curing_ID'].toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        _captureAndStoreImage(data);
                                      },
                                      child: const Icon(Icons.camera_alt),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        _fetchAndShowPhotos(data);
                                      },
                                      child: const Icon(Icons.photo_library),
                                    ),
                                  ),
                                ],
                              );
                            } else if (data['Schedule_Date_and_Time'] ==
                                    'N/A' ||
                                data['Schedule_Date_and_Time'] == null) {
                              return DataRow(
                                cells: [
                                  DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      data['Schedule_Curing_ID'].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                  DataCell(Text(
                                      data['Custom_slot_date_time'] ?? 'N/A')),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        _captureAndStoreImage(data);
                                      },
                                      child: const Icon(Icons.camera_alt),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        _fetchAndShowPhotos(data);
                                      },
                                      child: const Icon(Icons.photo_library),
                                    ),
                                  ),
                                ],
                              );
                            } else if (data['Custom_slot_date_time'] == 'N/A' ||
                                data['Custom_slot_date_time'] == null) {
                              return DataRow(
                                cells: [
                                  DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      data['Schedule_Curing_ID'].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                  DataCell(Text(
                                      data['Schedule_Date_and_Time'] ?? 'N/A')),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        _captureAndStoreImage(data);
                                      },
                                      child: const Icon(Icons.camera_alt),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        _fetchAndShowPhotos(data);
                                      },
                                      child: const Icon(Icons.photo_library),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return DataRow(
                                cells: [
                                  DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      data['Schedule_Curing_ID'].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                  DataCell(Text(
                                      data['Schedule_Date_and_Time'] ?? 'N/A')),
                                  DataCell(Text(
                                      data['Custom_slot_date_time'] ?? 'N/A')),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        _captureAndStoreImage(data);
                                      },
                                      child: const Icon(Icons.camera_alt),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        _fetchAndShowPhotos(data);
                                      },
                                      child: const Icon(Icons.photo_library),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
