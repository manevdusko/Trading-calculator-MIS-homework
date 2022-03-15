import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trading_calculator/components/loading.dart';
import 'package:trading_calculator/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

bool _validate = false;
bool _btcValidate = false;
bool loading = true;
double btcPrice = 0;

class Convert extends StatefulWidget {
  @override
  _ConvertAppState createState() => _ConvertAppState();
}

class _ConvertAppState extends State<Convert> {
  final _sum = TextEditingController();
  final _btc = TextEditingController();
  double _howMuch = 0;
  double _howMuchBtc = 0;
//get data from api
  Future<void> getBtcPrice() async {
    final response = await http
        .get(Uri.https('api.coindesk.com', 'v1/bpi/currentprice.json'))
        .then((value) {
      if (value.statusCode == 200) {
        final parsed = jsonDecode(value.body);
        setState(() {
          loading = false;
          btcPrice = double.parse(
              parsed['bpi']['USD']['rate'].toString().replaceAll(",", ""));
        });
      } else {
        throw Exception("Failed to load data");
      }
    });
  }

  void _setSum(String sum) {
    if (sum.length > 0) _howMuch = double.parse(sum);
  }

  void _setBtc(String sum) {
    if (sum.length > 0) _howMuchBtc = double.parse(sum);
  }

  usdToBtc() {
    String calculation = "\$" +
        _howMuch.toString() +
        " is equal to " +
        (_howMuch / btcPrice).toString() +
        "BTC";

    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Converted:"),
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

  btcToUsd() {
    String calculation = _howMuchBtc.toString() +
        "BTC is equal to " +
        "\$" +
        (_howMuchBtc * btcPrice).toString();

    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Converted:"),
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

  @override
  void initState() {
    super.initState();
    getBtcPrice();
  }

  @override
  Widget build(BuildContext context) {
    Widget _textElement() {
      return Column(
        children: [
          Text("1 BTC = " + btcPrice.toString() + " USD"),
          new TextField(
            controller: _sum,
            onChanged: (val) {
              _setSum(val);
            },
            decoration: new InputDecoration(
                errorText: _validate ? 'Value Can\'t Be Empty' : null,
                hintText: "Ammout in \$"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          new TextField(
            controller: _btc,
            onChanged: (val) {
              _setBtc(val);
            },
            decoration: new InputDecoration(
                errorText: _btcValidate ? 'Value Can\'t Be Empty' : null,
                hintText: "Ammout in BTC"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_sum.text.isEmpty) {
                  _validate = true;
                } else {
                  _validate = false;
                  _btcValidate = false;
                }
              });
              usdToBtc();
            },
            child: Text("USD to BTC"),
          ),
          ElevatedButton(
            //_btcValidate
            onPressed: () {
              setState(() {
                if (_btc.text.isEmpty) {
                  _btcValidate = true;
                } else {
                  _validate = false;
                  _btcValidate = false;
                }
              });
              btcToUsd();
            },
            child: Text("BTC to USD"),
          ),
        ],
      );
    }

    if (loading) {
      return Image.asset(
        'images/loading.gif',
      );
    } else
      return new Scaffold(
          appBar: new AppBar(title: new Text('Convert'), backgroundColor: Colors.green,),
          body: new Container(
              padding: EdgeInsets.all(16),
              child: new Column(
                children: <Widget>[
                  _textElement(),
                ],
              )));
  }
}
