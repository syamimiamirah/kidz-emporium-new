import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/screens/admin/update_task_admin.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/models/therapist_model.dart';

import '../../contants.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class TaskDetailsAdminPage extends StatefulWidget {
  final LoginResponseModel userData;
  final TaskModel task;

  const TaskDetailsAdminPage({
    Key? key,
    required this.userData,
    required this.task,
  }) : super(key: key);

  @override
  _TaskDetailsAdminPageState createState() => _TaskDetailsAdminPageState();
}

class _TaskDetailsAdminPageState extends State<TaskDetailsAdminPage> {
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildDetailItem(
                label: 'Task:',
                value: widget.task.taskTitle,
                icon: Icons.task,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Date:',
                value: DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.task.fromDate)),
                icon: Icons.calendar_today,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Time Slot:',
                value: "${DateFormat('hh:mm a').format(DateTime.parse(widget.task.fromDate))} - ${DateFormat('hh:mm a').format(DateTime.parse(widget.task.toDate))}",
                icon: Icons.access_time,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Description:',
                value: widget.task.taskDescription,
                icon: Icons.description,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Therapist:',
                value: "",
                icon: Icons.people,
                iconColor: kPrimaryColor,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print('Task ID: ${widget.task.id}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateTaskAdminPage(userData: widget.userData, taskId: widget.task.id ?? ''),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: kPrimaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Update',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required String label, required String value, required IconData icon, Color iconColor = kPrimaryColor}) {
    if (label == 'Therapist:') {
      // Convert therapist IDs to a list of names
      final therapistNames = widget.task.therapistId.map((therapistId) {
        print('Therapist ID: $therapistId');
        // Find the corresponding therapist in the users list
        UserModel? therapist = users.firstWhere((user) => user.id == therapistId, orElse: () => UserModel(id: '',
            name: '',
            email: '',
            password: '',
            phone: '',
            role: 'Therapist'), // Default value if user not found
        );
        return therapist?.name ?? 'Unknown Therapist';
      }).toList();

      // Join the therapist names into a single string
      value = therapistNames.map((name) => '• $name').join('\n');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: iconColor),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16),
                  softWrap: true,
                  maxLines: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
