import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderunnertask1/mapbox/mapbox_page.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:riderunnertask1/module/location_page/location_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> selectbody = <Widget>[
    MapBoxPage(),
    LocationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: selectbody.elementAt(_selectedIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: BottomNavyBar(
          selectedIndex: _selectedIndex,
          showElevation: true, // use this to remove appBar's elevation
          onItemSelected: (index) => setState(() {
            _selectedIndex = index;
          }),
          items: [
            BottomNavyBarItem(
              icon: Icon(Icons.location_on_outlined),
              title: Text('Maps'),
              activeColor: Colors.green,
            ),
            BottomNavyBarItem(
                icon: Icon(Icons.people),
                title: Text('Users'),
                activeColor: Colors.green
            ),
          ],
        ),
      ),
    );
  }
}
