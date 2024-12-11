import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class sell extends StatefulWidget {
  const sell({super.key});

  @override
  State<sell> createState() => _sellState();
}

class _sellState extends State<sell> {
  DateTime? _startdate;
  DateTime? _enddate;

  Future<void>pickdaterange(BuildContext context)async{
    DateTimeRange? picked=await showDateRangePicker(
        context: context,
        initialDateRange: _startdate != null &&_enddate !=null
            ? DateTimeRange(start: _startdate!, end: _enddate!)
            :null,
        firstDate: DateTime(1990),
        lastDate: DateTime(2100),
    );
    if(picked!=null){
      setState(() {
        _startdate=picked.start;
        _enddate=picked.end;
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
      print("Error in isInSelectedRangeDate: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("${AppLocalizations.of(context)!.sellreports}"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(onPressed:()=>pickdaterange(context),
              icon:Icon(Icons.calendar_month))
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
            return const Center(child: SpinKitWaveSpinner(
              color: Colors.blue,
              size: 250,
              trackColor: Colors.blue,
              waveColor: Colors.yellowAccent,
            ) ,);
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No data"));
          }

          // پردازش داده‌ها برای جمع‌آوری فروشات هر کارمند
          final Map<String, double> employeeSales = {};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final String date=data["date"];
            if(!isInSelectedRangeDate(date))continue;
            final username = data['username'] as String? ?? 'Unknown';
            final totalValue = data['total'];

            // محاسبه مجموع فروشات
            double total = 0.0;

            if (totalValue is List) {
              // اگر مقدار total یک لیست باشد، مقادیر داخل لیست را جمع کنیم
              for (var value in totalValue) {
                total += _convertToDouble(value);
              }
            } else {
              // اگر مقدار total یک عدد باشد، به صورت مستقیم اضافه کنیم
              total += _convertToDouble(totalValue);
            }

            // جمع‌آوری فروشات برای هر کارمند
            if (employeeSales.containsKey(username)) {
              employeeSales[username] = employeeSales[username]! + total;
            } else {
              employeeSales[username] = total;
            }
          }

          // تبدیل Map به لیست برای نمایش در ListView
          final employeeList = employeeSales.entries.toList();

          return ListView.builder(
            itemCount: employeeList.length,
            itemBuilder: (context, index) {
              final employee = employeeList[index];
              return Card(   shadowColor: Colors.yellowAccent,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
                child: ListTile(
                  title: Text("${AppLocalizations.of(context)!.name}: ${employee.key}"), // نام کارمند
                  trailing: Text("${employee.value.toStringAsFixed(2)} AFN",style: TextStyle(fontSize: 15),), // مجموع فروشات
                ),
              );
            },
          );
        },
      ),
    );
  }

  // تابع برای تبدیل مقدار به double
  double _convertToDouble(dynamic value) {
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    } else if (value is num) {
      return value.toDouble();
    } else {
      return 0.0;
    }
  }
}
