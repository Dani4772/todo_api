import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Reset extends StatefulWidget {
  const Reset({Key? key}) : super(key: key);

  @override
  _ResetState createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  @override
  Widget build(BuildContext context) {
    var email = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password'),),
      body: Column(
        children: [
          SizedBox(height: 160),
      Padding(

        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Email',
              hintText: 'Enter valid email id as abc@gmail.com'),
          controller: email,
        ),
      ),
          SizedBox(height: 30),
          Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(20)),
            child: TextButton(
              onPressed: () async{
                try{
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email.text,
                  );
                }
                on FirebaseAuthException catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!)));
                }

              },
              child: Text(
                'Reset',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
