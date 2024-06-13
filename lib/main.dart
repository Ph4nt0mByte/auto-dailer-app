import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Phone Dialer',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentCallIndex = 0;
  List<String> phoneNumbers = [];
  List<CallState> callStates = []; // List to track call states
  List<TextEditingController> textControllers = []; // List to store text editing controllers
  FocusNode newTextFieldFocus = FocusNode(); // Focus node for the newly added text field

  @override
  void initState() {
    super.initState();
    // Add initial text editing controller
    textControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    // Dispose the focus node and text editing controllers
    newTextFieldFocus.dispose();
    textControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _addPhoneNumber() {
  setState(() {
    // Existing logic for adding new text controller, phone number, and call state
    textControllers.add(TextEditingController());
    phoneNumbers.add("");
    callStates.add(CallState.idle);

    // Unfocus the previous text field using FocusScope
    FocusScope.of(context).unfocus();

    // Request focus on the newly added text field using FocusScope
    FocusScope.of(context).requestFocus(new FocusNode());
  });
}

  void _makeCall() async {
  // Check if list is not empty and index is within bounds
  if (phoneNumbers.isNotEmpty && currentCallIndex < phoneNumbers.length) {
    String phoneNumber = phoneNumbers[currentCallIndex];
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    setState(() {
      callStates[currentCallIndex] = CallState.dialing; // Update to dialing state
    });
    // Simulate call duration (replace with actual call duration detection)
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      callStates[currentCallIndex] = CallState.ended; // Update to ended state
    });

    // Check if there are more calls to be made
    if (currentCallIndex + 1 < phoneNumbers.length) {
      // Introduce a delay before starting the next call
      await Future.delayed(Duration(seconds: 2)); // Adjust delay as needed
      _makeCall(); // Recursively call _makeCall to initiate the next call
    } else {
      _showEndOfListDialog();
    }
    currentCallIndex++;
  } else {
    // Handle empty list or out-of-bounds index scenario
    print('No phone numbers to call or invalid index');
  }
}


  void _resetPhoneNumbers() {
  setState(() {
    phoneNumbers = [];
    callStates = [];
    currentCallIndex = 0;
    textControllers = []; // Clear the text controllers
  });
}

  void _showEndOfListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reached End of List'),
          content: Text('All phone numbers have been dialed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto dialer'),
        backgroundColor: Color.fromARGB(64, 255, 214, 64),
      ),
      body: Column(
        children: [
          Expanded(
            child: (phoneNumbers.isNotEmpty)
                ? ListView.builder(
                    itemCount: phoneNumbers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: callStates[index] == CallState.ended
                            ? Icon(Icons.check, color: Colors.green)
                            : null, // Show checkmark only for ended calls
                        title: TextField(
                          key: ValueKey('phone_number_input_$index'),
                          decoration: InputDecoration(
                            hintText: 'Enter phone number ${index + 1}',
                          ),
                          keyboardType: TextInputType.phone,
                          controller: textControllers[index], // Use the respective text editing controller
                          focusNode: index == phoneNumbers.length - 1 ? newTextFieldFocus : null, // Set focus node for the new text field
                          onChanged: (value) {
                            setState(() {
                              phoneNumbers[index] = value; // Update the phone number
                            });
                          },
                        ),
                        // Add checkbox and other list item features
                      );
                    },
                  )
                : Center(child: Text('No phone numbers added yet.')),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust button spacing
            children: [
              IconButton(
                iconSize: 40, // Increase the icon size
                hoverColor: Colors.blueGrey,
                icon: Icon(Icons.add),
                onPressed: _addPhoneNumber,
                color: Color.fromARGB(255, 3, 109, 109),
              ),
              IconButton(
                iconSize: 40, // Increase the icon size
                hoverColor: Colors.blueGrey,
                icon: Icon(Icons.call),
                onPressed: _makeCall,
                color: Color.fromARGB(255, 3, 109, 109),
              ),
              IconButton(
                iconSize: 40, // Increase the icon size
                hoverColor: Colors.blueGrey,
                icon: Icon(Icons.clear),
                onPressed: _resetPhoneNumbers,
                tooltip: 'Clear all phone numbers',
                color: Color.fromARGB(255, 3, 109, 109),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 229, 219, 241), // Add this line to set the background color to grey
    );
  }
}

enum CallState { idle, dialing, ended } // Define call state enum
