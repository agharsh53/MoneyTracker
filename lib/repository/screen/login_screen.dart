import 'package:flutter/material.dart';
import 'package:money_tracker/feature/home/pages/home_page.dart';
import 'package:money_tracker/common/color/colors.dart';
import 'package:money_tracker/feature/widgets/pages/transaction_detail.dart';
import 'package:money_tracker/repository/screen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var signInKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  void SignedInSubmit() async {
    final isValid = signInKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    signInKey.currentState!.save();
    //If Successfully logged In (Credential are correct)
    var sharedPref = await SharedPreferences.getInstance();
    sharedPref.setBool(SplashScreenState.KEYLOGIN, true);
    sharedPref.setStringList('userDetails', [nameController.text.toString(),emailController.text.toString()]);
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Coloors.blueDark,
                        Coloors.blueLight2,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/wallet.png",
                                width: media.width * 0.15,
                                fit: BoxFit.contain),
                            SizedBox(width: 10),
                            Text('Money Tracker',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Coloors.backgroundLight))
                          ],
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Form(
                              key: signInKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  TextFormField(
                                    controller: nameController,
                                    keyboardType: TextInputType.name,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Please enter your name";
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                      hintText: "Your Name",
                                      prefixIcon: Icon(Icons.person),
                                      hintStyle:
                                      TextStyle(fontWeight: FontWeight.w300),
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.red)),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value!.isEmpty ||
                                          !RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                              .hasMatch(value)) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email),
                                      hintText: 'Enter email',
                                      hintStyle:
                                      TextStyle(fontWeight: FontWeight.w300),
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.red)),
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  TextFormField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.visiblePassword,
                                    validator: (value) {
                                      RegExp regex = RegExp(
                                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                                      if (value!.isEmpty) {
                                        return 'Please enter password';
                                      } else {
                                        if (value.length < 6) {
                                          return 'Enter valid password';
                                        } else {
                                          return null;
                                        }
                                      }
                                    },
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icon(Icons.lock),
                                      hintText: 'Enter Password',
                                      hintStyle:
                                      TextStyle(fontWeight: FontWeight.w300),
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.red)),
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        // Handle forgot password
                                      },
                                      child: Text('Forgot password?'),
                                    ),
                                  ),
                                  SizedBox(height: 24.0),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF4FC3F7),
                                          Color(0xFFCE93D8),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: TextButton(
                                      onPressed: () => SignedInSubmit(),
                                      child: Text(
                                        'LOGIN',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.0),
                                  Text('Or Sign Up Using'),
                                  SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        onPressed: () {
                                          // Handle Facebook login
                                        },
                                        icon: Image.asset(
                                            'assets/images/facebook_icon.png',
                                            width: 30,
                                            height: 30),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Handle Google login
                                        },
                                        icon: Image.asset(
                                            'assets/images/google_icon.png',
                                            width: 30,
                                            height: 30),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Handle Twitter login
                                        },
                                        icon: Image.asset(
                                            'assets/images/twitter_icon.png',
                                            width: 30,
                                            height: 30),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}