import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Product/productlist.dart';
import '../Stock/page_scok.dart';
import '../purchase/purchase_list.dart';
import '../salsefactors/saleslist.dart';
import '../workerlist/workerlist.dart';
class firstpage extends StatefulWidget {
  const firstpage({super.key});
  @override
  State<firstpage> createState() => _firstpageState();
}
class _firstpageState extends State<firstpage> {
  var w=300.0;
  var h=50.0;
  var total;
  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
        backgroundColor: CupertinoColors.systemYellow,
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap:() {
                  setState(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => factors_page(),));
                  });
                },
                child: Container(
                  child: Center(child: Text("Sales Factors",style: TextStyle(fontSize: 20),)),
                  width: w,height: h,decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.blue,gradient:
                    LinearGradient(colors:[
                      Colors.yellow,
                      Colors.purpleAccent,
                      Colors.orange,
                    ])

                ),),
              ),
              SizedBox(height: 40,),
              GestureDetector(
                onTap:() {
                  setState(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => receivedlist(),));
                  });
                },
                child: Container(
                  child: Center(child: Text("Received Factors",style: TextStyle(fontSize: 20),)),
                  width: w,height: h,decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.blue,gradient:
                LinearGradient(colors:[
                  Colors.yellow,
                  Colors.purpleAccent,
                  Colors.orange,
                ])),),
              ),
              SizedBox(height: 40,),
              GestureDetector(
                onTap:() {
                  setState(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => objectlist(),));
                  });
                },
                child: Container(
                  child: Center(child: Text("Products",style: TextStyle(fontSize: 20),)),
                  width: w,height: h,decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.blue,gradient:
                LinearGradient(colors:[
                  Colors.yellow,
                  Colors.purpleAccent,
                  Colors.orange,
                ])),),
              ),
              SizedBox(height: 40,),
              GestureDetector(
                onTap:() {
                  setState(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerList(),));
                  });
                },
                child: Container(
                  child: Center(child: Text("Staffs",style: TextStyle(fontSize: 20),)),
                  width: w,height: h,decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.blue,gradient:
                LinearGradient(colors:[
                  Colors.yellow,
                  Colors.purpleAccent,
                  Colors.orange,
                ])),),
              ),
              SizedBox(height: 40,),
              GestureDetector(
                onTap:() {
                  setState(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  StockPage (),));
                  });
                },
                child: Container(
                  child: Center(child: Text("Stock",style: TextStyle(fontSize: 20),)),
                  width: w,height: h,decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.blue,gradient:
                LinearGradient(colors:[
                  Colors.yellow,
                  Colors.purpleAccent,
                  Colors.orange,
                ])),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
