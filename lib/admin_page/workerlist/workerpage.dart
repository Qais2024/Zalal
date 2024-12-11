import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class workerpage extends StatefulWidget {
  final Map<String, dynamic>? worker;
  const workerpage({super.key, this.worker});
  @override
  State<workerpage> createState() => _WorkerPageState();
}

class _WorkerPageState extends State<workerpage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  // TextEditingController tazkeraController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  // TextEditingController ageController = TextEditingController();
  // TextEditingController dateController = TextEditingController();
  // TextEditingController salaryController = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  // TextEditingController psitioncontroller = TextEditingController();
  TextEditingController rolecontroller = TextEditingController();
  bool? condition;
  int currentId = 1;

  @override
  void initState() {
    super.initState();
    syncofflineData();
    getLastId();
    if (widget.worker != null) {
      idController.text = widget.worker!["iid"] ?? '';
      nameController.text = widget.worker!["name"] ?? '';
      fatherNameController.text = widget.worker!["fathername"] ?? '';
      lastNameController.text = widget.worker!["lastname"] ?? '';
      // tazkeraController.text = widget.worker!["tazkera"] ?? '';
      phoneNumberController.text = widget.worker!["phonenumber"] ?? '';
      // addressController.text = widget.worker!["address"] ?? '';
      // ageController.text = widget.worker!["age"] ?? '';
      // dateController.text = widget.worker!["date"] ?? '';
      // salaryController.text = widget.worker!["salary"] ?? '';
      passwordcontroller.text = widget.worker!["password"] ?? '';
      // psitioncontroller.text = widget.worker!["position"] ?? '';
      rolecontroller.text = widget.worker!["role"] ?? '';
      condition=widget.worker!["condition"]??true;
    }
  }
  Future<void> getLastId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && widget.worker == null) {
        var snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('workers')
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



  Future<bool> isconected() async {
    var connectedresult = await Connectivity().checkConnectivity();
    return connectedresult != ConnectivityResult.none;
  }

  Future<void> syncofflineData() async {
    var box = await Hive.openBox("offlinewokerlist");
    if (await isconected()) {
      CollectionReference workercolection =
          FirebaseFirestore.instance.collection("workers");
      for (var key in box.keys) {
        var workersdata = box.get(key);
        await workercolection.doc(key).set(workersdata);
      }
      await box.clear();
    }
  }

  Future<void> saveToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User is not logged in.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in')),
      );
      return;
    }
    // داده‌هایی که باید ذخیره شوند
    final Map<String, dynamic> workersData = {
      "iid": idController.text,
      "name": nameController.text,
      "fathername": fatherNameController.text,
      "lastname": lastNameController.text,
      "phonenumber": phoneNumberController.text,
      "password":passwordcontroller.text,
      "role":rolecontroller.text,
      "condition":condition ?? true,
    };
    bool connected = await isconected();
    try {
      if (connected) {
        // ذخیره در Firestore
        CollectionReference workerCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection("workers");
        if (widget.worker != null) {
          // ویرایش داده
          await workerCollection.doc(widget.worker!["iid"]).update(workersData);
          print("Worker updated successfully.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Worker updated successfully!')),
          );
          setState(() {
            currentId++;
            idController.text = currentId.toString();
          });
        } else {
          // اضافه کردن داده
          await workerCollection.doc(idController.text).set(workersData);
          print("Worker added successfully.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Worker added successfully!')),
          );
        }
      } else {
        // ذخیره آفلاین در Hive
        var box = await Hive.openBox("offlineWorkerList");
        await box.put(idController.text, workersData);
        print("Data saved offline in Hive.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No internet connection. Data saved offline.')),
        );
      }
    } catch (e) {
      print("Failed to save or update worker: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save worker: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            saveToFirebase();
            Navigator.pop(context);
          }
        },
        child: Icon(Icons.save),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("${AppLocalizations.of(context)!.registerWorker}"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: idController,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "${AppLocalizations.of(context)!.id}",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? "Please enter ID" : null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "${AppLocalizations.of(context)!.name}",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? "Please enter Name" : null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: fatherNameController,
                  decoration: InputDecoration(
                    labelText: "${AppLocalizations.of(context)!.fatherName}",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? "Please enter Father name" : null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: "${AppLocalizations.of(context)!.lastName}",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? "Please enter Last name" : null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "${AppLocalizations.of(context)!.phoneNumber}",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? "Please enter Phone number" : null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: passwordcontroller,
                  decoration: InputDecoration(
                    labelText: "password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? "Please enter password" : null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: rolecontroller,
                  decoration: InputDecoration(
                    labelText: "Role",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? "Please enter password" : null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
