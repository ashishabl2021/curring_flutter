//Project And Site use asign
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'logout.dart';

class CreateSchedulePage extends StatefulWidget {
  final String username;
  final String password;

  const CreateSchedulePage(
      {super.key, required this.username, required this.password});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  // ignore: unused_field
  bool _isLoading = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late String project = ''; // Initialize with an empty string
  late String site = ''; // Initialize with an empty string
  String?
      structuralElementName; // Nullable string for selected Structural Element
  List<String> structuralElements =
      []; // List to store Structural Element names

  late String scheduleDateTime = '';

  @override
  void initState() {
    super.initState();
    // Fetch Structural Element data from the API when the page is loaded
    fetchData();
    fetchStructuralElements();
  }

  Future<void> fetchData() async {
    final String username = widget.username;
    final String password = widget.password;
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final Map<String, String> headers = {
      'Authorization': basicAuth,
    };

    try {
      final response = await http.get(
        Uri.parse('http://114.143.219.69:8882/user-assignment/'),
        headers: headers, // Set headers with Basic Authentication
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          project = data['Project_Name'];
          site = data['Site_Name'];
        });
      } else {
        // Handle other status codes here
        print(
            'Failed to load user assignment. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors here
      print('Error occurred: $error');
    }
  }

  Future<void> fetchStructuralElements() async {
    final String username = widget.username;
    final String password = widget.password;
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final url = Uri.parse('http://114.143.219.69:8882/structural_elementsapi/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response to get Structural Element names
        final List<dynamic> responseBody = json.decode(response.body);
        final List<String> elementNames = responseBody
            .map((element) => element['Structural_Element']
                .toString()) // Assuming the API response contains a 'name' field
            .toList();

        setState(() {
          structuralElements = elementNames;
        });
      } else {
        final errorMessage = response.body;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error occurred while fetching Structural Elements: $error'),
        ),
      );
    }
  }

  Future<void> _selectDateTime() async {
    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    // Show date picker
    pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1), // Allow past years
      lastDate: DateTime(DateTime.now().year + 1),
    );

    // If a date is picked, show time picker
    if (pickedDate != null) {
      // ignore: use_build_context_synchronously
      pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
    }

    // If both date and time are picked, update the scheduleDateTime
    if (pickedDate != null && pickedTime != null) {
      final formattedTime = DateFormat('hh:mm a').format(
        DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        ),
      );

      setState(() {
        scheduleDateTime =
            "${pickedDate?.day}/${pickedDate?.month}/${pickedDate?.year} $formattedTime";
      });
    }
  }

  Future<Map<String, dynamic>> getUserAssignment(
      String username, String password) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    final url = Uri.parse('http://114.143.219.69:8882/user-assignment/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to load user assignment');
    }
  }

  Future<void> startSchedule() async {
    setState(() {
      _isLoading = true; // Show a progress indicator while making the request
    });

    final String username = widget.username;
    final String password = widget.password;
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final url = Uri.parse('http://114.143.219.69:8882/transaction-concreting/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json', // Specify JSON content type
        },
        body: json.encode({
          'Structural_Element': structuralElementName,
          'Schedule_Date_and_Time': scheduleDateTime,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        setState(() {
          project = responseBody['Project'];
          site = responseBody['Site'];
          structuralElementName =
              responseBody['Structural_Element']; // Update the name
          scheduleDateTime = responseBody['Schedule_Date_and_Time'];
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule started successfully')),
        );
      } else {
        final errorMessage = response.body;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred while starting schedule: $error'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide the progress indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Schedule"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (String choice) {
              if (choice == 'logout') {
                LogoutPage.logout(context, widget.username, widget.password);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'username',
                child: Text(widget.username),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Project: $project',
              style: const TextStyle(
                fontSize: 18, // Adjust the font size as needed
                fontWeight: FontWeight.bold, // Make "Project" bold
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Site: $site',
              style: const TextStyle(
                fontSize: 18, // Adjust the font size as needed
                fontWeight: FontWeight.bold, // Make "Project" bold
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Structural Element :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              value: structuralElementName,
              icon: null, // Set the default dropdown icon to null
              iconSize: 0, // Set the icon size to 0 to hide the default icon
              onChanged: (String? newValue) {
                setState(() {
                  structuralElementName = newValue;
                });
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select a Structural Element',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Icon(Icons
                          .arrow_drop_down), // Custom dropdown icon on the right
                    ],
                  ),
                ),
                ...structuralElements.map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Select Date And Time:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              onTap: _selectDateTime,
              controller: TextEditingController(
                text: scheduleDateTime,
              ),
              readOnly: true,
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: startSchedule,
              child: const Text('Start Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
*/