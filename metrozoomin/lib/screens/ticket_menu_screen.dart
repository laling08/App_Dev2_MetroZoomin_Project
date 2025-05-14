import 'package:flutter/material.dart';
import 'package:metrozoomin/widgets/universalwidgets.dart';

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
