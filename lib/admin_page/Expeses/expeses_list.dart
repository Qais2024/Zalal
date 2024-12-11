import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:factor/admin_page/Expeses/expeses_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';  // برای فرمت‌بندی تاریخ

class expenseslist extends StatefulWidget {
  const expenseslist({super.key});

  @override
  State<expenseslist> createState() => _expenseslistState();
}

class _expenseslistState extends State<expenseslist> {
  List<Map<String, dynamic>> expenses = [];
  DateTimeRange? selectedDateRange;  // متغیر برای ذخیره بازه زمانی انتخاب‌شده

  // تاریخ را به فرمت قابل مقایسه تبدیل می‌کند
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);  // فرمت 'yyyy-MM-dd'
  }
  @override
  void initState() {
    super.initState();
    // مقدار پیش‌فرض: بازه‌ای از امروز تا امروز
    selectedDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now(),
    );
  }// وقتی فیلتر تاریخ تغییر می‌کند
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: selectedDateRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  Future<void> addedite({Map<String, dynamic>? expes, String? docid}) async {
    User? user = FirebaseAuth.instance.currentUser;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => expensespage(expenses: expes),
      ),
    );
    if (result != null) {
      if (docid != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user?.uid)
            .collection("expenses")
            .doc(docid)
            .update(result);
      } else {
        await FirebaseFirestore.instance.collection("expenses").add(result);
      }
    }
  }

  Future<void> delete(String docid) async {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("expenses")
        .doc(user?.uid)
        .collection("expenses")
        .doc(docid)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          addedite(); // Call addedite method for adding a new expense
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("${AppLocalizations.of(context)!.expense_list}"),
        actions: [
          IconButton(
            onPressed: () {
              _selectDateRange(context); // فیلتر تاریخ با انتخاب بازه زمانی
            },
            icon: Icon(
              Icons.calendar_month,
              color: Colors.yellowAccent,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("expenses")
        // فیلتر کردن داده‌ها بر اساس تاریخ
            .where("date", isGreaterThanOrEqualTo: selectedDateRange != null ? formatDate(selectedDateRange!.start) : "")
            .where("date", isLessThanOrEqualTo: selectedDateRange != null ? formatDate(selectedDateRange!.end) : "")
            .snapshots(),
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
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final expese = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final docId = snapshot.data!.docs[index].id;
              return GestureDetector(
                onTap: () {
                  addedite(expes: expese, docid: docId);
                },
                onLongPress: () {
                  delete(docId);
                },
                child: Card(
                  shadowColor: Colors.yellowAccent,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${AppLocalizations.of(context)!.by}: ${expese["by"] ?? ""}"),
                        Divider(color: Colors.blueAccent),
                        Text("${AppLocalizations.of(context)!.money}: ${expese["money"] ?? ""}"),
                        Divider(color: Colors.blueAccent),
                        Row(
                          children: [
                            Expanded(child: Text("${AppLocalizations.of(context)!.date}: ${expese["date"] ?? ""}")),
                            Expanded(child: Text("${expese["time"] ?? ""}")),
                          ],
                        ),
                      ],
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
}
