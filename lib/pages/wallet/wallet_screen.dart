import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:vnpay_flutter/vnpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:project/service/database_service.dart';

import '../../service/qr.dart';

class WalletScreen extends StatefulWidget {
  final String userName;
  final String email;

  const WalletScreen({
    Key? key,
    required this.userName,
    required this.email,
  }) : super(key: key);

  @override
  State<WalletScreen> createState() => _PaymentState();
}

class Item {
  final int money;
  final String code;
  final String status;

  Item(this.money, this.code, this.status);
}

class _PaymentState extends State<WalletScreen> {
  late String userName;
  late String email;
  late QuerySnapshot uid;
  late QuerySnapshot wallet;
  QuerySnapshot? paymentList;
  String title = 'Mở QR';
  double userInput = 0;
  int token = 0;
  Item? selectedItem;
  final List<Item> items = List.empty(growable: true);
  final DatabaseService databaseService = DatabaseService();

  TextEditingController inputController = TextEditingController();

  @override
  void initState() {
    userName = widget.userName;
    email = widget.email;
    getData();
    super.initState();
  }

  Future<void> getData() async {
    uid = await databaseService.getUserWithEmail(email);

    updatePayment();
  }

  Future<void> updatePayment() async {
    items.clear();

    if (uid.docs[0].exists) {
      wallet = await databaseService.getWallet(uid.docs[0].id);
    } else {
      return;
    }

    paymentList = await databaseService.getPayment(wallet.docs[0].id);

    for (DocumentSnapshot pay in paymentList!.docs) {
      Item newItem = Item(pay['amount'], pay['code'], pay['status']);
      items.add(newItem);
    }

    setState(() {
      items;
      token = wallet.docs[0]["token"];
    });
  }

