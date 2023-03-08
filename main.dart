import 'package:flutter/material.dart';
import 'package:requests/requests.dart';
import 'dart:io';

// => ; // only if function has one expression
// ? https://
String url = "https://api.api-ninjas.com/v1/nutrition?query=";
Future<void> sendMessage(Socket socket, String message) async {
  print('Client: $message');
  socket.write(message);
  await Future.delayed(Duration(seconds: 2));
}

class Activities extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ActivitiesState();
  }
}

class ActivitiesState extends State<Activities> {
    late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Activity Prompt", textAlign: TextAlign.center),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: "Enter Activity Prompt"),
            controller: controller,
          ),
          actions: [TextButton(onPressed: submit, child: Text("SUBMIT"))],
        ),
      );

  void submit() {
    Navigator.of(context).pop(controller.text);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            FloatingActionButton(onPressed: null, child: Text(0.toString())),
        actions: [
          FloatingActionButton(onPressed: null, child: Text(0.toString())),
        ],
        centerTitle: true,
        title: Text(
          'CaloCalc',
          style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
            child: Text('+', style: TextStyle(fontSize: 40.0)),
            onPressed: () async {
              final active = await openDialog();
            }),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  int cal = 0;
  int prot = 0;
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Meal Prompt", textAlign: TextAlign.center),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: "Enter Meal Prompt"),
            controller: controller,
          ),
          actions: [TextButton(onPressed: submit, child: Text("SUBMIT"))],
        ),
      );

  void submit() {
    Navigator.of(context).pop(controller.text);
  }

  String checktime() {
    String time = "Evening";
    final now = DateTime.now();
    if (now.hour > 0 && now.hour < 12) {
      time = "Morning";
      return time;
    }
    if (now.hour > 12 && now.hour < 18) {
      time = "Afternoon";
      return time;
    }
    return time;
  }

  void checkCalAndProt() {
    final now = DateTime.now();
    if (now.hour == 0) {
      cal = 0;
      prot = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    checkCalAndProt();
    return Scaffold(
      appBar: AppBar(
        leading:
            FloatingActionButton(onPressed: null, child: Text(cal.toString())),
        actions: [
          FloatingActionButton(onPressed: null, child: Text(prot.toString())),
        ],
        centerTitle: true,
        title: Text(
          'CaloCalc',
          style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Row(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: ElevatedButton(
              onPressed: null,
              child: Text(
                "Morning",
                style: TextStyle(color: Colors.blue, fontSize: 20.0),
              ),
            ),
          ),
          SizedBox(width: 25),
          Align(
            alignment: Alignment.topCenter,
            child: ElevatedButton(
              onPressed: null,
              child: Text(
                "Afternoon",
                style: TextStyle(color: Colors.blue, fontSize: 20.0),
              ),
            ),
          ),
          SizedBox(width: 25),
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              onPressed: null,
              child: Text(
                "Evening",
                style: TextStyle(color: Colors.blue, fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
            child: Text('+', style: TextStyle(fontSize: 40.0)),
            onPressed: () async {
              final mealPrompt = await openDialog();
              var list = mealPrompt.split("and");
              for (int i = 0; i < list.length; i++) {
                var item = list[i];
                String prompt = url + item;
                var r = await Requests.get(prompt, headers: <String, String>{
                  'X-Api-Key': 'FJnvyvhmnBeRNhDaNq9/QQ==DudESE1KlDAfjt1h'
                });
                String body = r.content();
                //print(body.toString());
                var nameStart = body.indexOf("name");
                var nameEnd = nameStart + 4;
                var calStart = body.indexOf("calories");
                var calEnd = calStart + 8;
                var protStart = body.indexOf("protein_g");
                var protEnd = protStart + 9;
                var nameStr =
                    body.substring(nameEnd + 4, find(nameEnd + 4, body, '"'));
                var calStr =
                    body.substring(calEnd + 3, find(calEnd + 3, body, ','));
                var protStr =
                    body.substring(protEnd + 3, find(protEnd + 3, body, ','));
                String name = body.substring(nameStart, nameEnd);
                String calo = body.substring(calStart, calEnd);
                String pro = body.substring(protStart, protEnd);
                print(nameStr);
                print(calStr);
                print(protStr);
                var newCal = cal + double.parse(calStr);
                var newProt = prot + double.parse(protStr);
                //showcal(Text(newCal.toString()));
                //showprot(Text(newProt.toString()));
              }
            }),
      ),
    );
  }

  int find(int start, String str, String action) {
    int i = start;
    while (str[i] != action) {
      i++;
    }
    return i;
  }
}

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CaloCalc',
          style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 120,
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter valid username id'),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            SizedBox(
              height: 45,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Register()));
              },
              child: Text(
                'Register',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            SizedBox(
              height: 45,
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: ElevatedButton(
                onPressed: () {
                  //first check if has login then confirm
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => BottomNavi()));
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Register extends StatefulWidget {
  @override
  RegState createState() => RegState();
}

class RegState extends State<Register> {
  final control = TextEditingController();
  final ctrl = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    control.dispose();
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CaloCalc',
          style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 120,
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter valid username id'),
                controller: control,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            SizedBox(
              height: 45,
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Login()));
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavi extends StatefulWidget {
  @override
  NaviState createState() => NaviState();
}

class NaviState extends State<BottomNavi> {
  List _pages = [MyApp(), Activities()];
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Main'),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Activities',
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ));
  }
}
/*String path = r"C:\Project\files\first_app\lib\user.db";
                Database database = await openDatabase(path, version: 1,
                    onCreate: (Database db, int version) async {
                  // When creating the db, create the table
                  await db.execute(
                      'CREATE TABLE IF NOT EXISTS data (username TEXT PRIMARY KEY NOT NULL, password TEXT NOT NULL, calgoal INTEGER, protgoal INTEGER, hashname TEXT)');
                });
                await database.transaction((txn) async {
                  int id1 = await txn.rawInsert(
                      'INSERT INTO data(name, password) VALUES(?,?,?,?,?)', [
                    Text(control.text),
                    Text(ctrl.text),
                    0,
                    0,
                    md5.convert(utf8.encode(control.text)).toString(),
                  ]);
                });*/