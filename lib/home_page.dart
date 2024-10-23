import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentallica/articles/articles_page.dart';
import 'package:mentallica/journal/journal_entry_page.dart';
import 'package:mentallica/meds/medication_list_page.dart';
import 'package:mentallica/schedule/schedule_page.dart';
import 'package:mentallica/statistics/statistics_page.dart';
import 'package:mentallica/tests/autism/aqtest.dart';
import 'package:mentallica/tests/autism/catqtest.dart';
import 'package:mentallica/tests/autism/rbq2atest.dart';
import 'package:mentallica/tests/depression/phq9.dart';
import 'package:mentallica/tests/tests_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'articles/add_article_page.dart';
import 'auth/auth.dart';
import 'journal/calendar.dart';
import 'meds/pill_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? role = 'Patient';
  String? name = 'User';

  final List<Widget> testPages = [
    CATQTestPage(),
    RBQ2ATestPage(),
    AQTestPage(),
  ];

  @override
  void initState() {
    super.initState();
    _getUserRoleAndName();
  }

  Future<void> _getUserRoleAndName() async {
    String? userRole = await Auth().getUserField('role');
    String? userName = await Auth().getUserField('name');

    setState(() {
      if (userRole != '' && userRole != null && userName != null && userName != '') {
        role = userRole;
        name = userName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (role == null || name == null) {
      return const CircularProgressIndicator();
    }

    if (role == 'Patient') {
      return _buildPatientHomePage();
    } else if (role == 'Doctor') {
      return _buildDoctorHomePage();
    } else {
      return const Center(child: Text('Please register or login.'));
    }
  }

  Widget _buildPatientHomePage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: SvgPicture.asset(
            'assets/images/logo.svg', height: 40),
        actions: [
          IconButton(icon: PhosphorIcon(PhosphorIcons.bell(), size: 28,),
              onPressed: () {}),
          IconButton(
              icon: PhosphorIcon(PhosphorIcons.slidersHorizontal(), size: 28,),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi, $name 👋', style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 32),),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HomeButton(
                          icon: PhosphorIcons.smiley(),
                          text: 'Journal',
                          color: const Color(0xFFEEC27F),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CalendarPage()),
                            );
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.pill(),
                          text: 'Meds',
                          color: const Color(0xFFE29E85),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MedicationPage()),
                            );
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.pencil(),
                          text: 'Tests',
                          color: const Color(0xFF78C0D6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TestsPage()),
                            );
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.articleNyTimes(),
                          text: 'Articles',
                          color: const Color(0xFF746A6A),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ArticlesPage(isDoctor: role == 'Doctor' ? true : false)),
                            );
                            },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.chartPie(),
                          text: 'Stats',
                          color: const Color(0xFF8BACA5),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StatisticsPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],),),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFFFAF1EA),
                  ),
                  child:
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Container(
                                  width: 180,
                                  height: 120,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          PhosphorIcon(
                                              PhosphorIcons.smiley(),
                                              color: const Color(
                                                  0xFFEEC27F), size: 32),
                                          const SizedBox(height: 4),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                  builder: (context) => JournalEntryPage(date: DateTime.now())));
                                            },
                                            child: const SizedBox(
                                              width: 120,
                                              child: Text(
                                                'How do I feel today?',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 180,
                                  height: 120,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                  ),
                                  child: NextPillWidget(),
                                ),
                              ]
                          ),
                          const SizedBox(height: 10),
                      Container(
                        width: 380,
                        height: 120,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF8BACA5),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            final randomIndex = Random().nextInt(testPages.length);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => testPages[randomIndex]),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox.fromSize(
                                  size: const Size.fromRadius(44),
                                  child: Image.asset(
                                    'assets/images/random_test.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Random test',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 160,
                                    height: 40,
                                    child: Text(
                                      'Take one of our free personality tests',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Featured Tests',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const TestsPage()));
                                },
                                child:
                                Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius
                                      .all(
                                    Radius.circular(15.0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child:
                                const Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: [
                                      Text('All Tests ',
                                        style: TextStyle(fontSize: 14,
                                            fontWeight: FontWeight.bold),),
                                      PhosphorIcon(
                                        PhosphorIconsBold.caretRight, size: 10,)
                                    ]),
                              ),)
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PHQ9TestPage()),
                              );
                            },
                            child: Container(
                              width: 380,
                              height: 96,
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: SizedBox.fromSize(
                                      size: const Size.fromRadius(32),
                                      child: Image.asset(
                                        'assets/images/depression.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 254,
                                    height: 100,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Depression Test',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '1 min',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black.withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Based on the Beck Depression Inventory, which measures depression symptoms.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CATQTestPage()),
                              );
                            },
                            child: Container(
                              width: 380,
                              height: 96,
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: SizedBox.fromSize(
                                      size: const Size.fromRadius(32),
                                      child: Image.asset(
                                        'assets/images/autism.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 254,
                                    height: 100,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Autism Spectrum Test',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '3 min',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black.withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Measuring Autism Spectrum Disorders across 10 different scales.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ))
              ),
            ]
        ),),
    );
  }

  Widget _buildDoctorHomePage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: SvgPicture.asset(
            'assets/images/logo.svg', height: 40),
        actions: [
          IconButton(icon: PhosphorIcon(PhosphorIcons.bell(), size: 28,),
              onPressed: () {}),
          IconButton(
              icon: PhosphorIcon(PhosphorIcons.slidersHorizontal(), size: 28,),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi, $name 👋', style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 32),),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HomeButton(
                          icon: PhosphorIcons.addressBookTabs(),
                          text: 'Sessions',
                          color: const Color(0xFFEEC27F),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CalendarPage()),
                            );
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.pencil(),
                          text: 'Schedule',
                          color: const Color(0xFFE29E85),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ScheduleForm.empty()),
                            );
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.articleNyTimes(),
                          text: 'Articles',
                          color: const Color(0xFF746A6A),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ArticlesPage(isDoctor: role == 'Doctor' ? true : false)),
                            );
                            // Navigate to Articles screen
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.pill(),
                          text: 'Meds',
                          color: const Color(0xFF8BACA5),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MedicationPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],),),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFFFAF1EA),
                  ),
                  child:
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Container(
                                  width: 180,
                                  height: 120,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          PhosphorIcon(
                                              PhosphorIcons.articleNyTimes(),
                                              color: const Color(
                                                  0xFFEEC27F), size: 32),
                                          const SizedBox(height: 4),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => AddArticlePage()));
                                            },
                                            child: const SizedBox(
                                              width: 120,
                                              child: Text(
                                                'Want to write an article?',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 180,
                                  height: 120,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE29E85)
                                              .withOpacity(0.2),
                                          borderRadius: const BorderRadius
                                              .all(
                                            Radius.circular(15.0),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 8.0),
                                        child: const Text('Today',
                                          style: TextStyle(fontSize: 14,
                                              color: Color(0xFFE29E85)),),
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: [
                                          const Text(
                                            '12:00', style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),),
                                          const SizedBox(width: 5),
                                          PhosphorIcon(
                                              PhosphorIcons.clock(),
                                              size: 20)
                                        ],
                                      ),
                                      const Text('Semen Petrov',
                                          style: TextStyle(fontSize: 14,)),
                                    ],
                                  ),
                                ),
                              ]
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Medication Info',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius
                                      .all(
                                    Radius.circular(15.0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child:
                                const Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: [
                                      Text('See All ',
                                        style: TextStyle(fontSize: 14,
                                            fontWeight: FontWeight.bold),),
                                      PhosphorIcon(
                                        PhosphorIconsBold.caretRight, size: 10,)
                                    ]),
                              )
                            ],
                          ),
                          Container(
                            width: 380,
                            height: 96,
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    // Image border
                                    child: SizedBox.fromSize(
                                      size: const Size.fromRadius(32),
                                      // Image radius
                                      child: Image.asset(
                                          'assets/images/depression.png',
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 16,),
                                  SizedBox(
                                    width: 254,
                                    height: 100,
                                    child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: [
                                              const Text('Depression Test',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .bold)),
                                              Text('3 min',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black
                                                          .withOpacity(
                                                          0.5))),
                                            ]),
                                        Text(
                                            'Based on the Beck Depression Inventory, which measures depression symptoms.',
                                            style: TextStyle(fontSize: 13,
                                                color: Colors.black.withOpacity(
                                                    0.5))),
                                      ],
                                    ),),
                                ]),),
                          Container(
                            width: 380,
                            height: 96,
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    // Image border
                                    child: SizedBox.fromSize(
                                      size: const Size.fromRadius(32),
                                      // Image radius
                                      child: Image.asset(
                                          'assets/images/autism.png',
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 16,),
                                  SizedBox(
                                    width: 254,
                                    height: 100,
                                    child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: [
                                              const Text('Autism Spectrum Test',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .bold)),
                                              Text('5 min',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black
                                                          .withOpacity(
                                                          0.5))),
                                            ]),
                                        Text(
                                            'Measuring Autism Spectrum Disorders across 10 different scales.',
                                            style: TextStyle(fontSize: 13,
                                                color: Colors.black.withOpacity(
                                                    0.5))),
                                      ],
                                    ),),
                                ]),),
                          Container(
                            width: 380,
                            height: 96,
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    // Image border
                                    child: SizedBox.fromSize(
                                      size: const Size.fromRadius(32),
                                      // Image radius
                                      child: Image.asset(
                                          'assets/images/depression.png',
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 16,),
                                  SizedBox(
                                    width: 254,
                                    height: 100,
                                    child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: [
                                              const Text('Depression Test',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .bold)),
                                              Text('3 min',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black
                                                          .withOpacity(
                                                          0.5))),
                                            ]),
                                        Text(
                                            'Based on the Beck Depression Inventory, which measures depression symptoms.',
                                            style: TextStyle(fontSize: 13,
                                                color: Colors.black.withOpacity(
                                                    0.5))),
                                      ],
                                    ),),
                                ]),),
                          Container(
                            width: 380,
                            height: 96,
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    // Image border
                                    child: SizedBox.fromSize(
                                      size: const Size.fromRadius(32),
                                      // Image radius
                                      child: Image.asset(
                                          'assets/images/autism.png',
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 16,),
                                  SizedBox(
                                    width: 254,
                                    height: 100,
                                    child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: [
                                              const Text('Autism Spectrum Test',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .bold)),
                                              Text('5 min',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black
                                                          .withOpacity(
                                                          0.5))),
                                            ]),
                                        Text(
                                            'Measuring Autism Spectrum Disorders across 10 different scales.',
                                            style: TextStyle(fontSize: 13,
                                                color: Colors.black.withOpacity(
                                                    0.5))),
                                      ],
                                    ),),
                                ]),),
                          const SizedBox(height: 20),
                        ],
                      ))
              ),
            ]
        ),),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const HomeButton({super.key, required this.icon, required this.text, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
        Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color,
        ),
        child: PhosphorIcon(
          icon,
          color: Colors.white,
          size: 32,
        )
      ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ]
    )
    );
  }
}