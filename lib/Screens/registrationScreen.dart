import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/Screens/loginScreen.dart';
import 'package:rider_app/Screens/mainscreen.dart';
import 'package:rider_app/Widgets/progressDialog.dart';
import 'package:rider_app/main.dart';

// ignore: must_be_immutable
class RegistrationScreen extends StatelessWidget {
  static const String routeName = '/register';

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController phoneEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image(
                image: AssetImage('images/logo.png'),
                width: 390,
                height: 250,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 1),
              Text(
                'Register as a Rider',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Brand Bold',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 1),
                    TextFormField(
                      controller: nameEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 1),
                    TextFormField(
                      controller: emailEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 1),
                    TextFormField(
                      controller: phoneEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 1),
                    TextFormField(
                      controller: passwordEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    // ignore: deprecated_member_use
                    RaisedButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24),
                      ),
                      color: Colors.yellow,
                      textColor: Colors.white,
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Brand Bold',
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (nameEditingController.text.length < 3) {
                          displayToastMessage(
                              'Name must be at least 3 characters', context);
                        } else if (!emailEditingController.text.contains('@')) {
                          displayToastMessage(
                              'Email format is incorrect', context);
                        } else if (phoneEditingController.text.isEmpty) {
                          displayToastMessage(
                              'Phone number is mandatory', context);
                        } else if (passwordEditingController.text.length < 6) {
                          displayToastMessage(
                              'Password must be 6 or more characters long',
                              context);
                        } else {
                          registerNewUser(context);
                        }
                      },
                    )
                  ],
                ),
              ),
              // ignore: deprecated_member_use
              FlatButton(
                child: Text('Already have an account? Login Here'),
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(LoginScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ProgressDialog('Creating account, Please wait...');
        });
    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
      email: emailEditingController.text,
      password: passwordEditingController.text,
    )
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage('Error: ${errMsg.toString()}', context);
    }))
        .user;

    if (firebaseUser != null) {
      Map userDataMap = {
        'name': nameEditingController.text.trim(),
        'email': emailEditingController.text.trim(),
        'phone': phoneEditingController.text.trim(),
        // 'password': passwordEditingController,
      };
      usersRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMessage('Congratulations! Account created', context);
      Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
    } else {
      Navigator.pop(context);
      displayToastMessage('Account not created', context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
