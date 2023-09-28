import 'package:flutter/material.dart';

import '../services/table_services.dart';

class PopUpTask extends StatefulWidget {
  const PopUpTask({super.key});

  @override
  State<PopUpTask> createState() => _PopUpTaskState();
}

class _PopUpTaskState extends State<PopUpTask> {
  TextEditingController myTextController =
      TextEditingController(text: "select...");

  TextEditingController countTextFieldController = TextEditingController();
  TextEditingController searchTextFieldController = TextEditingController();

  final GlobalKey _popupMenuKey = GlobalKey();

  bool isSearchEnable = false;

  // Keep track of whether the menu is open
  bool isMenuOpen = false;

  FocusNode searchBarFocusNode = FocusNode();
  FocusNode countTextFieldFocusNode = FocusNode();

  int selectedIndex = -1;

  final List<dynamic> dataList = TableModelClass.jsonData["data"];
  List<int> searchIndexList = [];

  // Initialize items with all records initially
  List<dynamic> items = TableModelClass.jsonData["data"];

  List<Map<String, dynamic>> searchResults = [];

  @override
  Widget build(BuildContext context) {
    final itemHeight = MediaQuery.of(context).size.height * 0.035;

    return Scaffold(
      appBar: AppBar(
        title: const Text("PopUp Dialog"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              controller: countTextFieldController,
              focusNode: countTextFieldFocusNode,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter count of column",
                isDense: true,
              ),
              onTap: () {},
              onSubmitted: (val) {
                // The condition is met, so open the popup menu

                if (int.tryParse(val) != null &&
                    int.parse(val) >= 2 &&
                    int.parse(val) <= 4) {
                  TableModelClass.columnCount = int.parse(val);
                  _handleMenuItemSelected(
                      'OptionA'); // Call the function with a value
                } else {
                  TableModelClass.columnCount = 2;
                }
                debugPrint(
                    "TableModelClass id: ${TableModelClass.columnCount}");
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).focusColor, // Set the border color
                  width: 1.0, // Set the border width
                ),
                borderRadius: BorderRadius.circular(8.0), // Set border radius
              ),
              width: MediaQuery.of(context).size.width,
              child: PopupMenuButton<String>(
                key: _popupMenuKey,
                shape: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                ),
                color: Theme.of(context).primaryColor,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                position: PopupMenuPosition.under,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      padding: const EdgeInsets.all(0.0),
                      value: 'OptionA',
                      child: StatefulBuilder(builder: (context, setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            /*
                              * SearchBar
                              * */
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              alignment: Alignment.centerRight,
                              color: Theme.of(context).primaryColor,
                              width: double.infinity,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 30,
                                  maxWidth:
                                      MediaQuery.of(context).size.width - 200,
                                ),
                                child: TextField(
                                  controller: searchTextFieldController,
                                  focusNode: searchBarFocusNode,
                                  decoration: InputDecoration(
                                    hintText: "Search...",
                                    hintStyle: const TextStyle(fontSize: 14.0),
                                    border: const OutlineInputBorder(),
                                    focusedBorder: const OutlineInputBorder(),
                                    suffixIcon: !isSearchEnable
                                        ? IconButton(
                                            onPressed: () {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      searchBarFocusNode);
                                              setState(() {
                                                isSearchEnable = true;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.search,
                                              size: 18.0,
                                              color: Colors.black,
                                            ),
                                          )
                                        : IconButton(
                                            onPressed: () {
                                              setState(() {
                                                searchTextFieldController.text =
                                                    "";
                                                searchIndexList.clear();
                                                items = dataList;
                                                isSearchEnable = false;
                                              });
                                              FocusScope.of(context).unfocus();
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              size: 18.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                    contentPadding: const EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 8.0,
                                      right: 0.0,
                                      left: 8.0,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  onTap: () {
                                    FocusScope.of(context)
                                        .requestFocus(searchBarFocusNode);
                                    setState(() {
                                      searchIndexList.clear();
                                      isSearchEnable = true;
                                    });
                                  },
                                  onTapOutside: (val) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      isSearchEnable = false;
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      filterSearchResults(value);
                                    });
                                  },
                                ),
                              ),
                            ),
                            const Divider(
                              color: Colors.black12,
                              height: 1.0,
                            ),
                            /*
                              * Table Header
                              * */
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              color: Theme.of(context).primaryColor,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: generateHeaderColumns(),
                              ),
                            ),

                            /*
                              * Table Body
                              * */
                            Container(
                              constraints: const BoxConstraints(
                                maxHeight: 250,
                              ),
                              color: Colors.white,
                              //TODO:  height: itemHeight * item
                              height: isSearchEnable
                                  ? itemHeight * items.length
                                  : itemHeight * dataList.length,
                              width: double.maxFinite,
                              child: dataListView(),
                            ),
                            Container(
                              color: Theme.of(context).primaryColor,
                              height: 1.0,
                            ),

                            /*
                              * Table Footer
                              * */
                            Container(
                              margin: const EdgeInsets.only(top: 6.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Flexible(
                                    child: OutlinedButton.icon(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                      ),
                                      onPressed: () {
                                        // Handle button press
                                      },
                                      icon: const Icon(Icons.add),
                                      // Icon widget
                                      label: const Text('Add'), // Text widget
                                    ),
                                  ),
                                  Flexible(
                                    child: OutlinedButton.icon(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                      ),
                                      onPressed: () {
                                        // Handle button press
                                      },
                                      icon: const Icon(Icons.edit),
                                      // Icon widget
                                      label: const Text('Edit'), // Text widget
                                    ),
                                  ),
                                  Flexible(
                                    child: OutlinedButton.icon(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                      ),
                                      onPressed: () {
                                        // Handle button press
                                      },
                                      icon: const Icon(Icons.delete),
                                      // Icon widget
                                      label:
                                          const Text('Delete'), // Text widget
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ];
                },
                onCanceled: () {
                  // Reset items to show all records when the menu is closed
                  if (isMenuOpen) {
                    setState(() {
                      searchTextFieldController.text = "";
                      items = dataList;
                      isMenuOpen = false;
                    });
                  }
                },
                onOpened: () {
                  setState(() {
                    isMenuOpen = true;
                  });
                },
                onSelected: _handleMenuItemSelected,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: isMenuOpen
                            ? Theme.of(context).primaryColor
                            : Colors.black),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    myTextController.text,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const TextField(
              readOnly: true,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Another fields"),
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        items = dataList
            .where((item) =>
                item['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else {
      // Reset items to show all records when the query is empty
      setState(() {
        items = dataList;
      });
    }
  }

  List<Widget> generateHeaderColumns() {
    List<Widget> column = [];
    const List<TableHeader> header = TableHeader.values;
    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) {
        return text;
      }
      return text[0].toUpperCase() + text.substring(1);
    }

    for (int i = 0; i < TableModelClass.columnCount; i++) {
      column.add(
        Expanded(
          child: Text(
            capitalizeFirstLetter(header[i].toString().split('.').last),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return column;
  }

  Widget dataListView() {
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = items[index];
        bool isSelected = selectedIndex == item["id"];
        return InkWell(
          child: Container(
            padding: const EdgeInsets.all(4.0),
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: generateBodyColumns(item),
            ),
          ),
          onTap: () {
            setState(() {
              searchTextFieldController.text = "";
              setControllerText(item);
            });
            Navigator.of(context).pop();
          },
          onDoubleTap: () {
            // Close the popup menu programmatically
            Navigator.of(context).pop();
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        color: Theme.of(context).primaryColor,
        height: 1.0,
      ),
    );
  }

  generateBodyColumns(Map<String, dynamic> item) {
    List<Widget> columns = [];

    for (int i = 0; i < TableModelClass.columnCount; i++) {
      columns.add(
        Expanded(
          child: Text("${item.values.elementAt(i)}"),
        ),
      );
    }
    return columns;
  }

  void setControllerText(Map<String, dynamic> item) {
    // searchTextFieldController.text = "";
    // searchIndexList.clear();
    // Reset the filter data
    // items = dataList;
    myTextController.text = "${item["name"]}";
    selectedIndex = item["id"];
  }

  void _handleMenuItemSelected(String value) {
    // searchTextFieldController.text = "";
    final dynamic popupState = _popupMenuKey.currentState;

    setState(() {
      // Set isMenuOpen to true when the menu is open
      isMenuOpen = true;
      // Reset the filter data
      // items = dataList;
    });
    popupState.showButtonMenu();
  }
}
