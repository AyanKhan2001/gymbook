import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClockInOutScreen extends StatefulWidget {
  @override
  _ClockInOutScreenState createState() => _ClockInOutScreenState();
}

class _ClockInOutScreenState extends State<ClockInOutScreen> {
  bool clockedIn = false;
  late DateTime clockInTime = DateTime.now();
  late DateTime clockOutTime = DateTime.now();
  List<Map<String, dynamic>> sessionDurations = [];
  late Timer _timer;
  int _secondsElapsed = 0;
  int pointsEarned = 0;

  late String deviceId;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (clockedIn) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _loadDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deviceId = prefs.getString('deviceId') ?? UniqueKey().toString();
      prefs.setString('deviceId', deviceId);
    });
  }

  void clockIn() {
    setState(() {
      clockedIn = true;
      clockInTime = DateTime.now();
      _secondsElapsed = 0;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (clockedIn) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void clockOut() {
    setState(() {
      clockedIn = false;
      clockOutTime = DateTime.now();
      int durationInSeconds = clockOutTime.difference(clockInTime).inSeconds;
      sessionDurations.add({
        'duration': clockOutTime.difference(clockInTime),
        'seconds': durationInSeconds,
      });
      pointsEarned += 25;
    });

    _timer.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have earned 25 points.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void resetDurations() {
    setState(() {
      sessionDurations.clear();
    });
  }

  void buySubscription() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Premium Subscription'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://storage.pixteller.com/designs/designs-images/2020-12-21/04/gym-membership-sale-banner-1-5fe0b55eb1aa5.png',
                height: 250,
                width: 300,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text('Would you like to buy the Premium Subscription for 100 points?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deductPoints(context, 100);
              },
              child: Text('Buy Subscription'),
            ),
          ],
        );
      },
    );
  }

  void deductPoints(BuildContext context, int pointsToDeduct) {
    setState(() {
      if (pointsEarned >= pointsToDeduct) {
        pointsEarned -= pointsToDeduct;
        showDeductedPointsDialog(pointsToDeduct);
      } else {
        showInsufficientPointsDialog(context);
      }
    });
  }

  void showDeductedPointsDialog(int pointsToDeduct) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Points Deducted'),
          content: Text('You have successfully deducted $pointsToDeduct points.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showInsufficientPointsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Insufficient Points'),
          content: Text('You do not have enough points to perform this action.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String formatDuration(Duration duration) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  String formatTimer(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds ~/ 60) % 60;
    int remainingSeconds = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Center(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/images/logo.png', width: 100, height: 100, fit: BoxFit.cover,),
                ),
                Text(
                  'GYM Booking',
                  style: GoogleFonts.getFont('Poppins', fontSize: 40, color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 150,
            child: PageView(
              children: [
                Image.asset('assets/images/ss1.jpeg', width: 100, height: 100, fit: BoxFit.cover,),
                Image.asset('assets/images/ss2.jpg', width: 100, height: 100, fit: BoxFit.cover),
                Image.asset('assets/images/ss3.jpg', width: 100, height: 100, fit: BoxFit.cover,),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Text(
              'Timer: ${formatTimer(_secondsElapsed)}',
              style: TextStyle(fontSize: 36, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: clockedIn ? clockOut : clockIn,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      clockedIn ? Colors.red : Colors.green,
                    ),
                    minimumSize: MaterialStateProperty.all(Size(120, 50)),
                  ),
                  child: Text(clockedIn ? 'Clock Out' : 'Clock In', style: TextStyle(fontSize: 20)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.money, color: Colors.black, size: 38,),
                      SizedBox(width: 10),
                      Text(
                        '$pointsEarned',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: sessionDurations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'Session ${index + 1}: ${formatDuration(sessionDurations[index]['duration'])} (${sessionDurations[index]['seconds']} seconds)',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: resetDurations,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                    minimumSize: MaterialStateProperty.all(Size(120, 50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Reset Durations', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: buySubscription,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    minimumSize: MaterialStateProperty.all(Size(120, 50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.subscriptions, color: Colors.black,),
                      SizedBox(width: 8),
                      Text('Buy Subscriptions', style: TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
