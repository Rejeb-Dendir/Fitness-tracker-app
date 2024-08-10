import 'package:fitness_tracker_app/database/db_service.dart';
import 'package:fitness_tracker_app/models/activity.dart';
import 'package:fitness_tracker_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  String dropdownValue = "weight";
  String selectedTab = "All";
  buildTap(String text) {
    bool selected = text == selectedTab;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = text;
          });
        },
        child: Chip(
          elevation: 10,
          backgroundColor: selected ? Colors.redAccent : Colors.white,
          label: Text(
            text,
            style: selected
                ? textStyle(18, Colors.white, FontWeight.w700)
                : textStyle(18, Colors.black, FontWeight.w700),
          ),
        ),
      ),
    );
  }

  openAddDialog(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400, // Set your desired max width here
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter stateSetter) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // This line makes the Column take only as much space as needed
                      children: [
                        Text(
                          "Add",
                          style: textStyle(28, Colors.black, FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 125,
                              height: 40,
                              child: TextFormField(
                                controller: controller,
                                style: textStyle(
                                    20, Colors.black, FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: dropdownValue == "weight"
                                      ? "In kg"
                                      : "In cm",
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DropdownButton(
                              hint: Text(
                                'Choose',
                                style: textStyle(
                                    18, Colors.black, FontWeight.w700),
                              ),
                              dropdownColor: Colors.grey,
                              onChanged: (value) {
                                stateSetter(() {
                                  dropdownValue = value.toString();
                                });
                              },
                              elevation: 5,
                              value: dropdownValue,
                              items: [
                                DropdownMenuItem(
                                  value: 'weight',
                                  child: Text(
                                    'Weight',
                                    style: textStyle(
                                        18, Colors.black, FontWeight.w700),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'height',
                                  child: Text(
                                    'Height',
                                    style: textStyle(
                                        18, Colors.black, FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        IconButton(
                          color: Colors.redAccent,
                          iconSize: 50,
                          onPressed: () async {
                            if (controller.text.isEmpty ||
                                double.tryParse(controller.text) == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid input')),
                              );
                              return;
                            }

                            try {
                              int? success =
                                  await DatabaseService.instance.addActivity({
                                DatabaseService.type: dropdownValue,
                                DatabaseService.date: DateTime.now().toString(),
                                DatabaseService.data:
                                    double.parse(controller.text),
                              });

                              if (context.mounted) {
                                if (success != null && success > 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Data inserted successfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Failed to insert data')),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            } finally {
                              controller.clear();
                              if (context.mounted) {
                                Navigator.pop(context);
                                setState(() {});
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.double_arrow_rounded,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fitness tracker',
          style: textStyle(34, Colors.black, FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xfffbf5f5),
      floatingActionButton: Chip(
        backgroundColor: Colors.redAccent,
        onDeleted: () => openAddDialog(context),
        deleteIcon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 26,
        ),
        label: Text(
          "Add",
          style: textStyle(22, Colors.white, FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
                child: Row(
                  children: [
                    buildTap('All'),
                    buildTap('Weight'),
                    buildTap('Height'),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600, // Set your desired max width here
                ),
                child: FutureBuilder(
                  future: DatabaseService.instance.getActivities(selectedTab),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    List<Activity> activityList = List.generate(
                        snapshot.data!.length,
                        (index) => Activity(
                            int.parse(
                                snapshot.data![index]['columnId'].toString()),
                            snapshot.data![index]['date'].toString(),
                            double.parse(
                                snapshot.data![index]['data'].toString()),
                            snapshot.data![index]['type'].toString()));

                    return GroupedListView<Activity, String>(
                        groupBy: (Activity activity) => DateFormat.MMMd()
                            .format(DateTime.parse(activity.date.toString())),
                        elements: activityList,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, activity) {
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: Image(
                                  width: 50,
                                  height: 50,
                                  image: AssetImage(
                                      'assets/images/${activity.type}.jpeg'),
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  activity.type == 'weight'
                                      ? '${activity.data} kg'
                                      : '${activity.data} cm',
                                  style: textStyle(
                                      27, Colors.black, FontWeight.w600),
                                ),
                                trailing: InkWell(
                                  onTap: () {
                                    DatabaseService.instance
                                        .deleteActivity(activity.id);
                                    setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        groupSeparatorBuilder: (String value) {
                          return Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              value,
                              style:
                                  textStyle(23, Colors.black, FontWeight.w600),
                            ),
                          );
                        });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
