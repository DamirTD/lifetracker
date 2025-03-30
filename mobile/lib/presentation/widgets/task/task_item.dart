import 'package:flutter/material.dart';
import 'package:mobile/data/models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            if (!task.isCompleted) {
              onCompleted();
            }
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getPriorityIcon(task.priority),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPriorityIcon(int priority) {
    IconData iconData;
    Color color;

    switch (priority) {
      case 1:
        iconData = Icons.flag;
        color = Colors.green;
        break;
      case 2:
        iconData = Icons.flag;
        color = Colors.orange;
        break;
      case 3:
        iconData = Icons.flag;
        color = Colors.red;
        break;
      default:
        iconData = Icons.flag_outlined;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }
}