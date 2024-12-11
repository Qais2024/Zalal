import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class TotalReports extends StatefulWidget {
  const TotalReports({Key? key}) : super(key: key);

  @override
  State<TotalReports> createState() => _TotalReportsState();
}

class _TotalReportsState extends State<TotalReports> {
  double totalSell = 0.0;
  double totalBuy = 0.0;
  double totalExpenses = 0.0;
  double totalcatch = 0.0;
  double totalReceipt = 0.0;
  double totalSalary = 0.0;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    fetchSellTotal(); // فراخوانی متد برای دریافت مجموع از کالکشن factors
    fetchBuyTotal();// فراخوانی متد برای دریافت مجموع از کالکشن receivedfactors
    fetchexpensesTotal();
    fetchcatchTotal();
    fetchreceiptTotal();
  }

  Future<void> fetchexpensesTotal() async {
    User? user = FirebaseAuth.instance.currentUser;
    double expesesAmount = 0.0;

    try {
      final sellSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
      .collection("expenses")
          .get();
      for (var doc in sellSnapshot.docs) {
        var totalValue = doc.data()['money'];

        // بررسی اینکه آیا totalValue رشته است یا خیر و تبدیل به double
        if (totalValue is String) {
          expesesAmount += _convertToDoublee(totalValue); // تبدیل مقدار رشته‌ای به double
        } else {
        }
      }

      setState(() {
        totalExpenses = expesesAmount; // ذخیره مجموع هزینه‌ها
      });
    } catch (e) {
    }
  }

  Future<void> fetchcatchTotal() async {
    User? user = FirebaseAuth.instance.currentUser;
    double catchAmount = 0.0;

    try {
      final sellSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
      .collection("catch")
          .get();
      for (var doc in sellSnapshot.docs) {
        var totalValue = doc.data()['money'];
        print("Document ID: ${doc.id}, Total Value: $totalValue");

        // بررسی اینکه آیا totalValue رشته است یا خیر و تبدیل به double
        if (totalValue is String) {
          catchAmount += _convertToDoublee(totalValue); // تبدیل مقدار رشته‌ای به double
        } else {
          print("Unexpected type for 'money' field.");
        }
      }

      setState(() {
        totalcatch = catchAmount; // ذخیره مجموع هزینه‌ها
      });
    } catch (e) {
      print("Error fetching expenses total: $e");
    }
  }


  Future<void> fetchreceiptTotal() async {
    User? user = FirebaseAuth.instance.currentUser;
    double receiptAmount = 0.0;

    try {
      final sellSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
      .collection("receipt")
          .get();
      for (var doc in sellSnapshot.docs) {
        var totalValue = doc.data()['money'];
        print("Document ID: ${doc.id}, Total Value: $totalValue");

        // بررسی اینکه آیا totalValue رشته است یا خیر و تبدیل به double
        if (totalValue is String) {
          receiptAmount += _convertToDoublee(totalValue); // تبدیل مقدار رشته‌ای به double
        } else {
          print("Unexpected type for 'money' field.");
        }
      }

      setState(() {
        totalReceipt = receiptAmount; // ذخیره مجموع هزینه‌ها
      });
    } catch (e) {
      print("Error fetching expenses total: $e");
    }
  }

  double _convertToDoublee(String value) {
    // تبدیل مقدار رشته‌ای به double. اگر تبدیل ناموفق بود، مقدار پیش‌فرض 0.0 را باز می‌گرداند
    return double.tryParse(value) ?? 0.0;
  }

  // متد برای دریافت مجموع از کالکشن 'factors'
  Future<void> fetchSellTotal() async {
    User? user = FirebaseAuth.instance.currentUser;
    double sellAmount = 0.0;

    try {
      final sellSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
      .collection("factors")
          .get();
      for (var doc in sellSnapshot.docs) {
        var totalValue = doc.data()['totalpay'];

        if (totalValue is List) {
          for (var item in totalValue) {
            sellAmount += _convertToDouble(item);
          }
        } else {
          sellAmount += _convertToDouble(totalValue);
        }
      }

      setState(() {
        totalSell = sellAmount; // ذخیره مقدار مجموع فروش
      });
    } catch (e) {
      print("Error fetching sell total: $e");
    }
  }

  // متد برای دریافت مجموع از کالکشن 'receivedFactors'
  Future<void> fetchBuyTotal() async {
    User? user = FirebaseAuth.instance.currentUser;
    double buyAmount = 0.0;

    try {
      final buySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
      .collection("receivedfactors")

          .get();
      for (var doc in buySnapshot.docs) {
        var totalValue = doc.data()['total'];

        if (totalValue is List) {
          for (var item in totalValue) {
            buyAmount += _convertToDouble(item);
          }
        } else {
          buyAmount += _convertToDouble(totalValue);
        }
      }

      setState(() {
        totalBuy = buyAmount; // ذخیره مقدار مجموع خرید
      });
    } catch (e) {
      print("Error fetching buy total: $e");
    }
  }

  // تابع برای تبدیل داده به double
  double _convertToDouble(dynamic value) {
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double received = totalSell + totalReceipt;
    double expeses = totalBuy + totalExpenses + totalcatch + totalSalary;
    double cash = received - expeses;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text("${AppLocalizations.of(context)!.totalreports}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          border: TableBorder.all(color: Colors.blueAccent, width: 1),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _buildTableRow("${AppLocalizations.of(context)!.totalsell}", totalSell.toStringAsFixed(2)),
            _buildTableRow("${AppLocalizations.of(context)!.purchase}", totalBuy.toStringAsFixed(2)),
            _buildTableRow("${AppLocalizations.of(context)!.expenses}", totalExpenses.toStringAsFixed(2)),
            _buildTableRow("${AppLocalizations.of(context)!.ccatch}", totalcatch.toStringAsFixed(2)),
            _buildTableRow("${AppLocalizations.of(context)!.receipt}", totalReceipt.toStringAsFixed(2)),
            _buildTableRow("${AppLocalizations.of(context)!.salary}", totalSalary.toStringAsFixed(2)),
            _buildTableRow("${AppLocalizations.of(context)!.total_income}", received.toStringAsFixed(2), color: Colors.green),
            _buildTableRow("${AppLocalizations.of(context)!.total_expenses}", expeses.toStringAsFixed(2), color: Colors.red),
            _buildTableRow("${AppLocalizations.of(context)!.cash}", cash.toStringAsFixed(2), color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

// تابع برای ساخت هر ردیف جدول با دو سلول
  TableRow _buildTableRow(String label, String value, {Color color = Colors.black}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  }