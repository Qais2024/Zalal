import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class receipt_page extends StatefulWidget {
  final Map<String, dynamic>? receipt;
  const receipt_page({super.key, this.receipt});

  @override
  State<receipt_page> createState() => _receipt_pageState();
}

class _receipt_pageState extends State<receipt_page> {
  TextEditingController desController = TextEditingController();
  TextEditingController byController = TextEditingController();
  TextEditingController moneyController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.receipt != null) {
      desController.text = widget.receipt!["description"] ?? "";
      byController.text = widget.receipt!["by"] ?? '';
      moneyController.text = widget.receipt!["money"] ?? '';
      dateController.text = widget.receipt!['date'] ?? '';
      timeController.text = widget.receipt!["time"] ?? '';
    }
  }

  void validateAndSubmit(BuildContext context) {
    if (desController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفا بخش توضیحات را پر کنید')),
      );
      return;
    }

    if (moneyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفا مقدار پول را مشخص کنید')),
      );
      return;
    }

    if (byController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفا طرف حساب را ذکر کنید')),
      );
      return;
    }
    if (dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفا تاریخ را انتخاب کنید')),
      );
      return;
    }
    if (timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفا ساعت را انتخاب کنید')),
      );
      return;
    }

    // اگر همه فیلدها پر بودند، عملیات مورد نظر را انجام دهید
    saveToFirebase();
    Navigator.pop(context);
  }
  // بررسی اتصال اینترنت
  Future<bool> isConnected() async {
    var connected = await Connectivity().checkConnectivity();
    return connected != ConnectivityResult.none;
  }

  // همگام‌سازی داده‌های آفلاین با Firebase
  Future<void> syncOffline() async {
    User? user = FirebaseAuth.instance.currentUser;
    var box = await Hive.openBox("receipt");
    if (await isConnected()) {
      CollectionReference expensesCollection = FirebaseFirestore.instance
          .collection("users")
      .doc(user!.uid)
      .collection("receipt")

      ;
      for (var key in box.keys) {
        var expenseData = box.get(key);
        await expensesCollection.doc(key).set(expenseData);
      }
      await box.clear();
    }
  }

  // ذخیره‌سازی داده‌ها در Firebase
  Future<void> saveToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    final Map<String, dynamic> expenseData = {
      "description": desController.text,
      "by": byController.text,
      "money": moneyController.text,
      "date": dateController.text,
      "time": timeController.text, // زمان فرمت‌شده
    };

    if (await isConnected()) {
      CollectionReference expensesCollection = FirebaseFirestore.instance
          .collection("users")
      .doc(user!.uid)
      .collection("receipt")
      ;
      if (widget.receipt != null) {
        await expensesCollection.doc(widget.receipt!['time']).update(expenseData);
      } else {
        await expensesCollection.doc(expenseData['time']).set(expenseData);
      }
    } else {
      var box = await Hive.openBox("receipt");
      await box.put(expenseData['time'], expenseData); // ذخیره داده‌ها در Hive
    }
  }

  // انتخاب تاریخ از تقویم
  Future<void> selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // نمایش فقط تاریخ
      });
    }
  }

  // انتخاب ساعت
  Future<void> selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        timeController.text = pickedTime.format(context); // نمایش ساعت
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
       validateAndSubmit(context);
        },
        child: Icon(
          Icons.save,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("${AppLocalizations.of(context)!.receipt_page}"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              controller: desController,
              decoration: InputDecoration(
                label: Text("${AppLocalizations.of(context)!.description}"),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: moneyController,
                    decoration: InputDecoration(
                      label: Text("${AppLocalizations.of(context)!.money}"),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: byController,
                    decoration: InputDecoration(
                      label: Text("${AppLocalizations.of(context)!.by}..."),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      label: Text("${AppLocalizations.of(context)!.date}"),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onTap: selectDate, // انتخاب تاریخ
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      label: Text("${AppLocalizations.of(context)!.time}"),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onTap: selectTime, // انتخاب ساعت
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
