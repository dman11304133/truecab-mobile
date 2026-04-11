import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import 'package:intl/intl.dart';

class ScheduledMarketplace extends StatefulWidget {
  const ScheduledMarketplace({super.key});

  @override
  State<ScheduledMarketplace> createState() => _ScheduledMarketplaceState();
}

class _ScheduledMarketplaceState extends State<ScheduledMarketplace> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
    super.initState();
  }

  _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await getScheduledRides();
    await getMyClaimedRides();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: page,
      appBar: AppBar(
        backgroundColor: page,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: textColor),
        ),
        title: MyText(
          text: languages[choosenLanguage]['text_scheduled_marketplace'],
          size: media.width * 0.05,
          fontweight: FontWeight.w600,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: buttonColor,
          labelColor: buttonColor,
          unselectedLabelColor: hintColor,
          tabs: [
            Tab(text: languages[choosenLanguage]['text_available_rides']),
            Tab(text: languages[choosenLanguage]['text_my_claims']),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRideList(scheduledRides, true),
                _buildRideList(myClaimedRides, false),
              ],
            ),
    );
  }

  Widget _buildRideList(List rides, bool isAvailable) {
    var media = MediaQuery.of(context).size;

    if (rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 60, color: hintColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            MyText(
              text: isAvailable ? languages[choosenLanguage]['text_no_ride_in_area'] : languages[choosenLanguage]['text_no_data_found'],
              size: media.width * 0.04,
              color: hintColor,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          var ride = rides[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: buttonColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: MyText(
                        text: ride['request_number'],
                        size: 12,
                        color: buttonColor,
                        fontweight: FontWeight.bold,
                      ),
                    ),
                    MyText(
                      text: '${ride['currency_symbol']}${ride['request_eta_amount']}',
                      size: 16,
                      fontweight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    MyText(
                      text: ride['trip_start_time'],
                      size: 14,
                      fontweight: FontWeight.w500,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildLocationRow(Icons.circle, Colors.green, ride['pick_address']),
                const Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: SizedBox(height: 10, child: VerticalDivider(width: 1)),
                ),
                _buildLocationRow(Icons.location_on, Colors.red, ride['drop_address']),
                const SizedBox(height: 16),
                if (isAvailable)
                  Button(
                    onTap: () async {
                      _showConfirmDialog(ride);
                    },
                    text: languages[choosenLanguage]['text_claim_ride'],
                    color: buttonColor,
                    textcolor: Colors.white,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String address) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: MyText(
            text: address,
            size: 13,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  _showConfirmDialog(dynamic ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languages[choosenLanguage]['text_confirm']),
        content: Text(languages[choosenLanguage]['text_confirmridelater']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languages[choosenLanguage]['text_cancel']),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (!mounted) return;
              setState(() => _isLoading = true);
              var result = await claimScheduledRide(ride['id']);
              if (!mounted) return;
              if (result == 'success') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(languages[choosenLanguage]['text_rideLaterSuccess'])),
                );
                _fetchData();
              } else {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.toString())),
                );
              }
            },
            child: Text(languages[choosenLanguage]['text_confirm']),
          ),
        ],
      ),
    );
  }
}
