import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'journal/calendar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Text('Hi, Katya 👋', style: TextStyle(
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
                                  builder: (
                                      context) => const CalendarPage()),
                            );
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.pill(),
                          text: 'Meds',
                          color: const Color(0xFFE29E85),
                          onTap: () {
                            // Navigate to Meds screen
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.pencil(),
                          text: 'Tests',
                          color: const Color(0xFF78C0D6),
                          onTap: () {
                            // Navigate to Tests screen
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.articleNyTimes(),
                          text: 'Articles',
                          color: const Color(0xFF746A6A),
                          onTap: () {
                            // Navigate to Articles screen
                          },
                        ),
                        HomeButton(
                          icon: PhosphorIcons.chartPie(),
                          text: 'Stats',
                          color: const Color(0xFF8BACA5),
                          onTap: () {
                            // Navigate to My Stats screen
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
                                          const SizedBox(
                                              width: 120,
                                              child: Text(
                                                  'How do I feel today?',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight
                                                          .bold)))
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
                                      const Text('Ibuprofen, 2 pills',
                                          style: TextStyle(fontSize: 14,)),
                                    ],
                                  ),
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
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    // Image border
                                    child: SizedBox.fromSize(
                                      size: const Size.fromRadius(44),
                                      // Image radius
                                      child: Image.asset(
                                          'assets/images/random_test.png',
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 16,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      const Text('Random test', style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                      SizedBox(
                                        width: 160,
                                        height: 40,
                                        child: Text(
                                            'Take one of our free personality tests',
                                            style: TextStyle(fontSize: 14,
                                                color: Colors.white.withOpacity(0.8))),)
                                    ],
                                  ),
                                ]),),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Featured Tests',
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('All Tests ',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                    PhosphorIcon(PhosphorIconsBold.caretRight, size: 10,)
                              ]),
                              )],
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
                                            style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.5))),
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
                                            style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.5))),
                                      ],
                                    ),),
                                ]),),
                          const SizedBox(height: 20),
                          const Text(
                            'Article of the day',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[200],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Doctor\'s Choice',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 10),
                                Text('How to cure mental illness'),
                                Text('3 min read'),
                              ],
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius : BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              color : Color.fromRGBO(255, 255, 255, 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,

                              children: <Widget>[Container(
                                decoration: const BoxDecoration(

                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,

                                  children: <Widget>[Container(
                                      width: 320,
                                      height: 160,
                                      decoration: const BoxDecoration(

                                      ),
                                      child: Stack(
                                          children: <Widget>[
                                            Positioned(
                                                top: 0,
                                                left: 0,
                                                child: Container(
                                                    width: 320,
                                                    height: 160,
                                                    decoration: const BoxDecoration(
                                                      image : DecorationImage(
                                                          image: AssetImage('assets/images/Image1.png'),
                                                          fit: BoxFit.fitWidth
                                                      ),
                                                    )
                                                )
                                            ),
                                          ]
                                      )
                                  ), const SizedBox(height : 16),
                                    Container(
                                      decoration: const BoxDecoration(

                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,

                                        children: <Widget>[Container(
                                          decoration: const BoxDecoration(

                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,

                                            children: <Widget>[
                                              Text('The Dark Side of Hypomania', textAlign: TextAlign.left, style: TextStyle(
                                                  color: Color.fromRGBO(28, 13, 3, 1),
                                                  fontFamily: 'Nunito',
                                                  fontSize: 16,
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.normal,
                                                  height: 1.25
                                              ),), SizedBox(width : 8),
                                              Text('5 min', textAlign: TextAlign.right, style: TextStyle(
                                                  color: Color.fromRGBO(28, 13, 3, 1),
                                                  fontFamily: 'Nunito',
                                                  fontSize: 12,
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.normal,
                                                  height: 1.3333333333333333
                                              ),),

                                            ],
                                          ),
                                        ), const SizedBox(height : 8),
                                          const Text('Hypomania is a personality style characterized by high energy levels, talkativeness and confidence, ...', textAlign: TextAlign.left, style: TextStyle(
                                              color: Color.fromRGBO(28, 13, 3, 1),
                                              fontFamily: 'Nunito',
                                              fontSize: 12,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.normal,
                                              height: 1.3333333333333333
                                          ),),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ],
                            ),
                          )
                        ],
                      ))
              ),
            ]
        ),),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Doctors'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
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