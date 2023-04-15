import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts;

// => ; // only if function has one action
String url = "https://api.api-ninjas.com/v1/nutrition?query=";

class FoodData extends StatefulWidget {
  User u1 = User("", 0, 0, 0, 0, 0, "", "", "");
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
  User user = User("", 0, 0, 0, 0, 0, "", "", "");
  @override
  void initState() {
    super.initState();
    _activeChannel = IOWebSocketChannel.connect("ws://10.0.0.21:8820");
    user = widget.u1;
    print("Entered Food Data");
  }

  @override
  void dispose() {
    super.dispose();
    _activeChannel.sink.close();
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
        dat2.add([changed[0], changed[1], changed[2]]);
      }
    }
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
          0: FractionColumnWidth(0.3),
          1: FractionColumnWidth(0.3),
          2: FractionColumnWidth(0.4),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  User u1 = User("", 0, 0, 0, 0, 0, "", "", "");
  MyApp(User un) {
    u1 = un;
  }
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "");
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
    setState(() {
      user.current_cal = ca;
    });
  }

  void _incrementProt(int pro) {
    setState(() {
      user.current_prot = pro;
    });
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
            var list;
            if (mealPrompt == null) {
              list = [];
            } else {
              list = mealPrompt.split("and");
            }
            for (int i = 0; i < list.length; i++) {
              mealChannel = IOWebSocketChannel.connect("ws://10.0.0.21:8820");
              var item = list[i];
              String prompt = url + item;
              var sub1;
              mealChannel.sink
                  .add("Food," + user.name + "," + prompt.toString());
              sub1 = mealChannel.stream.listen(
                (msg) {
                  print("Message Recieved: $msg");
                  String body = msg;
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
                  print(nameStr + ": " + calStr + "," + protStr);
                  var newCal = double.parse(calStr).toInt() + user.current_cal;
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
                      IOWebSocketChannel.connect("ws://10.0.0.21:8820");
                  _mainChannel.sink.add(message);
                  sub = _mainChannel.stream.listen(
                    (msg) {
                      print("Recieved Message:${msg}");
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
              RegExp numeric = RegExp(r'\d+');
              RegExp nonNumeric = RegExp(r'\D+');
              String numericString =
                  weight.replaceAll(nonNumeric, ''); // extracts numbers
              String nonNumericString =
                  weight.replaceAll(numeric, ''); // extracts non-numbers
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
            var _weightChan = IOWebSocketChannel.connect("ws://10.0.0.21:8820");
            String message =
                "Update Weight," + user.name + "," + user.weight.toString();
            _weightChan.sink.add(message);
            var sub;
            sub = _weightChan.stream.listen(
              (msg) {
                print("Recieved Message:${msg}");
                sub.cancel();
              },
            );
            _weightChan.sink.close();
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
                      IOWebSocketChannel.connect("ws://10.0.0.21:8820");
                  var sub;
                  String message = "Login,${control.text},${ctrl.text}";
                  _LogChannel.sink.add(message);
                  sub = _LogChannel.stream.listen(
                    (msg) {
                      print("Message Received: $msg");
                      var params = msg.split(",");
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
                        );
                        _LogChannel.sink.close();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BottomNavi(u1)),
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
  @override
  void initState() {
    super.initState();
    _regChannel = IOWebSocketChannel.connect("ws://10.0.0.21:8820");
    print("Entered Register");
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    control.dispose();
    ctrl.dispose();
    super.dispose();
    _regChannel.sink.close();
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
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Protein',
                    hintText: 'Enter first protein goal'),
                controller: ctrl2,
              ),
            ),
            SizedBox(
              height: 45,
            ),
            ElevatedButton(
              onPressed: () {
                String message =
                    "Register,${control.text},${ctrl.text},${cntl.text},${control2.text},${ctrl2.text}";
                _regChannel.sink.add(message);
                User u1 = new User(
                    control.text,
                    double.parse(cntl.text),
                    int.parse(control2.text),
                    int.parse(ctrl2.text),
                    0,
                    0,
                    "",
                    "",
                    "");
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => BottomNavi(u1)));
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightGraph extends StatefulWidget {
  User un = User("", 0, 0, 0, 0, 0, "", "", "");
  WeightGraph(User u1) {
    un = u1;
  }
  @override
  WeightGraphState createState() => WeightGraphState();
}

class WeightGraphState extends State<WeightGraph> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "");
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
    if (user.weight_data == "") {
      seriesList = _createSampleData([]);
    } else {
      List data2 = user.weight_data.split("/");
      List weight = data2[0].split("-");
      List td = data2[1].split("+");
      for (int i = 0; i < weight.length; i++) {
        Weight w1 = Weight(DateTime.parse(td[i]), double.parse(weight[i]));
        matches.add(w1);
      }
      seriesList = _createSampleData(matches);
    }
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
  User un = User("", 0, 0, 0, 0, 0, "", "", "");
  BottomNavi(User u2) {
    un = u2;
  }
  @override
  NaviState createState() => NaviState();
}

class NaviState extends State<BottomNavi> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "");
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
      AccountDetails(user),
      Activities(user)
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
            icon: Icon(Icons.account_box_rounded),
            label: 'Account Data',
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Activities',
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
  User un = User("", 0, 0, 0, 0, 0, "", "", "");
  AccountDetails(User u2) {
    un = u2;
  }
  @override
  AccountDeatilsState createState() => AccountDeatilsState();
}

