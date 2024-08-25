import 'package:flutter/material.dart';
import 'package:flutter_app/pages/experience.page.dart';
import 'package:flutter_app/pages/home.page.dart';
import 'package:flutter_app/widgets/theme.provider.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'pages/bahr.page.dart';
import 'pages/rifaia.page.dart';
import 'pages/dailywerd.page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          builder: (context, widget) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: widget!,
            );
          },
          home: MainScreen(),
          routes: {
            '/home': (context) => HomePage(),
            // Other routes can be added here
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _indexPages = 0;
  late TabController _tabController;

  final List<Widget> _pages = [
    HomePage(),
    DailyWerdPage(),
    ExperiencePage(),
    RifaiaPage(),
    BahrPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_indexPages],
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        color: Colors.green,
        backgroundColor: Theme.of(context).colorScheme.background,
        items: [
          Icon(
            Icons.feed,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.handshake_outlined,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.security_sharp,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.star_border_outlined,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.waves,
            size: 30,
            color: Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _indexPages = index;
            _tabController.index = index;
          });
        },
        animationCurve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
