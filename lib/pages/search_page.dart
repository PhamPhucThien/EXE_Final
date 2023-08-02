import 'package:project/helper/helper_function.dart';
import 'package:project/pages/chat_page.dart';
import 'package:project/service/database_service.dart';
import 'package:project/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  bool isJoining = false;
  User? user;
  List<String> joinedGroups = [];
  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
    joinedOrNot("", "", "", ""); // Call the joinedOrNot function in initState
  }

  getCurrentUserIdandName() async {
    userName = (await HelperFunctions.getUserNameFromSF()) ?? "";
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Search",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups....",
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                )
              : Expanded(
                  child: groupList(),
                ),
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    // if (searchController.text.isNotEmpty) {
    //   setState(() {
    //     isLoading = true;
    //   });
    await DatabaseService()
        .searchByName(searchController.text)
        .then((snapshot) {
      setState(() {
        searchSnapshot = snapshot;
        isLoading = false;
        hasUserSearched = true;
      });
    });
    // }
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              final groupId = searchSnapshot!.docs[index]['groupId'];
              final groupName = searchSnapshot!.docs[index]['groupName'];
              final admin = searchSnapshot!.docs[index]['admin'];

              // Kiểm tra xem phòng đã tham gia hay chưa
              final isGroupJoined = joinedGroups.contains(groupId);

              return groupTile(
                userName,
                groupId,
                groupName,
                admin,
                isGroupJoined,
                index, // Truyền trạng thái đã tham gia vào widget
              );
            },
          )
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupName, String admin) async {
    if (user != null) {
      await DatabaseService(uid: user!.uid)
          .isUserJoined(groupName, groupId, userName)
          .then((value) {
        setState(() {
          isJoined = value;
        });
      });
    }
  }

  Widget groupTile(String userName, String groupId, String groupName,
      String admin, bool isGroupJoined, int index) {
    if (isGroupJoined) {
      return ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            groupName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(groupName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("Admin: ${getName(admin)}"),
        trailing: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text(
            "Joined",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      int maxGroupMembers = 2; // Số lượng thành viên tối đa trong phòng
      bool isGroupFull =
          searchSnapshot!.docs[index]['members'].length >= maxGroupMembers;

      return ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            groupName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(groupName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("Admin: ${getName(admin)}"),
        trailing: isGroupFull
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey, // Hoặc màu khác tùy ý
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Unavailable",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : InkWell(
                onTap: () async {
                  if (isJoining)
                    return; // Ngăn người dùng nhấn lại trong quá trình xử lý

                  setState(() {
                    isJoining = true;
                  });

                  bool updatedIsJoined = !isGroupJoined;
                  await DatabaseService(uid: user!.uid)
                      .toggleGroupJoin(groupId, userName, groupName);
                  setState(() {
                    // Thêm hoặc xóa groupId khỏi danh sách nhóm đã tham gia
                    if (updatedIsJoined) {
                      joinedGroups.add(groupId);
                    } else {
                      joinedGroups.remove(groupId);
                    }
                    isJoined = updatedIsJoined;
                    isJoining = false; // Đặt lại trạng thái isJoining
                  });

                  if (updatedIsJoined) {
                    showSnackbar(
                        context, Colors.green, "Successfully joined the group");
                  } else {
                    showSnackbar(
                        context, Colors.red, "Left the group $groupName");
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).primaryColor,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text("Join Now",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
      );
    }
  }
}









// import 'package:project/helper/helper_function.dart';
// import 'package:project/pages/chat_page.dart';
// import 'package:project/service/database_service.dart';
// import 'package:project/widgets/widgets.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SearchPage extends StatefulWidget {
//   const SearchPage({Key? key}) : super(key: key);

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   TextEditingController searchController = TextEditingController();
//   bool isLoading = false;
//   QuerySnapshot? searchSnapshot;
//   bool hasUserSearched = false;
//   String userName = "";
//   bool isJoined = false;
//   User? user;

//   @override
//   void initState() {
//     super.initState();
//     getCurrentUserIdandName();
//   }

//   getCurrentUserIdandName() async {
//     await HelperFunctions.getUserNameFromSF().then((value) {
//       setState(() {
//         userName = value!;
//       });
//     });
//     user = FirebaseAuth.instance.currentUser;
//   }

//   String getName(String r) {
//     return r.substring(r.indexOf("_") + 1);
//   }

//   String getId(String res) {
//     return res.substring(0, res.indexOf("_"));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Theme.of(context).primaryColor,
//         title: const Text(
//           "Search",
//           style: TextStyle(
//               fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Theme.of(context).primaryColor,
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: searchController,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         hintText: "Search groups....",
//                         hintStyle:
//                             TextStyle(color: Colors.white, fontSize: 16)),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     initiateSearchMethod();
//                   },
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(40)),
//                     child: const Icon(
//                       Icons.search,
//                       color: Colors.white,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           isLoading
//               ? Center(
//                   child: CircularProgressIndicator(
//                       color: Theme.of(context).primaryColor),
//                 )
//               : groupList(),
//         ],
//       ),
//     );
//   }

//   initiateSearchMethod() async {
//     // if (searchController.text.isNotEmpty) {
//     //   setState(() {
//     //     isLoading = true;
//     //   });
//       await DatabaseService()
//           .searchByName(searchController.text)
//           .then((snapshot) { /// Kết quả tìm kiếm được trả về dưới dạng snapshot
//         setState(() {
//           searchSnapshot = snapshot;
//           isLoading = false;
//           hasUserSearched = true;
//         });
//       });
//    // }
//   }

//   groupList() {
//     return hasUserSearched
//         ? ListView.builder(
//             shrinkWrap: true,
//             itemCount: searchSnapshot!.docs.length,
//             itemBuilder: (context, index) {
//               return groupTile(
//                 userName,
//                 searchSnapshot!.docs[index]['groupId'],
//                 searchSnapshot!.docs[index]['groupName'],
//                 searchSnapshot!.docs[index]['admin'],
//               );
//             },
//           )
//         : Container();
//   }

//   joinedOrNot(
//       String userName, String groupId, String groupname, String admin) async {
//     await DatabaseService(uid: user!.uid)
//         .isUserJoined(groupname, groupId, userName)
//         .then((value) {
//       setState(() {
//         isJoined = value;
//       });
//     });
//   }

//   Widget groupTile(
//       String userName, String groupId, String groupName, String admin) {
//     // function to check whether user already exists in group
//     joinedOrNot(userName, groupId, groupName, admin);
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       leading: CircleAvatar(
//         radius: 30,
//         backgroundColor: Theme.of(context).primaryColor,
//         child: Text(
//           groupName.substring(0, 1).toUpperCase(),
//           style: const TextStyle(color: Colors.white),
//         ),
//       ),
//       title:
//           Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
//       subtitle: Text("Admin: ${getName(admin)}"),
//       trailing: InkWell(    /// giong event
//         onTap: () async {
//           await DatabaseService(uid: user!.uid)
//               .toggleGroupJoin(groupId, userName, groupName);
//           if (isJoined) {
//             setState(() {
//               isJoined = !isJoined;
//             });
//             showSnackbar(context, Colors.green, "Successfully joined he group");
//             Future.delayed(const Duration(seconds: 2), () {
//               nextScreen(
//                   context,
//                   ChatPage(
//                       groupId: groupId,
//                       groupName: groupName,
//                       userName: userName));
//             });
//           } else {
//             setState(() {
//               isJoined = !isJoined;
//               showSnackbar(context, Colors.red, "Left the group $groupName");
//             });
//           }
//         },
//         child: isJoined
//             ? Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.black,
//                   border: Border.all(color: Colors.white, width: 1),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: const Text(
//                   "Joined",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               )
//             : Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: const Text("Join Now",
//                     style: TextStyle(color: Colors.white)),
//               ),
//       ),
//     );
//   }
// }
