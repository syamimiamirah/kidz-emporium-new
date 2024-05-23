import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/Screens/admin/create_task_admin.dart';
import 'package:kidz_emporium/Screens/admin/details_task_admin.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import '../../components/side_menu.dart';
import '../../models/booking_model.dart';
import '../../models/child_model.dart';
import '../../models/login_response_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'details_task_therapist.dart';

class ViewTaskTherapistPage extends StatefulWidget {
  final LoginResponseModel userData;

  const ViewTaskTherapistPage ({Key? key, required this.userData}): super(key: key);
  @override
  _viewTaskTherapistPageState createState() => _viewTaskTherapistPageState();
}

class _viewTaskTherapistPageState extends State<ViewTaskTherapistPage>{
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
        _loadTasks(userId),
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

  Future<void> _loadTasks(String userId) async {
    try {
      List<TaskModel> allTasks = await APIService.getAllTasks();
      List<TaskModel> therapistTasks = allTasks.where((task) => task.therapistId.contains(userId)).toList();
      setState(() {
        tasks = therapistTasks;
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
      drawer: TherapistNavBar(userData: widget.userData,),
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
                        TaskDetailsTherapistPage(
                            userData: widget.userData,
                            task: task),
                  ),
                  );
                },

              ),
            ),
          );
        })
      ],
    );
  }
}