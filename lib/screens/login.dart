import 'package:capstone/screens/app.dart';
import 'package:capstone/providers/firebase_provider.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() {
    return _LoginState();
  }
}

//overall needs more error checking / alerts for improper submission
class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
  }

  //used to update after keystroke
  final passwordContrl = TextEditingController();
  final emailContrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: (Align(
          alignment: Alignment.center,
          child: Container(
              height: 400,
              width: 400,
              decoration: BoxDecoration(
                color: Colors.blue[400]!.withOpacity(0.8),
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Column(children: [
                const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: TextFormField(
                      controller: emailContrl,
                      decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter Email",
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(width: 2, color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(width: 5, color: Colors.black)),
                          contentPadding: EdgeInsets.all(20.0)),
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: TextFormField(
                      controller: passwordContrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter Password",
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(width: 2, color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(width: 5, color: Colors.black)),
                          contentPadding: EdgeInsets.all(20.0)),
                    )),
                SizedBox(
                    //padding: const EdgeInsets.all(20),
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        String? valid = await login(emailContrl.text, passwordContrl.text);
                        if (valid == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CapstoneHomePage(),
                            ),
                          );
                        } else {
                          print(valid);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text("Login"),
                      ),
                    )),
                TextButton(
                  style: TextButton.styleFrom(primary: Colors.white),
                  child: const Text(
                    "Need Account? Click to register",
                  ),
                  onPressed: () async {
                    String? valid = await register(emailContrl.text, passwordContrl.text);
                    if (valid == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CapstoneHomePage(),
                        ),
                      );
                    }
                  },
                )
              ])))),
    ));
  }
}
