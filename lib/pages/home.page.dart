import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/widgets/customappbar.page.dart';
import 'package:flutter_app/widgets/theme.provider.dart'; // Ensure the actualities data is correctly imported

import '../data/actuality_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: Directionality(
        textDirection: TextDirection.rtl, // RTL for Arabic support
        child: Scaffold(
          appBar: CustomAppBar(isHomePage: true, title: 'أقوال و حكم'),
          body: HomePageContent(),
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<Map<String, dynamic>> _randomActualities;

  @override
  void initState() {
    super.initState();
    _randomActualities = _getRandomActualities();
  }

  List<Map<String, dynamic>> _getRandomActualities() {
    List<Map<String, dynamic>> shuffledActualities = List.from(actualities);
    shuffledActualities.shuffle(Random());
    return shuffledActualities.take(5).toList(); // Adjust the number as needed
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize =themeProvider.themeData.textTheme.bodyLarge?.fontSize ?? 22;

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical, // Set sliding direction to vertical
          itemCount: _randomActualities.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final actuality = _randomActualities[index];
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actuality['title'] ?? '',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.headline6?.color ?? Colors.blueAccent, // Use theme color
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            actuality['description'] ?? '',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: theme.textTheme.bodyText1?.color ?? Colors.black87, // Use theme color
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: FloatingActionButton(
            heroTag: 'prev',
            onPressed: _currentPage > 0
                ? () {
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
                : null,
            backgroundColor: _currentPage > 0 ? Colors.blue : Colors.grey,
            child: Icon(Icons.arrow_upward),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'next',
            onPressed: _currentPage < _randomActualities.length - 1
                ? () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
                : null,
            backgroundColor: _currentPage < _randomActualities.length - 1
                ? Colors.blue
                : Colors.grey,
            child: Icon(Icons.arrow_downward),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: HomePage(),
    ),
  );
}
