import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snapshot App',
      home: HomePage(),
    );
  }
}

class NewsBlock extends StatefulWidget {
  NewsBlock({Key key}) : super(key: key);

  @override
  _NewsBlockState createState() => _NewsBlockState();
}

class _NewsBlockState extends State<NewsBlock> {

  final _categories = <String> ["Canada", "Technology", "Sports"];
  List _sports = [];
  List _tech = [];
  List _national = [];
  bool requested = false;

  List<Widget> _buildNewsCards() {
    return new List<Widget>.generate(_categories.length, (int index) {
      if (index == 0){
        return _buildCard(_categories[index], _national);
      }   else if (index == 1) {
        return _buildCard(_categories[index], _tech);
      }
      else {
        return _buildCard(_categories[index], _sports);
      }});
  }

  _getArticles() async {
    String sports_url = "https://f8893426.ngrok.io/filter?category=sports";
    Response sports_response = await get(sports_url);

    String tech_url = "https://f8893426.ngrok.io/filter?category=technology";
    Response tech_response = await get(tech_url);

    String national_url = "https://f8893426.ngrok.io/filter?country=ca";
    Response national_response = await get(national_url);

    String sports_json = sports_response.body;
    String tech_json = tech_response.body;
    String national_json = national_response.body;

    Map<String,dynamic> sports_map = jsonDecode(sports_json);
    Map<String,dynamic> tech_map = jsonDecode(tech_json);
    Map<String,dynamic> national_map = jsonDecode(national_json);

    List sports_info = sports_map["articles"];
    List tech_info = tech_map["articles"];
    List national_info = national_map["articles"];

    print(sports_info);
    updateValues(sports_info, tech_info, national_info);
  }

  void updateValues(List sports_info, List tech_info, List national_info) {
    setState(() {
      _sports = sports_info;
      _tech = tech_info;
      _national = national_info;
    });
  }

  Widget _buildCard(String category, List info) {

    String title1 = info[0]["title"];
    String title2 = info[1]["title"];
    String title3 = info[2]["title"];

    String url1 = info[0]["url"];
    String url2 = info[1]["url"];
    String url3 = info[2]["url"];

    return new Card(
        color: const Color(0xff232323),
        child: Container(
          margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          width: 350,
          height: 150,
          child: Column(
            children: <Widget>[
              Text(
                category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              Row (
                children: <Widget>[
                  Text (
                    title1,
                  ),
                  RaisedButton (
                    onPressed: _launchURL(url1),
                  ),
                ],
              ),
              Row (
                children: <Widget>[
                  Text (
                    title2,
                  ),
                  RaisedButton (
                    onPressed: _launchURL(url2),
                  ),
                ],
              ),
              Row (
                children: <Widget>[
                  Text (
                    title3,
                  ),
                  RaisedButton (
                    onPressed: _launchURL(url3),
                  ),
                ],
              ),
            ],
          )
        )
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    if (!requested) {
      _getArticles();
      requested = true;
    }

    return Column(
      children: _buildNewsCards()
    );
  }
}

class WeatherBlock extends StatefulWidget {
  WeatherBlock({Key key, this.location}) : super(key: key);

  final String location;
  @override
  _WeatherBlockState createState() => _WeatherBlockState();
}

class _WeatherBlockState extends State<WeatherBlock> {

  List _info = [];
  bool requested = false;

  _makeGetRequest() async {
    String url = "http://api.openweathermap.org/data/2.5/forecast?q=Hamilton,CA&APPID=2eedd160c26afbcc18b9934999f86de8";
    Response response = await get(url);

    int statusCode = response.statusCode;
    print(statusCode);
    String json = response.body;

    Map<String,dynamic> map = jsonDecode(json);

    List info = map["list"];
    updateValues(info);
}

  void updateValues(List info) {
    setState(() {
      _info = info;
    });
  }

  Widget _buildHourlyWeather() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _info.length,
        itemBuilder: (BuildContext context, int index) => _buildHour(_info[index], index)
    );
  }

  Widget _buildHour(Map entry, int time) {

    String iconId = entry['weather'][0]["icon"];

    double celsiusTemp = entry['main']['temp'] - 273.0;
    String temp = "${celsiusTemp.toStringAsFixed(0)} \u00b0";

    print(entry['sys']);
    String timeStamp = "15:00";
    //String timeStamp = "${(time + 15) % 24}:00";

    return new Card(
      color: const Color(0xff121212),
      child: Container(
        width: 60,
        height: 50,
        child: Column(
          children: [
            Image.asset("assets/$iconId.png"),
            Spacer(),
            Text(
              temp,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
            Spacer(),
            Text(
              timeStamp,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
        ]
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    // Already made a request
    if (!requested) {
      _makeGetRequest();
      requested = true;
    }

    return Container(
      height: 160,
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
      color: const Color(0xff121212),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget> [
            Expanded(
              child: _buildHourlyWeather()
            )
          ]
        )
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position _currentPosition = Position(latitude: 0.0, longitude: 0.0);

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  _setLocation(Position position) {
    if (position != null) {
      print(position);
      return "LAT: ${position.latitude}, LNG: ${position.longitude}";
    }
    else {
      return "Null";
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentPosition = _getCurrentLocation();
    final _location = _setLocation(_currentPosition);
    return Scaffold (
      backgroundColor: const Color(0xff121212),
        appBar: null,
        body: ListView (
          padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
          children: <Widget>[
            Container(
              color: const Color(0xff121212),
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset("assets/logo_1.png"),
                ]),
              ),
            Text(
              "Hamilton, ON",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.0,
              ),
            ),
            WeatherBlock(location: _location),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0,0.0,0.0,20.0),
              child: Text(
                "Today's Snapshot",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xff7A9FFF),
                  fontSize: 30.0,
                ),
              ),
            ),
            NewsBlock(),
      ]
        )
      );
    }
}
