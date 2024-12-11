import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'salsereportes.dart';
import 'factor.dart';

class factors_page extends StatefulWidget {
  const factors_page({super.key});

  @override
  State<factors_page> createState() => _SalesFactorsState();
}

class _SalesFactorsState extends State<factors_page> {
  DateTime? _startdate;
  DateTime? _enddate;
  TextEditingController searchControllers = TextEditingController();
  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _startdate = DateTime(today.year, today.month, today.day);
    _enddate = DateTime(today.year, today.month, today.day, 23, 59, 59);
    searchControllers.addListener(() {
      setState(() {}); // به‌روزرسانی رابط کاربری هنگام جستجو
    });
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dateRange != null) {
      setState(() {
        _startdate = dateRange.start;
        _enddate = dateRange.end;
      });
    }
  }
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
      return false;
    }
  }

  Future<void> _callCustomer(String number) async {
    final Uri launcher = Uri(scheme: 'tel', path: number);
    await launchUrl(launcher);
  }
  Future<void> addEditFactor({Map<String, dynamic>? factors, String? docId}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if(user!=null){
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => newfactor(factors: factors)),
      );
      if (result != null) {
        try {
          CollectionReference factorrefrence=FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("factors");

          if (docId != null) {
            await factorrefrence.doc(docId).update(result);
          } else {
            await factorrefrence.add(result);
          }
        } catch (e) {}
      }
  }}
  Future<void> deleteFromFirebase(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
      .collection("factors")
          .doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Factor deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting Factor: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => addEditFactor(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextField(
          controller: searchControllers,
          decoration: InputDecoration(
            hintText: "${AppLocalizations.of(context)!.search}...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black87),
          ),
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => sells_table_reports(),));
            });
          },icon:Icon(Icons.list_alt,color: Colors.yellowAccent,),),
          IconButton(onPressed:()=>pickDateRange(context),
              icon:Icon(Icons.calendar_month,color: Colors.yellowAccent,)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("factors")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitWaveSpinner(
              color: Colors.blue,
              size: 250,
              trackColor: Colors.blue,
              waveColor: Colors.yellowAccent,
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Factors found"));
          }

          final filteredDocs = snapshot.data!.docs.where((doc) {
            final factors = doc.data() as Map<String, dynamic>;
            final searchText = searchControllers.text.toLowerCase();


            final matchesSearch =
                (factors["name"] ?? "")
                .toString()
                .toLowerCase()
                .contains(searchText) ||
                (factors["number"] ?? "")
                    .toString()
                    .toLowerCase()
                    .contains(searchText);
            final matchesDate = isInSelectedRangeDate(factors["date"]);

            return matchesSearch && matchesDate;
          }).toList();


          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final factors = filteredDocs[index].data() as Map<String, dynamic>;
              final docId = filteredDocs[index].id;

              List<dynamic> totalPrice = factors["total"] is List<dynamic>
                  ? factors["total"]
                  : [];
              double totalBell = calculateTotal(totalPrice);
              return GestureDetector(
                onTap: () => addEditFactor(factors: factors, docId: docId),
                onLongPress: () {
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: Text("${AppLocalizations.of(context)!.alert}?"),
                      actions: [
                        ElevatedButton(
                          style:ElevatedButton.styleFrom(
                            backgroundColor: Colors.red
                          ),
                          onPressed: () {
                            deleteFromFirebase(docId);
                            Navigator.pop(context);
                          },
                          child: Text("${AppLocalizations.of(context)!.yes}"),
                        ),
                        ElevatedButton(
                          style:ElevatedButton.styleFrom(
                              backgroundColor: Colors.green
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text("${AppLocalizations.of(context)!.no}"),
                        ),
                      ],
                    );
                  });
                },
                child: Card(
                  shadowColor: Colors.yellowAccent,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${AppLocalizations.of(context)!.customer}: ${factors["name"] ?? ""}"),
                        Divider(color: Colors.blue),
                        Text(
                          "${AppLocalizations.of(context)!.totalbell}: ${totalBell.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: (double.tryParse(factors["totalpay"].toString()) ?? 0) < totalBell
                                ? Colors.red
                                : Colors.blueAccent,
                          ),
                        ),
                        Divider(color: Colors.blue),
                        Text("${AppLocalizations.of(context)!.totalpay}: ${factors["totalpay"] ?? ""}"),
                        Divider(color: Colors.blue),
                        Text("${AppLocalizations.of(context)!.date}: ${factors["date"] ?? ""}"),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => _callCustomer(factors["number"] ?? ""),
                      icon: Icon(Icons.call, color: Colors.blue),
                    ),
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
}
