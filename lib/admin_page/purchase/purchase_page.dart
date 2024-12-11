import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class receivedfactor extends StatefulWidget {
  final Map<String, dynamic>? receicedfactor;
  const receivedfactor({super.key,this.receicedfactor});

  @override
  State<receivedfactor> createState() => _NewFactorState();
}

class _NewFactorState extends State<receivedfactor> {
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
  int currentId = 1;


  @override
  void initState() {
    super.initState();
    loadstaffname();
    loadproducts();
    syncoffline();
    getLastId();
    if (widget.receicedfactor != null) {
      namelar.text = widget.receicedfactor!["name"] ?? "";
      numberlar.text = widget.receicedfactor!["number"] ?? "";
      idController.text = widget.receicedfactor!["no"] ?? "";
      Salectedstaf = widget.receicedfactor!["username"] ?? "";
      paylar.text = widget.receicedfactor!["totalpay"] ?? "";
      datecontroller.text = widget.receicedfactor!["date"] ?? "";

      List<String> object = List<String>.from(widget.receicedfactor!["object"] ?? []);
      List<String> fee = List<String>.from(widget.receicedfactor!["feed"] ?? []);
      List<String> price = List<String>.from(widget.receicedfactor!["price"] ?? []);
      List<String> total = List<String>.from(widget.receicedfactor!["total"] ?? []);

      for (int i = 0; i < object.length; i++) {
        TextEditingController objectController = TextEditingController(text: object[i]);
        TextEditingController feelController = TextEditingController(text: fee[i]);
        TextEditingController priceController = TextEditingController(text: price[i]);
        TextEditingController totalController = TextEditingController(text: total[i]);

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
      if (user != null && widget.receicedfactor == null) {
        var snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('receivedfactors')
            .orderBy('no', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          int lastId = int.tryParse(snapshot.docs.first['no']) ?? 0;
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

  Future<bool> isconnected()async{
    var connectedresult=await Connectivity().checkConnectivity();
    return connectedresult != ConnectivityResult.none;
  }

  Future<void>syncoffline()async {
    User? user = FirebaseAuth.instance.currentUser;
    var box = await Hive.openBox("receivedfactors");
    if (user != null) {
      if (await isconnected()) {
        CollectionReference factorscollection =
        FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("receivedfactors");
        for (var key in box.keys) {
          var factordata = box.get(key);
          await factorscollection.doc(key).set(factordata);
        }
        await box.clear();
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

  Future<void> savetofirebase()async{
    User? user = FirebaseAuth.instance.currentUser;
    final Map<String,dynamic> receiveddata={
      "name": namelar.text,
      "number": numberlar.text,
      "no": idController.text,
      "username": Salectedstaf,
      "totalpay": paylar.text,
      "object": objectControllers.map((e) => e.text).toList(),
      "feed": feelControllers.map((e) => e.text).toList(),
      "price": priceControllers.map((e) => e.text).toList(),
      "total": totalControllers.map((e) => e.text).toList(),
      "date": datecontroller.text,
    };
    if(await  isconnected()){
      try{
        CollectionReference collectionReference=
            FirebaseFirestore.instance
                .collection("users")
        .doc(user?.uid)
        .collection("receivedfactors");

        if(widget.receicedfactor!=null){
          setState(() {
            currentId++;
            idController.text = currentId.toString();
          });
          await collectionReference.doc(widget.receicedfactor!["no"]).update(receiveddata);
        }else{
          await collectionReference.doc(idController.text).set(receiveddata);
        }
      }catch(e){}
    }else{
      var box = await Hive.openBox('receivedfactors');
      await box.put(idController.text, receiveddata);
    }
  }

  Future<void>loadstaffname()async{
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore firestore=FirebaseFirestore.instance;
    try{
      QuerySnapshot querySnapshot=
          await firestore
              .collection("users")
          .doc(user?.uid)
          .collection("workers")
              .where("condition", isEqualTo: true)
              .get();
      setState(() {
        staffnameslist=querySnapshot.docs
            .map((docs)=>docs["name"].toString())
            .toList();
      });
    }catch(e){}
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
          var price = productDoc.docs.first['perprice'];
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

  Future<void> loadproducts()async {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
      try {
        QuerySnapshot querySnapshot =
        await firestore
            .collection("users")
            .doc(user?.uid)
        .collection("products")
            .where("condition", isEqualTo: true)
            .get();
        setState(() {
          productNames = querySnapshot.docs
              .map((doc) => doc["name"].toString())
              .toList();
        });
      } catch (e) {}
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
      totaloffactorcontroller.text=totalFactorPrice.toString();
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))
              ),
            ),),
            // Text("${AppLocalizations.of(context)!.totals}: "),
            // Text("${totalFactorPrice.toStringAsFixed(0)} ${AppLocalizations.of(context)!.af} "),
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
        child: Icon(Icons.add),
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
                          labelText: "${AppLocalizations.of(context)!.seller}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                          labelText: "${AppLocalizations.of(context)!.number}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment:MainAxisAlignment.spaceBetween,
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
                            borderRadius: BorderRadius.circular(14),
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
                        padding: const EdgeInsets.only(left: 14, right: 14),
                      ),
                      items: staffnameslist
                          .map<DropdownMenuItem<String>>((String name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 5,),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: paylar,
                        decoration: InputDecoration(
                          labelText: "${AppLocalizations.of(context)!.totalpay}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText:"${AppLocalizations.of(context)!.factornumber}",
                          border:
                          OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
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
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: Expanded(
                      child: TextFormField(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              datecontroller.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                            });
                          }
                        },
                        controller: datecontroller,
                        decoration: InputDecoration(
                            labelText: "Date",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                  ),
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
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                       border: Border.fromBorderSide(BorderSide(color: Colors.blue,strokeAlign: 0))
                      ),
                      children: [
                        Expanded(
                          child: DropdownButton2<String>(
                            value: objectControllers[i].text.isNotEmpty ? objectControllers[i].text : null, // مقدار اولیه
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
                        IconButton(onPressed:(){
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
                        }, icon: Icon(Icons.delete,color: Colors.red,))
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