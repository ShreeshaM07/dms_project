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
  TextEditingController _tournamentNameController = TextEditingController();
  String inputValue = '';
  String tournamentResult = '';
  String tournamentName = '';

  Future<void> _makeTournament(BuildContext context) async {
    setState(() {
      inputValue = _controller.text;
      tournamentName = _tournamentNameController.text;
    });
    if (inputValue.isEmpty || tournamentName.isEmpty) {
      print("Fields are empty");
      return;
    }
    if (inputValue == '') {
      print("No number entered");
      return;
    }
    int numberOfTeams = int.tryParse(inputValue) ?? 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailsPage(
          tournamentName: tournamentName,
          numberOfTeams: numberOfTeams,
        ),
      ),
    );
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
                      controller: _tournamentNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Tournament name',
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 250,
                  child: Center(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number of teams(even)',
                      ),
                    ),
                  ),
                ),
              ),
              const Text('\n'),
              ElevatedButton(
                onPressed: () => _makeTournament(context),
                child: Text('Tournament Details'),
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

class TournamentDetailsPage extends StatefulWidget {
  final String tournamentName;
  final int numberOfTeams;

  TournamentDetailsPage(
      {required this.tournamentName, required this.numberOfTeams});

  @override
  _TournamentDetailsPageState createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {
  Map<int, String> tournamentTeams = {};

  Future<void> _sendDataToServer(BuildContext context) async {
    List<String> teamNames = tournamentTeams.values.toList();

    var requestBody = jsonEncode({
      'numberOfTeams': widget.numberOfTeams,
      'teamNames': teamNames,
    });

    var response = await http.post(
      Uri.parse(
          'http://localhost:5000/maketournament'), // Replace with your server endpoint
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print('Data sent successfully!');
      var jsonData = json.decode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultPage(jsonData)),
      );
      // Handle successful response if needed
    } else {
      print('Error sending data to server.');
      // Handle error response if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournamentName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.numberOfTeams,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                onChanged: (teamName) {
                  tournamentTeams[index] = teamName;
                },
                decoration: InputDecoration(
                  labelText: 'Enter team name for Team ${index + 1}',
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //     Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ResultPage()),
          // );
          // Perform actions with the tournamentTeams map, e.g., send it to the server.
          _sendDataToServer(context);
          print('Tournament Teams: $tournamentTeams');
        },
        child: Icon(Icons.save),
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
