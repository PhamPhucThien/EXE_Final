import 'package:flutter/material.dart';
import 'package:project/helper/helper_function.dart';
import 'package:project/pages/auth/login_page.dart';
import 'package:project/pages/booking.dart';
import 'package:project/pages/doctor_schedular_work.dart';
import 'package:project/pages/meeting_rooms.dart';
import 'package:project/pages/profile_page.dart';
import 'package:project/pages/search_page.dart';
import 'package:project/service/auth_service.dart';
import 'package:project/service/database_service.dart';
import 'package:project/widgets/group_tile.dart';
import 'package:project/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/pages/roles.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  // string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(context, const SearchPage());
            },
            icon: const Icon(
              Icons.search,
            ),
          )
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Groups",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27,
          ),
        ),
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: const EdgeInsets.symmetric(vertical: 50),
      //     children: <Widget>[
      //       Icon(
      //         Icons.account_circle,
      //         size: 150,
      //         color: Colors.grey[700],
      //       ),
      //       const SizedBox(
      //         height: 15,
      //       ),
      //       Text(
      //         userName,
      //         textAlign: TextAlign.center,
      //         style: const TextStyle(fontWeight: FontWeight.bold),
      //       ),
      //       const SizedBox(
      //         height: 30,
      //       ),
      //       const Divider(
      //         height: 2,
      //       ),
      //       ListTile(
      //         onTap: () {},
      //         selectedColor: Theme.of(context).primaryColor,
      //         selected: true,
      //         contentPadding:
      //             const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      //         leading: const Icon(Icons.group),
      //         title: const Text(
      //           "Groups",
      //           style: TextStyle(color: Colors.black),
      //         ),
      //       ),
      //       ListTile(
      //         onTap: () {
      //           nextScreenReplace(
      //             context,
      //             ProfilePage(
      //               userName: userName,
      //               email: email,
      //             ),
      //           );
      //         },
      //         contentPadding:
      //             const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      //         leading: const Icon(Icons.group),
      //         title: const Text(
      //           "Profile",
      //           style: TextStyle(color: Colors.black),
      //         ),

      //       ),
      //       ListTile(
      //         onTap: () {
      //           nextScreenReplace(
      //             context,
      //             const BookingPage(),
      //           );
      //         },
      //         contentPadding:
      //             const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      //         leading: const Icon(Icons.room_service),
      //         title: const Text(
      //           "Booking",
      //           style: TextStyle(color: Colors.black),
      //         ),

      //       ),
      //       if(HelperFunctions.userRole == roles.Doctor.name)
      //         ListTile(
      //           onTap: () {
      //             nextScreenReplace(
      //               context,
      //               WorkingHoursScreen(),
      //             );
      //           },
      //           contentPadding:
      //               const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      //           leading: const Icon(Icons.schedule),
      //           title: const Text(
      //             "Working Schedule",
      //             style: TextStyle(color: Colors.black),
      //           ),

      //         ),
      //        ListTile(
      //           onTap: () {
      //             nextScreenReplace(
      //               context,
      //               MeetingRoomScreen(),
      //             );
      //           },
      //           contentPadding:
      //               const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      //           leading: const Icon(Icons.meeting_room),
      //           title: const Text(
      //             "Meeting Notes",
      //             style: TextStyle(color: Colors.black),
      //           ),

      //         ),
      //       ListTile(
      // onTap: () async {
      //   showDialog(
      //     barrierDismissible: false,
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         title: const Text("Logout"),
      //         content: const Text("Are you sure you want to logout?"),
      //         actions: [
      //           IconButton(
      //             onPressed: () {
      //               Navigator.pop(context);
      //             },
      //             icon: const Icon(
      //               Icons.cancel,
      //               color: Colors.red,
      //             ),
      //           ),
      //           IconButton(
      //             onPressed: () async {
      //               await authService.signOut();
      //               Navigator.of(context).pushAndRemoveUntil(
      //                 MaterialPageRoute(
      //                   builder: (context) => const LoginPage(),
      //                 ),
      //                 (route) => false,
      //               );
      //             },
      //             icon: const Icon(
      //               Icons.done,
      //               color: Colors.green,
      //             ),
      //           ),
      //         ],
      //       );
      //     },
      //   );
      // },
      //         contentPadding:
      //             const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      //         leading: const Icon(Icons.exit_to_app),
      //         title: const Text(
      //           "Logout",
      //           style: TextStyle(color: Colors.black),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
      body: groupList(),
      floatingActionButton: FutureBuilder<bool>(
        future: shouldShowFloatingActionButton(context),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return FloatingActionButton(
              onPressed: () {
                popUpDialog(context);
              },
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            );
          } else {
            return SizedBox(); // Ẩn nút floatingActionButton
          }
        },
      ),
    );
  }

  Future<String?> getUserRoles(BuildContext context, String uid) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic>? userData =
            snapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          String? lol = userData['roles'];

          if (lol != null) {
            return lol;
          }
        } else {
          return "none";
        }
      }
    } catch (e) {
      print('Error getting user roles: $e');
    }
    return null;
  }

  Future<bool> shouldShowFloatingActionButton(BuildContext context) async {
    // Get the current user's UID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Get the user's roles using the getUserRoles() method
    String? userRoles = await getUserRoles(context, uid);

    // Kiểm tra nếu vai trò là "Customer", trả về false để ẩn nút floatingActionButton
    if (userRoles == roles.Customer.toString()) {
      return false;
    }

    return true; // Mặc định hiển thị nút floatingActionButton
  }

  popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            title: const Text(
              "Create a group",
              textAlign: TextAlign.left,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor),
                      )
                    : TextField(
                        onChanged: (val) {
                          setState(() {
                            groupName = val;
                          });
                        },
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (groupName != "") {
                    setState(() {
                      _isLoading = true;
                    });
                    await DatabaseService(
                      uid: FirebaseAuth.instance.currentUser!.uid,
                    )
                        .createGroup(
                      userName,
                      FirebaseAuth.instance.currentUser!.uid,
                      groupName,
                    )
                        .whenComplete(() {
                      setState(() {
                        _isLoading = false;
                      });
                      gettingUserData(); // Cập nhật lại dữ liệu sau khi tạo nhóm
                    });
                    Navigator.of(context).pop();
                    showSnackbar(
                      context,
                      Colors.green,
                      "Group created successfully.",
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                child: const Text("CREATE"),
              ),
            ],
          );
        }));
      },
    );
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                    groupId: getId(snapshot.data['groups'][reverseIndex]),
                    groupName: getName(snapshot.data['groups'][reverseIndex]),
                    userName: snapshot.data['fullName'],
                  );
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}








