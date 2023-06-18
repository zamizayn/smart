import 'package:flutter/material.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

class tab_test_screen extends StatefulWidget {
  const tab_test_screen({Key? key}) : super(key: key);

  @override
  State<tab_test_screen> createState() => _tab_test_screenState();
}

class _tab_test_screenState extends State<tab_test_screen> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          children: [
            Container(
              color: Colors.grey,
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(splashBg),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppBar(
              title: const Text(''),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: TabBar(
                controller: _tabController, // set the TabController
                tabs: [
                  Container(
                      color: Colors.white,
                      child: const Tab(icon: Icon(Icons.flight))),
                  Container(
                      color: Colors.white,
                      child: const Tab(icon: Icon(Icons.directions_transit))),
                ],
                indicatorColor: Colors.red,
                unselectedLabelColor: Colors.lightBlue,
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController, // set the TabController
            children: const [
              Icon(Icons.flight, size: 350),
              Icon(Icons.directions_transit, size: 350),
            ],
          ),
        ),
      ),
    );
  }
}
