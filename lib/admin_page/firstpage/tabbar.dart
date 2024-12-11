// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:zalal/Product/productlist.dart';
// import 'package:zalal/kompanylist/purchase_list.dart';
// import 'package:zalal/salsefactors/saleslist.dart';
// import 'package:zalal/workerlist/workerlist.dart';
// class tabbar extends StatefulWidget {
//   const tabbar({super.key});
//   @override
//   State<tabbar> createState() => _tabbarState();
// }
// class _tabbarState extends State<tabbar> {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         drawer: Drawer(
//
//         ),
//         appBar: AppBar(
//           bottom: TabBar(
//             tabs: [
//               Tab(
//                 text: "فروشات",
//                 icon: Icon(Icons.production_quantity_limits_sharp),
//               ),
//               Tab(
//                 text: "رسیدات",
//                 icon: Icon(Icons.book_outlined),
//               ),
//               Tab(
//                 text: "محصولات",
//                 icon: Icon(Icons.production_quantity_limits),
//               ),
//               Tab(
//                 text: "کارمندان",
//                 icon: Icon(Icons.person_pin),
//               ),
//
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             factors_page(),
//             receivedlist(),
//             objectlist(),
//             WorkerList(),
//           ],
//         ),
//       ),
//     );
//   }
// }
