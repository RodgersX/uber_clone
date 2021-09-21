import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/Screens/mainscreen.dart';
import 'package:rider_app/Screens/registrationScreen.dart';
import 'package:rider_app/Widgets/progressDialog.dart';
import 'package:rider_app/main.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                'Login as a Rider',
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
                    SizedBox(height: 1),
                    TextFormField(
                      controller: emailController,
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
                      controller: passwordController,
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
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Brand Bold',
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (!emailController.text.contains('@')) {
                          displayToastMessage(
                              'Email format is incorrect', context);
                        } else if (passwordController.text.length < 6) {
                          displayToastMessage(
                              'Password must be 6 or more characters long',
                              context);
                        } else {
                          loginUser(context);
                        }
                      },
                    )
                  ],
                ),
              ),
              // ignore: deprecated_member_use
              FlatButton(
                child: Text('Do not have an account? Register Here'),
                onPressed: () {
                  Navigator.of(context).pushNamed(RegistrationScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ProgressDialog('Authenticating, Please wait...');
        });
    final User firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
            .catchError((errMsg) {
              Navigator.pop(context);
      displayToastMessage('Error: ${errMsg.toString()}', context);
    }))
        .user;

    if (firebaseUser != null) {
      usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
          displayToastMessage('Successfully logged in', context);
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage('No record exists with these details', context);
        }
      });
    } else {
      Navigator.pop(context);
      displayToastMessage('Cannot be signed in', context);
    }
  }
}
