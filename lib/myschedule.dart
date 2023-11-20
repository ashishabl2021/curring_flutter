import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:curring_flutter/schedule_table.dart';

class MySchedules extends StatefulWidget {
  final String username;
  final String password;
  const MySchedules(
      {super.key, required this.username, required this.password});

  @override
  State<MySchedules> createState() => _MySchedulesState();
}

class _MySchedulesState extends State<MySchedules> {
  List<Map<String, dynamic>> transactionConcretingData = [];
  Map<String, dynamic>? selectedRowData;

  @override
  void initState() {
    super.initState();
    // Fetch data from your API when the widget is initialized
    fetchData();
  }

  Future<void> fetchData() async {
    final String username = widget.username;
    final String password = widget.password;
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final response = await http.get(
      Uri.parse(
          'http://114.143.219.69:8882/curing/all_transaction-concreting/'),
      headers: {'Authorization': basicAuth}, // Set the Authorization header
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          transactionConcretingData = List<Map<String, dynamic>>.from(data);
        });
      }
    } else {
      // Handle the error, e.g., show an error message
      print('Failed to load data: ${response.statusCode}');
    }
  }

  void onRowTap(int index) {
    if (mounted) {
      // Get the selected row data
      setState(() {
        selectedRowData = transactionConcretingData[index];
      });

      // Navigate to the SchedulTable widget
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchedulTable(
            username: widget.username,
            password: widget.password,
            trans_concreating: trans_concreating.fromJson(selectedRowData!),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose of any resources here, e.g., cancel timers or remove listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Schedule"),
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
      body: transactionConcretingData.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  horizontalMargin: 0,
                  columnSpacing: 5,
                  border: TableBorder.all(width: 1, style: BorderStyle.solid),
                  columns: const [
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Transaction ID',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Project',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                          child: Text(
                        'Site',
                        textAlign: TextAlign.center,
                      )),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Structural Element',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                          child: Text(
                        'Chainage',
                        textAlign: TextAlign.center,
                      )),
                    ),
                    DataColumn(
                      label: Expanded(
                          child: Text(
                        'Identification',
                        textAlign: TextAlign.center,
                      )),
                    ),
                    DataColumn(
                      label: Expanded(
                          child: Text(
                        'Schedule Date & Time',
                        textAlign: TextAlign.center,
                      )),
                    ),
                  ],
                  rows: [
                    for (var item in transactionConcretingData)
                      DataRow(
                        cells: [
                          DataCell(
                            GestureDetector(
                              onTap: () {
                                // Handle row tap and set selected row data
                                setState(() {
                                  selectedRowData = item;
                                });

                                // Navigate to SchedulTable with selected row data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SchedulTable(
                                      username: widget.username,
                                      password: widget.password,
                                      trans_concreating:
                                          item['Transaction_Concreting_ID']
                                              .toString(),
                                    ),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  item['Transaction_Concreting_ID'].toString(),
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(item['Project']),
                          ),
                          DataCell(
                            Text(item['Site']),
                          ),
                          DataCell(
                            Align(
                                alignment: Alignment.center,
                                child: Text(item['Structural_Element'])),
                          ),
                          DataCell(
                            Align(
                                alignment: Alignment.center,
                                child: Text(item['chainage'])),
                          ),
                          DataCell(
                            Align(
                                alignment: Alignment.center,
                                child: Text(item['idetification'])),
                          ),
                          DataCell(
                            Text(item['Schedule_Date_and_Time']),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
