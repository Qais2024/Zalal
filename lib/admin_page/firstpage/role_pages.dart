import 'package:factor/admin_page/firstpage/girdtilepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../user_page/firstpage/girdtilepage.dart';
import '../../resiption_page/resiption_page.dart';
class role_page extends StatefulWidget {
  const role_page({super.key});
  @override
  State<role_page> createState() => _role_pageState();
}
class _role_pageState extends State<role_page> {
  TextEditingController passwordcontroller = TextEditingController();
  int password=22232425;
  @override
  void dispose() {
    super.dispose();
    passwordcontroller.dispose();
  }
  void showdialog1() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon:Icon(Icons.error_outline,color: Colors.red,size: 40,),

            title: Text("Enter the password"),
            content: Container(
              child: TextFormField(
                controller: passwordcontroller,
                decoration: InputDecoration(
                    icon: Icon(Icons.key,color: Colors.blueAccent,),
                    hintText: "Enter password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)
                    )
                ),
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (passwordcontroller.text == password.toString()) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => gride_page_admin()), // این صفحه باید درست وارد شود
                          );
                        }
                      },
                      child: Text("✔",),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("✖"),
                    ),
                  ),
                ],
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blueAccent,
      automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          width: 250,
          height: 400,
          decoration: BoxDecoration(
              color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(width: 5,color: Colors.orange),
            image: DecorationImage(image: AssetImage("image/a27.jpg"),)
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Chose your account",style: TextStyle(fontSize: 20,color: Colors.yellowAccent),),
              ElevatedButton(
                style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange
                ),
                onPressed: () {
                  showdialog1(); // نیازی به setState نیست
                },
                child: Container(
                  width: 150,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Admin",style: TextStyle(fontSize: 20,color: Colors.black87),),
                      SizedBox(width: 10,),
                      Icon(Icons.admin_panel_settings_sharp,color: Colors.black,)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => gridepage_user()), // این صفحه هم باید درست وارد شود
                  );
                },
                child: Container(
                    width: 150,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("User",style: TextStyle(fontSize: 20,color: Colors.black87),),
                        SizedBox(width: 10,),
                        Icon(Icons.person,color: Colors.black,)
                      ],
                    )),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => resiption_page()), // این صفحه هم باید درست وارد شود
                  );
                },
                child: Container(
                    width: 150,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Accounting",style: TextStyle(fontSize: 18,color: Colors.black87),),
                        SizedBox(width: 10,),
                        Icon(Icons.account_balance,color: Colors.black,)
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
