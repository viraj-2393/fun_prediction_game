import 'package:DreamStar/helpers/texthelp.dart';
import 'package:flutter/material.dart';

class RulesWidget extends StatefulWidget {
  @override
  _RulesWidgetState createState() => _RulesWidgetState();
}

class _RulesWidgetState extends State<RulesWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rules'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rules:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(gameplay)
            ],
          ),
        ),
      ),
    ); // You can replace this with the actual content of your app.
  }
}

