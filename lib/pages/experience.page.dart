import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/customappbar.page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/experiences_data.dart';
import '../widgets/theme.provider.dart'; // For SystemChrome

class ExperiencePage extends StatefulWidget {
  const ExperiencePage({super.key});

  @override
  State<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
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
    final savedCounts = prefs.getStringList('tapCounts') ?? [];
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
    await prefs.setStringList('tapCounts', savedCounts);
  }

  Future<void> _resetTapCounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tapCounts');
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
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.color, // Adapt color to theme
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

  bool get _allExperiencesCompleted {
    // Check if each card's tap count has reached its target value
    return experiences.asMap().entries.every((entry) {
      final index = entry.key;
      final targetTaps = entry.value["targetTaps"] as int;
      final tapCount = _tapCounts[index] ?? 0;
      return tapCount >= targetTaps;
    });
  }

  double get _progressValue {
    // Calculate the progress based on completed cards
    final totalExperiences = experiences.length;
    final completedExperiences = experiences.asMap().entries.where((entry) {
      final index = entry.key;
      final targetTaps = entry.value["targetTaps"] as int;
      final tapCount = _tapCounts[index] ?? 0;
      return tapCount >= targetTaps;
    }).length;
    return totalExperiences > 0 ? completedExperiences / totalExperiences : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize =
        themeProvider.themeData.textTheme.bodyMedium?.fontSize ?? 24.0;

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
                    title: 'التحصين',
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
                    items: experiences.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> experience = entry.value;
                      int tapCount = _tapCounts[index] ?? 0;
                      int targetTaps = experience["targetTaps"] as int;
                      bool isCompleted = tapCount >= targetTaps;

                      return Builder(
                        builder: (BuildContext context) {
                          final textColor =
                              Theme.of(context).textTheme.bodyText1?.color;

                          return Center(
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: isCompleted
                                  ? Colors.green.withOpacity(0.2)
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
                                          experience["title"]!,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isCompleted
                                                ? Colors.grey[600]
                                                : textColor,
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
                                          experience["description"]!,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            color: isCompleted
                                                ? Colors.grey[600]
                                                : textColor,
                                          ),
                                          textAlign: TextAlign.center,
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
                      value: _progressValue,
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
                    ),)
                  ),
              Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: InkWell(
                        onTap: (_tapCounts[_currentIndex] ?? 0) >=
                            (experiences[_currentIndex]["targetTaps"] as int)
                            ? null
                            : () {
                          setState(() {
                            _tapCounts[_currentIndex] =
                                (_tapCounts[_currentIndex] ?? 0) + 1;
                            _saveTapCounts();
                            if (_tapCounts[_currentIndex] ==
                                experiences[_currentIndex]["targetTaps"]) {
                              Future.delayed(Duration(seconds: 1), () {
                                if (_allExperiencesCompleted) {
                                  _showCongratulationsDialog();
                                } else {
                                  _carouselController.nextPage();
                                }
                              });
                            }
                          });
                        },
                        borderRadius: BorderRadius.horizontal(
                          left : Radius.circular(40), // Semi-circular shape on the left
                        ),
                        child: Container(
                          width: 60, // Width of the button
                          height: 160, // Height is three times the original height
                          decoration: BoxDecoration(
                            color: (_tapCounts[_currentIndex] ?? 0) >=
                                (experiences[_currentIndex]["targetTaps"] as int)
                                ? Colors.grey // Use a disabled color when completed
                                : Colors.blue.withOpacity(0.5), // Semi-transparent blue
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: InkWell(
                        onTap: (_tapCounts[_currentIndex] ?? 0) >=
                            (experiences[_currentIndex]["targetTaps"] as int)
                            ? null
                            : () {
                          setState(() {
                            _tapCounts[_currentIndex] =
                                (_tapCounts[_currentIndex] ?? 0) + 1;
                            _saveTapCounts();
                            if (_tapCounts[_currentIndex] ==
                                experiences[_currentIndex]["targetTaps"]) {
                              Future.delayed(Duration(seconds: 1), () {
                                if (_allExperiencesCompleted) {
                                  _showCongratulationsDialog();
                                } else {
                                  _carouselController.nextPage();
                                }
                              });
                            }
                          });
                        },
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(40), // Semi-circular shape on the right
                        ),
                        child: Container(
                          width: 60, // Width of the button
                          height: 160, // Height is three times the original height
                          decoration: BoxDecoration(
                            color: (_tapCounts[_currentIndex] ?? 0) >=
                                (experiences[_currentIndex]["targetTaps"] as int)
                                ? Colors.grey // Use a disabled color when completed
                                : Colors.blue.withOpacity(0.5), // Semi-transparent blue
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(40), // Semi-circular shape on the right
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
        ));
  }
}
