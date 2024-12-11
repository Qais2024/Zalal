import 'package:carousel_slider/carousel_slider.dart';
import 'package:factor/admin_page/Expeses/expeses_list.dart';
import 'package:factor/admin_page/Receipt/receipt_list.dart';
import 'package:factor/admin_page/purchase/purchase_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Stock/page_scok.dart';
import '../Product/productlist.dart';
import '../all_reports/allreports_pages.dart';
import '../authsetting/authscreen.dart';
import '../authsetting/login-screen.dart';
import '../ccatch/cctch_list.dart';
import '../salsefactors/saleslist.dart';
import '../setting/setting_page.dart';
import '../setting/theme_setting/themeprovider.dart';
import '../workerlist/workerlist.dart';
class gride_page_admin extends StatefulWidget {
  const gride_page_admin({super.key});
  @override
  State<gride_page_admin> createState() => _gride_page_adminState();
}
class _gride_page_adminState extends State<gride_page_admin> {
  final _auth=Authservices();
  final myitems=[
    Image.asset("image/sa.jpg"),
    Image.asset("image/ro.jpg"),
    Image.asset("image/et.jpg"),
    Image.asset("image/AF.jpg"),
    Image.asset("image/at.jpg"),
  ];
  int mycurentindex=0;
  var w = 140.0;
  var h = 140.0;
  var total;
  @override
  Widget build(BuildContext context) {
    final themprovider = Provider.of<ThemeProvider>(context);
    return Scaffold(
            drawer: Drawer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        UserAccountsDrawerHeader(
                          decoration: BoxDecoration(color: Colors.blue),
                          accountName:Text(""),
                          accountEmail: null,
                          currentAccountPicture: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage("image/q.jpg"),
                          ),
                          otherAccountsPictures: [
                            Icon(Icons.light_mode),
                            Switch(
                                activeColor: Colors.white,
                                inactiveThumbColor: Colors.black,
                                activeThumbImage: AssetImage("image/d.jpg"),
                                inactiveThumbImage: AssetImage("image/l.jpg"),
                                value: themprovider.themeMode == ThemeMode.dark,
                                onChanged: (value) {
                                  themprovider.toggleTheme(value);
                                }),
                            Icon(Icons.dark_mode)
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => homescren(),
                                ));
                          },
                          child: ListTile(
                            leading: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => homescren(),
                                      ));
                                },
                                icon: Icon(Icons.settings,color: Colors.blueAccent,)),
                            title: Text(AppLocalizations.of(context)!.settings),
                          ),
                        ),
                        Divider(color: Colors.blueAccent,),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => expenseslist(),
                                ));
                          },
                          child: ListTile(
                            leading: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => expenseslist(),
                                      ));
                                },
                                icon: Icon(Icons.not_interested_outlined,color: Colors.blueAccent,)),
                            title: Text(AppLocalizations.of(context)!.expenses,),
                          ),
                        ),
                        Divider(color: Colors.blueAccent,),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => conceptlist(),
                                ));
                          },
                          child: ListTile(
                            leading: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => conceptlist(),
                                      ));
                                },
                                icon: Icon(Icons.output,color: Colors.blueAccent,)),
                            title: Text( AppLocalizations.of(context)!.ccatch,),
                          ),
                        ),
                        Divider(color: Colors.blueAccent,),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => receipt_list(),
                                ));
                          },
                          child: ListTile(
                            leading: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => receipt_list(),
                                      ));
                                },
                                icon: Icon(Icons.input,color: Colors.blueAccent,)),
                            title: Text( AppLocalizations.of(context)!.receipt,),
                          ),
                        ),
                        Divider(color: Colors.blueAccent,),
                        GestureDetector(
                          onTap: () {
                           _logout(context);
                          },
                          child: ListTile(
                            leading: IconButton(
                                onPressed:()async{
                                  await _auth.singout();
                                 _logout(context);
                                  print("you log out se...");
                                },
                                icon: Icon(Icons.login_sharp,color: Colors.blueAccent,)),
                            title: Text(AppLocalizations.of(context)!.logout),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.menu),
            ),
            body: Column(
              children: [
               Column(
                 children: [
                   CarouselSlider(
                       items: myitems,
                       options: CarouselOptions(
                         autoPlay: true,
                         height: 130,
                         autoPlayCurve: Curves.fastOutSlowIn,
                         autoPlayAnimationDuration: const Duration(seconds: 1),
                         autoPlayInterval: const Duration(seconds: 3),
                         enlargeCenterPage: true,
                         aspectRatio: 2.0,
                         onPageChanged: (index,reason){
                           setState(() {
                             mycurentindex=index;
                           });
                         }
                       ),
                   ),
                   buildcurentslider(),
                 ],
               ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        left: 22,
                        top: 50,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blue,
                              gradient: LinearGradient(colors: [
                                Colors.yellow,
                                Colors.purpleAccent,
                                Colors.orange,
                              ])),
                          width: 160,
                          height: 160,
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 60,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => factors_page(),
                                  ));
                            });
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.production_quantity_limits_sharp,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.salse,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ],
                            ),
                            width: w,
                            height: h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 22,
                        top: 50,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blue,
                              gradient: LinearGradient(colors: [
                                Colors.yellow,
                                Colors.purpleAccent,
                                Colors.orange,
                              ])),
                          width: 160,
                          height: 160,
                        ),
                      ),
                      Positioned(
                        right: 32,
                        top: 60,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => receivedlist(),
                                  ));
                            });
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.factory,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.purchase,
                                  style: TextStyle(fontSize: 20, color: Colors.black),
                                ),
                              ],
                            ),
                            width: w,
                            height: h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 22,
                        top: 240,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blue,
                              gradient: LinearGradient(colors: [
                                Colors.yellow,
                                Colors.purpleAccent,
                                Colors.orange,
                              ])),
                          width: 160,
                          height: 160,
                        ),
                      ),
                      Positioned(
                        right: 32,
                        top: 250,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkerList(),
                                  ));
                            });
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_alt, color: Colors.black),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.employee,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ],
                            ),
                            width: w,
                            height: h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 22,
                        top: 240,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blue,
                              gradient: LinearGradient(colors: [
                                Colors.yellow,
                                Colors.purpleAccent,
                                Colors.orange,
                              ])),
                          width: 160,
                          height: 160,
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 250,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => objectlist(),
                                  ));
                            });
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_objects_outlined,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.products,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ],
                            ),
                            width: w,
                            height: h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 22,
                        top: 430,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blue,
                              gradient: LinearGradient(colors: [
                                Colors.yellow,
                                Colors.purpleAccent,
                                Colors.orange,
                              ])),
                          width: 160,
                          height: 160,
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 440,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StockPage(),
                                  ));
                            });
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.book,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.stock,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ],
                            ),
                            width: w,
                            height: h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 210,
                        top: 430,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blue,
                              gradient: LinearGradient(colors: [
                                Colors.yellow,
                                Colors.purpleAccent,
                                Colors.orange,
                              ])),
                          width: 160,
                          height: 160,
                        ),
                      ),
                      Positioned(
                        left: 220,
                        top: 440,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => allreports(),
                                  ));
                            });
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.downLeftAndUpRightToCenter,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                AppLocalizations.of(context)!.reports,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ],
                            ),
                            width: w,
                            height: h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }
  buildcurentslider(){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center ,
        children: [
        for(int i=0;i<myitems.length;i++)
          Container(
            margin: EdgeInsets.all(5),
            height: i==mycurentindex?7:5,
            width: i==mycurentindex?7:5,
            decoration: BoxDecoration(
              color:i==mycurentindex?Colors.black:Colors.blue,
              shape: BoxShape.circle
            ),
          )
        ],
      ),
    );
  }

  // gotologin(BuildContext context) {
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => login_screen()),
  //         (Route<dynamic> route) => false, // شرط برای حذف تمام صفحات قبلی
  //   );
  // }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // پاک کردن اطلاعات لاگین شده
    await prefs.remove('isLoggedIn');
    await prefs.remove('role');

    // هدایت به صفحه ورود
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login_screen()), // صفحه لاگین شما
    );
  }
}

