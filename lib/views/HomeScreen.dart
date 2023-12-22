import 'dart:async';

import 'package:DreamStar/helpers/localCache.dart';
import 'package:DreamStar/helpers/texthelp.dart';
import 'package:DreamStar/views/Disclaimer.dart';
import 'package:DreamStar/views/LoginScreen.dart';
import 'package:DreamStar/views/PrivacyPolicy.dart';
import 'package:DreamStar/views/Rules.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kronos/flutter_kronos.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget{
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  FirebaseDatabase database = FirebaseDatabase.instance;
  var resultOfSlot;
  List<dynamic> shiftedResultOfSlot = [];
  List<dynamic> shiftedResultOfSlotDemo = [
    {
      'red' : 33000,
      'green' : 450
    },
    {
      'red' : 13050,
      'green' : 450
    },
    {
      'red' : 45000,
      'green' : 560
    },
    {
      'red' : 46890,
      'green' : 220
    },
    {
      'red' : 20000,
      'green' : 750
    },

  ];
  String recordSelected = 'Public';
  var dtime;
  late Timer _timer;
  int seconds = 0;
  int minutes = 1;
  int loop = 120;
  String slot = '00:00 to 00:00';
  String stakeOnColor = 'red';
  int multiplier = 1;
  double selectedAmount = 10;
  double currentSlotStake = 0;
  String currentSlotStakeColor = 'red';
  bool tenSelected = true;
  bool hundredSelected = false;
  bool fiveHundredSelected = false;
  bool thousandSelected = false;
  bool tenThousandSelected = false;
  String currentTimeSlot = '';
  bool pointOnStake = false;
  String userBalance = '00';
  bool settlementInitiated = false;
  int redPoint = 0;
  int greenPoint = 0;
  String userStakeColor = "";
  String userStakePoint = "0";
  var slots = [
    {'from' : 0, 'to' : 2},
    {'from' : 2, 'to' : 4},
    {'from' : 4, 'to' : 6},
    {'from' : 6, 'to' : 8},
    {'from' : 8, 'to' : 10},
    {'from' : 10, 'to' : 12},
    {'from' : 12, 'to' : 14},
    {'from' : 14, 'to' : 16},
    {'from' : 16, 'to' : 18},
    {'from' : 18, 'to' : 20},
    {'from' : 20, 'to' : 22},
    {'from' : 22, 'to' : 24},
    {'from' : 24, 'to' : 26},
    {'from' : 26, 'to' : 28},
    {'from' : 28, 'to' : 30},
    {'from' : 30, 'to' : 32},
    {'from' : 32, 'to' : 34},
    {'from' : 34, 'to' : 36},
    {'from' : 36, 'to' : 38},
    {'from' : 38, 'to' : 40},
    {'from' : 40, 'to' : 42},
    {'from' : 42, 'to' : 44},
    {'from' : 44, 'to' : 46},
    {'from' : 46, 'to' : 48},
    {'from' : 48, 'to' : 50},
    {'from' : 50, 'to' : 52},
    {'from' : 52, 'to' : 54},
    {'from' : 54, 'to' : 56},
    {'from' : 56, 'to' : 58},
    {'from' : 58, 'to' : 60},
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterKronos.sync();
    _getNTPTime();
    _getUserBalance();
    _getSlotResults();
  }

  _getSlotResults() async{
    shiftedResultOfSlot.clear();
    try{
      DateTime? todayDate = await FlutterKronos.getDateTime;
      String formattedDate = DateFormat('dd-MM-yyyy').format(todayDate!);
      DatabaseReference result = FirebaseDatabase.instance.ref('date/${formattedDate}/');
      result.get().then((value) => {
        if(value.value != null && value.value != ''){
          resultOfSlot = value.value as Map,
          resultOfSlot.forEach((hour,value){
            value.forEach((slot,value){
              value.forEach((key,value){
                var red = 0;
                var green = 0;
                value.forEach((key,value){
                  if(value['color'] == 'green'){
                    green += int.parse(value['point']);
                  } else{
                    red += int.parse(value['point']);
                  }
                });
                shiftedResultOfSlot.add({
                  'hour': hour,
                  'from':slot.split('-')[0],
                  'to':slot.split('-')[1],
                  'red':red,
                  'green':green
                });
              });
            });
          }),
          setState(() {

          })
        }
      });
    }catch(ex){
      Get.snackbar('Error!', 'Unable to do the action.');
    }
  }

  //get user balance
  _getUserBalance() async{
    try{
      String? uid = await getId();
      DatabaseReference ref = FirebaseDatabase.instance.ref('user/$uid/');
      ref.onValue.listen((event) {
        var map = event.snapshot.value as Map;
        if(mounted){
          setState(() {
            userBalance = map['balance'].toString() ?? '0';
          });
        }
      });

    }catch(ex){
      Get.snackbar('Error!', 'Unable to do the action.');
    }
  }

  //update user stake
  _updateUserStake({
    required String color,
    required String slot,
    required String points
}) async{
    try{
      userStakeColor = color;
      userStakePoint = points;
      DateTime? todayDate = await FlutterKronos.getDateTime;
      String formattedDate = DateFormat('dd-MM-yyyy').format(todayDate!);
      String hour = slot.split(':')[0].padLeft(2,'0');
      String from = slot.split(':')[1].padLeft(2,'0');
      String to = slot.split(':')[2].padLeft(2,'0');
      String formattedSlot = from+'-'+to;
      String? uid = await getId();
      DatabaseReference checkIfPresent = FirebaseDatabase.instance.ref('date/$formattedDate/$hour/$formattedSlot/players/$uid');
      DatabaseReference ref = FirebaseDatabase.instance.ref('date/$formattedDate/$hour/$formattedSlot/players/');
      DatabaseReference balanceRef = FirebaseDatabase.instance.ref('user/$uid/');
      checkIfPresent.once().then((value) => {
        if(value.snapshot.value == null){
            ref.update({
              uid! : {
                'color':color,
                'point':points
              }
            }),
            //update user balance
            balanceRef.update({
              'balance': int.parse(userBalance)-int.parse(points),
            })
        } else{
          Get.snackbar('Oho!', 'Points already at stake. Please wait for next round')
        }
      });
    }catch(ex){
      Get.snackbar('Error!', 'Unable to do the action.');
    }

  }

  _startSettlement() async{
    try{
      DateTime? todayDate = await FlutterKronos.getDateTime;
      String formattedDate = DateFormat('dd-MM-yyyy').format(todayDate!);
      String hour = currentTimeSlot.split(':')[0].padLeft(2,'0');
      String from = currentTimeSlot.split(':')[1].padLeft(2,'0');
      String to = currentTimeSlot.split(':')[2].padLeft(2,'0');
      String formattedSlot = from+'-'+to;
      String? uid = await getId();
      String balanceToUpdate = '0';
      DatabaseReference ref = FirebaseDatabase.instance.ref('date/$formattedDate/$hour/$formattedSlot/players/');
      DatabaseReference balanceRef = FirebaseDatabase.instance.ref('user/$uid/');
      ref.get().then((snapshot) {
        if(snapshot.value != null && snapshot.value != ''){
          var map = snapshot.value as Map;
          map.forEach((key, value) {
            if(value['color'] == 'red'){
              redPoint += int.parse(value['point']);
            }
            if(value['color'] == 'green'){
              greenPoint += int.parse(value['point']);
            }
          });
          //update user balance
          if(redPoint > greenPoint){
            if(userStakeColor == 'red'){
              balanceToUpdate = (int.parse(userBalance)).toString();
            } else{
              balanceToUpdate = (int.parse(userBalance) + (int.parse(userStakePoint)+(int.parse(userStakePoint)-int.parse(userStakePoint)*0.10))).toString();
            }
          }
          if(greenPoint > redPoint){
            if(userStakeColor == 'green'){
              balanceToUpdate = (int.parse(userBalance)).toString();
            } else{
              balanceToUpdate = (int.parse(userBalance) + (int.parse(userStakePoint)+(int.parse(userStakePoint)-int.parse(userStakePoint)*0.10))).toString();
            }
          }
          if(greenPoint == redPoint){
            balanceToUpdate = (int.parse(userBalance) + int.parse(userStakePoint)*0.50).toString();
          }
          balanceRef.update({
            'balance': int.parse(balanceToUpdate.toString()),
          });
          _getSlotResults();
        }
      });


    }catch(ex){
      Get.snackbar('Error!', 'Unable to do the action.');
    }
  }

  String getCurrentTimeSlot(int hour, int minute, int second) {
    if(second >= 0){
      minute = minute + 1;
    }
    for (var slot in slots) {
      if (minute > slot['from']! && minute <= slot['to']!) {
        return "${hour}:${slot['from']}:${slot['to']}";
      }
    }

    return "No matching time slot found";
  }


  _getNTPTime() async{
    try{
      dtime = await FlutterKronos.getDateTime;
      seconds = dtime.minute % 2 != 0 ? dtime.second + 60 : dtime.second;
      seconds = loop - seconds;
      minutes = dtime.minute % 2 != 0 ? 0 : 1;
      slot = '${dtime.hour}:${dtime.minute}';
      // Set up a timer that runs every second
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async{
        _updateTimer();
        _updateUI();
      });

      currentTimeSlot = getCurrentTimeSlot(dtime.hour, dtime.minute, dtime.second);
    }catch(ex){
      Get.snackbar('Error!','It seems that your device time is not correct');
    }
  }

  void _updateTimer() async{
    //seconds--;
    if(seconds == 0){
      loop = 120;
      dtime = await FlutterKronos.getDateTime;
      seconds = dtime.minute % 2 != 0 ? dtime.second + 60 : dtime.second;
      seconds = loop - seconds;
      minutes = dtime.minute % 2 != 0 ? 0 : 1;
      currentTimeSlot = getCurrentTimeSlot(dtime.hour, dtime.minute, dtime.second);
      pointOnStake = false;
      settlementInitiated = false;
      currentSlotStake = 0;
      userStakePoint = "0";
      userStakeColor = "";
      redPoint = 0;
      greenPoint = 0;
    } else {
      seconds--;
      if(seconds <= 3 && settlementInitiated == false){
        settlementInitiated = true;
        _startSettlement();
      }
    }
  }

  void _updateUI() {
    setState(() {
      // Update UI elements here
    });
  }

  Widget _moneyTile({required String color}) {
    return StatefulBuilder(
      builder: (BuildContext context,StateSetter bottomDialogState){
        return Container(
          height: MediaQuery.of(context).size.height*0.5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  color == 'red' ?
                      Container(
                        padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.red
                        ),
                        child: Text('Join Red',style: TextStyle(color: Colors.white),),
                      ):
                      Container(
                        padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.green
                        ),
                        child: Text('Join Green',style: TextStyle(color: Colors.white),),
                      )
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        bottomDialogState(() {
                          tenSelected = true;
                          hundredSelected = false;
                          fiveHundredSelected = false;
                          thousandSelected = false;
                          tenThousandSelected = false;
                          selectedAmount = 10;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: tenSelected ? Color(0xFF7ECAE3):Color(0xFF4A5664)
                        ),
                        child: Center(child: Text('10',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        bottomDialogState(() {
                          tenSelected = false;
                          hundredSelected = true;
                          fiveHundredSelected = false;
                          thousandSelected = false;
                          tenThousandSelected = false;
                          selectedAmount = 100;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: hundredSelected ? Color(0xFF7ECAE3):Color(0xFF4A5664)
                        ),
                        child: Center(child: Text('100',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        bottomDialogState(() {
                          tenSelected = false;
                          hundredSelected = false;
                          fiveHundredSelected = true;
                          thousandSelected = false;
                          tenThousandSelected = false;
                          selectedAmount = 500;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: fiveHundredSelected ? Color(0xFF7ECAE3):Color(0xFF4A5664)
                        ),
                        child: Center(child: Text('500',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: InkWell(
                      onTap: (){bottomDialogState(() {
                        tenSelected = false;
                        hundredSelected = false;
                        fiveHundredSelected = false;
                        thousandSelected = true;
                        tenThousandSelected = false;
                        selectedAmount = 1000;
                      });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: thousandSelected ? Color(0xFF7ECAE3):Color(0xFF4A5664)
                        ),
                        child: Center(child: Text('1000',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: InkWell(
                      onTap: (){bottomDialogState(() {
                        tenSelected = false;
                        hundredSelected = false;
                        fiveHundredSelected = false;
                        thousandSelected = false;
                        tenThousandSelected = true;
                        selectedAmount = 10000;
                      });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: thousandSelected ? Color(0xFF7ECAE3):Color(0xFF4A5664)
                        ),
                        child: Center(child: Text('10000',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10,),
              Container(
                width: double.infinity,
                child: Center(child: Text('X',style: TextStyle(fontSize: 20)),),
              ),
              const SizedBox(height: 10,),
              Container(
                width: double.infinity,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          if(multiplier == 1){
                            return;
                          }
                          bottomDialogState(() {
                            multiplier--;
                          });
                        },
                        child: Container(
                          width: 50,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.withOpacity(0.5),width: 1)
                          ),
                          child: Center(child: Text('-',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Container(
                        width: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.withOpacity(0.5),width: 1)
                        ),
                        child: Center(child: Text('${multiplier}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),),
                      ),
                      const SizedBox(width: 10,),
                      InkWell(
                        onTap: () {
                          bottomDialogState(() {
                            multiplier++;
                          });
                        },
                        child: Container(
                          width: 50,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.withOpacity(0.5),width: 1)
                          ),
                          child: Center(child: Text('+',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Text('Total: ${multiplier * selectedAmount}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: Text('Disclaimer',),
                            content: Container(
                              height: MediaQuery.sizeOf(context).height * 0.6,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(pointAtStake),
                                    const SizedBox(height: 10,),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Ok')
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    );
                  },
                  child: Text("Disclaimer",style: TextStyle(color: Colors.green),)
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        multiplier = 1;
                        selectedAmount = 10;
                        tenSelected = true;
                        hundredSelected = false;
                        fiveHundredSelected = false;
                        thousandSelected = false;
                        tenThousandSelected = false;
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 10,bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xFF4A5664)
                        ),
                        child: Center(
                          child: Text('Cancel',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if(seconds <= 15){
                          Get.snackbar('Please wait!', 'Settlement in progress...');
                          return;
                        }
                        if(int.parse(userBalance) >= (multiplier*selectedAmount).toInt()){
                          if(!pointOnStake){
                            _updateUserStake(
                                color: color,
                                slot: currentTimeSlot,
                                points: (multiplier * selectedAmount).toInt().toString()
                            );
                            currentSlotStake = multiplier * selectedAmount;
                            currentSlotStakeColor = color;
                            multiplier = 1;
                            selectedAmount = 10;
                            tenSelected = true;
                            hundredSelected = false;
                            fiveHundredSelected = false;
                            thousandSelected = false;
                            pointOnStake = true;
                            Navigator.of(context).pop();
                          } else {
                            Get.snackbar('Oho!', 'Points already at stake. Please wait for next round');
                          }
                        } else {
                          Get.snackbar(
                              'Oho!',
                              'Insufficient points.',
                              backgroundColor: Colors.redAccent
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 10,bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xFF4A5664)
                        ),
                        child: Center(
                          child: Text('Confirm',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      drawer:Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF4A5664),
              ),
              child: Center(child: Text('Welcome Champion!',style: TextStyle(color: Colors.white),),),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.note_rounded),
              title: const Text('Disclaimer'),
              onTap: () {
                Get.to(() => DisclaimerWidget());
              },
            ),
            ListTile(
              leading: Icon(Icons.rule_sharp),
              title: const Text('Rules'),
              onTap: () {
                Get.to(() => RulesWidget());
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () {
                Get.to(() => PrivacyPolicyWidget());
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                removeLoggedIn();
                removeId();
                Get.offAll(() => LoginScreen());
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A5664),
        title: Transform.translate(
            offset: Offset(-20.0, 0.0),
            child: Text('Home',style: TextStyle(color: Colors.white),) // here you can put the search bar
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF7ECAE3),
                borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Balance: ${userBalance}',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
                  const SizedBox(height: 5,),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  title: Text('Rule',),
                                  content: Container(
                                    height: MediaQuery.sizeOf(context).height * 0.6,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Text(gameplay),
                                          const SizedBox(height: 10,),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Ok')
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xFF4A5664)
                          ),
                          child: Text('Read Rule',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      InkWell(
                        onTap: () {

                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xFF4A5664)
                          ),
                          child: Text('Graph Trend',style: TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            currentTimeSlot != '' ?
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10),
                  width: 180,
                  padding: EdgeInsets.only(top: 4,bottom: 4,left: 10,right: 10),
                  decoration: BoxDecoration(
                      color: Color(0xFF4A5664),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timelapse,color: Colors.white,),
                      const SizedBox(width: 5,),
                      Text(
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          int.parse(currentTimeSlot.split(':')[0]),
                          int.parse(currentTimeSlot.split(':')[1]),
                        ).millisecondsSinceEpoch.toString().substring(0,9)
                        ,style: TextStyle(color: Colors.white,fontSize: 20),)
                    ],
                  ),
                ),
                Expanded(child: Container(),),
                pointOnStake?
                Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.only(top: 4,bottom: 4,left: 10,right: 10),
                  decoration: BoxDecoration(
                      color: currentSlotStakeColor == 'red' ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${currentSlotStake}',style: TextStyle(color: Colors.white),)
                    ],
                  ),
                ):Container(),
              ],
            ):Container(),
            dtime != null ?
            Text('${seconds}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 60),):
            Text('00:00',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 60)),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: seconds <= 15 ? Colors.grey : Colors.red
                          ),
                          child: Center(
                            child: Text('Join Red',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context){
                                  return _moneyTile(color: 'red');
                                }
                            );
                          },
                          child: Icon(Icons.add_circle_outline_rounded,color: Colors.red,size: 40,),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 50,),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: seconds <= 15 ? Colors.grey : Colors.green
                          ),
                          child: Center(
                            child: Text('Join Green',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context){
                                  return _moneyTile(color: 'green');
                                }
                            );
                          },
                          child: Icon(Icons.add_circle_outline_rounded,color: Colors.green,size: 40,),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                  decoration: BoxDecoration(
                      color: recordSelected == 'Public' ? Color(0xFF4A5664) : Colors.grey,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text('Public',style: TextStyle(color: Colors.white),),
                ),
                const SizedBox(width: 10,),
                Image.asset('assets/images/trophy.png',height: 30,),
                Text('Record',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                const SizedBox(width: 10,),
                Container(
                  padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                  decoration: BoxDecoration(
                    color: recordSelected == 'Private' ? Color(0xFF4A5664) : Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text('Private',style: TextStyle(color: Colors.white),),
                )
              ],
            ),
            Container(
              height: 5,
              width: double.infinity,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF4A5664)
              ),
            ),
            Row(
              children: [
                Expanded(child: Text('Period',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),),
                Expanded(child: Text('Period Pool',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),),
                Expanded(child: Text('Result',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),),
              ],
            ),
            shiftedResultOfSlot.isNotEmpty ?
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...List.generate(shiftedResultOfSlot.length, (index) {
                          return Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                      DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          int.parse(shiftedResultOfSlot[index]['hour']),
                                          int.parse(shiftedResultOfSlot[index]['from']),
                                      ).millisecondsSinceEpoch.toString().substring(0,9)
                                    ,textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(((shiftedResultOfSlot[index]['red']+shiftedResultOfSlot[index]['green'])*5).toString(),textAlign: TextAlign.center,),
                                ),
                                shiftedResultOfSlot[index]['red'] == shiftedResultOfSlot[index]['green']?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle
                                          ),
                                        ),
                                        Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle
                                          ),
                                        )
                                      ],
                                    ):
                                Expanded(
                                  child: Container(
                                    height: 15,
                                    child: Center(
                                      child: shiftedResultOfSlot[index]['red'] > shiftedResultOfSlot[index]['green']?
                                      Container(
                                        height: 15,
                                        width: 15,
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle
                                        ),
                                      ):Container(
                                        height: 15,
                                        width: 15,
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                ):
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...List.generate(shiftedResultOfSlotDemo.length, (index) {
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day
                                ).millisecondsSinceEpoch.toString().substring(0,9)
                                ,textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(((shiftedResultOfSlotDemo[index]['red']+shiftedResultOfSlotDemo[index]['green'])*500).toString(),textAlign: TextAlign.center,),
                            ),
                            Expanded(
                              child: Container(
                                height: 15,
                                child: Center(
                                  child: Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                        color: shiftedResultOfSlotDemo[index]['red'] > shiftedResultOfSlotDemo[index]['green'] ? Colors.green:Colors.red,
                                        shape: BoxShape.circle
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}