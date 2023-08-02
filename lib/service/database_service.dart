import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");
  final CollectionReference walletCollection =
      FirebaseFirestore.instance.collection("wallets");
  final CollectionReference paymentCollection =
      FirebaseFirestore.instance.collection("payment_histories");

  // saving the userdata
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "aa",
      "uid": uid,
      "roles": "Customer",
    });
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference =
        userCollection.doc(uid); // cập nhật groups trong nhánh cha users
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // get group members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search
  searchByName(String groupName) {
    if (groupName == "") {
      return getall();
    } else {
      return groupCollection.where("groupName", isEqualTo: groupName).get();
    }
  }

  getall() {
    return groupCollection.get();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> deleteGroupByGroupId(String groupId) async {
    try {
      QuerySnapshot groupSnapshot =
          await groupCollection.where("groupId", isEqualTo: groupId).get();

      if (groupSnapshot.docs.isNotEmpty) {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        groupSnapshot.docs.forEach((doc) {
          batch.delete(doc.reference);
        });

        await batch.commit();
      }
    } catch (error) {
      print("Lỗi khi xóa nhóm từ collection 'groups': $error");
    }
  }

  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // Check if the group already has two members
    DocumentSnapshot groupSnapshot = await groupDocumentReference.get();
    List<dynamic> members = groupSnapshot['members'];

    // Check if the current user is the admin of the group
    bool isAdmin = groupSnapshot['admin'] == "${uid}_$userName";

    if (members.length >= 2) {
      if (members.length == 2 && members.contains("${uid}_$userName")) {
        // Last member is leaving the group, delete the entire group
        await deleteGroupAndRemoveFromUser(groupId);

        if (isAdmin) {
          DocumentReference adminGroupReference =
              userCollection.doc(uid).collection("groups").doc(groupId);
          await adminGroupReference.delete();
        }
      } else {
        // Remove the user from the group's member list
        await groupDocumentReference.update({
          "members": FieldValue.arrayRemove(["${uid}_$userName"])
        });

        // Remove the group from user's groups field
        await userDocumentReference.update({
          "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
        });
      }
    } else {
      if (groups.contains("${groupId}_$groupName")) {
        await userDocumentReference.update({
          "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
        });
      } else {
        await userDocumentReference.update({
          "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
        });
        await groupDocumentReference.update({
          "members": FieldValue.arrayUnion(["${uid}_$userName"])
        });
      }
    }
  }

  Future deleteGroupAndRemoveFromUser(String groupId) async {
    QuerySnapshot messagesSnapshot =
        await groupCollection.doc(groupId).collection("messages").get();
    for (DocumentSnapshot messageDoc in messagesSnapshot.docs) {
      await messageDoc.reference.delete();
    }

    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot groupSnapshot = await groupDocumentReference.get();
    await groupDocumentReference.delete();

    QuerySnapshot usersSnapshot = await userCollection.get();
    for (DocumentSnapshot userDoc in usersSnapshot.docs) {
      List<dynamic> userGroups = userDoc['groups'];
      if (userGroups.contains("${groupId}_${groupSnapshot['groupName']}")) {
        await userDoc.reference.update({
          "groups": FieldValue.arrayRemove(
              ["${groupId}_${groupSnapshot['groupName']}"]),
        });
      }
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  // Get wallet info for user with id
  Future getWallet(String userId) async {
    QuerySnapshot snapshot =
        await walletCollection.where("user_id", isEqualTo: userId).get();
    return snapshot;
  }

  // Get histories from wallet with wallet id
  Future getPayment(String walletId) async {
    QuerySnapshot snapshot =
        await paymentCollection.where("wallet_id", isEqualTo: walletId).get();
    return snapshot;
  }

  // Get histories from wallet with wallet id and status
  Future getPaymentWithStatus(String walletId, String status) async {
    QuerySnapshot snapshot = await paymentCollection
        .where("wallet_id", isEqualTo: walletId)
        .where("status", isEqualTo: status)
        .get();
    return snapshot;
  }

  //Create new payment
  Future createPayment(String walletId, double amount, String code) async {
    DocumentReference paymentDocumentReference = await paymentCollection.add({
      "wallet_id": walletId,
      "amount": amount,
      "status": "Created",
      "code": code
    });
  }

  //Update payment
  Future updatePayment(String uid, String status) async {
    paymentCollection.doc(uid).update({"status": status});
  }

  //Get wallet_id with email
  Future getUserWithEmail(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();

    return snapshot;
  }

  //Get money from wallet
  Future getMoneyFromWallet(String uid) async {
    QuerySnapshot snapshot =
        await walletCollection.where("user_id", isEqualTo: uid).get();

    return snapshot;
  }

  //Update token
  Future updateToken(String uid, int token) async {
    return await walletCollection.doc(uid).update({"token": token});
  }
}
