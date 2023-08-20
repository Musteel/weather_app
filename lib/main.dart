import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String apiKey = '9df27e2f6c14008b2df2ed6e1bee8eb1';
  String currentWeatherEndpoint =
      'http://api.openweathermap.org/data/2.5/weather';
  String forecastEndpoint = 'http://api.openweathermap.org/data/2.5/forecast';
  String location = 'Stockholm,se';
  Map<String, dynamic> currentWeatherData = {};
  List<dynamic> forecastData = [];

  @override
  void initState() {
    super.initState();
    fetchCurrentWeather();
    fetchForecastWeather();
  }

  Future<void> fetchCurrentWeather() async {
    var url = '$currentWeatherEndpoint?q=$location&appid=$apiKey&units=metric';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        currentWeatherData = jsonDecode(response.body);
      });
    } else {
      // Handle error here
    }
  }

  Future<void> fetchForecastWeather() async {
    var url = '$forecastEndpoint?q=$location&appid=$apiKey&units=metric';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        forecastData = jsonDecode(response.body)['list'];
      });
    } else {
      // Handle error here
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
        ),
        body: SafeArea(
          child: Center(
            child: _buildTabContent(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Current Weather',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Forecast',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }

  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildCurrentWeatherScreen();
      case 1:
        return _buildForecastScreen();
      case 2:
        return _buildAboutScreen();
      default:
        return _buildCurrentWeatherScreen();
    }
  }

  Widget _buildCurrentWeatherScreen() {
    if (currentWeatherData == null ||
        currentWeatherData['main'] == null ||
        currentWeatherData['weather'] == null) {
      // Handle the case when weather data is not available yet
      return const Center(
        child:
            CircularProgressIndicator(), // You can display a loading indicator or an error message here
      );
    }

    double temperature = currentWeatherData['main']['temp'];
    String weatherDescription = currentWeatherData['weather'][0]['description'];
    String iconCode = currentWeatherData['weather'][0]['icon'];

    int temperatureInCelsius =
        temperature.toInt(); // Convert temperature to integer

    Color backgroundColor = _getBackgroundColor(weatherDescription);

    return Container(
      color: backgroundColor,
      child: _buildCurrentWeatherContent(
          temperatureInCelsius, weatherDescription, iconCode),
    );
  }

  Color _getBackgroundColor(String weatherDescription) {
    switch (weatherDescription) {
      case 'clear sky':
        return Colors.blue;
      case 'few clouds':
        return Colors.lightBlue;
      case 'scattered clouds':
        return Colors.blueGrey;
      case 'broken clouds':
        return Colors.grey;
      case 'shower rain':
        return Colors.indigo;
      case 'rain':
        return Colors.indigoAccent;
      case 'thunderstorm':
        return Colors.deepPurple;
      case 'snow':
        return Colors.lightBlueAccent;
      case 'mist':
        return Colors.blueGrey;
      default:
        return Colors.blue;
    }
  }
  

  Widget _buildCurrentWeatherContent(
      int temperatureInCelsius, String weatherDescription, String iconCode) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Stockholm, SE', // Replace with your location name
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'http://openweathermap.org/img/w/$iconCode.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(width: 10),
              Text(
                '$temperatureInCelsius°C',
                style: const TextStyle(fontSize: 40),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            weatherDescription,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Text(
            '${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          // You can add more weather details here, such as humidity, wind, etc.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Humidity',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${currentWeatherData['main']['humidity']}%',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  const Text(
                    'Wind',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${currentWeatherData['wind']['speed']} m/s',
                    style: const TextStyle(fontSize: 18),
                  ),                  
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                fetchCurrentWeather();
                fetchForecastWeather();
              });
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastScreen() {
    // Implement the UI for the forecast screen here
    return ListView.builder(
      itemCount: forecastData.length,
      itemBuilder: (context, index) {
        var forecastItem = forecastData[index];
        var forecastDateTime = DateTime.parse(forecastItem['dt_txt']);
        var forecastTemperature = forecastItem['main']['temp'];
        var forecastIconCode = forecastItem['weather'][0]['icon'];
        var weatherDescription = forecastItem['weather'][0]['description'];


        return ListTile(
          leading: Image.network(
            'http://openweathermap.org/img/w/$forecastIconCode.png',
            width: 50,
            height: 50,
          ),
          title: Text(
            '${forecastDateTime.day}/${forecastDateTime.month} ${forecastDateTime.hour}:00',
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            weatherDescription,
            style: const TextStyle(fontSize: 18),
          ),
          trailing: Text(
            '${forecastTemperature.toInt()}°C',
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }

  Widget _buildAboutScreen() {
    // Implement the UI for the about screen here
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Project Weather',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          Text(
            'This is an app that is developed for the course 1DV535 at Linnaeus University using Flutter and the OpenWeatherMap API.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          Text(
            'Developed by the student Mustafa Ismail.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
