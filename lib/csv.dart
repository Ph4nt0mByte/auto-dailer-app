import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Phone Numbers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<dynamic>>? _phoneNumbers;
  int _columnCount = 0;

  Future<void> _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result!= null) {
      String csvData = String.fromCharCodes(result.files.single.bytes!);
      List<List<dynamic>> rowsAsListOfValues = CsvToListConverter().convert(csvData);
      rowsAsListOfValues.removeAt(0); // Remove the header row

      // Find the maximum number of columns in the CSV file
      _columnCount = rowsAsListOfValues.fold(0, (max, row) => max < row.length? row.length : max);

      List<List<dynamic>> phoneNumbers = rowsAsListOfValues.map((row) {
        List<dynamic> newRow = [];
        for (int i = 0; i < _columnCount; i++) {
          newRow.add(i < row.length? row[i] : '');
        }
        return newRow;
      }).toList();

      setState(() {
        _phoneNumbers = phoneNumbers;
      });

      // Create a for loop for each element in the CSV file
      for (var row in rowsAsListOfValues) {
        String name = row.length > 0? row[0] : '';
        String lastName = row.length > 1? row[1] : '';
        String phoneNumber = row.length > 2? row[2] : '';
        print('Name: $name, Last Name: $lastName, Phone Number: $phoneNumber');
        // Perform any additional processing here
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSV Phone Numbers'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _openFilePicker,
              child: Row(
                children: [
                  Icon(Icons.folder_open),
                  Text('Open CSV File'),
                ],
              ),
            ),
            SizedBox(height: 20),
            _phoneNumbers!= null
          ? Expanded(
                  child: DataTable(
                    columns: List.generate(_columnCount, (index) => DataColumn(label: Text('Column $index'))),
                    rows: _phoneNumbers!
                  .map(
                        (row) => DataRow(
                          cells: row.map((cell) => DataCell(Text(cell.toString()))).toList(),
                        ),
                      )
                  .toList(),
                  ),
                )
              : Container(), // Display nothing if _phoneNumbers is null
          ],
        ),
      ),
    );
  }
}