import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class all_received_factors extends StatefulWidget {
  const all_received_factors({super.key});

  @override
  State<all_received_factors> createState() => _all_received_factorsState();
}

class _all_received_factorsState extends State<all_received_factors> {
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
      setState(() {});
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
    if (_startdate == null || _enddate == null || date == null) return true;
    try {
      DateTime? parsedDate = parseDate(date);
      if (parsedDate == null) return false;
      return !parsedDate.isBefore(_startdate!) && !parsedDate.isAfter(_enddate!);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          IconButton(
            onPressed: () => pickDateRange(context),
            icon: Icon(Icons.calendar_month, color: Colors.yellowAccent),
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
            return Center(
              child: SpinKitWaveSpinner(
                color: Colors.blue,
                size: 250,
                trackColor: Colors.blue,
                waveColor: Colors.yellowAccent,
              ),
            );
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

            final matchesSearch = (factors["name"] ?? "")
                .toString()
                .toLowerCase()
                .contains(searchText) ||
                (factors["number"] ?? "").toString().toLowerCase().contains(searchText);
            final matchesDate = isInSelectedRangeDate(factors["date"]);

            return matchesSearch && matchesDate;
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              border: TableBorder.all(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blueAccent,
                width: 1,
              ),
              columns: [
                DataColumn(label: Text("نام مشتری", style: TextStyle(fontSize: 12))),
                DataColumn(label: Text("مبلغ کل", style: TextStyle(fontSize: 12))),
                DataColumn(label: Text("پرداخت شده", style: TextStyle(fontSize: 12))),
                DataColumn(label: Text("تاریخ", style: TextStyle(fontSize: 12))),
              ],
              rows: [
                // ساخت ردیف‌های داده‌های اصلی
                ...filteredDocs.map((doc) {
                  final factors = doc.data() as Map<String, dynamic>;
                  final totalPay = (factors["totalpay"] ?? 0).toString();

                  return DataRow(cells: [
                    DataCell(Text(factors["name"] ?? "", style: TextStyle(fontSize: 12))),
                    DataCell(Text(
                      calculateTotal(factors["total"] ?? []).toStringAsFixed(2),
                      style: TextStyle(fontSize: 12),
                    ),),
                    DataCell(Text(totalPay, style: TextStyle(fontSize: 12))),
                    DataCell(Text(factors["date"] ?? "", style: TextStyle(fontSize: 12))),
                  ]);
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
  double calculateTotal(List<dynamic> totalPrice) {
    return totalPrice.fold(0, (sum, price) => sum + double.parse(price.toString()));
  }
}
