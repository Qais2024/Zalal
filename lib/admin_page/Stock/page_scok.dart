import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _salesreportsState();
}

class _salesreportsState extends State<StockPage> {
  List<Map<String, dynamic>> salselist = [];
  List<Map<String, dynamic>> receivedlist = [];
  Map<String, int> productQuantities = {};
  Map<String, int> receivedQuantities = {};
  Map<String, double> totalPayreseved = {};
  Map<String, double> totalPaysell = {};
  TextEditingController searchControllers = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> allKeys = [];

  @override
  void initState() {
    super.initState();
    loadfactorss();
    loadreceivedd();
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
    }
  }
  DateTime? parseDate(String date) {
    try {
      return DateFormat("yyyy-MM-dd").parse(date); // فرمت اول
    } catch (e1) {
      try {
        return DateFormat("dd/MM/yyyy").parse(date); // فرمت دوم
      } catch (e2) {
        print("Error parsing date: $date");
        return null; // اگر هیچ فرمتی کار نکرد، null برگرداند
      }
    }
  }


  bool isInSelectedRangeDate(String? date) {
    if (_startDate == null || _endDate == null || date == null) return true;
    try {
      DateTime? parsedDate = parseDate(date); // تبدیل رشته به تاریخ
      if (parsedDate == null) return false; // اگر تاریخ معتبر نبود
      return !parsedDate.isBefore(_startDate!) && !parsedDate.isAfter(_endDate!);
    } catch (e) {
      return false;
    }
  }

  Future<void> loadfactorss() async {
    User? user = FirebaseAuth.instance.currentUser;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("factors")
        .get();

    // فیلتر داده‌ها براساس محدوده تاریخ
    salselist = snapshot.docs
        .map((doc) => doc.data())
        .where((data) {
      String? dateStr = data["date"];
      return isInSelectedRangeDate(dateStr); // بررسی تاریخ در محدوده
    })
        .toList()
        .cast<Map<String, dynamic>>();

    calculateProductQuantit();
    setState(() {});
  }


  Future<void> loadreceivedd() async {
    User? user = FirebaseAuth.instance.currentUser;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("receivedfactors")
        .get();

    // فیلتر داده‌ها براساس محدوده تاریخ
    receivedlist = snapshot.docs
        .map((doc) => doc.data())
        .where((data) {
      String? dateStr = data["date"];
      return isInSelectedRangeDate(dateStr);
    })
        .toList()
        .cast<Map<String, dynamic>>();

    calculateProductQuantitreceived();
    setState(() {});
  }


  void calculateProductQuantitreceived() {
    Map<String, int> tempProductQuantitiesr = {};
    Map<String, double> tempTotalPay = {};

    for (var sale in receivedlist) {
      List<String> productNames = sale["object"] is List ? List<String>.from(sale["object"]) : [];
      List<String> feeList = sale["feed"] is List ? List<String>.from(sale["feed"]) : [];
      List<String> perPriceList = sale["price"] is List ? List<String>.from(sale["price"]) : []; // قیمت هر محصول

      for (int i = 0; i < productNames.length; i++) {
        String productName = productNames[i];
        String feeText = feeList.length > i ? feeList[i] : "0";
        String perPriceText = perPriceList.length > i ? perPriceList[i] : "0.0";
        try {
          int fee = int.parse(feeText);
          double perPrice = double.parse(perPriceText);
          // جمع تعداد
          if (tempProductQuantitiesr.containsKey(productName)) {
            tempProductQuantitiesr[productName] = tempProductQuantitiesr[productName]! + fee;
          } else {
            tempProductQuantitiesr[productName] = fee;
          }
          // محاسبه totalpay
          double totalPayForProduct = fee * perPrice;
          if (tempTotalPay.containsKey(productName)) {
            tempTotalPay[productName] = tempTotalPay[productName]! + totalPayForProduct;
          } else {
            tempTotalPay[productName] = totalPayForProduct;
          }
        } catch (e) {
          print("Error parsing fee or perPrice: $feeText, $perPriceText");
        }
      }
    }
    setState(() {
      receivedQuantities = tempProductQuantitiesr;
      totalPayreseved = tempTotalPay; // ذخیره مقدار totalpay برای هر محصول
    });
  }

  void calculateProductQuantit() {
    Map<String, int> tempProductQuantities = {};
    Map<String, double> tempTotalPay = {};
    for (var sale in salselist) {
      List<String> productNames = sale["object"] is List ? List<String>.from(sale["object"]) : [];
      List<String> feeList = sale["fee"] is List ? List<String>.from(sale["fee"]) : [];
      List<String> perPriceList = sale["price"] is List ? List<String>.from(sale["price"]) : [];

      for (int i = 0; i < productNames.length; i++) {
        String perPriceText = perPriceList.length > i ? perPriceList[i] : "0.0";
        String productName = productNames[i];
        String feeText = feeList.length > i ? feeList[i] : "0";
        try {
          double perPrice = double.parse(perPriceText);
          int fee = int.parse(feeText); // تبدیل به عدد
          if (tempProductQuantities.containsKey(productName)) {
            tempProductQuantities[productName] = tempProductQuantities[productName]! + fee;
          } else {
            tempProductQuantities[productName] = fee;
          }
          double totalpayfactor=fee * perPrice;
          if(tempTotalPay.containsKey(productName)){
            tempTotalPay [productName]=tempTotalPay[productName]!+totalpayfactor;
          }else{
            tempTotalPay[productName]=totalpayfactor;
          }

        } catch (e) {
          print("Error parsing fee: $feeText");
        }
      }
    }
    setState(() {
      productQuantities = tempProductQuantities;
      totalPaysell=tempTotalPay;
      allKeys=productQuantities.keys.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // لیست فیلتر شده بر اساس متن جستجو
    List<String> filteredKeys = allKeys
        .where((key) => key.toLowerCase().contains(searchControllers.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextField(
          controller: searchControllers,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search,
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              // متن وارد شده لیست را فیلتر می‌کند
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () async {
              await pickDateRange(context);
              await loadfactorss();
              await loadreceivedd();
            },
          ),
        ],
      ),
      body: salselist.isEmpty && receivedlist.isEmpty
          ? Center(
        child: SpinKitWaveSpinner(
          color: Colors.blue,
          size: 250,
          trackColor: Colors.blue,
          waveColor: Colors.yellowAccent,
        ),
      )
          : ListView.builder(
        itemCount: filteredKeys.length, // استفاده از لیست فیلترشده
        itemBuilder: (context, index) {
          String productName = filteredKeys[index];
          int totalFee = productQuantities[productName] ?? 0;
          int receivedQty = receivedQuantities[productName] ?? 0;
          int totalobject = receivedQty - totalFee;
          double productTotalBuy = totalPayreseved[productName] ?? 0.0;
          double productTotalsell = totalPaysell[productName] ?? 0.0;
          double profit = productTotalsell - productTotalBuy;

          return Card(
            shadowColor: Colors.yellowAccent,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
            child: ListTile(
              title: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.name}: ",
                      ),
                      Text(
                        "$productName",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(width: 30),
                      Text("${AppLocalizations.of(context)!.profit}: "),
                      Text("${profit.toStringAsFixed(2)}"),
                    ],
                  ),
                  Divider(color: Colors.blue),
                  Row(
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.salse}: ",
                      ),
                      Text("$totalFee"),
                      SizedBox(width: 40),
                      Text("${AppLocalizations.of(context)!.money}: "),
                      Text("${productTotalsell.toStringAsFixed(2)}"),
                    ],
                  ),
                  Divider(color: Colors.blue),
                  Row(
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.received}: ",
                      ),
                      Text("$receivedQty"),
                      SizedBox(width: 10),
                      Text("${AppLocalizations.of(context)!.money}: "),
                      Text("${productTotalBuy.toStringAsFixed(2)}"),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                children: [
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    "$totalobject",
                    style: TextStyle(
                        color: totalobject < 0
                            ? Colors.red
                            : totalobject > 0
                            ? Colors.green
                            : Colors.black,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
