import 'package:factor/admin_page/authsetting/singup-screen.dart';
import 'package:factor/admin_page/firstpage/girdtilepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'authscreen.dart';
import 'local_login_page.dart';
class login_screen extends StatefulWidget {
  const login_screen({super.key});

  @override
  State<login_screen> createState() => _login_screenState();
}

class _login_screenState extends State<login_screen> {
  final _auth=Authservices();
  final _email =TextEditingController();
  final _password =TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment:MainAxisAlignment.start,
            children: [
              CircleAvatar(
                maxRadius: 150,
                backgroundImage: AssetImage("image/factor.jpg"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text("Welcome to Zalal application",style: TextStyle(fontSize: 15,color: Colors.blueAccent),),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: TextFormField(
                  controller:
                  _email,
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
              SizedBox(height: 20,),
              ElevatedButton(onPressed:_login, child: Text("Login")),
              Divider(color: Colors.blueAccent,),
              Row(
                mainAxisAlignment:MainAxisAlignment.center,
                children: [
                  Text("Already have an account ?"),
                  SizedBox(width: 10,),
                  SizedBox(width: 10,),
                  TextButton(onPressed:()=>gotosingup(context), child:Text("Register",style: TextStyle(color: Colors.blueAccent),))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
_login()async{
    setState(() {
      _isLoading=true;
    });
    final user=await _auth.loginuserwhithemailandpassword(_email.text, _password.text);
    if(user!=null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("you login successful")),
      );
      gotouserpage(context);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email or password is incorrect try again ")),
      );
    }
    setState(() {
      _isLoading=false;
    });
}
  gotohome(BuildContext cotext)=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => gride_page_admin(),));
  gotosingup(BuildContext cotext)=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => singup_screen(),));
  gotouserpage(BuildContext cotext)=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => local_login_page(),));
}
