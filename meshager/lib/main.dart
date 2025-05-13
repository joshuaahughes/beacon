import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/meshtastic_provider.dart';
import 'providers/map_provider.dart';
import 'package:meshager/services/meshtastic_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final meshtasticService = MeshtasticService();
  print('Initializing MeshtasticService...');
  await meshtasticService.initialize();
  print('MeshtasticService initialized');
  
  runApp(MyApp(meshtasticService: meshtasticService));
}

class MyApp extends StatelessWidget {
  final MeshtasticService meshtasticService;
  
  const MyApp({super.key, required this.meshtasticService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MeshtasticProvider(meshtasticService),
        ),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: MaterialApp(
        title: 'Meshager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.blue,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
