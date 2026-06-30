import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_a1_game/username_screen.dart';

class HomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('French dessert collector',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 28
            ),),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => UsernameScreen(),),);
            }, child: Text('Game Start',
            style: TextStyle(fontSize: 24),
            ),
            )
          ],
        )
      )
    );
  }
}