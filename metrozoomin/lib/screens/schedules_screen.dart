import 'package:flutter/material.dart';
import 'package:metrozoomin/widgets/universalwidgets.dart';

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
