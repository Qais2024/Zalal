import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_controller.dart';
class photopage extends StatefulWidget {
  const photopage({super.key});

  @override
  State<photopage> createState() => _photopageState();
}

class _photopageState extends State<photopage> {
  final myitems=[
    Image.asset("image/a27.jpg"),
    Image.asset("image/a39.jpg"),
    Image.asset("image/a43.jpg"),
    Image.asset("image/a73.jpg"),
    Image.asset("image/a90.jpg"),
    Image.asset("image/a142.jpg"),
  ];
  int mycurentindex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("book"),),
      body:SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
                items: myitems,
                options: CarouselOptions(
                  autoPlay: true,
                  height: 150,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: const Duration(seconds: 1),
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  onPageChanged: (index,reason){
                    setState(() {
                      mycurentindex=index;
                    });
                  }
                ),
            ),
          ],
        ),
      )
    );
  }
}
