import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class newfactor extends StatefulWidget {
  final Map<String, dynamic>? factors;
  const newfactor({super.key, this.factors});

  @override
  State<newfactor> createState() => _NewFactorState();
}

class _NewFactorState extends State<newfactor> {
  String? Salectedstaf;
  List<String> staffnameslist = [];
  TextEditingController textEditingController = TextEditingController();

  List<Map<String, dynamic>> productList = [];
  List<String> productNames = [];
  List<TextEditingController> objectControllers = [];
  List<TextEditingController> feelControllers = [];
  List<TextEditingController> priceControllers = [];
  List<TextEditingController> totalControllers = [];

  TextEditingController namelar = TextEditingController();
  TextEditingController numberlar = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController usernamelar = TextEditingController();
  TextEditingController paylar = TextEditingController();
  TextEditingController datecontroller = TextEditingController();
  TextEditingController totaloffactorcontroller = TextEditingController();
  double totalFactorPrice = 0.0;
  bool? condition;
  int currentId = 1;

  @override
  void initState() {
    super.initState();
    calculate();
    syncOfflineData();
    loadStaffName();
    loadproductname();
    getLastId();
    if (widget.factors != null) {
      namelar.text = widget.factors!["name"] ?? "";
      numberlar.text = widget.factors!["number"] ?? "";
      idController.text = widget.factors!["iid"] ?? "";
      Salectedstaf = widget.factors!["username"] ?? "";
      paylar.text = widget.factors!["totalpay"] ?? "";
      datecontroller.text = widget.factors!["date"] ?? "";
      condition = widget.factors!["condition"] ?? true;
      List<String> object = List<String>.from(widget.factors!["object"] ?? []);
      List<String> fee = List<String>.from(widget.factors!["fee"] ?? []);
      List<String> price = List<String>.from(widget.factors!["price"] ?? []);
      List<String> total = List<String>.from(widget.factors!["total"] ?? []);
      for (int i = 0; i < object.length; i++) {
        TextEditingController objectController =
            TextEditingController(text: object[i]);
        TextEditingController feelController =
            TextEditingController(text: fee[i]);
        TextEditingController priceController =
            TextEditingController(text: price[i]);
        TextEditingController totalController =
            TextEditingController(text: total[i]);

        objectControllers.add(objectController);
        feelControllers.add(feelController);
        priceControllers.add(priceController);
        totalControllers.add(totalController);

        // Add listeners for live calculation
        feelController.addListener(() => calculate());
        priceController.addListener(() => calculate());
      }
    }
  }

