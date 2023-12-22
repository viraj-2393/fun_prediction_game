import 'package:DreamStar/helpers/texthelp.dart';
import 'package:flutter/material.dart';

class DisclaimerWidget extends StatefulWidget {
  @override
  _DisclaimerWidgetState createState() => _DisclaimerWidgetState();
}

class _DisclaimerWidgetState extends State<DisclaimerWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disclaimer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Disclaimer:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(pointAtStake)
            ],
          ),
        ),
      ),
    ); // You can replace this with the actual content of your app.
  }
}

