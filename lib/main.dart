import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _controller = TextEditingController();
  String inputValue = '';
  String tournamentResult = '';

  Future<void> _makeTournament(BuildContext context) async {
    setState(() {
      inputValue = _controller.text;
    });
    if (inputValue == '') {
      print("No number entered");
      return;
    }
    final apiUrl = Uri.parse('http://localhost:5000/maketournament');
    final response = await http.post(
      apiUrl,
      body: {'number': inputValue}, // Send the input value to Flask
    );
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultPage(result)),
      );
      setState(() {
        tournamentResult = result.toString();
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultPage(result)),
      );
      print('Data sent successfully!');
    } else {
      print('Error sending data to Flask.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Tournament Scheduling',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  width: 250,
                  child: Center(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter the total number of teams(even)',
                      ),
                    ),
                  ),
                ),
              ),
              const Text('\n'),
              ElevatedButton(
                onPressed: () => _makeTournament(context),
                child: Text('View Tournament'),
              ),
              // SizedBox(height: 20),
              // Text('Tournament Schedule:'),
              // Text(tournamentResult),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> jsonData;

  ResultPage(this.jsonData);

  @override
  Widget build(BuildContext context) {
    final List<String> columnHeaders = jsonData.keys.toList();
    final List<String> gameRounds = jsonData.values.first.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Schedule'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Games')),
            ...columnHeaders.map((header) => DataColumn(label: Text(header))),
          ],
          rows: gameRounds.map((round) {
            final gameDetails = columnHeaders.map((header) {
              final dynamic value = jsonData[header][round];
              return DataCell(Text(value.toString()));
            }).toList();

            return DataRow(cells: [
              DataCell(Text(round)),
              ...gameDetails,
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
