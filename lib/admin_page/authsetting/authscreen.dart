
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class Authservices{
  final _auth=FirebaseAuth.instance;

  Future<User?> createuserwhithemailandpassword(String email,String password)async{
    try{
      final cred=await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return cred.user;
    }catch(e){
      print("somting went wrong");
    };
    return null;
  }

  Future<User?> loginuserwhithemailandpassword(String email,String password)async{
    try{
      final cred=await _auth.signInWithEmailAndPassword(email: email, password: password);
      return cred.user;
    }catch(e){
      print("somting went wrong");
    };
    return null;
  }


  Future<void> singout()async{
   await _auth.signOut();
  }
}

