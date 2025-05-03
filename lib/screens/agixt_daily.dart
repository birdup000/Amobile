import 'package:agixt/models/agixt/daily.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AGiXTDailyPage extends StatefulWidget {
  const AGiXTDailyPage({super.key});

  @override
  AGiXTDailyPageState createState() => AGiXTDailyPageState();
}

class AGiXTDailyPageState extends State<AGiXTDailyPage> {
  late Box<AGiXTDailyItem> _agixtDailyBox;

  @override
  void initState() {
    super.initState();
    _agixtDailyBox = Hive.box<AGiXTDailyItem>('agixtDailyBox');
  }

  Future<void> _sortBox() async {
    final items = _agixtDailyBox.values.toList()
      ..sort((a, b) => TimeOfDay(hour: a.hour!, minute: a.minute!)
          .compareTo(TimeOfDay(hour: b.hour!, minute: b.minute!)));
    await _agixtDailyBox.clear();
    await _agixtDailyBox.addAll(items);
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        return _AddItemDialog(
          onAdd: (title, hour, minute) {
            final newItem =
                AGiXTDailyItem(title: title, hour: hour, minute: minute);
            _agixtDailyBox.add(newItem);
            _sortBox();
            setState(() {});
          },
        );
      },
    );
  }

  void _editItem(int index) {
    final item = _agixtDailyBox.getAt(index);
    showDialog(
      context: context,
      builder: (context) {
        return _AddItemDialog(
          item: item,
          onAdd: (title, hour, minute) {
            final newItem =
                AGiXTDailyItem(title: title, hour: hour, minute: minute);
            _agixtDailyBox.putAt(index, newItem);
            _sortBox();
            setState(() {});
          },
        );
      },
    );
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _agixtDailyBox.deleteAt(index);
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
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
        title: Text('AGiXT Daily'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _agixtDailyBox.listenable(),
        builder: (context, Box<AGiXTDailyItem> box, _) {
          final items = box.values.toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text(
                    '${item.hour.toString().padLeft(2, '0')}:${item.minute.toString().padLeft(2, '0')}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editItem(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteItem(index),
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

class _AddItemDialog extends StatefulWidget {
  final Function(String, int, int) onAdd;
  final AGiXTDailyItem? item;

  const _AddItemDialog({required this.onAdd, this.item});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  TextEditingController titleController = TextEditingController();
  late int hour;
  late int minute;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.item?.title ?? '';
    hour = widget.item?.hour ?? TimeOfDay.now().hour;
    minute = widget.item?.minute ?? TimeOfDay.now().minute;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Title'),
            controller: titleController,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                  'Time: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}'),
              SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: hour, minute: minute),
                  );
                  if (picked != null) {
                    setState(() {
                      hour = picked.hour;
                      minute = picked.minute;
                    });
                  }
                },
                icon: Icon(Icons.edit),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onAdd(titleController.text, hour, minute);
            Navigator.of(context).pop();
          },
          child: widget.item == null ? Text('Add') : Text('Save'),
        ),
      ],
    );
  }
}
