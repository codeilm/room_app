import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_app/data/moor_database.dart';
import 'package:moor_flutter/moor_flutter.dart';

class NewTaskInput extends StatefulWidget {
  const NewTaskInput({Key? key}) : super(key: key);

  @override
  _NewTaskInputState createState() => _NewTaskInputState();
}

class _NewTaskInputState extends State<NewTaskInput> {
  DateTime? selectedDate;
  Tag? _selectedTag;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final dao = Provider.of<TaskDao>(context);
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Enter Task name'),
              onSubmitted: (value) {
                Insertable<Task> task = TasksCompanion(
                    name: Value(value),
                    dueDate: Value(selectedDate),
                    tagName: Value(_selectedTag?.name));
                dao.insertTask(task);
                setState(() {
                  controller.clear();
                  print('Controller Value : ${controller.text}');
                  selectedDate = null;
                });
              },
            ),
          ),
          StreamBuilder<List<Tag>>(
              stream: Provider.of<TagDao>(context).watchTags(),
              builder: (context, snapshot) {
                List<Tag> tags = snapshot.data ?? [];
                List<DropdownMenuItem<Tag>> _items = tags
                    .map(
                      (tag) => DropdownMenuItem(
                        value: tag,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(tag.color),
                              ),
                            ),
                            Text(tag.name),
                          ],
                        ),
                      ),
                    )
                    .toList()
                      ..insert(
                          0,
                          DropdownMenuItem(
                            value: null,
                            child: Text('No Tag'),
                          ));
                return DropdownButton<Tag>(
                    value: _selectedTag,
                    onChanged: (tag) {
                      setState(() {
                        _selectedTag = tag;
                      });
                    },
                    items: _items);
              }),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.calendar_today_outlined),
        onPressed: () async {
          selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 7)),
          );
        },
      ),
    );
  }
}
