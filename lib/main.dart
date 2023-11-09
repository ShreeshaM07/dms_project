import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
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
  int _selectedIndex = 0;

  // final List<Widget> _pages = [
  //   MyApp(), // Create Tournament Page
  //   ScheduleDates(), // Schedule Dates Page
  // ];

  void Function(int)? _onItemTapped(BuildContext context) {
    return (int index) {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 0) {
        // Navigate to Create Tournament page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      } else if (index == 1) {
        // Navigate to ScheduleDates page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScheduleDates()),
        );
      }
    };
  }

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
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Create Tournament',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'See Schedules',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped(context),
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
        MaterialPageRoute(
            builder: (context) => ResultPage(jsonData, widget.tournamentName)),
      );
      // Handle successful response if needed
    } else {
      print('Error sending data to server.');
      // Handle error response if needed
    }
  }

  Future<void> _sendHomeAwayDataToServer(BuildContext context) async {
    List<String> teamNames = tournamentTeams.values.toList();

    var requestBody = jsonEncode({
      'numberOfTeams': widget.numberOfTeams,
      'teamNames': teamNames,
    });

    var response = await http.post(
      Uri.parse(
          'http://localhost:5000/homeawayscheduling'), // Replace with your server endpoint
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print('Data sent successfully!');
      var jsonData = json.decode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultPage(jsonData, widget.tournamentName)),
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
      body: Center(
        child: Container(
          width: 400,
          child: Padding(
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
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            right: 50,
            bottom: 50,
            child: FloatingActionButton(
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
              tooltip: 'Neutral Matchup',
              heroTag: 'neutralmatchup',
            ),
          ),
          Positioned(
            right: 150,
            bottom: 50,
            child: FloatingActionButton(
              onPressed: () {
                //     Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ResultPage()),
                // );
                // Perform actions with the tournamentTeams map, e.g., send it to the server.
                _sendHomeAwayDataToServer(context);
                print('Tournament Teams: $tournamentTeams');
              },
              child: Icon(Icons.airplanemode_active),
              tooltip: 'Home Away Matchup',
              heroTag: 'homeawaymatchup',
            ),
          )
        ],
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> jsonData;
  final String tournamentName;

  ResultPage(this.jsonData, this.tournamentName);

  Future<void> createDatedSchedule(BuildContext context) async {
    //call some function in app.py and use df_global(find a better way as this
    //may not work when more than 1 tournament is created at once)(USE jsonData)
    // and add dates to the
    //strings store all these in 1D 1 List and then store it in database.
    //in ScheduleDates page give options to select which league user wants to
    //access using a dropdown menu with all the already created and stored in
    //database leagues and on selecting display the list as cards.
    try {
      var response = await http.post(
        Uri.parse('http://localhost:5000/scheduletournament'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'jsonData': jsonData}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Dated schedule created successfully'),
        ));
        print('Dated schedule created successfully!');
        var datedSchedule = jsonDecode(response.body)['dated_schedule'];

        // Process dated_schedule and store it in the database
        for (var i = 0; i < datedSchedule.length; i++) {
          var round = i + 1;
          var roundMatches = datedSchedule[i];
          for (var j = 0; j < roundMatches.length; j++) {
            var matchDetails = roundMatches[j].split('\n');
            var date = matchDetails[0];
            var match = matchDetails[1];

            // Store the data into the database
            await DatabaseHelper()
                .saveTournament(tournamentName, date, match, round);
          }
        }

        // Handle successful response if needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error creating dated schedule.'),
        ));
        print('Error creating dated schedule.');
        // Handle error response if needed
      }
    } catch (e) {
      print('Error: $e');
      // Handle exceptions if any
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> columnHeaders = jsonData.keys.toList();
    final List<String> gameRounds = jsonData.values.first.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(this.tournamentName + ' Tournament Schedule'),
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.table_chart),
          //   label: 'Points Table',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
        selectedItemColor: Colors.grey, // Set the selected tab color
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            //Navigate to ScheduleDates page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScheduleDates()),
            );
          }
          // } else if (index == 1) {
          //   // Navigate to PointsTable page
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => PointsTable()),
          //   );
          // }
          else {
            Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));
            // Navigate to PointsTable page
            // Add PointsTable widget implementation and navigate to it
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Function to create dated schedule
          createDatedSchedule(context);
        },
        child: Icon(Icons.add),
        tooltip: 'Create Schedule With Dates',
      ),
    );
  }
}

class ScheduleDates extends StatefulWidget {
  @override
  _ScheduleDatesState createState() => _ScheduleDatesState();
}

class _ScheduleDatesState extends State<ScheduleDates> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  Set<String> tournamentNames = {};
  String selectedTournament = '';
  List<Map<String, dynamic>> tournamentSchedule = [];

  @override
  void initState() {
    super.initState();
    _loadTournamentNames();
  }

  Future<void> _loadTournamentNames() async {
    List<String> names = await _databaseHelper.getTournamentNames();
    setState(() {
      tournamentNames = names.toSet();
    });
  }

  Future<void> _loadTournamentSchedule() async {
    List<Map<String, dynamic>> schedule =
        await _databaseHelper.getTournamentSchedule(selectedTournament);
    setState(() {
      tournamentSchedule = schedule;
    });
  }

  Future<void> _clearDatabase(BuildContext context) async {
    bool confirmClear = await _showClearDatabaseConfirmationDialog(context);
    if (confirmClear) {
      await _databaseHelper.clearDatabase();
      setState(() {
        // Reset UI state or variables related to the database if necessary.
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Deleted Database'),
      ));
      print('Deleted Database');
    }
  }

  Future<bool> _showClearDatabaseConfirmationDialog(
      BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Clear Database'),
          content: Text(
              'Are you sure you want to clear the entire database? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Clear'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedTournament.isEmpty ? null : selectedTournament,
            items: tournamentNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedTournament = newValue ?? '';
                _loadTournamentSchedule();
              });
            },
            hint: Text('Select a tournament'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tournamentSchedule.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        subtitle: Center(
                            child: Text(tournamentSchedule[index]['date'])),
                        title: Center(
                            child: Text(
                                tournamentSchedule[index]['matchDetails'])),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _clearDatabase(context);
            },
            child: Text('Clear Database'),
          ),
        ),
      ),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'tournaments_1.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tournaments_1 (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournamentName TEXT,
        date TEXT,
        matchDetails TEXT,
        round INTEGER
      )
    ''');
  }

  Future<void> saveTournament(String tournamentName, String date,
      String matchDetails, int round) async {
    Database db = await database;

    await db.insert(
      'tournaments_1',
      {
        'tournamentName': tournamentName,
        'date': date,
        'matchDetails': matchDetails,
        'round': round,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getTournamentNames() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('tournaments_1');
    List<String> tournamentNames = [];

    for (var entry in result) {
      String name = entry['tournamentName'] as String;
      if (!tournamentNames.contains(name)) {
        tournamentNames.add(name);
      }
    }

    return tournamentNames;
  }

  Future<List<Map<String, dynamic>>> getTournamentSchedule(
      String tournamentName) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'tournaments_1',
      where: 'tournamentName = ?',
      whereArgs: [tournamentName],
    );
    return result;
  }

  Future<void> clearDatabase() async {
    Database db = await database;
    await db.delete('tournaments_1');
  }
}

class PointsTable extends StatefulWidget {
  @override
  _PointsTableScreen createState() => _PointsTableScreen();
}

class _PointsTableScreen extends State<PointsTable> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Points Table'),
      ),
      body: Text('Nothing yet'),
    );
  }
}
