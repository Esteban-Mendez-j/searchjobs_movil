import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/cache_storage.dart';
import 'core/storage/token_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/prediction_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/prediction_service.dart';
import 'ui/view_models/auth_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lee el archivo .env de la raíz (ENV, MOCK_URL, PROD_URL).
  await AppConfig.load();

  // Composición de dependencias (DI manual).
  final tokenStorage = TokenStorage();
  final cacheStorage = CacheStorage(await SharedPreferences.getInstance());
  final apiClient = ApiClient(
    client: http.Client(),
    tokenStorage: tokenStorage,
  );

  final authRepository = AuthRepository(
    AuthService(apiClient),
    tokenStorage,
    cacheStorage,
  );
  final predictionRepository = PredictionRepository(
    PredictionService(apiClient),
    cacheStorage,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<PredictionRepository>.value(value: predictionRepository),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository, apiClient)..init(),
        ),
      ],
      child: const SearchJobsApp(),
    ),
  );
}
