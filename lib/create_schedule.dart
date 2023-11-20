import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:curring_flutter/schedule_table.dart';

class CreateSchedulePage extends StatefulWidget {
  final String username;
  final String password;

  const CreateSchedulePage(
      {super.key, required this.username, required this.password});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  List<String> projectNames = [];
  String? selectedProjectName;
  String? selectedSiteName;
  Map<String, List<String>> siteMap = {};
  String? selectedStructuralElement;
  List<String> structuralElements = [];

  final TextEditingController chainageController = TextEditingController();
  final TextEditingController identificationController =
      TextEditingController();
  late String scheduleDateTime = '';

  // bool _isLoading = false;
  bool _dataLoaded = false;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUrlData();
    _updateScheduleDateTime(); // Set initial date and time
  }

  void _updateScheduleDateTime() {
    final currentDateTime = DateTime.now();
    final formattedDateTime =
        DateFormat('dd/MM/yyyy hh:mm a').format(currentDateTime);
    setState(() {
      scheduleDateTime = formattedDateTime;
      _controller.text = scheduleDateTime; // Update the controller as well
    });
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
        _controller.text = scheduleDateTime; // Update the controller as well
      });
    }
  }

  Future<void> fetchUrlData() async {
    final String username = widget.username;
    final String password = widget.password;
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final url =
        Uri.parse('http://114.143.219.69:8882/curing/transaction-concreting/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': basicAuth,
        },
      );

      // Check if the widget is still mounted before updating the state
      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Fetch and process "Structural_Elements" data
        final structuralElementsData =
            data['Structural_Elements'] as List<dynamic>;
        structuralElements = structuralElementsData
            .map((element) => element['Structural_Element'].toString())
            .toList();

        // Fetch and process project and site data
        final projects = data['projects'];
        for (var project in projects) {
          final projectName = project['Project_Name'];
          projectNames.add(projectName);

          final projectSites = project['Sites'] as List<dynamic>;
          final siteNames =
              projectSites.map((site) => site['Site_Name'].toString()).toList();
          siteMap[projectName] = siteNames;
        }

        // Check if the widget is still mounted before updating the state
        if (mounted && projectNames.isNotEmpty) {
          setState(() {
            selectedProjectName = projectNames[0];
            selectedSiteName = siteMap[selectedProjectName]?.first;
            selectedStructuralElement =
                structuralElements[0]; // Set the default structural element
            _dataLoaded = true;
          });
        }
      } else {
        // Check if the widget is still mounted before showing a SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching data from the API')),
          );
        }
      }
    } catch (error) {
      // Check if the widget is still mounted before showing a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred while fetching data: $error'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> createSchedule() async {
    setState(() {
      // _isLoading = true; // Show a progress indicator while making the request
    });

    final String username = widget.username;
    final String password = widget.password;
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final url =
        Uri.parse('http://114.143.219.69:8882/curing/transaction-concreting/');

    final Map<String, dynamic> scheduleData = {
      'Project': selectedProjectName,
      'Site': selectedSiteName,
      'Structural_Element': selectedStructuralElement,
      'chainage': chainageController.text,
      'idetification': identificationController.text,
      'Schedule_Date_and_Time': scheduleDateTime,
      // Add other required fields as needed
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: json.encode(scheduleData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final trans_concreating = responseData[
            'Transaction_Concreting_ID']; // Replace with the actual key from the API response

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedule created: $trans_concreating')),
        );

        // Navigate to SchedulTable after a schedule is created
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchedulTable(
              username: widget.username,
              password: widget.password,
              trans_concreating: trans_concreating,
            ),
          ),
        );
      } else {
        final errorMessage = json.decode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred while creating a schedule: $error'),
        ),
      );
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: const Text("Create Schedule"),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_dataLoaded)
                Container(
                  width: MediaQuery.of(context)
                      .size
                      .width, // Set the width to the screen width
                  child: DropdownButton<String>(
                    value: selectedProjectName,
                    items: projectNames.map((String projectName) {
                      return DropdownMenuItem<String>(
                        value: projectName,
                        child: Text(projectName),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedProjectName = newValue;
                          selectedSiteName =
                              siteMap[selectedProjectName]?.first;
                        });
                      }
                    },
                    hint: const Text('Select a Project'),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Site :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_dataLoaded && selectedProjectName != null)
                Container(
                  width: MediaQuery.of(context)
                      .size
                      .width, // Set the width to the screen width
                  child: DropdownButton<String>(
                    value: selectedSiteName,
                    items: siteMap[selectedProjectName]?.map((siteName) {
                      return DropdownMenuItem<String>(
                        value: siteName,
                        child: Text(siteName),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedSiteName = newValue;
                        });
                      }
                    },
                    hint: const Text('Select a Site'),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Structural Element :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_dataLoaded)
                Container(
                  width: MediaQuery.of(context)
                      .size
                      .width, // Set the width to the screen width
                  child: DropdownButton<String>(
                    value: selectedStructuralElement,
                    items: structuralElements.map((element) {
                      return DropdownMenuItem<String>(
                        value: element,
                        child: Text(element),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedStructuralElement = newValue;
                        });
                      }
                    },
                    hint: const Text('Select a Structural Element'),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Chainage :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: chainageController,
                decoration: const InputDecoration(labelText: 'Chainage'),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Identification of Sturctural Element :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: identificationController,
                decoration: const InputDecoration(
                    labelText: 'Identification of Sturctural Element'),
              ),
              const SizedBox(
                height: 20,
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
                controller: _controller,
                readOnly: true,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: createSchedule,
                child: const Text('Create Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Schedule"),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _dataLoaded
              ? SingleChildScrollView(
                  child: _buildContent(),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project :',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_dataLoaded)
          Container(
            width: MediaQuery.of(context)
                .size
                .width, // Set the width to the screen width
            child: DropdownButton<String>(
              value: selectedProjectName,
              items: projectNames.map(
                (String projectName) {
                  return DropdownMenuItem<String>(
                    value: projectName,
                    child: Text(projectName),
                  );
                },
              ).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      selectedProjectName = newValue;
                      selectedSiteName = siteMap[selectedProjectName]?.first;
                    },
                  );
                }
              },
              hint: const Text('Select a Project'),
            ),
          ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Site :',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_dataLoaded && selectedProjectName != null)
          Container(
            width: MediaQuery.of(context)
                .size
                .width, // Set the width to the screen width
            child: DropdownButton<String>(
              value: selectedSiteName,
              items: siteMap[selectedProjectName]?.map((siteName) {
                return DropdownMenuItem<String>(
                  value: siteName,
                  child: Text(siteName),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedSiteName = newValue;
                  });
                }
              },
              hint: const Text('Select a Site'),
            ),
          ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Structural Element :',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_dataLoaded)
          Container(
            width: MediaQuery.of(context)
                .size
                .width, // Set the width to the screen width
            child: DropdownButton<String>(
              value: selectedStructuralElement,
              items: structuralElements.map((element) {
                return DropdownMenuItem<String>(
                  value: element,
                  child: Text(element),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedStructuralElement = newValue;
                  });
                }
              },
              hint: const Text('Select a Structural Element'),
            ),
          ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Chainage :',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          controller: chainageController,
          decoration: const InputDecoration(labelText: 'Chainage'),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Identification of Sturctural Element :',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          controller: identificationController,
          decoration: const InputDecoration(
              labelText: 'Identification of Sturctural Element'),
        ),
        const SizedBox(
          height: 20,
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
          controller: _controller,
          readOnly: true,
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: createSchedule,
          child: const Text('Create Schedule'),
        ),
      ],
    );
  }
}
/*asdasdjhasdvjasvnksavfjasvdfjsvdjfvsjadvfjasvdfjv */