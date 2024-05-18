import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/person.dart';  // Correct import for your Person model

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  await Hive.openBox<Person>('peopleBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive CRUD Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InfoScreen(),
    );
  }
}

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late final Box<Person> personBox;

  @override
  void initState() {
    super.initState();
    personBox = Hive.box<Person>('peopleBox');
  }

  void _addPerson(String name, String country) {
    final person = Person(name: name, country: country);
    personBox.add(person);
  }

  void _updatePerson(int index, String name, String country) {
    final person = Person(name: name, country: country);
    personBox.putAt(index, person);
  }

  void _deletePerson(int index) {
    personBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final countryController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('People Info')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add Person'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: countryController,
                    decoration: InputDecoration(labelText: 'Country'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _addPerson(nameController.text, countryController.text);
                    Navigator.of(context).pop();
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: personBox.listenable(),
        builder: (context, Box<Person> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No data available.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final person = box.getAt(index)!;

              return ListTile(
                title: Text(person.name),
                subtitle: Text(person.country),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        nameController.text = person.name;
                        countryController.text = person.country;

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Edit Person'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(labelText: 'Name'),
                                ),
                                TextField(
                                  controller: countryController,
                                  decoration: InputDecoration(labelText: 'Country'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _updatePerson(index, nameController.text, countryController.text);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Update'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deletePerson(index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
