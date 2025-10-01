// ... ostali importovi na vrhu
import 'package:sdmt_final/screens/live_data_screen.dart';

// ... unutar MiniToolApp widgeta ...
      routes: {
        '/': (context) => const MainMenuScreen(),
        '/testList': (context) => const TestListScreen(),
        '/testScreen': (context) => const TestScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/about': (context) => const AboutScreen(),
        '/liveData': (context) => const LiveDataScreen(), // <-- DODAJTE OVU LINIJU
      },
// ... ostatak koda