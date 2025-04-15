import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';

class PriceList extends StatefulWidget {
  const PriceList({super.key});

  @override
  State<PriceList> createState() => _PriceListState();
}

class _PriceListState extends State<PriceList>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  List<String> serviceNames = ['Dry Cleaning', 'Laundry'];
  List<String> uniqueSubtrades = [];
  List<Map<String, dynamic>> filteredItems = [];
  String? selectedSubtrade;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: serviceNames.length, vsync: this);
    filterItemsByService(serviceNames[0]); // Initialize with first service
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  void filterItemsByService(String service) {
    setState(() {
      uniqueSubtrades =
          service == 'Dry Cleaning'
              ? ['Suits', 'Dresses', 'Jackets']
              : ['Shirts', 'Pants', 'Bedding'];
      selectedSubtrade = uniqueSubtrades.isNotEmpty ? uniqueSubtrades[0] : null;
      filterItemsBySubtrade(selectedSubtrade ?? '');
    });
  }

  void filterItemsBySubtrade(String subtrade) {
    setState(() {
      selectedSubtrade = subtrade;
      filteredItems = List.generate(
        13,
        (index) => {
          'item_name': '$subtrade Item ${index + 1}',
          'min_price': 100 + (index * 10),
          'max_price': 150 + (index * 10),
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Price List"),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.blue.shade50),
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.white,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelColor: Colors.black,
                indicatorPadding: EdgeInsets.all(6),
                dividerColor: Colors.blue[900],
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[800]!,
                      Colors.blue[400]!,
                      Colors.blue[800]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                controller: tabController,
                tabs:
                    serviceNames
                        .map((service) => Tab(text: service.toUpperCase()))
                        .toList(),
                onTap: (index) {
                  filterItemsByService(serviceNames[index]);
                },
              ),
              SizedBox(height: 10),
              // Subtrades Horizontal List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: uniqueSubtrades.length,
                    itemBuilder: (context, index) {
                      final subtrade = uniqueSubtrades[index];
                      bool isSelected = subtrade == selectedSubtrade;
                      return GestureDetector(
                        onTap: () {
                          filterItemsBySubtrade(subtrade);
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 4),
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blue.shade700
                                    : Colors.blue.shade100,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              subtrade,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                letterSpacing: 1,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Filtered Items List
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children:
                      serviceNames.map((service) {
                        return ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 12,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade900,
                                    width: 0.6,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['item_name'] ?? 'N/A',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                          letterSpacing: 0.5,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        "Rs. ${item['min_price']} - ${item['max_price']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                          letterSpacing: 0.5,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
