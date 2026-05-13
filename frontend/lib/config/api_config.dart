import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configuración de URLs según plataforma
  static const String androidEmulatorUrl = 'http://10.0.2.2:5000/api';
  static const String localUrl = 'http://localhost:5000/api';

  static String get url {
    if (kIsWeb) {
      return localUrl;
    }
    // Si estás en un dispositivo físico, deberías usar la IP de tu PC
    return androidEmulatorUrl;
  }
}
