import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/Custom_buttom.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: KinputDecoration.copyWith(hintText: 'Enter Your Username') ,
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration:KinputDecoration.copyWith(hintText: 'Enter Your Password')  ,
              ),
              SizedBox(
                height: 24.0,
              ),
          CustomButton(color:Colors.lightBlueAccent,text: 'Login',onPressed: () async{
             setState(() {
               loading =true;
             });
            try{
            var user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                if(user!= null) {
                  Navigator.pushNamed(context, ChatScreen.id);
                }
                   setState(() {
                     loading =false;
                        });
             }
            catch(e){
               print(e);}

               },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
