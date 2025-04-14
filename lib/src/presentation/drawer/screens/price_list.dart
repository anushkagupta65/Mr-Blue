import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';

class PriceList extends StatefulWidget {
  const PriceList({super.key});

  @override
  State<PriceList> createState() => _PriceListState();
}

class _PriceListState extends State<PriceList> {
  List<String> serviceNames = [
    'Dry Cleaning',
    'Laundry',
    'Ironing',
    'Stain Removal',
  ];
  List<String> uniqueSubtrades = [];
  List<Map<String, dynamic>> filteredItems = [];
  String? selectedService;
  String? selectedSubtrade;

  @override
  void initState() {
    super.initState();
    if (serviceNames.isNotEmpty) {
      selectedService = serviceNames[0];
      filterItemsByService(selectedService!);
    }
  }

  void filterItemsByService(String service) {
    setState(() {
      selectedService = service;
      uniqueSubtrades =
          service == 'Dry Cleaning'
              ? ['Suits', 'Dresses', 'Jackets']
              : service == 'Laundry'
              ? ['Shirts', 'Pants', 'Bedding']
              : service == 'Ironing'
              ? ['Shirts', 'Trousers', 'Skirts']
              : ['Carpets', 'Upholstery', 'Curtains'];

      if (uniqueSubtrades.isNotEmpty) {
        selectedSubtrade = uniqueSubtrades[0];
        filterItemsBySubtrade(selectedSubtrade!);
      } else {
        filteredItems = [];
      }
    });
  }

  void filterItemsBySubtrade(String subtrade) {
    setState(() {
      selectedSubtrade = subtrade;
      // Mock filtered items (replace with API logic later)
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.blue.shade50),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: serviceNames.length,
                  itemBuilder: (context, index) {
                    final service = serviceNames[index];
                    bool isSelected = service == selectedService;
                    return GestureDetector(
                      onTap: () {
                        filterItemsByService(service);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 4),
                        width: MediaQuery.of(context).size.width * 0.4,
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
                            service,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : Colors.black87,
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
                              color: isSelected ? Colors.white : Colors.black87,
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
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
