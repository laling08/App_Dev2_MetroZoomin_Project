import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrozoomin/screens/personalprofile.dart';
import 'package:metrozoomin/screens/auth_screen.dart';
import 'package:metrozoomin/Models/Station.dart';
import 'package:metrozoomin/services/station_service.dart';
import 'package:metrozoomin/services/notification_service.dart';
import 'package:metrozoomin/screens/schedules_screen.dart';
import 'package:metrozoomin/screens/ticket_menu_screen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/Post.dart';
import '../widgets/universalwidgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final StationService _stationService = StationService();
  List<Station> _nearbyStations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyStations();

    // Setup notification listeners
    NotificationService().setupNotificationListeners((notificationId) {
      // Navigate to posts tab when notification is tapped
      setState(() {
        _selectedIndex = 2; // Posts tab index
      });
    });
  }

  @override
  void dispose() {
    NotificationService().disposeNotificationListeners();
    super.dispose();
  }

  Future<void> _loadNearbyStations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For demo purposes, using a fixed location
      final userLocation = const GeoPoint(40.7128, -74.0060); // New York City
      final stations = await _stationService.getNearbyStations(userLocation, 10);

      setState(() {
        _nearbyStations = stations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      _buildHomeTab(),
      const CityMapScreen(),
      const PersonalPostsScreen(),
      const PersonalProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MetroZoomin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          _buildWelcomeSection(),
          const SizedBox(height: 24),

          // Search bar
          _buildSearchBar(),
          const SizedBox(height: 24),

          // Quick actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Nearby stations
          _buildNearbyStations(),
          const SizedBox(height: 24),

          // Recent activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        String username = 'User';
        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          username = userData?['username'] ?? 'User';
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Gold Member',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search stations, routes, or places',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionItem(
              icon: Icons.directions_subway,
              label: 'Find Route',
              color: Colors.blue,
              onTap: () {
                setState(() {
                  _selectedIndex = 1; // Navigate to Map tab
                });
              },
            ),
            _buildActionItem(
              icon: Icons.schedule,
              label: 'Schedules',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SchedulesScreen()),
                );
              },
            ),
            _buildActionItem(
              icon: Icons.credit_card,
              label: 'Ticket Menu',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TicketMenuScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyStations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nearby Stations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to map view
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _nearbyStations.isEmpty
            ? const Center(
          child: Text('No nearby stations found'),
        )
            : SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _nearbyStations.length,
            itemBuilder: (context, index) {
              final station = _nearbyStations[index];
              return _buildStationCard(station);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStationCard(Station station) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Station image
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: station.imageUrl.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(station.imageUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: station.imageUrl.isEmpty
                ? Center(
              child: Icon(
                Icons.train,
                size: 40,
                color: Colors.blue.shade700,
              ),
            )
                : null,
          ),
          // Station info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${station.type} • 0.5 km away',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.train,
                  title: 'Central Station',
                  subtitle: 'Yesterday at 5:30 PM',
                  trailing: 'Check-in',
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.credit_card,
                  title: 'Monthly Pass',
                  subtitle: '3 days ago',
                  trailing: 'Purchase',
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.star,
                  title: 'Westside Station',
                  subtitle: 'Last week',
                  trailing: 'Review',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalPostsScreen extends StatefulWidget {
  const PersonalPostsScreen({super.key});

  @override
  State<PersonalPostsScreen> createState() => _PersonalPostsScreenState();
}

class _PersonalPostsScreenState extends State<PersonalPostsScreen> {
  TextEditingController stationController = new TextEditingController();
  TextEditingController contentController = new TextEditingController();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  Future<List<Map<String, dynamic>>> getPosts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('posts').orderBy('time', descending: true).get();
    List<Map<String, dynamic>> posts = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    return posts;
  }

  Future<void> _fetchPosts() async {
    try {
      List<Map<String, dynamic>> posts = await getPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching posts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildCreatePostSection(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _buildPostCard(post);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCreatePostSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(
              Icons.person,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _showCreatePostDialog();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Share your metro experience...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.photo_camera),
            color: Colors.blue,
            onPressed: () {
              // Open camera
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post['station'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm:ss').format(post['time'].toDate()).toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Show post options
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post['content']),
            const SizedBox(height: 16),
            if (post['imageUrl'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_hasUserLikedPost(post)
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                        color: _hasUserLikedPost(post) ? Colors.blue : null,
                      ),
                      onPressed: () {
                        _likePost(post);
                      },
                    ),
                    Text('${post['likes']}'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Your comments have been disabled by Metro Zoomin.')),
                        );
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing posts has been disabled by Metro Zoomin.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _likePost(Map<String, dynamic> post) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final postId = post['id'];

      final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

      final postSnapshot = await postRef.get();
      if (!postSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post no longer exists')),
        );
        return;
      }

      final postData = postSnapshot.data()!;

      List<String> likedBy = List<String>.from(postData['likedBy'] ?? []);
      int currentLikes = postData['likes'] ?? 0;

      if (likedBy.contains(userId)) {
        post['likes'] = currentLikes - 1;
        post['likedBy'].remove(userId);

        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        post['likes'] = currentLikes + 1;
        post['likedBy'] = [...likedBy, userId];

        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }

      setState(() {
        // rebuild widget
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like: ${e.toString()}')),
      );
    }
  }

  bool _hasUserLikedPost(Map<String, dynamic> post) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    List<String> likedBy = List<String>.from(post['likedBy'] ?? []);
    return likedBy.contains(currentUser.uid);
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .get(),
                        builder: (context, snapshot) {
                          String username = 'Unknown User';
                          if (snapshot.hasData && snapshot.data != null) {
                            final userData = snapshot.data!.data() as Map<String, dynamic>?;
                            username = userData?['username'] ?? 'User';
                          }
                          return Text(
                            username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Public',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'What station are you visiting?',
                  border: InputBorder.none,
                ),
                controller: stationController,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Share your metro experience...',
                  border: InputBorder.none,
                ),
                maxLines: 5,
                controller: contentController,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _postComment();
                    Navigator.pop(context);
                  },
                  child: const Text('Post'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _postComment() async {
    var userData = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get();
    var data = userData.data() as Map<String, dynamic>;
    final uuid = Uuid();
    final customId = uuid.v4();

    Post post = Post(
      id: customId,
      username: data['username'],
      station: stationController.text,
      content: contentController.text,
      imageUrl: "",
      likes: 0,
      time: Timestamp.fromDate(DateTime.now()),
      likedBy: [],
    );

    try {
      await FirebaseFirestore.instance.collection('posts').doc(customId).set(post.toMap());
      print('Post added successfully!');

      // Show notification when a new post is created
      await NotificationService().showNewPostNotification(
        username: data['username'],
        station: stationController.text,
      );

      stationController.clear();
      contentController.clear();
      await _fetchPosts();
    } catch (e) {
      print('Failed to add post: $e');
    }
  }
}

class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key});

  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final StationService _stationService = StationService();
  bool _isLoading = true;
  bool _isShowingDirections = false;

  // Update the API key
  final String _mapsApiKey = 'AIzaSyAYmYgkEZKIWrMY-S0hlPrDJ4zUfxEuXFI';

  // Default camera position (Montreal instead of New York)
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(45.5017, -73.5673), // Montreal coordinates
    zoom: 12.0,
  );

  // Source and destination for directions
  LatLng? _source;
  LatLng? _destination;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For demo purposes, using a fixed location
      final userLocation = const GeoPoint(40.7128, -74.0060); // New York City
      final stations = await _stationService.getNearbyStations(userLocation, 10);

      // Create markers for each station
      for (var station in stations) {
        final marker = Marker(
          markerId: MarkerId(station.name),
          position: LatLng(
            station.location.latitude,
            station.location.longitude,
          ),
          infoWindow: InfoWindow(
            title: station.name,
            snippet: station.type,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            station.type.contains('Metro')
                ? BitmapDescriptor.hueBlue
                : BitmapDescriptor.hueRed,
          ),
          onTap: () {
            _onMarkerTapped(LatLng(
              station.location.latitude,
              station.location.longitude,
            ), station.name);
          },
        );

        _markers.add(marker);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMarkerTapped(LatLng position, String stationName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stationName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _source = position;
                      });
                      Navigator.pop(context);

                      if (_destination != null) {
                        _getDirections();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Now select a destination')),
                        );
                      }
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('Set as Source'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _destination = position;
                      });
                      Navigator.pop(context);

                      if (_source != null) {
                        _getDirections();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Now select a source')),
                        );
                      }
                    },
                    icon: const Icon(Icons.flag),
                    label: const Text('Set as Destination'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getDirections() async {
    if (_source == null || _destination == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_source!.latitude},${_source!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=$_mapsApiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];
          List<LatLng> polylineCoordinates = [];

          for (var step in steps) {
            polylineCoordinates.add(LatLng(
              step['start_location']['lat'],
              step['start_location']['lng'],
            ));
            polylineCoordinates.add(LatLng(
              step['end_location']['lat'],
              step['end_location']['lng'],
            ));
          }

          setState(() {
            _polylines.clear();
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ));
            _isShowingDirections = true;
            _isLoading = false;
          });

          // Fit the map to show the entire route
          if (_mapController != null) {
            final LatLngBounds bounds = _boundsFromLatLngList(polylineCoordinates);
            _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['status']}')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch directions: ${response.statusCode}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error getting directions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? minLat, maxLat, minLng, maxLng;

    for (final latLng in list) {
      if (minLat == null || latLng.latitude < minLat) {
        minLat = latLng.latitude;
      }
      if (maxLat == null || latLng.latitude > maxLat) {
        maxLat = latLng.latitude;
      }
      if (minLng == null || latLng.longitude < minLng) {
        minLng = latLng.longitude;
      }
      if (maxLng == null || latLng.longitude > maxLng) {
        maxLng = latLng.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  void _clearDirections() {
    setState(() {
      _polylines.clear();
      _source = null;
      _destination = null;
      _isShowingDirections = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for stations or places',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Map controls
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.zoomIn(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.zoomOut(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(_initialCameraPosition),
                      );
                    },
                  ),
                ),
                if (_isShowingDirections) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearDirections,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Transit Schedules'),
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Metro'),
                Tab(text: 'REM'),
                Tab(text: 'EXO'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMetroSchedule(),
                _buildREMSchedule(),
                _buildEXOSchedule(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetroSchedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLineHeader('Orange Line', Colors.orange),
          _buildScheduleCard('Montmorency → Côte-Vertu', [
            {'time': '5:30 AM - 12:30 AM', 'frequency': 'Every 3-5 minutes (peak)'},
            {'time': '', 'frequency': 'Every 8-10 minutes (off-peak)'},
          ]),
          const SizedBox(height: 16),

          _buildLineHeader('Green Line', Colors.green),
          _buildScheduleCard('Angrignon → Honoré-Beaugrand', [
            {'time': '5:30 AM - 12:30 AM', 'frequency': 'Every 3-5 minutes (peak)'},
            {'time': '', 'frequency': 'Every 8-10 minutes (off-peak)'},
          ]),
          const SizedBox(height: 16),

          _buildLineHeader('Blue Line', Colors.blue),
          _buildScheduleCard('Snowdon → Saint-Michel', [
            {'time': '5:30 AM - 12:30 AM', 'frequency': 'Every 3-5 minutes (peak)'},
            {'time': '', 'frequency': 'Every 8-10 minutes (off-peak)'},
          ]),
          const SizedBox(height: 16),

          _buildLineHeader('Yellow Line', Colors.amber.shade700),
          _buildScheduleCard('Berri-UQAM → Longueuil', [
            {'time': '5:30 AM - 12:30 AM', 'frequency': 'Every 3-5 minutes (peak)'},
            {'time': '', 'frequency': 'Every 8-10 minutes (off-peak)'},
          ]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildREMSchedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLineHeader('REM Line 1', Colors.lightBlue),
          _buildScheduleCard('Brossard → Gare Centrale', [
            {'time': '5:00 AM - 1:00 AM', 'frequency': 'Every 2-4 minutes (peak)'},
            {'time': '', 'frequency': 'Every 7-15 minutes (off-peak)'},
          ]),
          const SizedBox(height: 16),

          _buildLineHeader('REM Line 2 (Coming Soon)', Colors.purple),
          _buildScheduleCard('Anse-à-l\'Orme → Fairview-Pointe-Claire', [
            {'time': 'Opening 2024', 'frequency': 'Schedule to be announced'},
          ]),
          const SizedBox(height: 16),

          _buildLineHeader('REM Line 3 (Coming Soon)', Colors.teal),
          _buildScheduleCard('Airport → Gare Centrale', [
            {'time': 'Opening 2024', 'frequency': 'Schedule to be announced'},
          ]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEXOSchedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLineHeader('Vaudreuil-Hudson Line', Colors.indigo),
          _buildScheduleCard('Vaudreuil → Lucien-L\'Allier', [
            {'time': 'Weekdays', 'frequency': '6 departures (morning)'},
            {'time': '', 'frequency': '6 departures (evening)'},
          ]),
          const SizedBox(height: 16),

          _buildLineHeader('Saint-Jérôme Line', Colors.deepOrange),
          _buildScheduleCard('Saint-Jérôme → Lucien-L\'Allier', [
            {'time': 'Weekdays', 'frequency': '5 departures (morning)'},
            {'time': '', 'frequency': '5 departures (evening)'},
          ]),
          const SizedBox(height: 16),

          _buildLineHeader('Candiac Line', Colors.brown),
          _buildScheduleCard('Candiac → Lucien-L\'Allier', [
            {'time': 'Weekdays', 'frequency': '4 departures (morning)'},
            {'time': '', 'frequency': '4 departures (evening)'},
          ]),
          const SizedBox(height: 16),

          _buildLineHeader('Mascouche Line', Colors.pink),
          _buildScheduleCard('Mascouche → Gare Centrale', [
            {'time': 'Weekdays', 'frequency': '4 departures (morning)'},
            {'time': '', 'frequency': '4 departures (evening)'},
          ]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLineHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(String route, List<Map<String, String>> schedules) {
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(),
            ...schedules.map((schedule) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (schedule['time']!.isNotEmpty) ...[
                    SizedBox(
                      width: 120,
                      child: Text(
                        schedule['time']!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 120),
                  ],
                  Expanded(
                    child: Text(schedule['frequency']!),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}


class TicketMenuScreen extends StatefulWidget {
  const TicketMenuScreen({super.key});

  @override
  State<TicketMenuScreen> createState() => _TicketMenuScreenState();
}

class _TicketMenuScreenState extends State<TicketMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Ticket Menu'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Single Fares'),
            _buildTicketCard(
              title: 'STM Single Fare',
              price: '\$3.75',
              description: 'Valid for one trip on the Montreal metro or bus network.',
              icon: Icons.directions_subway,
            ),
            _buildTicketCard(
              title: 'REM Single Fare',
              price: '\$4.50',
              description: 'Valid for one trip on the REM light rail network.',
              icon: Icons.train,
            ),
            _buildTicketCard(
              title: 'EXO Single Fare',
              price: '\$5.25 - \$9.75',
              description: 'Price varies by zones. Valid for one trip on the EXO commuter train network.',
              icon: Icons.tram,
            ),

            _buildSectionHeader('Day Passes'),
            _buildTicketCard(
              title: '24-Hour Pass',
              price: '\$11.00',
              description: 'Unlimited travel on STM metro and bus networks for 24 hours.',
              icon: Icons.access_time,
            ),
            _buildTicketCard(
              title: 'Weekend Pass',
              price: '\$14.75',
              description: 'Unlimited travel from Friday 4 PM to Monday 5 AM on STM, REM, and EXO networks.',
              icon: Icons.weekend,
            ),

            _buildSectionHeader('Monthly Passes'),
            _buildTicketCard(
              title: 'STM Monthly Pass',
              price: '\$94.00',
              description: 'Unlimited travel on STM metro and bus networks for one calendar month.',
              icon: Icons.calendar_month,
            ),
            _buildTicketCard(
              title: 'TRAM Monthly Pass',
              price: '\$150.00 - \$255.00',
              description: 'Price varies by zones. Unlimited travel on STM, REM, and EXO networks for one calendar month.',
              icon: Icons.calendar_month,
            ),

            _buildSectionHeader('Special Fares'),
            _buildTicketCard(
              title: 'Reduced Fare (Students)',
              price: '40% off regular price',
              description: 'Available for full-time students with valid ID.',
              icon: Icons.school,
            ),
            _buildTicketCard(
              title: 'Reduced Fare (Seniors)',
              price: '40% off regular price',
              description: 'Available for seniors aged 65 and over.',
              icon: Icons.elderly,
            ),
            _buildTicketCard(
              title: 'Children (Under 12)',
              price: 'Free',
              description: 'Children under 12 travel for free when accompanied by an adult.',
              icon: Icons.child_care,
            ),

            const SizedBox(height: 20),
            _buildPurchaseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTicketCard({
    required String title,
    required String price,
    required String description,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket purchase functionality coming soon!')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Purchase Tickets',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
