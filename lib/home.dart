import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'analysis.dart';
import 'contact.dart';
import 'Loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String rollNumber;

  const HomePage({super.key, required this.username, required this.rollNumber});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _title = 'Home';

  late List<Widget> _pages;

  // Variables for date and time
  String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());
  String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

  // Meal wastage variables for today (initialized to 0)
  double totalBreakfastWasted = 0.0;
  double totalLunchWasted = 0.0;
  double totalDinnerWasted = 0.0;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeContent(),
      AnalysisPage(username: widget.username, rollNumber: widget.rollNumber),
      const ContactPage(),
    ];
    _updateTime();
    _fetchMealWastageData();
  }

  // Function to update the time every minute instead of every second
  void _updateTime() {
    Future.delayed(const Duration(minutes: 1), () {
      setState(() {
        formattedTime = DateFormat('hh:mm a').format(DateTime.now());
        formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());
      });
      _updateTime(); // Repeat the update every minute
    });
  }

  // Fetch today's meal wastage data from Firestore
  void _fetchMealWastageData() async {
    try {
      // Get today's index (0 = Monday, 1 = Tuesday, ..., 6 = Sunday)
      int todayIndex = DateTime.now().weekday - 1; // DateTime.weekday returns 1 for Monday, 7 for Sunday

      // Fetch the document from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('food_wastage')
          .doc(widget.rollNumber)
          .get();

      if (doc.exists) {
        // Retrieve the 'wasteData' map from the document
        Map<String, dynamic> wasteData = doc['wasteData'] ?? {};

        // Get the daily data for breakfast, lunch, and dinner
        List<dynamic> breakfastData = wasteData['breakfast'] ?? [];
        List<dynamic> lunchData = wasteData['lunch'] ?? [];
        List<dynamic> dinnerData = wasteData['dinner'] ?? [];

        // Get today's wasted value from each meal list based on today's index
        setState(() {
          totalBreakfastWasted = _getWastedAmount(breakfastData, todayIndex);
          totalLunchWasted = _getWastedAmount(lunchData, todayIndex);
          totalDinnerWasted = _getWastedAmount(dinnerData, todayIndex);
        });

        // Debug prints to check values
        print('Today\'s Breakfast Wasted: $totalBreakfastWasted');
        print('Today\'s Lunch Wasted: $totalLunchWasted');
        print('Today\'s Dinner Wasted: $totalDinnerWasted');
      } else {
        print('No document found for rollNumber: ${widget.rollNumber}');
      }
    } catch (e) {
      print('Error fetching meal wastage data: $e');
    }
  }

  // Helper function to return wasted amount, ensuring null safety
  double _getWastedAmount(List<dynamic> data, int todayIndex) {
    if (data.length > todayIndex && data[todayIndex] is double) {
      return data[todayIndex] as double;
    }
    return 0.0;
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildUserCard()), // User card
              const SizedBox(width: 40),
              Expanded(child: _buildTimeCard()), // Time and Date display card
            ],
          ),
          const SizedBox(height: 20),
          _buildMealCard('Breakfast', totalBreakfastWasted, Icons.free_breakfast, Colors.orangeAccent),
          _buildMealCard('Dinner', totalDinnerWasted, Icons.dinner_dining, Colors.purpleAccent),
          _buildMealCard('Lunch', totalLunchWasted, Icons.lunch_dining, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade300, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Name: ${widget.username}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            'Roll Number: ${widget.rollNumber}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String meal, double wasted, IconData icon, Color color) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          meal,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          'Wasted: ${wasted.toStringAsFixed(2)} units',
          style: const TextStyle(fontSize: 14, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    bool shouldLogout = await _showLogoutDialog();
    if (shouldLogout) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), // Redirect to Login Page
      );
    }
  }

  // Confirm logout with a dialog
  Future<bool> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.contact_mail), label: 'Contact'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _title = 'Home';
          break;
        case 1:
          _title = 'Analysis';
          break;
        case 2:
          _title = 'Contact';
          break;
      }
    });
  }
}
