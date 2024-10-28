import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _textEditingController = TextEditingController();
  Box? _todoBox;

  @override
  void initState() {
    super.initState();
    Hive.openBox("todo_box").then((_box) {
      setState(() {
        _todoBox = _box;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TO DO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF287aea),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayAlertBox(context);
        },
        child: const Icon(Icons.add),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_todoBox == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ValueListenableBuilder(
        valueListenable: _todoBox!.listenable(),
        builder: (context, box, child) {
          final todoKeys = box.keys.toList();
          return SizedBox.expand(
            child: ListView.builder(
                itemCount: todoKeys.length,
                itemBuilder: (context, index) {
                  Map todo = _todoBox!.get(todoKeys[index]);
                  return Slidable(
                    endActionPane:
                        ActionPane(motion: StretchMotion(), children: [
                      SlidableAction(
                        onPressed: (context) {
                          _todoBox!.delete(todoKeys[index]);
                        },
                        backgroundColor: Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ]),
                    child: ListTile(
                      title: Text(todo["content"]),
                      subtitle: Text(todo["createdTime"].toString()),
                      trailing: Checkbox(
                          value: todo["isDone"],
                          onChanged: (value) {
                            todo["isDone"] = value;
                            _todoBox!.put(todoKeys[index], todo);
                          }),
                    ),
                  );
                }),
          );
        },
      );
    }
  }

  Future _displayAlertBox(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter your Task'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              hintText: "Todo....",
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _todoBox?.add({
                  "content": _textEditingController.text,
                  "createdTime": DateTime.now(),
                  "isDone": false
                });
                Navigator.pop(context);
                _textEditingController.clear();
              },
              child: const Text('Okay'),
            )
          ],
        );
      },
    );
  }
}
