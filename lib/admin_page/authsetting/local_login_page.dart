import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:factor/admin_page/firstpage/girdtilepage.dart';
import 'package:factor/resiption_page/resiption_page.dart';
import 'package:factor/user_page/firstpage/girdtilepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class local_login_page extends StatefulWidget {
  const local_login_page({super.key});
  @override
  State<local_login_page> createState() => _local_login_pageState();
}
class _local_login_pageState extends State<local_login_page> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
        child: SpinKitWaveSpinner(
          color: Colors.blue,
          size: 250,
          trackColor: Colors.blue,
          waveColor: Colors.yellowAccent,
        ),
      )
          : Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.email,
                      color: Colors.blueAccent,
                    ),
                    hintText: "Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.key,
                      color: Colors.blueAccent,
                    ),
                    hintText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _login,
                child: Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    // بررسی مقادیر خالی
    if (nameController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Name and password cannot be empty.")),
      );
      return;
    }

    // شروع نمایش لودینگ
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No user is currently logged in.")),
        );
        return;
      }

      // خواندن داده‌ها از Firestore
      CollectionReference workerCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workers');

      QuerySnapshot workerSnapshot = await workerCollection
          .where('name', isEqualTo: nameController.text.trim())
          .where('password', isEqualTo: passwordController.text.trim())
          .get();

      if (workerSnapshot.docs.isNotEmpty) {
        var workerData =
        workerSnapshot.docs.first.data() as Map<String, dynamic>;
        String role = workerData['role'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('role', role);

        // هدایت به صفحات بر اساس نقش
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => gride_page_admin()),
          );
        } else if (role == 'receptionist') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => resiption_page()),
          );
        } else if (role == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => gridepage_user()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Role not recognized.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid name or password.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

}
