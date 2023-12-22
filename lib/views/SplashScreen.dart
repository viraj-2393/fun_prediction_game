import 'dart:async';
import 'package:DreamStar/helpers/localCache.dart';
import 'package:DreamStar/views/LoginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'HomeScreen.dart';

class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      getLoggedIn().then((value) => {
        if(value != null && value){
          Get.offAll(() => HomeScreen())
        } else{
          Get.offAll(() => LoginScreen())
      }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/dstar.jpg',
                height: 100,
                width: 100,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              'DreamStar: A Fantasy Game',
              style: TextStyle(
                  fontSize: 20
              ),
            ),
            const SizedBox(height: 30,),
            CupertinoActivityIndicator(),
            Spacer(),
            Text('v1.0'),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}