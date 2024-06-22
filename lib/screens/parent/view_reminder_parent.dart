import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/screens/parent/create_reminder_parent.dart';
import 'package:kidz_emporium/screens/parent/update_reminder_parent.dart';
import 'package:kidz_emporium/models/reminder_model.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../components/side_menu.dart';
import '../../config.dart';
import '../../contants.dart';
import '../../models/login_response_model.dart';

class ViewReminderParentPage extends StatefulWidget {
  final LoginResponseModel userData;

  const ViewReminderParentPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ViewReminderParentPageState createState() => _ViewReminderParentPageState();
}

class _ViewReminderParentPageState extends State<ViewReminderParentPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  Map<String, dynamic> mySelectedEvents = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
    _loadReminders(widget.userData.data!.id);
  }

  Future<void> _loadReminders(String userId) async {
    try {
      List<ReminderModel> reminders = await APIService.getReminder(widget.userData.data!.id);
      print('API Response: $reminders');

      for (var reminderData in reminders) {
        String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(reminderData.fromDate as String));
        String title = reminderData.eventName;
        String details = reminderData.details;
        String? id = reminderData.id;
        String fromTime = DateFormat('hh:mm a').format(DateTime.parse(reminderData.fromDate));
        String toTime = DateFormat('hh:mm a').format(DateTime.parse(reminderData.toDate));
        //print('Reminder ID from API: $id');


        mySelectedEvents[dateKey] ??= [];
        mySelectedEvents[dateKey]!.add({
          'id': id,
          'title': title,
          'details': details,
          'fromTime': fromTime,
          'toTime': toTime
        });
      }

      setState(() {});
    } catch (error) {
      print('Error loading reminders: $error');
    }
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(userData: widget.userData),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text("View Reminder"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2023),
            lastDay: DateTime(2025),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDate, selectedDay)) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _listOfDayEvents,
          ),
          Expanded(
            child: _listOfDayEvents(_selectedDate!).isNotEmpty
                ? ListView.builder(
              itemCount: _listOfDayEvents(_selectedDate!).length,
              itemBuilder: (context, index) {
                String reminderTitle = _listOfDayEvents(_selectedDate!)[index]['title'];
                String reminderDetails = _listOfDayEvents(_selectedDate!)[index]['details'];
                String reminderId = _listOfDayEvents(_selectedDate!)[index]['id']!;
                String fromTime = _listOfDayEvents(_selectedDate!)[index]['fromTime'];
                String toTime = _listOfDayEvents(_selectedDate!)[index]['toTime'];
                Color backgroundColor = Colors.grey.withOpacity(0.3);

                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    color: Colors.red,
                    alignment: AlignmentDirectional.centerEnd,
                    padding: EdgeInsets.only(right: 20),
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onDismissed: (direction) async {
                    String? reminderId = mySelectedEvents[DateFormat('yyyy-MM-dd').format(_selectedDate!)]![index]['id'];

                    // Ensure the reminderId is not null before attempting deletion
                    if (reminderId != null) {
                      bool deleteConfirmed = await showDeleteConfirmationDialog(context);

                      if (deleteConfirmed) {
                        bool deleteSuccess = await APIService.deleteReminder(reminderId);

                        if (deleteSuccess) {
                          setState(() {
                            mySelectedEvents[DateFormat('yyyy-MM-dd').format(_selectedDate!)]!.removeAt(index);
                          });

                          // Show an AlertDialog for successful deletion
                          showAlertDialog(context, 'Reminder deleted successfully');
                        } else {
                          showAlertDialog(context, 'Failed to delete reminder');
                        }
                      }
                    }
                  },
                  child: Card(
                    color: kPrimaryColor,
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text('$reminderTitle', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),),
                          SizedBox(height: 4),
                          Text('Details: $reminderDetails', style: TextStyle(fontSize: 16),),
                          SizedBox(height: 4),
                          Text(
                            'Time: $fromTime - $toTime',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateReminderParentPage(userData: widget.userData, reminderId: reminderId),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(child: Text('No reminders for the selected date', style: TextStyle(fontSize: 16),), ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateReminderParentPage(userData: widget.userData,  selectedDate: _selectedDate!,),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: kPrimaryColor,
      ),
    );
  }
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Config.appName),
          content: Text('Are you sure you want to delete this reminder?'),
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
              child: Text('OK', style: TextStyle(color: kPrimaryColor),),
            ),
          ],
        );
      },
    );
  }
}


