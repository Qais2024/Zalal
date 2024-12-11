import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class BuyReports extends StatefulWidget {
  const BuyReports({super.key});

  @override
  State<BuyReports> createState() => _BuyReportsState();
}

class _BuyReportsState extends State<BuyReports> {
  DateTime? _startDate; // تاریخ شروع
  DateTime? _endDate; // تاریخ پایان

  // ویجت برای انتخاب بازه تاریخ
  Future<void> _pickDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  // بررسی اینکه تاریخ در بازه انتخاب شده قرار دارد
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
    if (_startDate == null || _endDate == null || date == null) return true;
    try {
      DateTime? parsedDate = parseDate(date);
      if (parsedDate == null) return false; // اگر تاریخ معتبر نبود
      return !parsedDate.isBefore(_startDate!) && !parsedDate.isAfter(_endDate!);
    } catch (e) {
      print("Error in isInSelectedRangeDate: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("${AppLocalizations.of(context)!.purchase_reports}"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _pickDateRange(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("receivedfactors")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitWaveSpinner(
                color: Colors.blue,
                size: 250,
                trackColor: Colors.blue,
                waveColor: Colors.yellowAccent,
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No data"));
          }

          final Map<String, double> employBuy = {};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final String? date = data["date"]; // تاریخ
            if (!isInSelectedRangeDate(date)) continue; // فیلتر تاریخ

            final String users = data["username"] as String? ?? "";
            final totalValue = data['total'];

            double total = 0.0;

            if (totalValue is List) {
              for (var value in totalValue) {
                total += _convertToDouble(value);
              }
            } else {
              total += _convertToDouble(totalValue);
            }
            if (employBuy.containsKey(users)) {
              employBuy[users] = employBuy[users]! + total;
            } else {
              employBuy[users] = total;
            }
          }

          final employBuyList = employBuy.entries.toList();

          return ListView.builder(
            itemCount: employBuyList.length,
            itemBuilder: (context, index) {
              final employs = employBuyList[index];
              return Card(
                shadowColor: Colors.yellowAccent,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
                child: ListTile(
                  title: Text("${AppLocalizations.of(context)!.name}: ${employs.key}"),
                  trailing: Text(
                    "${employs.value.toStringAsFixed(2)} AFN",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  double _convertToDouble(dynamic value) {
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    } else {
      if (value is num) {
        return value.toDouble();
      } else {
        return 0.0;
      }
    }
  }
}
