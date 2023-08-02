import 'package:flutter/material.dart';
import 'package:project/pages/entryPoint/entry_point.dart';
import 'package:project/pages/home/home_screen.dart';
import 'package:project/pages/booking.dart';
import 'package:project/pages/doctor_schedular_work.dart';
import 'package:project/pages/meeting_rooms.dart';
import 'package:project/pages/profile_page.dart';
import 'package:project/pages/search_page.dart';
import '../../home/model/menu.dart';
import '../../home_page.dart';
import '../../search_page.dart';
import '../utils/rive_utils.dart';
import 'info_card.dart';
import 'side_menu.dart';
import '../../wallet/wallet_screen.dart';
import 'package:project/pages/auth/login_page.dart';
import 'package:project/service/auth_service.dart';

class SideBar extends StatefulWidget {
  final String userName;
  final String email;

  const SideBar({
    Key? key,
    required this.userName,
    required this.email,
  }) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu selectedSideMenu = sidebarMenus.first;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF17203A),
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoCard(
                  name: widget.userName,
                  bio: widget.email,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                  child: Text(
                    "Tính Năng".toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white70),
                  ),
                ),
                ...sidebarMenus
                    .map(
                      (menu) => SideMenu(
                        menu: menu,
                        selectedMenu: selectedSideMenu,
                        press: () {
                          if (menu.title == "Nhắn Tin") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EntryPoint(
                                        userName: widget.userName,
                                        email: widget.email,
                                        currentScreen: HomePage(),
                                      )),
                            );
                          } else if (menu.title == "Tìm Kiếm") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EntryPoint(
                                        userName: widget.userName,
                                        email: widget.email,
                                        currentScreen: SearchPage(),
                                      )),
                            );
                          } else if (menu.title == "Trang Chủ") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EntryPoint(
                                        userName: widget.userName,
                                        email: widget.email,
                                        currentScreen: home_screen(),
                                      )),
                            );
                          } else if (menu.title == "Ví cá nhân") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EntryPoint(
                                        userName: widget.userName,
                                        email: widget.email,
                                        currentScreen: WalletScreen(
                                          userName: widget.userName,
                                          email: widget.email,
                                        ),
                                      )),
                            );
                          } else if (menu.title == "Đặt lịch") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EntryPoint(
                                        userName: widget.userName,
                                        email: widget.email,
                                        currentScreen: BookingPage(),
                                      )),
                            );
                          } else if (menu.title == "Lịch làm việc") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EntryPoint(
                                        userName: widget.userName,
                                        email: widget.email,
                                        currentScreen: WorkingHoursScreen(),
                                      )),
                            );
                          } else if (menu.title == "Phòng trò chuyện") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EntryPoint(
                                        userName: widget.userName,
                                        email: widget.email,
                                        currentScreen: MeetingRoomScreen(),
                                      )),
                            );
                          } else {
                            RiveUtils.chnageSMIBoolState(menu.rive.status!);
                            setState(() {
                              selectedSideMenu = menu;
                            });
                          }
                        },
                        riveOnInit: (artboard) {
                          menu.rive.status = RiveUtils.getRiveInput(artboard,
                              stateMachineName: menu.rive.stateMachineName);
                        },
                      ),
                    )
                    .toList(),
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 40, bottom: 16),
                  child: Text(
                    "Thông Tin".toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white70),
                  ),
                ),
                ...sidebarMenus2
                    .map(
                      (menu) => SideMenu(
                        menu: menu,
                        selectedMenu: selectedSideMenu,
                        press: () {
                          if (menu.title == "Nhắn Tin") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EntryPoint(
                                        userName: widget.userName,
                                        email: widget.email,
                                        currentScreen: HomePage(),
                                      )),
                            );
                          } else if (menu.title == "Thoát") {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Logout"),
                                  content: const Text(
                                      "Are you sure you want to logout?"),
                                  actions: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await authService.signOut();
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.done,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            RiveUtils.chnageSMIBoolState(menu.rive.status!);
                            setState(() {
                              selectedSideMenu = menu;
                            });
                          }
                        },
                        riveOnInit: (artboard) {
                          menu.rive.status = RiveUtils.getRiveInput(artboard,
                              stateMachineName: menu.rive.stateMachineName);
                        },
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
