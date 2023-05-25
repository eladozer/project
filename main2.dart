import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts;
import 'handle_csv.dart' as cs;

String url = "https://api.api-ninjas.com/v1/nutrition?query=";
var key = "Key1986";

String xor_dec_enc(String text) {
  List<int> encrypted = [];
  for (int i = 0; i < text.length; i++) {
    int charCode = text.codeUnitAt(i) ^ key.codeUnitAt(i % key.length);
    encrypted.add(charCode);
  }
  return String.fromCharCodes(encrypted);
}

class FoodData extends StatefulWidget {
  User u1 = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  FoodData(User un) {
    u1 = un;
  }
  @override
  State<StatefulWidget> createState() {
    return FoodDataState();
  }
}

class FoodDataState extends State<FoodData> {
  var _activeChannel;
  User user = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  @override
  void initState() {
    super.initState();
    user = widget.u1;
    print("Entered Food Data");
  }

  @override
  void dispose() {
    super.dispose();
    print("Exited Food Data");
  }

  @override
  Widget build(BuildContext context) {
    var data = user.food_data;
    List dat = data.split("/");
    List dat2 = [];
    for (int i = 0; i < dat.length; i++) {
      if (dat[i] != "") {
        var changed = dat[i].split("+");
        dat2.add([changed[0], changed[1], changed[2], changed[3]]);
      }
    }
    print(dat2);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CaloCalc - Food Data',
          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Table(
        columnWidths: {
          0: FractionColumnWidth(0.25),
          1: FractionColumnWidth(0.25),
          2: FractionColumnWidth(0.25),
          3: FractionColumnWidth(0.25),
        },
        border: TableBorder.all(
          color: Colors.black,
          width: 3.0,
          style: BorderStyle.solid,
        ),
        children: [
          TableRow(
            children: [
              TableCell(
                child: Text(
                  'Date',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TableCell(
                child: Text(
                  'Cal Goal',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TableCell(
                child: Text(
                  'Prot Goal',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TableCell(
                child: Text(
                  'Burn Goal',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          ...List<TableRow>.generate(
            dat2.length,
            (index) => TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      dat2[index][0],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      dat2[index][1],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      dat2[index][2],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      dat2[index][3],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  User u1 = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  MyApp(User un) {
    u1 = un;
  }
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  var _mainChannel;
  var mealChannel;
  var meal_data;
  final control = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = widget.u1;
    print("Entered Main");
  }

  @override
  void dispose() {
    control.dispose();
    super.dispose();
    print("Exited Main");
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Meal Prompt",
            textAlign: TextAlign.center,
          ),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter Meal: (weight) + (type food)",
            ),
            controller: control,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, control.text);
              },
              child: Text("SUBMIT"),
            ),
          ],
        ),
      );

  void _incrementCal(int ca) {
    setState(
      () {
        user.current_cal = ca;
      },
    );
  }

  void _incrementProt(int pro) {
    setState(
      () {
        user.current_prot = pro;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    meal_data = user.meal_data;
    List meals = [];
    for (int i = 0; i < meal_data.length; i++) {
      meals.add(meal_data[i]);
    }
    return Scaffold(
      appBar: AppBar(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 45,
              width: 45,
              child: CircularProgressIndicator(
                value: user.current_cal / user.cal,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            Text(
              'Calories',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 45,
                width: 45,
                child: CircularProgressIndicator(
                  value: user.current_prot / user.prot,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                'Proteins',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
        centerTitle: true,
        title: Text(
          'CaloCalc',
          style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Table(
        columnWidths: {
          0: FractionColumnWidth(0.2),
          1: FractionColumnWidth(0.3),
          2: FractionColumnWidth(0.2),
          3: FractionColumnWidth(0.3),
        },
        border: TableBorder.all(
          color: Colors.black,
          width: 3.0,
          style: BorderStyle.solid,
        ),
        children: [
          TableRow(
            children: [
              TableCell(
                child: Text(
                  'Time',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TableCell(
                child: Text(
                  'Meal Name',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TableCell(
                child: Text(
                  'Calories',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TableCell(
                child: Text(
                  'Proteins',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          ...List<TableRow>.generate(
            meals.length,
            (index) {
              if (meals[index].isNotEmpty) {
                return TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          meals[index].split("-")[0].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          meals[index].split("-")[1].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          meals[index].split("-")[2].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          meals[index].split("-")[3].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          meals[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          meals[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          meals[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          meals[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          )
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          child: Text('+', style: TextStyle(fontSize: 40.0)),
          onPressed: () async {
            var mealPrompt = await openDialog();
            if (mealPrompt == null) {
              return;
            } else {
              var list;
              if (mealPrompt == null) {
                list = [];
              } else {
                list = mealPrompt.split("and");
              }
              for (int i = 0; i < list.length; i++) {
                mealChannel = IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                var item = list[i];
                String prompt = url + item;
                var sub1;
                mealChannel.sink.add(
                    xor_dec_enc("Food," + user.name + "," + prompt.toString()));
                sub1 = mealChannel.stream.listen(
                  (msg) {
                    print("Message Recieved: $msg");
                    String body = xor_dec_enc(msg);
                    var nameStart = body.indexOf("name");
                    var nameEnd = nameStart + 4;
                    var calStart = body.indexOf("calories");
                    var calEnd = calStart + 8;
                    var protStart = body.indexOf("protein_g");
                    var protEnd = protStart + 9;
                    var nameStr = body.substring(
                        nameEnd + 4, find(nameEnd + 4, body, '"'));
                    var calStr =
                        body.substring(calEnd + 3, find(calEnd + 3, body, ','));
                    var protStr = body.substring(
                        protEnd + 3, find(protEnd + 3, body, ','));
                    print(nameStr + ": " + calStr + "," + protStr);
                    var newCal =
                        double.parse(calStr).toInt() + user.current_cal;
                    var newProt =
                        double.parse(protStr).toInt() + user.current_prot;
                    var sub;
                    String message = "Update Food," +
                        user.name +
                        "," +
                        newCal.toString() +
                        "," +
                        newProt.toString();
                    _mainChannel =
                        IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                    _mainChannel.sink.add(xor_dec_enc(message));
                    sub = _mainChannel.stream.listen(
                      (msg) {
                        print("Recieved Message:${xor_dec_enc(msg)}");
                        sub.cancel();
                      },
                    );
                    _mainChannel.sink.close();
                    _incrementCal(newCal);
                    _incrementProt(newProt);
                    sub1.cancel();
                    mealChannel.sink.close();
                    var time = (DateTime.now().hour + 3).toString() +
                        ":" +
                        DateTime.now().minute.toString() +
                        ":" +
                        DateTime.now().second.toString() +
                        ":" +
                        DateTime.now().millisecond.toString();
                    user.meal_data.add(time.toString() +
                        "-" +
                        nameStr +
                        "-" +
                        calStr +
                        "-" +
                        protStr);
                  },
                );
              }
              List weight_data_split = user.weight_data.split("/");
              for (int j = 0; j < list.length; j++) {
                List dat = list[j].split(" ");
                var weight = dat[0];
                if (dat[0] == "") weight = dat[1];
                var weit;
                String numericString = weight.replaceAll(RegExp('[^0-9]'), '');
                String nonNumericString = weight.replaceAll(
                    RegExp(r'[^a-zA-Z]'), ''); // extracts non-numbers
                print(nonNumericString);
                if (nonNumericString == "gr") {
                  weit = double.parse(numericString) / 1000;
                } else if (nonNumericString == "kg") {
                  weit = double.parse(numericString);
                } else {
                  weit = double.parse(numericString) / 2.20462262;
                }
                user.set_weight(weit);
              }
              weight_data_split[0] += "-" + user.weight.toString();
              weight_data_split[1] += "+" + DateTime.now().toString();
              user.set_weight_data(weight_data_split.join("/"));
              var _weightChan =
                  IOWebSocketChannel.connect("ws://10.0.0.8:8820");
              String message =
                  "Update Weight," + user.name + "," + user.weight.toString();
              _weightChan.sink.add(xor_dec_enc(message));
              var sub;
              sub = _weightChan.stream.listen(
                (msg) {
                  print("Recieved Message:${xor_dec_enc(msg)}");
                  sub.cancel();
                },
              );
              _weightChan.sink.close();
            }
          },
        ),
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
  var _LogChannel;
  final control = TextEditingController();
  final ctrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    print("Entered Login");
  }

  @override
  void dispose() {
    control.dispose();
    ctrl.dispose();
    super.dispose();
    print("Login Finished");
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
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
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
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
                controller: ctrl,
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
                  _LogChannel =
                      IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                  var sub;
                  String message = "Login,${control.text},${ctrl.text}";
                  _LogChannel.sink.add(xor_dec_enc(message));
                  sub = _LogChannel.stream.listen(
                    (msg) {
                      print("Message Received: ${xor_dec_enc(msg)}");
                      var params = xor_dec_enc(msg).split(",");
                      if (params[0] == control.text) {
                        print("Has Login");
                        sub.cancel();
                        var data =
                            params[6].toString() + "/" + params[7].toString();
                        User u1 = User(
                            control.text,
                            double.parse(params[1]),
                            int.parse(params[2]),
                            int.parse(params[3]),
                            int.parse(params[4]),
                            int.parse(params[5]),
                            data,
                            params[9].toString(),
                            params[10].toString(),
                            params[13].toString(),
                            int.parse(params[12]),
                            int.parse(params[11]),
                            int.parse(params[14]),
                            int.parse(params[15]),
                            int.parse(params[16]),
                            int.parse(params[17]));
                        _LogChannel.sink.close();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    BottomNavi(u1),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      } else {
                        setState(
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Message: ${xor_dec_enc(msg)}'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                        );
                      }
                      _LogChannel.sink.close();
                    },
                  );
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
  var _regChannel;
  final control = TextEditingController();
  final ctrl = TextEditingController();
  final cntl = TextEditingController();
  final control2 = TextEditingController();
  final ctrl2 = TextEditingController();
  final ctrl1 = TextEditingController();
  @override
  void initState() {
    super.initState();
    print("Entered Register");
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    control.dispose();
    ctrl.dispose();
    control2.dispose();
    ctrl2.dispose();
    ctrl1.dispose();
    cntl.dispose();
    super.dispose();
    print("Register Finished");
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
              height: 75,
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
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
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
                controller: ctrl,
              ),
            ),
            SizedBox(
              height: 17,
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Weight',
                    hintText: 'Enter weight in kilograms'),
                controller: cntl,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Calorie',
                    hintText: 'Enter first calorie goal'),
                controller: control2,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Protein',
                    hintText: 'Enter first protein goal'),
                controller: ctrl2,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                ],
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Burned',
                    hintText: 'Enter first Calories Burned goal'),
                controller: ctrl1,
              ),
            ),
            SizedBox(
              height: 45,
            ),
            ElevatedButton(
              onPressed: () {
                var channel = IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                String msg = "In User,${control.text}";
                channel.sink.add(xor_dec_enc(msg));
                channel.stream.listen(
                  (message1) {
                    String msg = xor_dec_enc(message1);
                    print(msg);
                    if (msg == "False") {
                      if (!isNumeric(cntl.text) ||
                          !isNumeric(control2.text) ||
                          !isNumeric(ctrl2.text) ||
                          !isNumeric(ctrl1.text)) {
                      } else if (int.parse(cntl.text) == 0 ||
                          int.parse(control2.text) == 0 ||
                          int.parse(ctrl2.text) == 0 ||
                          int.parse(ctrl1.text) == 0) {
                      } else {
                        _regChannel =
                            IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                        String message =
                            "Register,${control.text},${ctrl.text},${cntl.text},${control2.text},${ctrl2.text},${ctrl1.text}";
                        _regChannel.sink.add(xor_dec_enc(message));
                        User u1 = new User(
                            control.text,
                            double.parse(cntl.text),
                            int.parse(control2.text),
                            int.parse(ctrl2.text),
                            0,
                            0,
                            cntl.text + "/" + (DateTime.now()).toString(),
                            "",
                            "",
                            "",
                            int.parse(ctrl1.text),
                            0,
                            0,
                            0,
                            0,
                            0);
                        var sub;
                        sub = _regChannel.stream.listen(
                          (msg) {
                            if (xor_dec_enc(msg).toLowerCase() == "no") {
                              sub.cancel();
                              _regChannel.sink.close();
                              return;
                            } else {
                              sub.cancel();
                              _regChannel.sink.close();
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      BottomNavi(u1),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var begin = Offset(1.0, 0.0);
                                    var end = Offset.zero;
                                    var curve = Curves.ease;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        );
                      }
                    } else {
                      print("In User");
                      setState(
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cant Register An Exisiting User'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                      );
                    }
                    channel.sink.close();
                  },
                );
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    // TODO according to DartDoc num.parse() includes both (double.parse and int.parse)
    return double.parse(s) != null || int.parse(s) != null;
  }
}

class WeightGraph extends StatefulWidget {
  User un = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  WeightGraph(User u1) {
    un = u1;
  }
  @override
  WeightGraphState createState() => WeightGraphState();
}

class WeightGraphState extends State<WeightGraph> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  final bool animate = true;
  @override
  void initState() {
    super.initState();
    user = widget.un;
    print("Entered Weight");
  }

  @override
  void dispose() {
    super.dispose();
    print("Weight done");
  }

  List<charts.Series<Weight, DateTime>> _createSampleData(List<Weight> data2) {
    final myData = data2;
    return [
      new charts.Series<Weight, DateTime>(
        id: 'Weight',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Weight dat, _) => dat.date_time,
        measureFn: (Weight dat, _) => dat.value,
        data: myData,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var seriesList;
    List<Weight> matches = [];
    List data2 = user.weight_data.split("/");
    List weight = data2[0].split("-");
    List td = data2[1].split("+");
    for (int i = 0; i < weight.length; i++) {
      Weight w1 = Weight(DateTime.parse(td[i]), double.parse(weight[i]));
      matches.add(w1);
    }
    seriesList = _createSampleData(matches);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CaloCalc - Weight Graph',
          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: charts.TimeSeriesChart(
        seriesList,
        animate: animate,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              new charts.BasicNumericTickProviderSpec(zeroBound: false),
        ),
      ),
    );
  }
}

class Weight {
  final double value;
  final DateTime date_time;
  Weight(this.date_time, this.value);
}

class BottomNavi extends StatefulWidget {
  User un = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  BottomNavi(User u2) {
    un = u2;
  }
  @override
  NaviState createState() => NaviState();
}

class NaviState extends State<BottomNavi> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  int _currentIndex = 0;
  List _pages = [];
  @override
  void initState() {
    super.initState();
    user = widget.un;
    _pages = [
      MyApp(user),
      FoodData(user),
      WeightGraph(user),
      Activities(user),
      TodaysActivitys(user),
      Challenges(user),
      AccountDetails(user)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Main',
              backgroundColor: Colors.lightBlue),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_outlined),
            label: 'Food Data',
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_chart_outlined),
            label: 'Weight Graph',
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Activities',
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_outlined),
            label: 'Todays Activitys',
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.run_circle_outlined),
            label: 'Challenges',
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_rounded),
            label: 'Account Data',
            backgroundColor: Colors.lightBlue,
          ),
        ],
        onTap: (index) {
          setState(
            () {
              _currentIndex = index;
            },
          );
        },
      ),
    );
  }
}

class AccountDetails extends StatefulWidget {
  User un = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  AccountDetails(User u2) {
    un = u2;
  }
  @override
  AccountDeatilsState createState() => AccountDeatilsState();
}

class AccountDeatilsState extends State<AccountDetails> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  final control = TextEditingController();
  @override
  void initState() {
    super.initState();
    user = widget.un;
    print("Entered Data");
  }

  void dispose() {
    super.dispose();
    control.dispose();
    print("Exited Data");
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Change Data", textAlign: TextAlign.center),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: "Enter New Value"),
            controller: control,
          ),
          actions: [TextButton(onPressed: submit, child: Text("SUBMIT"))],
        ),
      );
  void submit() {
    Navigator.of(context).pop(control.text);
  }

  void _change_name(var new_name) {
    setState(
      () {
        user.name = new_name;
      },
    );
  }

  void _change_weight_data(var new_data) {
    setState(
      () {
        user.weight = double.parse(new_data);
      },
    );
  }

  void _change_cal_goal(var new_data) {
    setState(
      () {
        user.cal = int.parse(new_data);
      },
    );
  }

  void _change_prot_goal(var new_data) {
    setState(
      () {
        user.prot = int.parse(new_data);
      },
    );
  }

  void _change_burned_goal(var new_data) {
    setState(
      () {
        user.burned = int.parse(new_data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CaloCalc - My Data',
          style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Name: " + user.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        var data = await openDialog();
                        if (data == null) {
                          return;
                        } else {
                          var _detailsChannel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          _detailsChannel.sink.add(xor_dec_enc(
                              "Update Name," + user.name + "," + data));
                          _detailsChannel.stream.listen(
                            (msg) {
                              print("Message Recieved ${xor_dec_enc(msg)}");
                              _change_name(data);
                              _detailsChannel.sink.close();
                            },
                          );
                        }
                      },
                      child: Text('Change Value'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Weight: " + user.weight.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        var data = await openDialog();
                        if (data == null) {
                          return;
                        } else if (!isNumeric(data)) {
                          print("NO BONK");
                        } else {
                          var _detailsChannel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          var dat = user.weight_data.split("/");
                          dat[0] += "-" + data;
                          dat[1] += "+" + DateTime.now().toString();
                          var new_dat = dat.join("/");
                          user.set_weight_data(new_dat);
                          _detailsChannel.sink.add(xor_dec_enc(
                              "Update Weight Data," +
                                  user.name +
                                  "," +
                                  data.toString()));
                          _detailsChannel.stream.listen(
                            (msg) {
                              print("Message Recieved ${xor_dec_enc(msg)}");
                              _change_weight_data(data);
                              _detailsChannel.sink.close();
                            },
                          );
                        }
                      },
                      child: Text('Change Value'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Calorie Goal: " + user.cal.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        var data = await openDialog();
                        if (data == null) {
                          return;
                        } else if (!isNumeric(data)) {
                          print("NO BONK");
                        } else {
                          var _detailsChannel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          _detailsChannel.sink.add(xor_dec_enc(
                              "Update Cal Goal," +
                                  user.name +
                                  "," +
                                  data.toString()));
                          _detailsChannel.stream.listen(
                            (msg) {
                              print("Message Recieved ${xor_dec_enc(msg)}");
                              _change_cal_goal(data);
                              _detailsChannel.sink.close();
                            },
                          );
                        }
                      },
                      child: Text('Change Value'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Protein Goal: " + user.prot.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        var data = await openDialog();
                        if (data == null) {
                          return;
                        } else if (!isNumeric(data)) {
                          print("NO BONK");
                        } else {
                          var _detailsChannel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          _detailsChannel.sink.add(xor_dec_enc(
                              "Update Prot Goal," +
                                  user.name +
                                  "," +
                                  data.toString()));
                          _detailsChannel.stream.listen(
                            (msg) {
                              print("Message Recieved ${xor_dec_enc(msg)}");
                              _change_prot_goal(data);
                              _detailsChannel.sink.close();
                            },
                          );
                        }
                      },
                      child: Text('Change Value'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Burned Goal: " + user.burned.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        var data = await openDialog();
                        if (data == null) {
                          return;
                        } else if (!isNumeric(data)) {
                          print("NO BONK");
                        } else {
                          var _detailsChannel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          _detailsChannel.sink.add(xor_dec_enc(
                              "Update Burned Goal," +
                                  user.name +
                                  "," +
                                  data.toString()));
                          _detailsChannel.stream.listen(
                            (msg) {
                              print("Message Recieved ${xor_dec_enc(msg)}");
                              _change_burned_goal(data);
                              _detailsChannel.sink.close();
                            },
                          );
                        }
                      },
                      child: Text('Change Value'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Password: **********",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        var data = await openDialog();
                        if (data == null) {
                          return;
                        } else {
                          var _detailsChannel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          _detailsChannel.sink.add(xor_dec_enc("Update Pas," +
                              user.name +
                              "," +
                              data.toString()));
                          _detailsChannel.stream.listen(
                            (msg) {
                              print("Message Recieved $msg");
                              _detailsChannel.sink.close();
                            },
                          );
                        }
                      },
                      child: Text('Change Value'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}

class Challenges extends StatefulWidget {
  User u1 = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  Challenges(User u2) {
    u1 = u2;
  }
  @override
  ChallengesState createState() => ChallengesState();
}

class ChallengesState extends State<Challenges> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  String button_text1 = "Follow";
  String button_text2 = "Follow";
  String text1 = "Unfollow";
  String text2 = "Unfollow";
  var visibility1 = false;
  var visibility2 = false;
  var visibility3 = true;
  var visibility4 = true;
  var application_channel;
  List running = [
    '100 KM Running',
    '200 KM Running',
    '300 KM Running',
    '400 KM Running',
    '500 KM Running',
    '600 KM Running',
    '700 KM Running',
    '800 KM Running',
    '900 KM Running',
    '1000 KM Running',
    '1100 KM Running',
    '1200 KM Running',
  ];
  List cycling = [
    '100 KM Cycling',
    '200 KM Cycling',
    '300 KM Cycling',
    '400 KM Cycling',
    '500 KM Cycling',
    '600 KM Cycling',
    '700 KM Cycling',
    '800 KM Cycling',
    '900 KM Cycling',
    '1000 KM Cycling',
    '1100 KM Cycling',
    '1200 KM Cycling',
  ];
  @override
  void initState() {
    super.initState();
    user = widget.u1;
    print("Entered Challenges");
  }

  @override
  Widget build(BuildContext context) {
    print(user.running.toString() + "," + user.cycling.toString());
    return data(user.challenge_one, user.challenge_two);
  }

  Scaffold data(var cond1, var cond2) {
    if (user.challenge_one == true) {
      if (user.challenge_two == true) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'CaloCalc - Monthly Challenge',
              style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  running[DateTime.now().month - 1].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'You Have All Month To Reach ${int.parse(running[DateTime.now().month - 1].toString().split(" ")[0])} KMS',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Visibility(
                  visible: visibility3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CircularPercentIndicator(
                      radius: 40.0,
                      lineWidth: 8.0,
                      percent: user.running /
                          int.parse(running[DateTime.now().month - 1]
                              .toString()
                              .split(" ")[0]),
                      center: new Text(
                        (user.running /
                                    int.parse(running[DateTime.now().month - 1]
                                        .toString()
                                        .split(" ")[0]))
                                .toString() +
                            "%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        change_chal(text1, visibility3, 1);
                        if (text1.toLowerCase() == "unfollow") {
                          application_channel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          String msg = "Update Chal," + user.name + ",1,0";
                          application_channel.sink.add(xor_dec_enc(msg));
                          application_channel.sink.close();
                        } else {
                          application_channel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          String msg = "Update Chal," + user.name + ",1,1";
                          application_channel.sink.add(xor_dec_enc(msg));
                          application_channel.sink.close();
                        }
                      },
                      child: Text(text1),
                    ),
                  ],
                ),
                SizedBox(
                  height: 150,
                ),
                Text(
                  cycling[DateTime.now().month - 1].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'You Have All Month To Reach ${int.parse(cycling[DateTime.now().month - 1].toString().split(" ")[0])} KMS',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Visibility(
                  visible: visibility4,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CircularPercentIndicator(
                      radius: 40.0,
                      lineWidth: 8.0,
                      percent: user.cycling /
                          int.parse(cycling[DateTime.now().month - 1]
                              .toString()
                              .split(" ")[0]),
                      center: new Text(
                        (user.cycling /
                                    int.parse(cycling[DateTime.now().month - 1]
                                        .toString()
                                        .split(" ")[0]))
                                .toString() +
                            "%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        change_chal(text2, visibility4, 2);
                        if (text2.toLowerCase() == "unfollow") {
                          application_channel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          String msg = "Update Chal," + user.name + ",2,0";
                          application_channel.sink.add(xor_dec_enc(msg));
                          application_channel.sink.close();
                        } else {
                          application_channel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          String msg = "Update Chal," + user.name + ",2,1";
                          application_channel.sink.add(xor_dec_enc(msg));
                          application_channel.sink.close();
                        }
                      },
                      child: Text(text2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'CaloCalc - Monthly Challenge',
              style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  running[DateTime.now().month - 1].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'You Have All Month To Reach ${int.parse(running[DateTime.now().month - 1].toString().split(" ")[0])} KMS',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Visibility(
                  visible: visibility3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CircularPercentIndicator(
                      radius: 40.0,
                      lineWidth: 8.0,
                      percent: user.running /
                          int.parse(running[DateTime.now().month - 1]
                              .toString()
                              .split(" ")[0]),
                      center: new Text(
                        (user.running /
                                    int.parse(running[DateTime.now().month - 1]
                                        .toString()
                                        .split(" ")[0]))
                                .toString() +
                            "%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        change_chal(text1, visibility3, 1);
                        if (text1.toLowerCase() == "unfollow") {
                          application_channel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          String msg = "Update Chal," + user.name + ",1,0";
                          application_channel.sink.add(xor_dec_enc(msg));
                          application_channel.sink.close();
                        } else {
                          application_channel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          String msg = "Update Chal," + user.name + ",1,1";
                          application_channel.sink.add(xor_dec_enc(msg));
                          application_channel.sink.close();
                        }
                      },
                      child: Text(text1),
                    ),
                  ],
                ),
                SizedBox(
                  height: 150,
                ),
                Text(
                  cycling[DateTime.now().month - 1].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'You Have All Month To Reach ${int.parse(cycling[DateTime.now().month - 1].toString().split(" ")[0])} KMS',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Visibility(
                  visible: visibility2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CircularPercentIndicator(
                      radius: 40.0,
                      lineWidth: 8.0,
                      percent: user.cycling /
                          int.parse(cycling[DateTime.now().month - 1]
                              .toString()
                              .split(" ")[0]),
                      center: new Text(
                        (user.cycling /
                                    int.parse(cycling[DateTime.now().month - 1]
                                        .toString()
                                        .split(" ")[0]))
                                .toString() +
                            "%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        change_chal(button_text2, visibility2, 2);
                        if (button_text2.toLowerCase() == "unfollow") {
                          application_channel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          String msg = "Update Chal," + user.name + ",2,0";
                          application_channel.sink.add(xor_dec_enc(msg));
                          application_channel.sink.close();
                        } else {
                          application_channel =
                              IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                          String msg = "Update Chal," + user.name + ",2,1";
                          application_channel.sink.add(xor_dec_enc(msg));
                          application_channel.sink.close();
                        }
                      },
                      child: Text(button_text2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    } else if (user.challenge_two == true) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'CaloCalc - Monthly Challenge',
            style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                running[DateTime.now().month - 1].toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'You Have All Month To Reach ${int.parse(running[DateTime.now().month - 1].toString().split(" ")[0])} KMS',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              Visibility(
                visible: visibility1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 8.0,
                    percent: user.running /
                        int.parse(running[DateTime.now().month - 1]
                            .toString()
                            .split(" ")[0]),
                    center: new Text(
                      (user.running /
                                  int.parse(running[DateTime.now().month - 1]
                                      .toString()
                                      .split(" ")[0]))
                              .toString() +
                          "%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                    progressColor: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      change_chal(button_text1, visibility1, 1);
                      if (button_text1.toLowerCase() == "unfollow") {
                        application_channel =
                            IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                        String msg = "Update Chal," + user.name + ",1,0";
                        application_channel.sink.add(xor_dec_enc(msg));
                        application_channel.sink.close();
                      } else {
                        application_channel =
                            IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                        String msg = "Update Chal," + user.name + ",1,1";
                        application_channel.sink.add(xor_dec_enc(msg));
                        application_channel.sink.close();
                      }
                    },
                    child: Text(button_text1),
                  ),
                ],
              ),
              SizedBox(
                height: 150,
              ),
              Text(
                cycling[DateTime.now().month - 1].toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'You Have All Month To Reach ${int.parse(cycling[DateTime.now().month - 1].toString().split(" ")[0])} KMS',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              Visibility(
                visible: visibility4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 8.0,
                    percent: user.cycling /
                        int.parse(cycling[DateTime.now().month - 1]
                            .toString()
                            .split(" ")[0]),
                    center: new Text(
                      (user.cycling /
                                  int.parse(cycling[DateTime.now().month - 1]
                                      .toString()
                                      .split(" ")[0]))
                              .toString() +
                          "%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                    progressColor: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      change_chal(text2, visibility4, 2);
                      if (text2.toLowerCase() == "unfollow") {
                        application_channel =
                            IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                        String msg = "Update Chal," + user.name + ",2,0";
                        application_channel.sink.add(xor_dec_enc(msg));
                        application_channel.sink.close();
                      } else {
                        application_channel =
                            IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                        String msg = "Update Chal," + user.name + ",2,1";
                        application_channel.sink.add(xor_dec_enc(msg));
                        application_channel.sink.close();
                      }
                    },
                    child: Text(text2),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CaloCalc - Monthly Challenge',
          style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              running[DateTime.now().month - 1].toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'You Have All Month To Reach ${int.parse(running[DateTime.now().month - 1].toString().split(" ")[0])} KMS',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Visibility(
              visible: visibility1,
              child: Align(
                alignment: Alignment.centerRight,
                child: CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 8.0,
                  percent: user.running /
                      int.parse(running[DateTime.now().month - 1]
                          .toString()
                          .split(" ")[0]),
                  center: new Text(
                    (user.running /
                                int.parse(running[DateTime.now().month - 1]
                                    .toString()
                                    .split(" ")[0]))
                            .toString() +
                        "%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  progressColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    change_chal(button_text1, visibility1, 1);
                    if (button_text1.toLowerCase() == "unfollow") {
                      application_channel =
                          IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                      String msg = "Update Chal," + user.name + ",1,0";
                      application_channel.sink.add(xor_dec_enc(msg));
                      application_channel.sink.close();
                    } else {
                      application_channel =
                          IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                      String msg = "Update Chal," + user.name + ",1,1";
                      application_channel.sink.add(xor_dec_enc(msg));
                      application_channel.sink.close();
                    }
                  },
                  child: Text(button_text1),
                ),
              ],
            ),
            SizedBox(
              height: 150,
            ),
            Text(
              cycling[DateTime.now().month - 1].toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'You Have All Month To Reach ${int.parse(cycling[DateTime.now().month - 1].toString().split(" ")[0])} KMS',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Visibility(
              visible: visibility2,
              child: Align(
                alignment: Alignment.centerRight,
                child: CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 8.0,
                  percent: user.cycling /
                      int.parse(cycling[DateTime.now().month - 1]
                          .toString()
                          .split(" ")[0]),
                  center: new Text(
                    (user.cycling /
                                int.parse(cycling[DateTime.now().month - 1]
                                    .toString()
                                    .split(" ")[0]))
                            .toString() +
                        "%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  progressColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    change_chal(button_text2, visibility2, 2);
                    if (button_text2.toLowerCase() == "unfollow") {
                      application_channel =
                          IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                      String msg = "Update Chal," + user.name + ",2,0";
                      application_channel.sink.add(xor_dec_enc(msg));
                      application_channel.sink.close();
                    } else {
                      application_channel =
                          IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                      String msg = "Update Chal," + user.name + ",2,1";
                      application_channel.sink.add(xor_dec_enc(msg));
                      application_channel.sink.close();
                    }
                  },
                  child: Text(button_text2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void change_chal(var text, var vis, var chal) {
    setState(
      () {
        if (text.toLowerCase() == "unfollow") {
          text = "Follow";
        } else {
          text = "Unfollow";
        }
        if (chal == 1) {
          user.set_chal_one(!user.challenge_one);
        } else {
          user.set_chal_two(!user.challenge_two);
        }
        vis = !vis;
      },
    );
  }
}

class Activities extends StatefulWidget {
  User u1 = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  Activities(User u2) {
    u1 = u2;
  }
  @override
  ActivitiesState createState() => ActivitiesState();
}

class ActivitiesState extends State<Activities> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  List<List<dynamic>> data = [];
  var control = TextEditingController();
  var items = [];
  var dv = 'Activity';
  var cond = ' Exercise or Sport (1 hour)';
  var condition = [];

  @override
  void initState() {
    super.initState();
    user = widget.u1;
    print("Entered Activities");
  }

  @override
  void dispose() {
    super.dispose();
    try {
      control.dispose();
    } catch (e) {
      print("NULL");
    }
  }

  Widget build(BuildContext context) {
    loadCSV();
    items = cs.activities(data);
    condition = cs.getDur(dv, data);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CaloCalc - Activities',
          style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value:
                  user.cur_burned / user.burned, // current_burned / burned_goal
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 4, 18, 128)),
              minHeight: 20.0, // Set the thickness of the progress bar
            ),
            Center(
              child: user.cur_burned / user.burned >= 1
                  ? Text(
                      'Current_Burned / Your Burned Goal = ${(100).toInt()}%',
                      style: TextStyle(fontSize: 14.0),
                    )
                  : Text(
                      'Current_Burned / Your Burned Goal = ${(user.cur_burned / user.burned * 100).toInt()}%',
                      style: TextStyle(fontSize: 14.0),
                    ),
            ),
            SizedBox(
              height: 50,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: DropdownButton(
                iconSize: 24.0,
                value: dv,
                icon: const Icon(Icons.keyboard_arrow_down),
                // Array list of items
                items: items.map(
                  (var items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(
                        items,
                        style: TextStyle(
                          fontSize: 14.0, // Set font size
                          color: Colors.black, // Set font color
                        ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (var newValue) {
                  setState(
                    () {
                      dv = newValue.toString();
                      condition = cs.getDur(dv, data);
                      cond = condition[0];
                    },
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: DropdownButton(
                value: cond,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: condition.map(
                  (var condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(condition),
                    );
                  },
                ).toList(),
                onChanged: (var newValue) {
                  setState(
                    () {
                      cond = newValue.toString();
                    },
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                style: TextStyle(fontSize: 14.0),
                decoration: InputDecoration(
                  hintText: "Enter Workout Duration",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                controller: control,
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                child: Text("SUBMIT"),
                onPressed: () {
                  if (dv == "Activity") {
                    final snackBar = SnackBar(
                      content: Text('Cannot Submit Random Activity'),
                      duration: Duration(seconds: 5),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Timer(
                      Duration(seconds: 5),
                      () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    );
                  } else if (control.text == "") {
                    final snackBar = SnackBar(
                      content: Text('Cannot Submit Timeless Activity'),
                      duration: Duration(seconds: 5),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Timer(
                      Duration(seconds: 5),
                      () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    );
                  } else {
                    var burned = cs.burned(dv, cond, data);
                    var actual = 0.0;
                    var distance = 0.0;
                    if (!control.text.contains("and")) {
                      var list = control.text.split(" ");
                      for (int i = 1; i < list.length; i++) {
                        var numeric = double.parse(list[i - 1]);
                        if (list[i].toLowerCase() == "hour" ||
                            list[i].toLowerCase() == "hours") {
                          actual = numeric * burned * user.weight;
                        } else if (list[i].toLowerCase() == "minute" ||
                            list[i].toLowerCase() == "minutes") {
                          actual = numeric * burned * user.weight / 60;
                        } else if (list[i].toLowerCase() == "second" ||
                            list[i].toLowerCase() == "seconds") {
                          actual = numeric * burned * user.weight / 3600;
                        }
                        if (dv.toLowerCase() == "running" &&
                            cond.contains("mph")) {
                          var state = double.parse(cond.split(" ")[1]);
                          if (list[i].toLowerCase() == "hour" ||
                              list[i].toLowerCase() == "hours") {
                            distance += state * 1.6 * numeric;
                          } else if (list[i].toLowerCase() == "minute" ||
                              list[i].toLowerCase() == "minutes") {
                            distance += state * 1.6 * numeric / 60;
                          } else if (list[i].toLowerCase() == "second" ||
                              list[i].toLowerCase() == "seconds") {
                            distance += state * 1.6 * numeric / 3600;
                          }
                        } else if (dv.toLowerCase() == "cycling" &&
                            cond.contains("mph")) {
                          var state = cond.split(" ")[1];
                          distance += cycling_dis(state, list.join(" "));
                        }
                      }
                    } else {
                      var time_list = control.text.split("and");
                      for (int i = 0; i < time_list.length; i++) {
                        var list = time_list[i];
                        double numeric =
                            double.parse(list.replaceAll(RegExp('[^0-9]'), ''));
                        String result =
                            list.replaceAll(RegExp(r'[^a-zA-Z]'), '');
                        if (result.toLowerCase() == "hour" ||
                            result.toLowerCase() == "hours") {
                          actual += numeric * burned * user.weight;
                        } else if (result.toLowerCase() == "minute" ||
                            result.toLowerCase() == "minutes") {
                          actual += numeric * burned * user.weight / 60;
                        } else if (result.toLowerCase() == "second" ||
                            result.toLowerCase() == "seconds") {
                          actual += numeric * burned * user.weight / 3600;
                        }
                        if (dv.toLowerCase() == "running" &&
                            cond.contains("mph")) {
                          var state = double.parse(cond.split(" ")[1]);
                          if (result.toLowerCase() == "hour" ||
                              result.toLowerCase() == "hours") {
                            distance += state * 1.6 * numeric;
                          } else if (result.toLowerCase() == "minute" ||
                              result.toLowerCase() == "minutes") {
                            distance += state * 1.6 * numeric / 60;
                          } else if (result.toLowerCase() == "second" ||
                              result.toLowerCase() == "seconds") {
                            distance += state * 1.6 * numeric / 3600;
                          }
                        } else if (dv.toLowerCase() == "cycling" &&
                            cond.contains("mph")) {
                          var state = cond.split(" ")[1];
                          distance += cycling_dis(state, list);
                        }
                      }
                    }
                    var to_decrease = actual / 300 * 0.039;
                    user.set_weight(-to_decrease);
                    List weight_data_split = user.weight_data.split("/");
                    weight_data_split[0] += "-" + user.weight.toString();
                    weight_data_split[1] += "+" + DateTime.now().toString();
                    user.set_weight_data(weight_data_split.join("/"));
                    var weit_chan =
                        IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                    String message = "Update Weight," +
                        user.name +
                        "," +
                        user.weight.toString();
                    weit_chan.sink.add(xor_dec_enc(message));
                    weit_chan.stream.listen(
                      (msg1) {
                        print("Recieved Message: ${xor_dec_enc(msg1)}");
                      },
                    );
                    // 300 cal = 0.039 kg
                    String msg = "";
                    if (dv.toLowerCase() == "running" && cond.contains("mph")) {
                      user.set_running(distance.toInt());
                    } else if (dv.toLowerCase() == "cycling" &&
                        cond.contains("mph")) {
                      user.set_cycling(distance.toInt());
                    }
                    _increaseCurBurn(actual.toInt());
                    var _detailsChannel =
                        IOWebSocketChannel.connect("ws://10.0.0.8:8820");
                    if (dv.toLowerCase().contains("running")) {
                      msg = "running," +
                          user.name +
                          "," +
                          (user.cur_burned.toInt() + actual.toInt())
                              .toString() +
                          "," +
                          distance.toInt().toString();
                    } else if (dv.toLowerCase() == "cycling") {
                      msg = "cycling," +
                          user.name +
                          "," +
                          (user.cur_burned.toInt() + actual.toInt())
                              .toString() +
                          "," +
                          distance.toInt().toString();
                    } else {
                      msg = "Random Activity," +
                          dv.toString() +
                          "," +
                          user.name +
                          "," +
                          (user.cur_burned.toInt() + actual.toInt()).toString();
                    }
                    _detailsChannel.sink.add(xor_dec_enc(msg));
                    _detailsChannel.stream.listen(
                      (message) {
                        print("Message: ${xor_dec_enc(message)}");
                      },
                    );
                    _detailsChannel.sink.close();
                    user.set_activity_data(
                        dv.toString() + "-" + actual.toInt().toString());
                    final snackBar = SnackBar(
                      content: Text('Activity Submitted'),
                      duration: Duration(seconds: 5),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Timer(
                      Duration(seconds: 5),
                      () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _increaseCurBurn(int new_burn) {
    setState(
      () {
        user.cur_burned += new_burn;
      },
    );
  }

  void loadCSV() async {
    final data2 = await rootBundle.loadString("assets/exercise_dataset.csv");
    var list2 = const CsvToListConverter().convert(data2);
    setState(
      () {
        data = list2;
      },
    );
  }

  double cycling_dis(var state, var time) {
    var distance = 0.0;
    double numeric = double.parse(time.replaceAll(RegExp('[^0-9]'), ''));
    String result = time.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    var stat = 0.0;
    if (state.contains("<")) {
      stat = 7.5;
    } else if (state.contains(">")) {
      stat = 22.5;
    } else if (state.contains("-")) {
      var li = state.split("-");
      stat = double.parse(
          ((double.parse(li[0]) + double.parse(li[1])) / 2).round().toString());
    }
    if (result.toLowerCase() == "hour" || result.toLowerCase() == "hours") {
      distance = stat * 1.6 * numeric;
    } else if (result.toLowerCase() == "minute" ||
        result.toLowerCase() == "minutes") {
      distance = stat * 1.6 * numeric / 60;
    } else if (result.toLowerCase() == "second" ||
        result.toLowerCase() == "seconds") {
      distance = stat * 1.6 * numeric / 3600;
    }
    return distance;
  }
}

class TodaysActivitys extends StatefulWidget {
  User u1 = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  TodaysActivitys(User u2) {
    u1 = u2;
  }
  @override
  TodaysActivityState createState() => TodaysActivityState();
}

class TodaysActivityState extends State<TodaysActivitys> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "", "", 0, 0, 0, 0, 0, 0);
  final control = TextEditingController();
  @override
  void initState() {
    super.initState();
    user = widget.u1;
    print("Entered Data");
  }

  @override
  Widget build(BuildContext context) {
    var activ_dat = user.activity_data;
    List activs = [];
    for (int i = 0; i < activ_dat.length; i++) {
      activs.add(activ_dat[i]);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CaloCalc - My Activities',
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Table(
        columnWidths: {
          0: FractionColumnWidth(0.5),
          1: FractionColumnWidth(0.5),
        },
        border: TableBorder.all(
          color: Colors.black,
          width: 3.0,
          style: BorderStyle.solid,
        ),
        children: [
          TableRow(
            children: [
              TableCell(
                child: Text(
                  'Activity Name',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TableCell(
                child: Text(
                  'Calories Burned',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          ...List<TableRow>.generate(
            activs.length,
            (index) {
              if (activs[index].isNotEmpty) {
                return TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          activs[index].split("-")[0].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          activs[index].split("-")[1].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          activs[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          activs[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          )
        ],
      ),
    );
  }
}

class User {
  String name = "";
  double weight = 0;
  int cal = 0;
  int prot = 0;
  int current_cal = 0;
  int current_prot = 0;
  String weight_data = "";
  String food_data = "";
  List activity_data = [];
  int burned = 0;
  int cur_burned = 0;
  int running = 0;
  int cycling = 0;
  bool challenge_one = false;
  bool challenge_two = false;
  List meal_data = [];
  User(
      String na,
      double weit,
      int ca,
      int pro,
      int cur_cal,
      int cur_prot,
      String weight_dat,
      String fod,
      String meals,
      String activ,
      int bur,
      int cur_bur,
      int run,
      int cyc,
      int chal_one,
      int chal_two) {
    name = na;
    weight = weit;
    cal = ca;
    prot = pro;
    current_cal = cur_cal;
    current_prot = cur_prot;
    weight_data = weight_dat;
    food_data = fod;
    meal_data = meals.split("#");
    activity_data = activ.split("#");
    burned = bur;
    cur_burned = cur_bur;
    running = run;
    cycling = cyc;
    if (chal_one == 1) challenge_one = true;
    if (chal_two == 1) challenge_two = true;
  }
  void set_weight(double weit) {
    weight += weit;
  }

  void set_weight_data(String new_dat) {
    weight_data = new_dat;
  }

  void set_activity_data(String new_ac) {
    activity_data.add(new_ac);
  }

  void set_running(int run) {
    running += run;
  }

  void set_cycling(int cyc) {
    cycling += cyc;
  }

  void set_chal_one(bool val) {
    challenge_one = val;
  }

  void set_chal_two(bool val) {
    challenge_two = val;
  }
}
