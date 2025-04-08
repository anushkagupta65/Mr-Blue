import 'package:flutter/material.dart';
import 'package:mr_blue/src/presentation/home/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [HomeScreen()];

  void _onItemTapped(int index) {
    if (index == 0 || index == 1) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 2) {
      // call();
    } else if (index == 3) {
      // openWhatsApp();
    }
  }

  Future<void> openWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/7011744407');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> call() async {
    final Uri telUri = Uri(scheme: 'tel', path: '8588882929');
    final status = await Permission.phone.request();

    if (status.isGranted) {
      try {
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        } else {
          throw 'Could not launch dialer';
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('Phone permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade800,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 1,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey,
          letterSpacing: 1,
          fontSize: 12,
        ),
        unselectedIconTheme: IconThemeData(color: Colors.white70),
        selectedIconTheme: IconThemeData(color: Colors.white),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'WhatsApp',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int) {
          _onItemTapped(int);
        },
        type: BottomNavigationBarType.fixed,
      ),
      body: _pages[_selectedIndex],
    );
  }
}
