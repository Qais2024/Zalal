import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class DailySales extends StatefulWidget {
  const DailySales({super.key});

  @override
  State<DailySales> createState() => _DailySalesState();
}

class _DailySalesState extends State<DailySales> {
  DateTime? _startDate;
  DateTime? _endDate;

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


  DateTime? parseDate(String date) {
    try {

      return DateFormat("yyyy-MM-dd").parse(date);
    } catch (e1) {
      try {

        return DateFormat("dd/MM/yyyy").parse(date);
      } catch (e2) {
        print("Error parsing date: $date");
        return null;
      }
    }
  }

  bool isInSelectedRangeDate(String? date) {
    if (_startDate == null || _endDate == null || date == null) return true;
    try {
      DateTime? parsedDate = parseDate(date);
      if (parsedDate == null) return false;
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
        title: Text("${AppLocalizations.of(context)!.dayssells}"),
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
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("factors")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Map<String, double> dailySales = {};

            for (var doc in snapshot.data!.docs) {
              String date = doc['date'];
              if (!isInSelectedRangeDate(date)) continue;

              String totalpay = doc['totalpay'].toString(); // تبدیل به رشته
              List<String> items = totalpay.split(','); // جدا کردن مقادیر بر اساس کاما

              double dailyTotal = items.fold(0.0, (sum, item) {
                double itemValue = double.tryParse(item.trim()) ?? 0.0; // تبدیل هر مقدار به double
                return sum + itemValue; // جمع مقادیر
              });

              if (dailySales.containsKey(date)) {
                dailySales[date] = dailySales[date]! + dailyTotal;
              } else {
                dailySales[date] = dailyTotal;
              }
            }
            return ListView.builder(
              itemCount: dailySales.length,
              itemBuilder: (context, index) {
                String date = dailySales.keys.elementAt(index);
                double sales = dailySales[date]!;
                return Card(
                  shadowColor: Colors.yellowAccent,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  child: ListTile(
                    title: Text("${AppLocalizations.of(context)!.date}: $date"),
                    subtitle: Text("${AppLocalizations.of(context)!.dayssells}: ${sales.toStringAsFixed(2)}"),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
