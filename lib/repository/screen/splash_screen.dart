import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/common/color/colors.dart';
import 'package:money_tracker/feature/home/pages/home_page.dart';

import 'package:shared_preferences/shared_preferences.dart';


import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  static const String KEYLOGIN = "Login";
  Timer? _periodicTimer;
  int index =0;
  @override
  void initState() {
    super.initState();

    _periodicTimer = Timer.periodic(const Duration(milliseconds: 300), (Timer timer) {
      if(mounted){
        setState(() {
          index++;
        });
      }
    });
    whereToGo();

  }

  @override
  void dispose() {
    _periodicTimer?.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Coloors.blueLight,Coloors.blueDark,Coloors.blueLight2
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(29),
                      color: Coloors.blueDark.withOpacity(0.2),
                    ),
                    child: Image.asset('assets/images/wallet.png',fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,),),
                  const SizedBox(height: 16),
                  const Text(
                    "Money Manage - Balance Budget",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SpinKitThreeBounce( // Change to SpinKitThreeBounce
                    color: index.isEven ? Coloors.blueLight2 : Coloors.blueDark,
                    size: 50.0,

                  ),

                ],
              ),
            ),
          ),
        ]
      ),

    );
  }

  void whereToGo() async{
    var sharedPred = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPred.getBool(KEYLOGIN);
    Timer(const Duration(seconds: 2),(){
      if (!mounted) return;
      if(isLoggedIn!=null){
        if(isLoggedIn){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const HomePage()));
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginScreen()));
        }
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginScreen()));
      }

    });
  }
}
