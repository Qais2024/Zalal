import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class ObjectPage extends StatefulWidget {
  final Map<String, dynamic>? products;
  const ObjectPage({Key? key, this.products}) : super(key: key);

  @override
  State<ObjectPage> createState() => _ObjectPageState();
}

class _ObjectPageState extends State<ObjectPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController perPackController = TextEditingController();
  final TextEditingController totalPriceController = TextEditingController();
  final TextEditingController perPriceController = TextEditingController();
  final TextEditingController salesController = TextEditingController();
  bool?  condition;
  int currentId = 1;

  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
    syncOfflineData(); // مقداردهی خودکار ID
    getLastId();
    if (widget.products != null) {
      idController.text = widget.products?["iid"] ?? '';
      nameController.text = widget.products?["name"] ?? '';
      perPackController.text = widget.products?["perpak"]?.toString() ?? '';
      totalPriceController.text = widget.products?["totalprice"]?.toString() ?? '';
      perPriceController.text = widget.products?["perprice"]?.toString() ?? '';
      salesController.text = widget.products?["salse"]?.toString() ?? '';
      condition=widget.products!["condition"]?? true;
    }
    totalPriceController.addListener(calculatePerPrice);
    perPackController.addListener(calculatePerPrice);
  }
  Future<void> getLastId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && widget.products == null) {
        var snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('products')
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


  void calculatePerPrice() {
    double totalPriceValue = double.tryParse(totalPriceController.text) ?? 0.0;
    double perPackValue = double.tryParse(perPackController.text) ?? 1.0;

    if (perPackValue > 0) {
      double calculatedPerPrice = totalPriceValue / perPackValue;
      perPriceController.text = calculatedPerPrice.toStringAsFixed(2);
    } else {
      perPriceController.text = '0';
    }
  }

  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> syncOfflineData() async {
    var box = await Hive.openBox('offlineProducts');
    if (await isConnected()) {
      CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

      for (var key in box.keys) {
        var productData = box.get(key);

        await productsCollection.doc(key).set(productData);
      }

      await box.clear();
    }
  }

  Future<void> saveToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final Map<String, dynamic> productData = {
        "iid": idController.text,
        "name": nameController.text,
        "perpak": int.tryParse(perPackController.text) ?? 0,
        "totalprice": double.tryParse(totalPriceController.text) ?? 0.0,
        "perprice": double.tryParse(perPriceController.text) ?? 0.0,
        "salse": int.tryParse(salesController.text) ?? 0,
        "condition":condition ?? true,
        "time":DateTime.now(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('products')
            .doc(idController.text)
            .set(productData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product saved successfully!')),
        );
        setState(() {
          currentId++;
          idController.text = currentId.toString();
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save product: $e')),
        );
      }
    } else {
      print("User not logged in.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            saveToFirestore();
            Navigator.pop(context);
          }
        },
        child: Icon(Icons.save),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(AppLocalizations.of(context)!.registerProduct),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(
                  idController, context, AppLocalizations.of(context)!.id, false,readOnly: true), // فیلد فقط خواندنی
                SizedBox(height: 16),
                _buildTextField(nameController, context, AppLocalizations.of(context)!.name, true),
                SizedBox(height: 16),
                _buildTextField(perPackController, context, AppLocalizations.of(context)!.everyPack, true),
                SizedBox(height: 16),
                _buildTextField(totalPriceController, context, AppLocalizations.of(context)!.totalPrice, true),
                SizedBox(height: 16),
                _buildTextField(perPriceController, context, AppLocalizations.of(context)!.perPrice, true, readOnly: true),
                SizedBox(height: 16),
                _buildTextField(salesController, context, AppLocalizations.of(context)!.sell, true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, BuildContext context, String labelText, bool isNumeric, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        return value == null || value.isEmpty ? 'Please enter $labelText' : null;
      },
    );
  }
}