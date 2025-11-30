import 'package:geolocator/geolocator.dart';

class LocalizacaoService {
  Future<Position> getPosicao() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception("Por favor, ative o GPS para continuar.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Permissão de localização negada.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Permissão de localização negada permanentemente. Por favor, habilite nas configurações.");
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  }
}