  Future<void> getLastId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && widget.factors == null) {
        var snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('factors')
            .orderBy('iid', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          int lastId = int.tryParse(snapshot.docs.first['iid']) ?? 0;
          currentId = lastId + 1;
        } else {
          currentId = 1;
        }
        idController.text = currentId.toString();
      }
    } catch (e) {
      print("Error fetching last ID: $e");
      idController.text = currentId.toString();
    }
  }


  Future<bool> isconnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> syncOfflineData() async {
    User? user = FirebaseAuth.instance.currentUser;
    var box = await Hive.openBox('abc');
    if(user!=null)
    if (await isconnected()) {
      CollectionReference factorssCollection =
      FirebaseFirestore.instance
          .collection('users')
      .doc(user.uid)
      .collection("factors")
      ;

      for (var key in box.keys) {
        var productData = box.get(key);

        await factorssCollection.doc(key).set(productData);
      }

      await box.clear();
    }
  }

  Future<void> savetofirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final Map<String, dynamic> factordata = {
        "name": namelar.text,
        "number": numberlar.text,
        "iid": idController.text,
        "username": Salectedstaf,
        "totalpay": paylar.text, // مقدار به صورت text
        "object": objectControllers.map((c) => c.text).toList(),
        "fee": feelControllers.map((c) => c.text).toList(),
        "price": priceControllers.map((c) => c.text).toList(),
        "total": totalControllers.map((c) => c.text).toList(),
        "date": datecontroller.text,
        "condition": condition ?? true,
      };
      if (await isconnected()) {
        try {
          CollectionReference productsCollection =
          FirebaseFirestore.instance
              .collection('users')
          .doc(user.uid)
          .collection("factors");
          if (widget.factors != null) {
            setState(() {
              currentId++;
              idController.text = currentId.toString();
            });
            // به‌روزرسانی سند موجود
            await productsCollection.doc(widget.factors!['iid']).update(
                factordata);
          } else {
            // ایجاد سند جدید با ID مشخص
            await productsCollection.doc(idController.text).set(factordata);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product saved successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update product: $e')),
          );
        }
      }
      else {
        // ذخیره‌سازی محلی
        var box = await Hive.openBox('abc');
        await box.put(idController.text, factordata);
        Navigator.pop(context);
      }
    }
  }

  Future<void> selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        datecontroller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void loadStaffName() async {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection("workers")
            .where("condition", isEqualTo: true)
            .get();
        setState(() {
          staffnameslist = querySnapshot.docs
              .map((doc) => doc['name'].toString())
              .toList();
        });
      } catch (e) {
        print("Error loading staff names: $e");
      }
    }
  }

  Future<void> getProductPrice(String productName, int rowIndex) async {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (user != null) {
      try {
        // جستجوی محصول بر اساس نام
        var productDoc = await firestore
            .collection("users")
            .doc(user.uid)
            .collection("products")
            .where("name", isEqualTo: productName)
            .get();

        if (productDoc.docs.isNotEmpty) {
          // دریافت قیمت از محصول
          var price = productDoc.docs.first['salse'];
          setState(() {
            // قرار دادن قیمت در فیلد قیمت برای ردیف مشخص
            priceControllers[rowIndex].text = price.toString();
          });
        }
      } catch (e) {
        print("Error fetching product price: $e");
      }
    }
  }

  void loadproductname() async {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot =
        await firestore
            .collection("users")
            .doc(user.uid)
            .collection("products")
            .where("condition", isEqualTo: true)
            .get();
        setState(() {
          productNames = querySnapshot.docs
              .map((doc) => doc["name"].toString())
              .toList();
        });
      } catch (e) {
        print("Error loading products: $e");
      }
    }
  }

  void addRow() {
    setState(() {
      TextEditingController objectController = TextEditingController();
      TextEditingController feelController = TextEditingController();
      TextEditingController priceController = TextEditingController();
      TextEditingController totalController = TextEditingController();

      objectControllers.add(objectController);
      feelControllers.add(feelController);
      priceControllers.add(priceController);
      totalControllers.add(totalController);

      feelController.addListener(() => calculate());
      priceController.addListener(() => calculate());
    });
  }

  void calculate() {
    double newTotal = 0.0;
    for (int i = 0; i < feelControllers.length; i++) {
      double fee = double.tryParse(feelControllers[i].text) ?? 0.0;
      double price = double.tryParse(priceControllers[i].text) ?? 0.0;
      double total = fee * price;
      totalControllers[i].text = total.toStringAsFixed(2);
      newTotal += total;
    }
    setState(() {
      totalFactorPrice = newTotal;
      totaloffactorcontroller.text = totalFactorPrice.toString();
      condition = true; // بعد از تغییر مبلغ، condition به true تغییر می‌کند
    });
  }

  void validateAndSubmit(BuildContext context) {
    if (namelar.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفا نام مشتری را وارد کنید')),
      );
      return;
    }

    if (datecontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفا تاریخ فاکتور را مشخص کنید')),
      );
      return;
    }

    if (idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفا شماره فاکتور را بنویسید')),
      );
      return;
    }

    for (int i = 0; i < objectControllers.length; i++) {
      if (objectControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لطفا نام جنس در ردیف ${i + 1} را وارد کنید')),
        );
        return;
      }

      if (feelControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لطفا تعداد در ردیف ${i + 1} را وارد کنید')),
        );
        return;
      }

      if (priceControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لطفا قیمت جنس در ردیف ${i + 1} را وارد کنید')),
        );
        return;
      }

      if (totalControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لطفا قیمت مجموعه در ردیف ${i + 1} را وارد کنید')),
        );
        return;
      }
    }

    // اگر همه فیلدها پر بودند، عملیات مورد نظر را انجام دهید
    savetofirebase();
    Navigator.pop(context);
  }


  @override
  void dispose() {
    objectControllers.forEach((controller) => controller.dispose());
    feelControllers.forEach((controller) => controller.dispose());
    priceControllers.forEach((controller) => controller.dispose());
    totalControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            SizedBox(width: 200,height: 35,child: TextFormField(
              controller: totaloffactorcontroller,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                labelText: "Total of factor",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
               validateAndSubmit(context);
            },
            icon: Icon(Icons.check),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addRow,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Main Form Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextFormField(
                        controller: namelar,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "${AppLocalizations.of(context)!.customer}",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: numberlar,
                        decoration: InputDecoration(
                          labelText: "${AppLocalizations.of(context)!.customernumber}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButton2<String>(
                        value: Salectedstaf,
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            Icon(
                              Icons.list,
                              size: 20,
                              color: Colors.blueAccent,
                            ),
                            Text("Seller"),
                          ],
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            Salectedstaf = newValue;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 45,
                          width: 160,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all()),
                        ),
                        dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                            )),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: const EdgeInsets.only(left: 8, right: 8),
                        ),
                        items: staffnameslist
                            .map<DropdownMenuItem<String>>((String name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        dropdownSearchData: DropdownSearchData(
                          searchController: textEditingController,
                          searchInnerWidgetHeight: 50,
                          searchInnerWidget: Container(
                            height: 50,
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 4,
                              right: 8,
                              left: 8,
                            ),
                            child: TextFormField(
                              expands: true,
                              maxLines: null,
                              controller: textEditingController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                hintText: '${AppLocalizations.of(context)!.search}...',
                                hintStyle: const TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          searchMatchFn: (item, searchValue) {
                            return item.value.toString().contains(searchValue);
                          },
                        ),
                        onMenuStateChange: (isOpen) {
                          if (!isOpen) {
                            textEditingController.clear();
                          }
                        }),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: 130,
                    height: 45,
                    child: Expanded(
                      child: TextFormField(
                        onTap: ()async{
                          DateTime?pickdate=await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2050));
                          if(pickdate!=null){
                            setState(() {
                              datecontroller.text="${pickdate.toLocal()}".split(" ")[0];
                            });
                          }
                        },
                        controller: datecontroller,
                        decoration: InputDecoration(
                            hintText: '${AppLocalizations.of(context)!.date}',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: idController,
                        decoration: InputDecoration(
                          labelText: "${AppLocalizations.of(context)!.factornumber}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text("${AppLocalizations.of(context)!.count}: ${objectControllers.length}"),
                    ],
                  ),
                  Column(
                    children: [
                      Text("${AppLocalizations.of(context)!.factor}",style: TextStyle(color: Colors.blue,fontSize: 24,),),
                    ],),
                ],
              ),
              SizedBox(height: 10),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                },
                children: [
                  for (int i = 0; i < objectControllers.length; i++)
                    TableRow(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.fromBorderSide(BorderSide(color: Colors.blue,strokeAlign: 0))),
                      children: [
                        Expanded(
                          child: DropdownButton2<String>(
                            value: objectControllers[i].text.isNotEmpty
                                ? objectControllers[i].text
                                : null, // مقدار اولیه
                            items: productNames
                                .map((name) => DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                objectControllers[i].text = value ?? '';
                              });
                              int rowIndex = objectControllers.length - 1;
                              getProductPrice(value!, rowIndex);
                            },
                            hint: Text('${AppLocalizations.of(context)!.products}'),
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 50,
                              width: 250,
                            ),

                            dropdownSearchData: DropdownSearchData(
                              searchController: textEditingController,
                              searchInnerWidgetHeight: 50,
                              searchInnerWidget: Container(
                                height: 60,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 4,
                                  right: 8,
                                  left: 8,
                                ),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: textEditingController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: '${AppLocalizations.of(context)!.search}...',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              searchMatchFn: (item, searchValue) {
                                return item.value
                                    .toString()
                                    .contains(searchValue);
                              },
                            ),
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                textEditingController.clear();
                              }
                            },
                          ),
                        ),
                        TextFormField(
                          controller: feelControllers[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "${AppLocalizations.of(context)!.qty}",
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                        TextFormField(
                          controller: priceControllers[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "${AppLocalizations.of(context)!.price}",
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                        TextFormField(
                          controller: totalControllers[i],
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "${AppLocalizations.of(context)!.total}",
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                objectControllers[i].dispose();
                                feelControllers[i].dispose();
                                priceControllers[i].dispose();
                                totalControllers[i].dispose();

                                objectControllers.removeAt(i);
                                feelControllers.removeAt(i);
                                priceControllers.removeAt(i);
                                totalControllers.removeAt(i);

                                // به روزرسانی محاسبه کل پس از حذف
                                calculate();
                              });
                            },
                            icon: Icon(Icons.delete,color: Colors.red,))
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
