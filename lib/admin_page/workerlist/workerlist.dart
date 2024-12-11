import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:factor/admin_page/workerlist/workerpage.dart';
import 'package:factor/admin_page/workerlist/workers_archive_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class WorkerList extends StatefulWidget {
  const WorkerList({super.key});
  @override
  State<WorkerList> createState() => _WorkerListState();
}

class _WorkerListState extends State<WorkerList> {
  List<Map<String, dynamic>> workersList = [];

  @override
  void initState() {
    super.initState();
  }
  Future<void> addeditelist({Map<String, dynamic>? object, String? docid})async{

    final result=await Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => workerpage(worker: object,),),
    );
    if(result!=null){
      if(docid!=null){
        await FirebaseFirestore.instance.collection("users").doc(docid).update(result);
      }else{
        await FirebaseFirestore.instance.collection("workers").add(result);
      }
    }
  }
  // Future<void>delete(String docId)async{
  //   User? user=FirebaseAuth.instance.currentUser;
  //   try{
  //     await FirebaseFirestore.instance.collection("users")
  //         .doc(user?.uid)
  //         .collection("workers")
  //         .doc(docId).delete();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Product deleted successfully")),
  //     );
  //   }catch(e){
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error deleting product: $e")),
  //     );
  //   }
  // }
  Future<void> archive(String docid) async {
    try {
      // به‌روزرسانی فیلد conjection در Firebase
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("workers")
          .doc(docid)
          .update({"condition": false,})
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


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(child: Text("${AppLocalizations.of(context)!.sttaflist}")),
        actions: [
          IconButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder: (context) => workers_archive_page(),));
          }, icon:Icon(Icons.archive,color: Colors.yellowAccent,))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () {
          addeditelist();
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("workers")
            .where("condition", isEqualTo: true)
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
            return Center(child: Text("No workers found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final worker = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final docId = snapshot.data!.docs[index].id;

              return GestureDetector(
                onTap: () {
                  addeditelist(object: worker, docid: docId);
                },
                child: Card(
                  shadowColor: Colors.yellowAccent,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2)),
                  child: ListTile(
                    trailing: IconButton(onPressed:(){
                      archive(docId);
                    }, icon:Icon(Icons.archive,color: Colors.blueAccent,)),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${AppLocalizations.of(context)!.id}: $docId"),
                        Divider(color: Colors.blue),
                        Text("${AppLocalizations.of(context)!.name}: ${worker["name"] ?? "Unknown"}"),
                        Divider(color: Colors.blue),
                        Text("${AppLocalizations.of(context)!.lastName}: ${worker["password"] ?? "Unknown"}"),
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
