import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:todo_list/helpers/task_helper.dart';
import 'package:todo_list/models/concludedTaskPercent.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/views/task_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> _taskList = [];
  TaskHelper _helper = TaskHelper();
  bool _loading = true;
  ConcludedTaskPercent _concludedTaskPercent =
      ConcludedTaskPercent(percent: 0.0, percentLabel: "0.0%");

  @override
  void initState() {
    super.initState();
    _helper.getAll().then((list) {
      setState(() {
        _taskList = list;
        _loading = false;
        _calculateConcludedTesksPercent();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 4.0,
              animation: true,
              percent: _concludedTaskPercent.percent,
              center: new Text(
                _concludedTaskPercent.percentLabel,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                    color: Colors.white),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.cyanAccent,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _addNewTask),
      body: _buildTaskList(),
    );
  }

  Widget _buildTaskList() {
    if (_taskList.isEmpty) {
      return Center(
        child: _loading ? CircularProgressIndicator() : Text("Sem tarefas!"),
      );
    } else {
      return ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.black26,
        ),
        itemBuilder: _buildTaskItemSlidable,
        itemCount: _taskList.length,
      );
    }
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    final task = _taskList[index];
    return CheckboxListTile(
        value: task.isDone,
        title: Text(task.title),
        subtitle: Text(task.description),
        onChanged: (bool isChecked) {
          setState(() {
            task.isDone = isChecked;
            _calculateConcludedTesksPercent();
          });

          _helper.update(task);
        },
        secondary: Padding(
            padding: EdgeInsets.all(6.0),
            child: _buildIconPriority(task.priority)));
  }

  Widget _buildTaskItemSlidable(BuildContext context, int index) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildTaskItem(context, index),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Editar',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            _addNewTask(editedTask: _taskList[index], index: index);
          },
        ),
        IconSlideAction(
          caption: 'Excluir',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            _deleteTask(deletedTask: _taskList[index], index: index);
          },
        ),
      ],
    );
  }

  Widget _buildIconPriority(int priority) {
    Color color = Colors.black;
    if (priority == 1) {
      color = Colors.blueAccent[700];
    } else if (priority == 2) {
      color = Colors.greenAccent[700];
    } else if (priority == 3) {
      color = Colors.yellow[700];
    } else if (priority == 4) {
      color = Colors.orange[800];
    } else if (priority == 5) {
      color = Colors.redAccent[700];
    }
    return Icon(
      Icons.trip_origin,
      color: color,
    );
  }

  Future _addNewTask({Task editedTask, int index}) async {
    final task = await showDialog<Task>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskDialog(task: editedTask);
      },
    );

    if (task != null) {
      setState(() {
        if (index == null) {
          _taskList.add(task);
          _helper.save(task);
        } else {
          _taskList[index] = task;
          _helper.update(task);
        }
        _calculateConcludedTesksPercent();
      });
    }
  }

  void _deleteTask({Task deletedTask, int index}) {
    setState(() {
      _taskList.removeAt(index);
    });

    _helper.delete(deletedTask.id);

    Flushbar(
      title: "Exclusão de tarefas",
      message: "Tarefa \"${deletedTask.title}\" removida.",
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      mainButton: FlatButton(
        child: Text(
          "Desfazer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          setState(() {
            _taskList.insert(index, deletedTask);
            _helper.update(deletedTask);
          });
        },
      ),
    )..show(context);
    _calculateConcludedTesksPercent();
  }

  void _calculateConcludedTesksPercent() {
    int concludedTasks = 0;
    double percent = 0.0;

    if (_taskList.length > 0.0) {
      for (Task task in _taskList) {
        if (task.isDone) {
          concludedTasks++;
        }
      }
      percent = (1 * concludedTasks) / _taskList.length;
    }

    String percentLabel = "${(percent * 100).toStringAsPrecision(4)}%";
    setState(() {
      _concludedTaskPercent.percent = percent;
      _concludedTaskPercent.percentLabel = percentLabel;
    });
  }
}
