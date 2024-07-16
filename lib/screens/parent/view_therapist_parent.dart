import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/models/therapist_model.dart';

import '../../components/side_menu.dart';
import '../../contants.dart';
import '../../models/login_response_model.dart';
import '../../models/user_model.dart';
import 'details_therapist_parent.dart';

class ViewTherapistParentPage extends StatefulWidget {
  final LoginResponseModel userData;
  final List<TherapistModel> therapists;
  final List<UserModel> users; // List of UserModel

  const ViewTherapistParentPage({
    Key? key,
    required this.userData,
    required this.therapists,
    required this.users,
  }) : super(key: key);

  @override
  _ViewTherapistParentPageState createState() => _ViewTherapistParentPageState();
}

class _ViewTherapistParentPageState extends State<ViewTherapistParentPage> {
  List<TherapistModel> filteredTherapists = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredTherapists = widget.therapists;
  }

  void _filterTherapists(String query) {
    setState(() {
      filteredTherapists = widget.therapists.where((therapist) {
        // Find the user associated with the therapist
        UserModel? therapistUser = widget.users.firstWhere(
              (user) => user.id == therapist.therapistId,
          orElse: () => UserModel(
            id: '',
            name: 'Unknown',
            email: '',
            password: '',
            phone: '',
            role: 'Therapist',
          ),
        );

        // Check if the therapist's name contains the query
        return therapistUser?.name.toLowerCase().contains(query.toLowerCase()) ?? false;
      }).toList();
    });
  }

  void _resetSearch() {
    setState(() {
      filteredTherapists = widget.therapists;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(userData: widget.userData),
      appBar: AppBar(
        title: Text('Therapists List'),
        backgroundColor: kSecondaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetSearch,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: _filterTherapists,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "List of Therapists",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTherapists.length,
                itemBuilder: (context, index) {
                  // Find the user associated with the therapist
                  UserModel? therapistUser = widget.users.firstWhere(
                        (user) => user.id == filteredTherapists[index].therapistId,
                    orElse: () =>  UserModel(id: '',
                        name: 'Unknown',
                        email: '',
                        password: '',
                        phone: '',
                        role: 'Therapist'),
                  );
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) =>
                        TherapistDetailParentPage(
                          userData: widget.userData,
                          therapistId: therapistUser.id!,
                          ),
                          ),
                        );
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            //color: Colors.pink[100]!.withOpacity(0.8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(color: Colors.grey.shade300, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage('assets/images/medical_team.png'),
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.person, size: 18, color: kSecondaryColor),
                                                SizedBox(width: 8),
                                                Text(
                                                  '${therapistUser?.name ?? 'N/A'}',
                                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.school, size: 18, color: kSecondaryColor),
                                                SizedBox(width: 8),
                                                Text(
                                                    '${filteredTherapists[index].specialization ?? 'N/A'}',
                                                  style: TextStyle(fontSize: 16),
                                                  softWrap: true,
                                                  maxLines: null,
                                                ),
                                              ],
                                            )
                                          ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),

                            ),
                          )
                      )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