// import 'package:project/helper/helper_function.dart';
// import 'package:project/pages/auth/login_page.dart';
// import 'package:project/pages/profile_page.dart';
// import 'package:project/pages/search_page.dart';
// import 'package:project/service/auth_service.dart';
// import 'package:project/service/database_service.dart';
// import 'package:project/widgets/group_tile.dart';
// import 'package:project/widgets/widgets.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';


// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String userName = "";
//   String email = "";
//   AuthService authService = AuthService();
//   Stream? groups;
//   bool _isLoading = false;
//   String groupName = "";

//   @override
//   void initState() {
//     super.initState();
//     gettingUserData();
//   }

//   // string manipulation
//   String getId(String res) {
//     return res.substring(0, res.indexOf("_"));
//   }

//   String getName(String res) {
//     return res.substring(res.indexOf("_") + 1);
//   }

//   gettingUserData() async {
//     await HelperFunctions.getUserEmailFromSF().then((value) {
//       setState(() {
//         email = value!;
//       });
//     });
//     await HelperFunctions.getUserNameFromSF().then((val) {
//       setState(() {
//         userName = val!;
//       });
//     });
//     // getting the list of snapshots in our stream
//     await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
//         .getUserGroups()
//         .then((snapshot) {
//       setState(() {
//         groups = snapshot;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           IconButton(
//               onPressed: () {
//                 nextScreen(context, const SearchPage());
//               },
//               icon: const Icon(
//                 Icons.search,
//               ))
//         ],
//         elevation: 0,
//         centerTitle: true,
//         backgroundColor: Theme.of(context).primaryColor,
//         title: const Text(
//           "Groups",
//           style: TextStyle(
//               color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
//         ),
//       ),
//       drawer: Drawer(
//           child: ListView(
//         padding: const EdgeInsets.symmetric(vertical: 50),
//         children: <Widget>[
//           Icon(
//             Icons.account_circle,
//             size: 150,
//             color: Colors.grey[700],
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           Text(
//             userName,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(
//             height: 30,
//           ),
//           const Divider(
//             height: 2,
//           ),
//           ListTile(
//             onTap: () {},
//             selectedColor: Theme.of(context).primaryColor,
//             selected: true,
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//             leading: const Icon(Icons.group),
//             title: const Text(
//               "Groups",
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//           ListTile(
//             onTap: () {
//               nextScreenReplace(
//                   context,
//                   ProfilePage(
//                     userName: userName,
//                     email: email,
//                   ));
//             },
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//             leading: const Icon(Icons.group),
//             title: const Text(
//               "Profile",
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//           ListTile(
//             onTap: () async {
//               showDialog(
//                   barrierDismissible: false,
//                   context: context,
//                   builder: (context) {
//                     return AlertDialog(
//                       title: const Text("Logout"),
//                       content: const Text("Are you sure you want to logout?"),
//                       actions: [
//                         IconButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           icon: const Icon(
//                             Icons.cancel,
//                             color: Colors.red,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () async {
//                             await authService.signOut();
//                             Navigator.of(context).pushAndRemoveUntil(
//                                 MaterialPageRoute(
//                                     builder: (context) => const LoginPage()),
//                                 (route) => false);
//                           },
//                           icon: const Icon(
//                             Icons.done,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     );
//                   });
//             },
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//             leading: const Icon(Icons.exit_to_app),
//             title: const Text(
//               "Logout",
//               style: TextStyle(color: Colors.black),
//             ),
//           )
//         ],
//       )),
//       body: groupList(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           popUpDialog(context);
//         },
//         elevation: 0,
//         backgroundColor: Theme.of(context).primaryColor,
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//           size: 30,
//         ),
//       ),
//     );
//   }

//   popUpDialog(BuildContext context) {
//     showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(builder: ((context, setState) {
//             return AlertDialog(
//               title: const Text(
//                 "Create a group",
//                 textAlign: TextAlign.left,
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _isLoading == true
//                       ? Center(
//                           child: CircularProgressIndicator(
//                               color: Theme.of(context).primaryColor),
//                         )
//                       : TextField(
//                           onChanged: (val) {
//                             setState(() {
//                               groupName = val;
//                             });
//                           },
//                           style: const TextStyle(color: Colors.black),
//                           decoration: InputDecoration(
//                               enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(
//                                       color: Theme.of(context).primaryColor),
//                                   borderRadius: BorderRadius.circular(20)),
//                               errorBorder: OutlineInputBorder(
//                                   borderSide:
//                                       const BorderSide(color: Colors.red),
//                                   borderRadius: BorderRadius.circular(20)),
//                               focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(
//                                       color: Theme.of(context).primaryColor),
//                                   borderRadius: BorderRadius.circular(20))),
//                         ),
//                 ],
//               ),
//               actions: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                       primary: Theme.of(context).primaryColor),
//                   child: const Text("CANCEL"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (groupName != "") {
//                       setState(() {
//                         _isLoading = true;
//                       });
//                       DatabaseService(
//                               uid: FirebaseAuth.instance.currentUser!.uid)
//                           .createGroup(userName,
//                               FirebaseAuth.instance.currentUser!.uid, groupName)
//                           .whenComplete(() {
//                         _isLoading = false;
//                       });
//                       Navigator.of(context).pop();
//                       showSnackbar(
//                           context, Colors.green, "Group created successfully.");
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                       primary: Theme.of(context).primaryColor),
//                   child: const Text("CREATE"),
//                 )
//               ],
//             );
//           }));
//         });
//   }