class AccountDeatilsState extends State<AccountDetails> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "");
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
                        var _detailsChannel =
                            IOWebSocketChannel.connect("ws://10.0.0.21:8820");
                        var data = await openDialog();
                        _detailsChannel.sink
                            .add("Update Name," + user.name + "," + data);
                        _detailsChannel.stream.listen(
                          (msg) {
                            print("Message Recieved $msg");
                            _change_name(data);
                            _detailsChannel.sink.close();
                          },
                        );
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
                        var _detailsChannel =
                            IOWebSocketChannel.connect("ws://10.0.0.21:8820");
                        var data = await openDialog();
                        var dat = user.weight_data.split("/");
                        dat[0] += "-" + data;
                        dat[1] += "+" + DateTime.now().toString();
                        var new_dat = dat.join("/");
                        user.set_weight_data(new_dat);
                        _detailsChannel.sink.add("Update Weight Data," +
                            user.name +
                            "," +
                            data.toString());
                        _detailsChannel.stream.listen(
                          (msg) {
                            print("Message Recieved $msg");
                            _change_weight_data(data);
                            _detailsChannel.sink.close();
                          },
                        );
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
                        var _detailsChannel =
                            IOWebSocketChannel.connect("ws://10.0.0.21:8820");
                        var data = await openDialog();
                        _detailsChannel.sink.add("Update Cal Goal," +
                            user.name +
                            "," +
                            data.toString());
                        _detailsChannel.stream.listen(
                          (msg) {
                            print("Message Recieved $msg");
                            _change_cal_goal(data);
                            _detailsChannel.sink.close();
                          },
                        );
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
                        var _detailsChannel =
                            IOWebSocketChannel.connect("ws://10.0.0.21:8820");
                        var data = await openDialog();
                        _detailsChannel.sink.add("Update Prot Goal," +
                            user.name +
                            "," +
                            data.toString());
                        _detailsChannel.stream.listen(
                          (msg) {
                            print("Message Recieved $msg");
                            _change_prot_goal(data);
                            _detailsChannel.sink.close();
                          },
                        );
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
                        var _detailsChannel =
                            IOWebSocketChannel.connect("ws://10.0.0.21:8820");
                        var data = await openDialog();
                        _detailsChannel.sink.add(
                            "Update Pas," + user.name + "," + data.toString());
                        _detailsChannel.stream.listen(
                          (msg) {
                            print("Message Recieved $msg");
                            _detailsChannel.sink.close();
                          },
                        );
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
}

class Activities extends StatefulWidget {
  User u1 = User("", 0, 0, 0, 0, 0, "", "", "");
  Activities(User u2) {
    u1 = u2;
  }
  @override
  ActivitiesState createState() => ActivitiesState();
}

class ActivitiesState extends State<Activities> {
  User user = User("", 0, 0, 0, 0, 0, "", "", "");
  final List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
  String selectedItem = 'Select an item';
  @override
  void initState() {
    super.initState();
    user = widget.u1;
    print("Entered Activities");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CaloCalc - Activities',
          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Align(
        alignment: Alignment.bottomLeft,
        child: ElevatedButton(
          onPressed: () {
            // Show the pop-up list
            showPopupMenu(context);
          },
          child: Text('Select Item'),
        ),
      ),
    );
  }

  void showPopupMenu(BuildContext context) async {
    final selected = await showMenu(
      context: context,
      position:
          RelativeRect.fromLTRB(0, 0, 0, 0), // Specify the pop-up list position
      items: items.map((String item) {
        return PopupMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );

    if (selected != null) {
      // Update selected item and re-build the UI
      setState(
        () {
          selectedItem = selected;
        },
      );
    }
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
  List meal_data = [];
  User(String na, double weit, int ca, int pro, int cur_cal, int cur_prot,
      String weight_dat, String fod, String meals) {
    name = na;
    weight = weit;
    cal = ca;
    prot = pro;
    current_cal = cur_cal;
    current_prot = cur_prot;
    weight_data = weight_dat;
    food_data = fod;
    meal_data = meals.split("#");
  }
  void set_weight(double weit) {
    weight += weit;
  }

  void set_weight_data(String new_dat) {
    weight_data = new_dat;
  }
}

/*Opacity(
          opacity: 0.5, // set the opacity value here between 0.0 to 1.0
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("your_background_image_path_here"),
                fit: BoxFit.cover,
              ),
            ),
            ),
      ),
      */