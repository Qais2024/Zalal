import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin_page/Expeses/expeses_list.dart';
import '../admin_page/Receipt/receipt_list.dart';
import '../admin_page/authsetting/authscreen.dart';
import '../admin_page/authsetting/login-screen.dart';
import '../admin_page/ccatch/cctch_list.dart';
import '../admin_page/setting/theme_setting/themeprovider.dart';
import '../user_page/setting/setting_page.dart';
class resiption_page extends StatefulWidget {
  const resiption_page({super.key});
  @override
  State<resiption_page> createState() => _resiption_pageState();
}
class _resiption_pageState extends State<resiption_page> {
  final _auth=Authservices();
  DateTime? _startdate;
  DateTime? _enddate;
  TextEditingController searchControllers = TextEditingController();
  Map<String, TextEditingController> controllers = {};
  var color=Colors.redAccent;
  DateTime? parseDate(String date) {
    try {
      // تلاش برای پارس کردن تاریخ با فرمت "yyyy-MM-dd"
      return DateFormat("yyyy-MM-dd").parse(date);
    } catch (e1) {
      try {
        // اگر فرمت اول شکست خورد، تلاش برای پارس کردن تاریخ با فرمت "dd/MM/yyyy"
        return DateFormat("dd/MM/yyyy").parse(date);
      } catch (e2) {
        print("Error parsing date: $date");
        return null; // اگر هیچ فرمتی کار نکرد، null برگرداند
      }
    }
  }
  bool isInSelectedRangeDate(String? date) {
    if (_startdate == null || _enddate == null || date == null) return true;
    try {
      DateTime? parsedDate = parseDate(date);
      if (parsedDate == null) return false; // اگر تاریخ معتبر نبود
      return !parsedDate.isBefore(_startdate!) && !parsedDate.isAfter(_enddate!);
    } catch (e) {
      print("Error in isInSelectedRangeDate: $e");
      return false;
    }
  }
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
                    onTap: ()async {
                      await _auth.singout();
                      _logout(context);
                      print("you log out se...");
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
        backgroundColor: Colors.blueAccent,
        title: Text(AppLocalizations.of(context)!.accounting,),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseAuth.instance.currentUser != null
            ? FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("factors")
            .where("condition", isEqualTo: true)
            .snapshots()
            : Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitWaveSpinner(
                color: Colors.blue,
                size: 250,
                trackColor: Colors.blue,
                waveColor: Colors.yellowAccent,
              ),
            );
          }

          final filtersearch = snapshot.hasData && snapshot.data != null
              ? snapshot.data!.docs.where((doc) {
            final factors = doc.data() as Map<String, dynamic>;
            final serchtext = searchControllers.text.toLowerCase();

            final matchesSearch = (factors["name"] ?? "")
                .toString()
                .toLowerCase()
                .contains(serchtext) ||
                (factors["number"] ?? "")
                    .toString()
                    .toLowerCase()
                    .contains(serchtext);
            final matchesDate = isInSelectedRangeDate(factors["date"]);
            return matchesSearch && matchesDate;
          }).toList()
              : [];
          return ListView.builder(
            itemCount: filtersearch.length,
            itemBuilder: (context, index) {
              final factors = filtersearch[index].data() as Map<String, dynamic>;
              final docid = filtersearch[index].id;

              controllers.putIfAbsent(docid, () => TextEditingController());
              List<dynamic> totalprice = factors["total"] is List<dynamic>
                  ? factors['total']
                  : [];
              double totalbell = calculateTotal(totalprice);
              return Card(
                shadowColor: Colors.yellowAccent,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                                "${AppLocalizations.of(context)!.name}: ${factors["name"]}"),
                            Divider(color: Colors.blueAccent),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                                "${AppLocalizations.of(context)!.totalbell}: ${totalbell.toStringAsFixed(0)}"),
                            Divider(color: Colors.blueAccent),
                          ],
                        ),
                      )
                    ],
                  ),
                  subtitle:Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final totalPay = calculateTotal(factors["total"]);

                      try {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection("factors")
                            .doc(docid)
                            .update({"condition": false, "totalpay": totalPay.toString()});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Payment confirmed and saved as cash.")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error updating: $e")),
                        );
                      }
                    },
                    child: Text("${AppLocalizations.of(context)!.cash}"),
                  ),
                  Text(
                      "${AppLocalizations.of(context)!.totalpay}: ${factors["totalpay"]}"),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      // نمایش دیالوگ برای وارد کردن مقدار پرداختی
                      final TextEditingController trustController = TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Enter Trust Amount"),
                            content: TextField(
                              controller: trustController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(hintText: "Enter amount"),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  if (trustController.text.isNotEmpty) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(FirebaseAuth.instance.currentUser!.uid)
                                          .collection("factors")
                                          .doc(docid)
                                          .update({
                                        "condition": true,
                                        "totalpay": trustController.text
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Payment saved as trust.")),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Error updating: $e")),
                                      );
                                    }
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text("Save"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Trust"),
                  ),
                ],
              ),

              ),
              );
            },
          );
        },
      ),
    );
  }
  double calculateTotal(List<dynamic> totalPrice) {
    return totalPrice.fold(0, (sum, price) => sum + double.parse(price.toString()));
  }

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