//   groupList() {
//     return StreamBuilder(
//       stream: groups,
//       builder: (context, AsyncSnapshot snapshot) {
//         // make some checks
//         if (snapshot.hasData) {
//           if (snapshot.data['groups'] != null) {
//             if (snapshot.data['groups'].length != 0) {
//               return ListView.builder(
//                 itemCount: snapshot.data['groups'].length,
//                 itemBuilder: (context, index) {
//                   int reverseIndex = snapshot.data['groups'].length - index - 1;
//                   return GroupTile(
//                       groupId: getId(snapshot.data['groups'][reverseIndex]),
//                       groupName: getName(snapshot.data['groups'][reverseIndex]),
//                       userName: snapshot.data['fullName']);
//                 },
//               );
//             } else {
//               return noGroupWidget();
//             }
//           } else {
//             return noGroupWidget();
//           }
//         } else {
//           return Center(
//             child: CircularProgressIndicator(
//                 color: Theme.of(context).primaryColor),
//           );
//         }
//       },
//     );
//   }

//   noGroupWidget() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 25),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           GestureDetector(
//             onTap: () {
//               popUpDialog(context);
//             },
//             child: Icon(
//               Icons.add_circle,
//               color: Colors.grey[700],
//               size: 75,
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           const Text(
//             "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
//             textAlign: TextAlign.center,
//           )
//         ],
//       ),
//     );
//   }
// }


