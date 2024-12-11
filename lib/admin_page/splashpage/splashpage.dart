import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../user_page/firstpage/girdtilepage.dart';
import '../authsetting/login-screen.dart';
import '../firstpage/girdtilepage.dart';
import '../../resiption_page/resiption_page.dart';

class splash_page extends StatefulWidget {
  const splash_page({super.key});

  @override
  State<splash_page> createState() => _splash_pageState();
}

class _splash_pageState extends State<splash_page> {
  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  void checkUserStatus() async {
    // تأخیر برای نمایش اسپلش
    await Future.delayed(const Duration(seconds: 3));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? role = prefs.getString('role');

    if (!isLoggedIn || role == null) {
      // اگر لاگین نیست یا نقش مشخص نشده، هدایت به صفحه لاگین
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => login_screen()),
      );
      return;
    }

    // بررسی نقش کاربر و هدایت به صفحه مربوطه
    switch (role) {
      case 'admin':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => gride_page_admin()),
              (Route<dynamic> route) => false, // این باعث می‌شود که تمام صفحات قبلی از پشته حذف شوند.
        );
        break;
      case 'receptionist':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => resiption_page()),
              (Route<dynamic> route) => false,
        );
        break;
      case 'user':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => gridepage_user()),
              (Route<dynamic> route) => false,
        );
        break;
      default:
      // نقش ناشناخته، هدایت به صفحه لاگین
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => login_screen()),
              (Route<dynamic> route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: CircleAvatar(
                backgroundImage: AssetImage("image/factor.jpg"),
                radius: 150,
              ),
            ),
            Positioned(
              bottom: 300,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Zalal",
                  style: TextStyle(fontSize: 50, color: Colors.blueAccent),
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(child: Text("V 0.1.0")),
            ),
          ],
        ),
      ),
    );
  }
}