  String generateRandomString(int length) {
    final random = Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(length,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();

    return randomString;
  }

  void onPayment() async {
    double value = double.parse(inputController.text) * 1000;
    String code = generateRandomString(10);

    if (value == 0 || value > 500000) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Số tiền cao nhất là 500.000VNĐ'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Đóng'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (inputController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Bạn phải nhập số tiền'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Đóng'),
              ),
            ],
          );
        },
      );
      return;
    }

    QuerySnapshot contain = await databaseService.getPaymentWithStatus(
        wallet.docs[0].id, "Created");

    if (contain.size > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Bạn phải hoàn thành đơn "Đang xử lý"'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Đóng'),
              ),
            ],
          );
        },
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://api.vietqr.io/v2/generate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-client-id': 'cf6535c1-96b6-4292-a1e8-96260ebf7f1f',
        'x-api-key': 'cf6535c1-96b6-4292-a1e8-96260ebf7f1f',
      },
      body: jsonEncode(<String, dynamic>{
        'accountNo': '67010001634026',
        'accountName': 'PHAN NHAT HOANG',
        'acqId': 970418,
        'amount': value,
        'addInfo': code,
        'format': 'text',
        'template': "print"
      }),
    );

    databaseService.createPayment(wallet.docs[0].id, value, code);
    final responseData = jsonDecode(response.body);
    final String data = responseData['data']['qrDataURL'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QR(qrCodeDataURL: data),
      ),
    );
  }

  void showPayment() async {
    QuerySnapshot contain = await databaseService.getPaymentWithStatus(
        wallet.docs[0].id, "Created");

    if (contain.size == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Có lỗi đã xảy ra'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Đóng'),
              ),
            ],
          );
        },
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://api.vietqr.io/v2/generate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-client-id': 'cf6535c1-96b6-4292-a1e8-96260ebf7f1f',
        'x-api-key': 'cf6535c1-96b6-4292-a1e8-96260ebf7f1f',
      },
      body: jsonEncode(<String, dynamic>{
        'accountNo': '67010001634026',
        'accountName': 'PHAN NHAT HOANG',
        'acqId': 970418,
        'amount': contain.docs[0]['amount'],
        'addInfo': contain.docs[0]['code'],
        'format': 'text',
        'template': "print"
      }),
    );

    final responseData = jsonDecode(response.body);
    final String data = responseData['data']['qrDataURL'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QR(qrCodeDataURL: data),
      ),
    );

    updatePayment();
  }

  void deletePayment() async {
    QuerySnapshot contain = await databaseService.getPaymentWithStatus(
        wallet.docs[0].id, "Created");

    if (contain.size == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Có lỗi đã xảy ra'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Đóng'),
              ),
            ],
          );
        },
      );
      return;
    }
    databaseService.updatePayment(contain.docs[0].id, "Cancelled");
    updatePayment();
  }

  void onCheck() async {
    wallet = await databaseService.getWallet(uid.docs[0].id);
    token = wallet.docs[0]["token"];
    setState(() {
      token;
    });
    QuerySnapshot contain = await databaseService.getPaymentWithStatus(
        wallet.docs[0].id, "Created");

    if (contain.size == 0) {
      return;
    }

    final response = await http.get(
        Uri.parse('https://oauth.casso.vn/v2/transactions?pageSize=50'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Apikey AK_CS.4afd6d7018f911eeb0babffb9f39c44a.XU0TD29K1XUafgPiOqTCUTVbEQBGrs89dNUSgzoIpaI2voiIC6HLq2FS6VJpnpV7YQMydera',
        });

    final responseData = jsonDecode(response.body);

    final List<dynamic> data = responseData['data']['records'];
    for (var i = 0; i < contain.docs.length; i++) {
      String check = contain.docs[i]["code"];
      for (var item in data) {
        String desc = item['description'];
        if (desc.contains(check)) {
          int amount = item['amount'] as int;
          token += (amount ~/ 1000);
          databaseService.updatePayment(contain.docs[0].id, "Finished");
          databaseService.updateToken(wallet.docs[0].id, token);
          setState(() {
            token;
          });
        }
      }
    }

    updatePayment();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(250, 250, 255, 1),
              Color.fromRGBO(115, 195, 184, 0.5),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Ví của bạn: $token xu',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Color(0xFF3E4D4B), fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Nạp thêm tiền:',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Color(0xFF3E4D4B),
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
            ),
            //TextField for user input (add tokens)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: inputController,
                decoration: InputDecoration(
                    hintText: '1 xu = 1000 VND',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        inputController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    )),
              ),
            ),

            const SizedBox(height: 16),

            //Button for add money using VietQR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  onPressed: onCheck,
                  color: Colors.lightBlue,
                  child: const Text('Tải lại',
                      style: TextStyle(color: Colors.white)),
                ),
                MaterialButton(
                  onPressed: onPayment,
                  color: Colors.lightBlue,
                  child: const Text('Nạp tiền',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Danh sách nạp tiền:',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Color(0xFF3E4D4B),
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  Item document = items[index];
                  String code = document.code;
                  String status = document.status;
                  int amount = document.money;
                  if (status == 'Finished') status = 'Đã nạp';
                  if (status == 'Cancelled') status = 'Hủy bỏ';
                  if (status == 'Created') status = 'Đang xử lý';
                  if (status == 'Đang xử lý') {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(115, 195, 184, 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mã: ' + code,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tiền: ' + amount.toString() + ' VNĐ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Text(
                              status,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(
                              height: 40,
                              child: VerticalDivider(
                                color: Colors.white70,
                              ),
                            ),
                            PopupMenuButton(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Text('Mở QR'),
                                  value: 'Mở QR',
                                ),
                                PopupMenuItem(
                                  child: Text("Xóa"),
                                  value: "Xóa",
                                )
                              ],
                              onSelected: (String newValue) {
                                if (newValue == "Mở QR") {
                                  showPayment();
                                } else if (newValue == "Xóa") {}
                                deletePayment();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(115, 195, 184, 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mã: ' + code,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tiền: ' + amount.toString() + ' VNĐ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Text(
                              status,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(
                              height: 40,
                              child: VerticalDivider(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
