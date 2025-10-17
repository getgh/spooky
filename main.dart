import 'package:flutter/material.dart';
import 'database_helper.dart';	
	
	
	// Here we are using a global variable. You can use something like	
	// get_it in a production app.	
final dbHelper = DatabaseHelper();	
	
	
Future<void> main() async {	
  WidgetsFlutterBinding.ensureInitialized();	
  // initialize the database	
  await dbHelper.init();	
  runApp(const MyApp());	
}	


class MyApp extends StatelessWidget {	
  const MyApp({super.key});	


  @override	
  Widget build(BuildContext context) {	
    return MaterialApp(	
      title: 'SQFlite Demo',	
      theme: ThemeData(	
        primarySwatch: Colors.blue,	
      ),	
      home: const MyHomePage(),	
    );	
  }	
}	


class MyHomePage extends StatelessWidget {	
  const MyHomePage({super.key});	


  // homepage layout	
  @override	
  Widget build(BuildContext context) {	
    return Scaffold(	
      appBar: AppBar(	
        title: const Text('sqflite'),	
      ),	
      body: Center(	
        child: Column(	
          mainAxisAlignment: MainAxisAlignment.center,	
          children: <Widget>[	
            ElevatedButton(	
              onPressed: _insert,	
              child: const Text('insert'),	
            ),	
            const SizedBox(height: 10),	
            ElevatedButton(	
              onPressed: _query,	
              child: const Text('query'),	
            ),	
            const SizedBox(height: 10),	
            ElevatedButton(	
              onPressed: _update,	
              child: const Text('update'),	
            ),	
            const SizedBox(height: 10),	
            ElevatedButton(	
              onPressed: _delete,	
              child: const Text('delete'),	
            ),	
          ],	
        ),	
      ),	
    );	
  }	
	
	
  // Button onPressed methods	
	
	
  void _insert() async {	
    // row to insert	
    Map<String, dynamic> row = {	
      DatabaseHelper.columnName: 'Bob',	
      DatabaseHelper.columnAge: 23	
	    };	
    final id = await dbHelper.insert(row);	
    debugPrint('inserted row id: $id');	
  }	


  void _query() async {	
    final allRows = await dbHelper.queryAllRows();	
    debugPrint('query all rows:');	
    for (final row in allRows) {	
      debugPrint(row.toString());	
    }	
  }	


  void _update() async {	
    // row to update	
    Map<String, dynamic> row = {	
      DatabaseHelper.columnId: 1,	
      DatabaseHelper.columnName: 'Mary',	
      DatabaseHelper.columnAge: 32	
    };	
    final rowsAffected = await dbHelper.update(row);	
    debugPrint('updated $rowsAffected row(s)');	
  }	


  void _delete() async {	
	    // Assuming that the number of rows is the id for the last row.	
    final id = await dbHelper.queryRowCount();	
    final rowsDeleted = await dbHelper.delete(id);	
    debugPrint('deleted $rowsDeleted row(s): row $id');	
  }	
}	

```
import 'package:flutter/material.dart';
import 'database_helper.dart';	
	
	
// Here we are using a global variable. You can use something like	
// get_it in a production app.	
final dbHelper = DatabaseHelper();	
	
	
Future<void> main() async {	
  WidgetsFlutterBinding.ensureInitialized();	
  // initialize the database	
  await dbHelper.init();	
  runApp(const MyApp());	
}	


class MyApp extends StatelessWidget {	
  const MyApp({super.key});	


  @override	
  Widget build(BuildContext context) {	
    return MaterialApp(	
      title: 'SQFlite Demo',	
      theme: ThemeData(	
        primarySwatch: Colors.blue,	
      ),	
      home: const MyHomePage(),	
    );	
  }	
}	


class MyHomePage extends StatelessWidget {	
  const MyHomePage({super.key});	


  // homepage layout	
  @override	
  Widget build(BuildContext context) {	
    return Scaffold(	
      appBar: AppBar(	
        title: const Text('sqflite'),	
      ),	
      body: Center(	
        child: Column(	
          mainAxisAlignment: MainAxisAlignment.center,	
          children: <Widget>[	
            ElevatedButton(	
              onPressed: _insert,	
              child: const Text('insert'),	
            ),	
            const SizedBox(height: 10),	
            ElevatedButton(	
              onPressed: _query,	
              child: const Text('query'),	
            ),	
            const SizedBox(height: 10),	
            ElevatedButton(	
              onPressed: _update,	
              child: const Text('update'),	
            ),	
            const SizedBox(height: 10),	
            ElevatedButton(	
              onPressed: _delete,	
              child: const Text('delete'),	
            ),	
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _queryById,
              child: const Text('query by ID'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _deleteAll,
              child: const Text('delete all'),
            ),
          ],	
        ),	
      ),	
    );	
  }	
	
	
  // Button onPressed methods	
	
	
  void _insert() async {	
    // row to insert	
    Map<String, dynamic> row = {	
      DatabaseHelper.columnName: 'Bob',	
      DatabaseHelper.columnAge: 23	
    };	
    final id = await dbHelper.insert(row);	
    debugPrint('inserted row id: $id');	
  }	


  void _query() async {	
    final allRows = await dbHelper.queryAllRows();	
    debugPrint('query all rows:');	
    for (final row in allRows) {	
      debugPrint(row.toString());	
    }	
  }	


  void _update() async {	
    // row to update	
    Map<String, dynamic> row = {	
      DatabaseHelper.columnId: 1,	
      DatabaseHelper.columnName: 'Mary',	
      DatabaseHelper.columnAge: 32	
    };	
    final rowsAffected = await dbHelper.update(row);	
    debugPrint('updated $rowsAffected row(s)');	
  }	


  void _delete() async {	
    // Assuming that the number of rows is the id for the last row.	
    final id = await dbHelper.queryRowCount();	
    final rowsDeleted = await dbHelper.delete(id);	
    debugPrint('deleted $rowsDeleted row(s): row $id');	
  }	


  // PART 2: Query by ID method
  void _queryById() async {
    // Query for a specific ID (change this value to test different IDs)
    const int idToQuery = 1;
    final row = await dbHelper.queryRowById(idToQuery);
    if (row != null) {
      debugPrint('query row with id $idToQuery:');
      debugPrint(row.toString());
    } else {
      debugPrint('no row found with id $idToQuery');
    }
  }


  // PART 2: Delete all records method
  void _deleteAll() async {
    final rowsDeleted = await dbHelper.deleteAll();
    debugPrint('deleted all records: $rowsDeleted row(s) removed');
  }
}```