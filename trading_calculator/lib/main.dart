import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trading_calculator/components/convert.dart';
import 'package:image_picker/image_picker.dart';
import 'model/data.dart';
import 'package:location/location.dart';

void main() {
  runApp(new MaterialApp(home: new TradingCalculator()));
}

class TradingCalculator extends StatefulWidget {
  const TradingCalculator({Key? key}) : super(key: key);

  @override
  State<TradingCalculator> createState() => _TradingCalculatorState();
}

class _TradingCalculatorState extends State<TradingCalculator> {
  final ImagePicker _picker = ImagePicker();
Location location = new Location();
  final GlobalKey _LoaderDialog = new GlobalKey();
  Data data = new Data();
  final _accountSize = TextEditingController();
  final _portfolioRisk = TextEditingController();
  final _stopLoss = TextEditingController();
  final _target = TextEditingController();

  bool _validate = false;

  Future<void> camera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    //File photofile = File(photo!.path);
  }

  void _setAccountSizeState(String accountSize) {
    if (accountSize.length > 0) data.accountSize = int.parse(accountSize);
  }

  void _setPortfolioRiskState(String portfolioRisk) {
    if (portfolioRisk.length > 0) data.portfolioRisk = int.parse(portfolioRisk);
  }

  void _setStopLossState(String stopLoss) {
    if (stopLoss.length > 0) data.stopLoss = int.parse(stopLoss);
  }

  void _setTargetState(String target) {
    if (target.length > 0) data.target = int.parse(target);
  }

  void _pushConvertButton() {
    setState(() {
      loading = true;
    });
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new Convert();
    }));
  }

  calculate() {
    double ta =
        (data.portfolioRisk.toDouble() / 100 * data.accountSize.toDouble()) /
            (data.stopLoss.toDouble() / 100);
    String calculation = " You have a \$" +
        data.accountSize.toString() +
        " account" +
        "\n Account risk is " +
        data.portfolioRisk.toString() +
        "%" +
        "\n Stop Loss of the trade is " +
        data.stopLoss.toString() +
        "% and that will be \$" +
        (data.portfolioRisk.toDouble() / 100 * data.accountSize.toDouble())
            .toString() +
        "\n You need to enter the trade with \$" +
        ta.toString() +
        " in order to have " +
        data.portfolioRisk.toString() +
        "% account risk" +
        "\n If you win with a " +
        data.target.toString() +
        "% target, You'll win \$" +
        ((ta * data.target.toDouble()) / 100).toString();

    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Here are the results:"),
      content: Text(calculation),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  getlocation() async {
    LocationData _current = await location.getLocation();

    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Here is your location:"),
      content: Text("Latitude: " +
          _current.latitude.toString() +
          "\n" +
          "Longitude: " +
          _current.longitude.toString()),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("Trading calculator"),
          actions: [
            Row(
              children: [
                new IconButton(
                    onPressed: getlocation, icon: Icon(Icons.location_city)),
                new IconButton(
                  onPressed: camera,
                  icon: Icon(Icons.camera),
                )
              ],
            )
          ],
        ),
        body: Center(
            child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _accountSize,
                      onChanged: (val) {
                        _setAccountSizeState(val);
                      },
                      decoration: new InputDecoration(
                          errorText: _validate ? 'Value Can\'t Be Empty' : null,
                          hintText: "Account size in \$"),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                    TextField(
                      controller: _portfolioRisk,
                      onChanged: (val) {
                        _setPortfolioRiskState(val);
                      },
                      decoration: new InputDecoration(
                          errorText: _validate ? 'Value Can\'t Be Empty' : null,
                          hintText: "What's your portfolio risk in %"),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                    TextField(
                      controller: _stopLoss,
                      onChanged: (val) {
                        _setStopLossState(val);
                      },
                      decoration: new InputDecoration(
                          errorText: _validate ? 'Value Can\'t Be Empty' : null,
                          hintText: "What's your stop loss on the trade in %"),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                    TextField(
                      controller: _target,
                      onChanged: (val) {
                        _setTargetState(val);
                      },
                      decoration: new InputDecoration(
                          errorText: _validate ? 'Value Can\'t Be Empty' : null,
                          hintText: "What's your target in %"),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _target.text.isEmpty ||
                                  _stopLoss.text.isEmpty ||
                                  _portfolioRisk.text.isEmpty ||
                                  _accountSize.text.isEmpty
                              ? _validate = true
                              : _validate = false;
                        });
                        calculate();
                      },
                      child: Text("Calculate"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _pushConvertButton();
                      },
                      child: Text("Convert"),
                    ),
                  ],
                ))));
  }
}
