import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:factor/admin_page/firstpage/girdtilepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'authscreen.dart';
import 'login-screen.dart';
class singup_screen extends StatefulWidget {
  final Map<String,dynamic>?account;
  const singup_screen({super.key, this.account});
  @override
  State<singup_screen> createState() => _singup_screenState();
}
class _singup_screenState extends State<singup_screen> {
  final _auth=Authservices();
  final _email =TextEditingController();
  final _password =TextEditingController();
  final _name =TextEditingController();
  final _lastname =TextEditingController();
  final _phonenumber =TextEditingController();
  final _bussenesname =TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
  }
  Future<void> savetoforebase(String uid) async {
      final Map<String, dynamic> account = {
        "uid": uid,
        "name": _name.text,
        "lastname": _lastname.text,
        "phonenumber": _phonenumber.text,
        "email": _email.text,
        "password": _password.text,
        "business": _bussenesname.text,
      };

      CollectionReference accountCollection =
      FirebaseFirestore.instance.collection("accounts");

      if (widget.account != null) {
        await accountCollection.doc(uid).update(account); // ذخیره بر اساس UID
      } else {
        await accountCollection.doc(uid).set(account); // ایجاد سند جدید با UID
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:_isLoading
          ? Center(
        child: SpinKitWaveSpinner(
          color: Colors.blue,
          size: 250,
          trackColor: Colors.blue,
          waveColor: Colors.yellowAccent,
        )
      ): Center(
        child:
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                maxRadius: 100,
                backgroundImage:AssetImage("image/factor.jpg")
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text("Welcom to Zalal appication",style: TextStyle(fontSize: 15,color: Colors.blueAccent),),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: TextFormField(
                  controller:_bussenesname,
                  decoration:InputDecoration(
                    icon: Icon(Icons.factory,color: Colors.blueAccent,),
                    hintText: "Business Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),

                    ),
                  ) ,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: TextFormField(
                  controller:_name,
                  decoration:InputDecoration(
                    icon: Icon(Icons.person,color: Colors.blueAccent,),
                    hintText: "Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),

                    ),
                  ) ,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: TextFormField(
                  controller:_lastname,
                  decoration:InputDecoration(
                    icon: Icon(Icons.person,color: Colors.blueAccent,),
                    hintText: "Last Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    ),
                  ) ,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: TextFormField(
                  controller:_phonenumber,
                  decoration:InputDecoration(
                    icon: Icon(Icons.phone,color: Colors.blueAccent,),
                    hintText: "Phone number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),

                    ),
                  ) ,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: TextFormField(
                  controller: _email,
                  decoration:InputDecoration(
                    icon: Icon(Icons.email,color: Colors.blueAccent,),
                    hintText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ) ,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: TextFormField(
                  controller: _password,
                  decoration:InputDecoration(
                    icon: Icon(Icons.key,color: Colors.blueAccent,),
                    hintText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ) ,
                ),
              ),
              SizedBox(height: 5,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                  onPressed:_signup,
                  child: Container(
                      width: 100,
                      height: 30,
                      child: Center(
                          child: Text("Sing up",style: TextStyle(color: Colors.white,fontSize: 20),)))),
              Divider(color: Colors.blueAccent,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account ?",style: TextStyle(fontSize: 15),),
                  SizedBox(width: 10,),
                  TextButton(onPressed:()=>gotologin(context), child:Text("Login",style: TextStyle(color: Colors.blueAccent),))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    }); // فعال کردن اسپینر

    if (_name.text.isEmpty || _lastname.text.isEmpty || _phonenumber.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty || _bussenesname.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields must be filled!")),
      );
      setState(() {
        _isLoading = false;
      }); // غیرفعال کردن اسپینر
      return; // خروج از متد در صورت خالی بودن فیلدها
    }
    try {
      final user = await _auth.createuserwhithemailandpassword(
        _email.text,
        _password.text,
      );
      if (user != null) {
        await savetoforebase(user.uid); // ذخیره اطلاعات در Firestore
        gotohome(context); // انتقال به صفحه اصلی
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User signed up")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email or password is incorrect try again")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during signup: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      }); // غیرفعال کردن اسپینر
    }
  }



  gotohome(BuildContext cotext)=>Navigator.push(context, MaterialPageRoute(builder: (context) => gride_page_admin(),));
  gotologin(BuildContext cotext)=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login_screen(),));
}
