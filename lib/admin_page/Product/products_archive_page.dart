import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:factor/admin_page/Product/productpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class products_archive_page extends StatefulWidget {
  const products_archive_page({super.key});
  @override
  State<products_archive_page> createState() => _ObjectListState();
}
class _ObjectListState extends State<products_archive_page> {
  List<Map<String, dynamic>> productlist = [];
  List<Map<String, dynamic>> filteredFactorss = [];
  TextEditingController searchControllers = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchControllers.addListener(() {
      filterFactorss();
    });
  }

  Future<void> archive(String docid) async {
    try {
      // به‌روزرسانی فیلد conjection در Firebase
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("products")
          .doc(docid)
          .update({"condition": true,})
      ;

      // نمایش پیام موفقیت
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment confirmed and removed from list")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating: $e")),
      );
    }
  }


  void filterFactorss() {
    String searchText = searchControllers.text.toLowerCase();
    setState(() {
      filteredFactorss = productlist.where((factor) {
        String productName = (factor["name"] ?? "").toLowerCase();
        String totalprice = (factor["totalprice"] ?? "").toLowerCase();
        return productName.contains(searchText) || totalprice.contains(searchText);
      }).toList();
    });
  }
  Future<void> addEditList({Map<String, dynamic>? object, String? docId}) async {
    // گرفتن اطلاعات کاربر احراز هویت شده
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User is not logged in")),
      );
      return;
    }

    // باز کردن صفحه و دریافت نتایج
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObjectPage(products: object),
      ),
    );

    if (result != null) {
      try {
        // مسیر به کالکشن مربوط به کاربر احراز هویت شده
        CollectionReference productsCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('products');

        if (docId != null) {
          // اگر docId وجود دارد، به‌روزرسانی سند
          await productsCollection.doc(docId).update(result);
        } else {
          // اگر docId وجود ندارد، اضافه کردن سند جدید
          await productsCollection.add(result);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product saved successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving product: $e")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: TextField(
          controller: searchControllers,
          decoration: InputDecoration(
            hintText: "${AppLocalizations.of(context)!.search}...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black87),
          ),
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('products')
            .where("condition", isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitWaveSpinner(
              color: Colors.blue,
              size: 250,
              trackColor: Colors.blue,
              waveColor: Colors.yellowAccent,
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No products found"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final products=snapshot.data!.docs[index].data()  as Map<String,dynamic>;
              final docId=snapshot.data!.docs[index].id;
              return GestureDetector(
                onTap: () {
                  addEditList(object: products, docId: docId);
                },
                child: Card(
                  shadowColor: Colors.yellowAccent,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  child: ListTile(
                    trailing: IconButton(onPressed:(){
                      archive(docId);
                    }, icon:Icon(Icons.archive,color: Colors.blueAccent,)),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${AppLocalizations.of(context)!.name}: ${products["name"]?? "Unknown"}"),
                        Text(
                            "${AppLocalizations.of(context)!.price}: ${products["totalprice"]?? "Unknown"}"),
                        Text(
                            "${AppLocalizations.of(context)!.sell}: ${products["salse"]?? "Unknown"} af"),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


}
