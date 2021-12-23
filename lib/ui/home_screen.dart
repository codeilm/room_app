import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_app/data/moor_database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:room_app/ui/widgets/new_tag_input.dart';
import 'package:room_app/ui/widgets/new_task_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool selectCompletedTask = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Room App'),
          actions: [
            Switch(
                activeColor: Colors.orange,
                value: selectCompletedTask,
                onChanged: (value) {
                  setState(() {
                    selectCompletedTask = value;
                  });
                }),
          ],
        ),
        body: Column(
          children: [
            Flexible(flex: 8, child: _buildTasks(context)),
            Flexible(flex: 1, child: NewTaskInput()),
            Flexible(flex: 1, child: NewTagInput()),
          ],
        ));
  }

  StreamBuilder _buildTasks(context) {
    final dao = Provider.of<TaskDao>(context);
    return StreamBuilder<List<TaskWithTag>>(
      stream:
          selectCompletedTask ? dao.watchCompletedTasks() : dao.watchTasks(),
      builder: (context, snapshot) {
        print('All Tasks : ${snapshot.data}');
        final List tasks = snapshot.data ?? [];
        return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return _buildTask(tasks[index], dao);
            });
      },
    );
  }

  Slidable _buildTask(TaskWithTag task, TaskDao dao) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => dao.deleteTask(task.task),
        )
      ],
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Color(task.tag?.color ?? 0xffffffff),
                ),
                Text(task.tag?.name ?? ''),
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: CheckboxListTile(
              title: Text(task.task.name),
              subtitle: Text(task.task.dueDate?.toString() ?? 'No date'),
              value: task.task.completed,
              onChanged: (newValue) {
                dao.updateTask(task.task.copyWith(completed: newValue));
              },
            ),
          ),
        ],
      ),
    );
  }
}
