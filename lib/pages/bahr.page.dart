import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bahr_data.dart';
import '../widgets/customappbar.page.dart';
import '../widgets/theme.provider.dart';

class BahrPage extends StatefulWidget {
  const BahrPage({super.key});

  @override
  State<BahrPage> createState() => _BahrPageState();
}

class _BahrPageState extends State<BahrPage> {
  final Map<int, int> _tapCounts = {};
  final CarouselController _carouselController = CarouselController();
  bool _isFullscreen = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTapCounts();
  }

  Future<void> _loadTapCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCounts = prefs.getStringList('bahrTapCounts') ?? [];
    setState(() {
      for (int i = 0; i < savedCounts.length; i++) {
        _tapCounts[i] = int.parse(savedCounts[i]);
      }
    });
  }

  Future<void> _saveTapCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCounts =
        _tapCounts.entries.map((e) => e.value.toString()).toList();
    await prefs.setStringList('bahrTapCounts', savedCounts);
  }

  Future<void> _resetTapCounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bahrTapCounts');
    setState(() {
      _tapCounts.clear();
      _carouselController.jumpToPage(0); // Return to the first card
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);
      }
    });
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد إعادة التعيين'),
          content: Text('هل أنت متأكد من أنك تريد إعادة تعيين جميع القيم؟'),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('نعم'),
              onPressed: () {
                _resetTapCounts();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  double get _completionPercentage {
    final totalCards = bahr.length;
    final completedCards = _tapCounts.entries.where((entry) {
      final index = entry.key;
      final tapCount = entry.value;
      final targetTaps = bahr[index]["targetTaps"] as int;
      return tapCount >= targetTaps;
    }).length;
    return totalCards > 0 ? (completedCards / totalCards) * 100 : 0;
  }

  bool get _allCardsCompleted {
    return bahr.length > 0 &&
        bahr.length ==
            _tapCounts.entries.where((entry) {
              final index = entry.key;
              final tapCount = entry.value;
              final targetTaps = bahr[index]["targetTaps"] as int;
              return tapCount >= targetTaps;
            }).length;
  }

  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'مبارك!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'لقد أتممت قراءة جميع البطاقات!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'لا تنسانا من صالح الدعاء.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('موافق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleTap() {
    setState(() {
      final targetTaps = bahr[_currentIndex]["targetTaps"] as int;
      _tapCounts[_currentIndex] = (_tapCounts[_currentIndex] ?? 0) + 1;
      _saveTapCounts();

      if (_tapCounts[_currentIndex]! >= targetTaps) {
        Future.delayed(Duration(milliseconds: 500), () {
          _carouselController.nextPage();
          if (_allCardsCompleted) {
            _showCongratulationsDialog();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize =
        themeProvider.themeData.textTheme.bodyLarge?.fontSize ?? 24;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: _isFullscreen
              ? null
              : CustomAppBar(
                  isHomePage: false,
                  title: 'حزب البحر المبارك',
                ),
          body: Center(
            child: Stack(
              children: [
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 700.0,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    aspectRatio: 9 / 16,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: Duration(milliseconds: 1800),
                    viewportFraction: 0.8,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: bahr.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> bahrItem = entry.value;
                    int tapCount = _tapCounts[index] ?? 0;
                    int targetTaps = bahrItem["targetTaps"] as int;
                    bool isCompleted = tapCount >= targetTaps;

                    return Builder(
                      builder: (BuildContext context) {
                        return Center(
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: isCompleted
                                ? Colors.green.withOpacity(
                                    0.2) // Light green with transparency
                                : Theme.of(context).cardColor,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        bahrItem["title"]!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isCompleted
                                              ? Colors.grey[600] // Light gray
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.color,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: tapCount >= targetTaps
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$tapCount',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        bahrItem["description"]!,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: isCompleted
                                              ? Colors.grey[600] // Light gray
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  ?.color,
                                        ),
                                        textAlign:
                                            TextAlign.center, // Center the text
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: LinearProgressIndicator(
                    value: _completionPercentage / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: FloatingActionButton(
                        heroTag: "reset",
                        backgroundColor: Colors.red,
                        onPressed: _showResetConfirmationDialog,
                        child: Icon(Icons.refresh),
                      ),
                    )),
                Stack(children: [
                  // Positioned button on the left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: InkWell(
                        onTap: (_tapCounts[_currentIndex] ?? 0) >=
                            (bahr[_currentIndex]["targetTaps"] as int)
                            ? null
                            : _handleTap,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(40), // Match borderRadius of Container
                        ),
                        child: Container(
                          width: 60, // Same width as the original button
                          height: 160, // Height is three times the original height
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.5), // Semi-transparent blue
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(40), // Semi-circular shape on the left
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2), // Shadow effect
                              ),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.center, // Center the icon within the container
                            child: Icon(
                              Icons.fingerprint,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: InkWell(
                        onTap: (_tapCounts[_currentIndex] ?? 0) >=
                            (bahr[_currentIndex]["targetTaps"] as int)
                            ? null
                            : _handleTap,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(40), // Match borderRadius of Container
                        ),
                        child: Container(
                          width: 60, // Same width as the original button
                          height: 160, // Height is three times the original height
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.5), // Semi-transparent blue
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(40), // Semi-circular shape on the left
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2), // Shadow effect
                              ),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.center, // Center the icon within the container
                            child: Icon(
                              Icons.fingerprint,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: BahrPage(),
    ),
  );
}
