import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../senha.dart';

class ClimaService {
  static const String apiKey = openWeatherApiKey;

  static Future<Position> buscarLocalizacao() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return Future.error("Por favor, ative o GPS.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Permissão de localização negada.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Permissão de localização negada permanentemente. Habilite nas configurações.");
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  }

  static Future<Map<String, dynamic>> buscarClimaAtual() async {
    try {
      final pos = await buscarLocalizacao();

      final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?"
        "lat=${pos.latitude}&lon=${pos.longitude}"
        "&units=metric&lang=pt_br&appid=$openWeatherApiKey",
      );

      final resposta = await http.get(url);

      if (resposta.statusCode != 200) {
        throw Exception("Erro ao buscar clima: ${resposta.statusCode}");
      }

      final data = json.decode(resposta.body);

      return {
        "cidade": data["name"],
        "temperatura": data["main"]["temp"],
        "icone": data["weather"][0]["icon"],
      };
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
