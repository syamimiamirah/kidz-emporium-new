import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/screens/admin/create_task_admin.dart';
import 'package:kidz_emporium/screens/admin/details_task_admin.dart';
import 'package:kidz_emporium/screens/parent/view_reminder_parent.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import '../../components/side_menu.dart';
import '../../config.dart';
import '../../models/booking_model.dart';
import '../../models/child_model.dart';
import '../../models/login_response_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class ViewTaskAdminPage extends StatefulWidget {
  final LoginResponseModel userData;

  const ViewTaskAdminPage ({Key? key, required this.userData}): super(key: key);
  @override
  _viewTaskAdminPageState createState() => _viewTaskAdminPageState();
}

class _viewTaskAdminPageState extends State<ViewTaskAdminPage>{
  List<TherapistModel> therapists = [];
  List<UserModel> users = [];
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadData(widget.userData.data!.id);
  }

  Future<void> _loadData(String userId) async {
    try {
      // Use Future.wait to wait for all API calls to complete
      await Future.wait([
        _loadTasks(),
        _loadTherapists(),
        _loadUsers(),
      ]);
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  Future<void> _loadUsers() async {
    try {
      List<UserModel> loadedUsers = await APIService.getAllUsers();
      setState(() {
        users = loadedUsers;
      });
    } catch (error) {
      print('Error loading users: $error');
    }
  }

  Future<void> _loadTherapists() async {
    try {
      List<TherapistModel> loadedTherapists = await APIService.getAllTherapists();
      setState(() {
        therapists = loadedTherapists;
      });
    } catch (error) {
      print('Error loading therapists: $error');
    }
  }

  Future<void> _loadTasks() async {
    try {
      List<TaskModel> loadedTasks = await APIService.getAllTasks();
      setState(() {
        tasks = loadedTasks;
      });
    } catch (error) {
      print('Error loading tasks: $error');
    }
  }
  List<TaskModel> filterTasksByDate(DateTime date) {
    return tasks.where((task){
      DateTime taskDate = DateTime.parse(task.fromDate);
      return taskDate.year == date.year &&
      taskDate.month == date.month &&
      taskDate.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      drawer: AdminNavBar(userData: widget.userData,),
      appBar: AppBar(
        title: Text('Task List'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('List of Tasks',
              style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,),
            ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 30,
              itemBuilder: (context, index){
                DateTime currentDate = DateTime.now().add(Duration(days: index));
                List<TaskModel> filteredTasks = filterTasksByDate(currentDate);
                return _buildTaskListView(currentDate, filteredTasks);
              },
            )
          ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => CreateTaskAdminPage(userData: widget.userData)),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: kPrimaryColor,
      ),
    );
  }

  Widget _buildTaskListView(DateTime date, List<TaskModel> filteredTasks) {
    if(filteredTasks.isEmpty){
      return SizedBox();
    }
    filteredTasks.sort((a, b) =>
    DateTime.parse(a.fromDate).compareTo(DateTime.parse(b.fromDate)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMM d').format(date),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        SizedBox(height: 8),
        ...filteredTasks.map((task){
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Dismissible(
              key: Key(task.id!), // Use a unique key for each Dismissible
              background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(
              Icons.delete,
              color: Colors.white,
              ),
            ),
              onDismissed: (direction) {
                _deleteTask(task);
              },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  task.taskTitle,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.date_range, size: 18, color: kPrimaryColor),
                        SizedBox(width: 8),
                        Text(
                          "${DateFormat('dd-MM-yyyy').format(
                              DateTime.parse(task.fromDate))}",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18, color: kPrimaryColor),
                        SizedBox(width: 8),
                        Text("${DateFormat('hh:mm a').format(
                            DateTime.parse(task.fromDate))} - ${DateFormat(
                            'hh:mm a').format(DateTime.parse(task.toDate))}",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),

                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) =>
                        TaskDetailsAdminPage(
                            userData: widget.userData,
                            task: task),
                  ),
                  );
                },

              ),
            ),
            ),
          );
        })
      ],
    );
  }
  Future<void> _deleteTask(TaskModel task) async {
    String? taskId = task.id;
    if (taskId != null) {
      bool deleteConfirmed = await showDeleteDialog(context);
      if (deleteConfirmed) {
        bool deleteSuccess = await APIService.deleteTask(taskId);
        if (deleteSuccess) {
          setState(() {
            tasks.removeWhere((t) => t.id == taskId); // Remove the deleted task from the list
          });
          showAlertDialog(context, 'Task deleted successfully');
        } else {
          showAlertDialog(context, 'Failed to delete task');
        }
      }
    }
  }
  Future<bool> showDeleteDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Config.appName),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancel is pressed
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when delete is pressed
              },
              child: Text('Delete', style: TextStyle(color: kPrimaryColor),),
            ),
          ],
        );
      },
    );
  }
  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Config.appName),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK',
                style: TextStyle(color: kPrimaryColor),),
            ),
          ],
        );
      },
    );
  }
}
