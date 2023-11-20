import 'package:curring_flutter/myschedule.dart';
import 'package:flutter/material.dart';

import 'package:curring_flutter/create_schedule.dart';

class UserProfile extends StatefulWidget {
  final String username;
  final String password;
  const UserProfile(
      {super.key, required this.username, required this.password});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
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
      /*body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateSchedulePage(
                    username: widget.username,
                    password: widget.password,
                  ),
                ),
              );
            },
            child: const Text('Create Schedule'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MySchedules(
                    username: widget.username,
                    password: widget.password,
                  ),
                ),
              );
            },
            child: const Text('My Schedule'),
          ),
        ],
      ),*/
      body: GridView.count(
        crossAxisCount: 2, // Number of columns in the grid
        padding: EdgeInsets.all(20.0),
        mainAxisSpacing: 30.0,
        crossAxisSpacing: 30.0,
        childAspectRatio: 2.5, // Adjust the aspect ratio as needed

        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateSchedulePage(
                    username: widget.username,
                    password: widget.password,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white, // Background color
              onPrimary: Colors.black, // Text color
              side: BorderSide(color: Colors.black), // Border color
            ),
            child: const Text('Create Schedule'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MySchedules(
                    username: widget.username,
                    password: widget.password,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white, // Background color
              onPrimary: Colors.black, // Text color
              side: BorderSide(color: Colors.black), // Border color
            ),
            child: const Text('My Schedule'),
          ),
        ],
      ),
    );
  }
}
