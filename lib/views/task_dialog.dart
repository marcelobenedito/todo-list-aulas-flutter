import 'package:flutter/material.dart';
import 'package:todo_list/models/task.dart';

class TaskDialog extends StatefulWidget {
  final Task task;

  TaskDialog({this.task});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Task _currentTask = Task();

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _currentTask = Task.fromMap(widget.task.toMap());
    }

    _titleController.text = _currentTask.title;
    _descriptionController.text = _currentTask.description;
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefas'),
      content: Container(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildTextFormField(
                  label: "Título",
                  error: "Insira um título!",
                  controller: _titleController,
                ),
                buildMultilineTextFormField(
                  label: "Descrição",
                  error: "Insira uma descrição!",
                  controller: _descriptionController,
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                ),
                Text("Prioridade:"),
                buildDropdown(),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Salvar'),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _currentTask.title = _titleController.value.text;
              _currentTask.description = _descriptionController.text;
              _currentTask.priority = _dropdownValue;
              print(_currentTask);
              Navigator.of(context).pop(_currentTask);
            }
          },
        ),
      ],
    );
  }

  Widget buildTextFormField(
      {TextEditingController controller, String error, String label}) {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(labelText: label),
      controller: controller,
      validator: (text) {
        return text.isEmpty ? error : null;
      },
    );
  }

  Widget buildMultilineTextFormField(
      {TextEditingController controller, String error, String label}) {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 2,
      decoration: InputDecoration(labelText: label),
      controller: controller,
      validator: (text) {
        return text.isEmpty ? error : null;
      },
    );
  }

  int _dropdownValue = 1;

  Widget buildDropdown() {
    return Center(
      child: DropdownButton<int>(
          value: _dropdownValue,
          onChanged: (value) {
            setState(() {
              _dropdownValue = value;
            });
          },
          disabledHint: Text("You can't select anything."),
          items: [
            DropdownMenuItem(
              value: 1,
              child: Text(
                "1 - Muito baixa",
                style: TextStyle(color: Colors.blueAccent[700]),
              ),
            ),
            DropdownMenuItem(
              value: 2,
              child: Text(
                "2 - Baixa",
                style: TextStyle(color: Colors.greenAccent[700]),
                
              ),
            ),
            DropdownMenuItem(
              value: 3,
              child: Text(
                "3 - Média",
                style: TextStyle(color: Colors.yellow[700]),
                
              ),
            ),
            DropdownMenuItem(
              value: 4,
              child: Text(
                "4 - Alta",
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
            DropdownMenuItem(
              value: 5,
              child: Text(
                "5 - Muito alta",
                style: TextStyle(color: Colors.redAccent[700]),
              ),
            ),
          ]),
    );
  }
}
