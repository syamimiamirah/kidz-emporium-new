import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import '../../components/side_menu.dart';
import '../../models/booking_model.dart';
import '../../models/child_model.dart';
import '../../models/login_response_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils.dart';
import 'create_booking_parent.dart';
import 'details_booking_parent.dart';

class ViewBookingParentPage extends StatefulWidget {
  final LoginResponseModel userData;

  const ViewBookingParentPage({Key? key, required this.userData}): super(key: key);
  @override
  _ViewBookingListPageState createState() => _ViewBookingListPageState();
}

class _ViewBookingListPageState extends State<ViewBookingParentPage> {
  List<BookingModel> bookings = [];
  List<ChildModel> children = [];
  List<TherapistModel> therapists = [];
  List<UserModel> users = []; // Add a list to store user details

  @override
  void initState() {
    super.initState();
    _loadData(widget.userData.data!.id);
  }

  Future<void> _loadData(String userId) async {
    try {
      // Use Future.wait to wait for all API calls to complete
      await Future.wait([
        _loadBooking(userId),
        _loadChildren(userId),
        _loadTherapists(userId),
        _loadUsers(), // Fetch user details
      ]);
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  // Fetch user details
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

  Future<void> _loadBooking(String userId) async {
    try {
      List<BookingModel> loadedBooking = await APIService.getBooking(widget.userData.data!.id);
      setState(() {
        bookings = loadedBooking;
      });
    } catch (error) {
      print('Error loading bookings: $error');
    }
  }

  Future<void> _loadChildren(String userId) async {
    try {
      List<ChildModel> loadedChildren = await APIService.getChild(widget.userData.data!.id);
      setState(() {
        children = loadedChildren;
      });
    } catch (error) {
      print('Error loading children: $error');
    }
  }

  Future<void> _loadTherapists(String userId) async {
    try {
      List<TherapistModel> loadedTherapists = await APIService.getAllTherapists();
      setState(() {
        therapists = loadedTherapists;
      });
    } catch (error) {
      print('Error loading therapists: $error');
    }
  }

  List<BookingModel> filterBookingsByDate(DateTime date) {
    return bookings.where((booking) {
      DateTime bookingDate = DateTime.parse(booking.fromDate);
      return bookingDate.year == date.year &&
          bookingDate.month == date.month &&
          bookingDate.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(userData: widget.userData),
      appBar: AppBar(
        title: Text('Booking List'),
        centerTitle: true,
        backgroundColor: kPrimaryColor, // Change the color to match your theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Bookings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 30, // Display bookings for the next 7 days
                itemBuilder: (context, index) {
                  DateTime currentDate = DateTime.now().add(Duration(days: index));
                  List<BookingModel> filteredBookings = filterBookingsByDate(currentDate);
                  return _buildBookingListView(currentDate, filteredBookings);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => CreateBookingParentPage(userData: widget.userData)),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: kPrimaryColor, // Change the color to match your theme
      ),
    );
  }

  Widget _buildBookingListView(DateTime date, List<BookingModel> filteredBookings) {
    if (filteredBookings.isEmpty) {
      return SizedBox(); // Return an empty SizedBox if there are no bookings for this date
    }
    filteredBookings.sort((a, b) =>
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
        ...filteredBookings.map((booking) {
          // Fetch user details for the therapist
          UserModel therapistUser = users.firstWhere(
                (user) => user.id == booking.therapistId,
            orElse: () => UserModel(id: '',
                name: 'Not decided yet',
                email: '',
                password: '',
                phone: '',
                role: 'Therapist'), // Default value if user not found
          );

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
                  children
                      .firstWhere((child) => child.id == booking.childId,
                      orElse: () => ChildModel(childName: 'Unknown',
                          birthDate: '',
                          gender: '',
                          program: '',
                          userId: ''))
                      .childName,
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
                              DateTime.parse(booking.fromDate))}",
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
                            DateTime.parse(booking.fromDate))} - ${DateFormat(
                            'hh:mm a').format(DateTime.parse(booking.toDate))}",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 18, color: kPrimaryColor),
                        SizedBox(width: 8),
                        Text(
                          "Therapist: ${therapistUser.name}",
                          // Use therapistUser.name
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingDetailsPage(
                            userData: widget.userData,
                            booking: booking,
                            therapist: therapists.firstWhere(
                                  (therapist) =>
                              therapist.id == booking.therapistId,
                              orElse: () =>
                                  TherapistModel(
                                    specialization: '',
                                    hiringDate: '',
                                    aboutMe: '',
                                    therapistId: '',
                                    managedBy: '',
                                  ),
                            ),
                            therapistUser: therapistUser,
                            child: children.firstWhere(
                                  (child) => child.id == booking.childId,
                              orElse: () =>
                                  ChildModel(
                                    childName: 'Unknown',
                                    birthDate: '',
                                    gender: '',
                                    program: '',
                                    userId: '',
                                  ),
                            ),
                          ),
                    ),
                  );
                },

              ),
            ),
          );
        }
        ),
      ],
    );
  }
}
