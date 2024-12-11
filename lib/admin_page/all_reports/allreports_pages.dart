import 'package:factor/admin_page/all_reports/sell%20reports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'buy reports.dart';
import 'cash_reports.dart';
import 'day sells.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class allreports extends StatefulWidget {
  const allreports({super.key});

  @override
  State<allreports> createState() => _allreportsState();
}

class _allreportsState extends State<allreports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: 1,
          itemBuilder:(context, index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TotalReports(),));
                  },
                  child: Card(
                      shadowColor: Colors.yellowAccent,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    child:ListTile(
                      title: Text("${AppLocalizations.of(context)!.cash}"),
                    )
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => sell(),));
                  },
                  child: Card(   shadowColor: Colors.yellowAccent,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                      child:ListTile(
                        title: Text("${AppLocalizations.of(context)!.sellreports}"),
                      )
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BuyReports(),));
                  },
                  child: Card(   shadowColor: Colors.yellowAccent,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                      child:ListTile(
                        title: Text("${AppLocalizations.of(context)!.buyreports}"),
                      )
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DailySales(),));
                  },
                  child: Card(   shadowColor: Colors.yellowAccent,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                      child:ListTile(
                        title: Text("${AppLocalizations.of(context)!.dayssells}"),
                      )
                  ),
                )
              ],
            );
          },
      ),
    );
  }
}
