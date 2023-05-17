import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:fieldapp_rcm/step_form.dart';
import 'package:fieldapp_rcm/task/collection.dart';
import 'package:fieldapp_rcm/task/customer.dart';
import 'package:fieldapp_rcm/task/pilot_process.dart';
import 'package:fieldapp_rcm/task/portfolio.dart';
import 'package:fieldapp_rcm/task/team.dart';
import 'package:fieldapp_rcm/widget/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'http_online.dart';

class Bucket extends StatefulWidget {
  final Function(String) onTask;

  final Function(String) onSubTask;
  final Function(List?) taskResult;
  final Function(String) onregionselected;
  final Function(String?) onareaselected;

  Bucket(
      {required this.onregionselected,
      required this.onareaselected,
      required this.onTask,
      required this.onSubTask,
      required this.taskResult});

  @override
  BucketState createState() => new BucketState();
}

class BucketState extends State<Bucket> {
  @override
  initState() {
    getFileProperties();
    agentList.toList();
  }

  final _formKey = GlobalKey<FormState>();
  late String selectedTask = '';
  String selectedSubTask = '';
  late String regionselected = '';
  late String areaselected = '';
  late String agentselected = '';
  List? _myActivities;
  late String priority = '';
  late String target;
  String? selectedarea;
  late String _myActivitiesResult;
  List<String> agentList = [];
  late Map<String, List<String>> dataTask = {
    'Portfolio Quality': portfolio,
    'Team Management': team,
    'Collection Drive': collection,
    'Pilot/Process Management': pilot,
    'Customer Management': customer,
  };
  final List<String> portfolio = [
    'Visiting unreachable welcome call clients',
    'Work with the Agents with low welcome calls to improve',
    'Change a red zone CSAT area to orange',
    'Attend to Fraud Cases',
    'Visit at-risk accounts',
    'Visits FPD/SPDs',
    'Other'
  ];

  final List<String> customer = [
    'Visiting of issues raised',
    'Repossession of customers needing repossession',
    'Look at the number of replacements pending at the shops',
    'Look at the number of repossession pending at the shops',
    'Other - Please Expound'
  ];

  final List<String> pilot = [
    'Conduct the process audit',
    'Conduct a pilot audit',
    'Testing the GPS accuracy of units submitted',
    'Reselling of repossessed units',
    'Repossessing qualified units for Repo and Resale',
    'Increase the Kazi Visit Percentage',
    'Other'
  ];

  final List<String> collection = [
    'Field Visits with low-performing Agents in Collection Score',
    'Repossession of accounts above 180',
    'Visits Tampering Home 400',
    'Work with restricted Agents',
    'Calling of special book',
    'Sending SMS to clients',
    'Table Meeting/ Collection Sensitization Training',
    'Others'
  ];

  final List<String> team = [
    'Assist a team member to improve the completion rate',
    'Raise a reminder to a team member',
    'Raise a warning to a team member',
    'Raise a new task to a team member',
    'Inform the team member of your next visit to his area, and planning needed',
    'Other'
  ];

  Future<void> listItems() async {
    try {
      StorageListOperation<StorageListRequest, StorageListResult<StorageItem>>
          operation = await Amplify.Storage.list(
        options: const StorageListOptions(
          accessLevel: StorageAccessLevel.guest,
          pluginOptions: S3ListPluginOptions.listAll(),
        ),
      );
      Future<StorageListResult<StorageItem>> result = operation.result;
      List<StorageItem> resultList = (await operation.result).items;
      for (StorageItem item in resultList) {
        print('Key: ${item.key}');
        print('Last Modified: ${item.lastModified}');
        // Access other properties as needed
      }

      safePrint('Got items: ${resultList.length}');
    } on StorageException catch (e) {
      safePrint('Error listing items: $e');
    }
  }

  Future<void> getFileProperties() async {
    List<String> uniqueAgentList = [];
    try {
      StorageGetPropertiesResult<StorageItem> result =
          await Amplify.Storage.getProperties(
        key: 'Agents_with_low_welcome_calls_2023-05-14T0204_r95sHZ.json',
      ).result;
      StorageGetUrlRequest fileResult = await Amplify.Storage.getUrl(
              key: 'Agents_with_low_welcome_calls_2023-05-14T0204_r95sHZ.json')
          .request;
      StorageItem dd = result.storageItem;
      StorageGetUrlResult urlResult = await Amplify.Storage.getUrl(
              key: 'Agents_with_low_welcome_calls_2023-05-14T0204_r95sHZ.json')
          .result;
      final response = await http.get(urlResult.url);
      final jsonData = jsonDecode(response.body);
      for (var item in jsonData) {
        String agent = item['Area'];
        uniqueAgentList.add(agent);
      }
      setState(() {
        agentList = uniqueAgentList.toSet().toList();
      });

      safePrint('File size: $dd');
      safePrint('File url: ${agentList}');
    } on StorageException catch (e) {
      safePrint('Could not retrieve properties: ${e.message}');
      rethrow;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new task"),
      ),
      body: Form(
        key: _formKey,
        child:

        Column(
          children: [
            SizedBox(
              height: 10,
            ),
            AppDropDown(
                disable: true,
                label: "Region",
                hint: "Region",
                items: agentList,
                onChanged: (value) {
                  widget.onregionselected(value!);
                  setState(() {
                    regionselected = value;
                  });
                  //_getArea();
                }),
            SizedBox(
              height: 8,
            ),
            AppDropDown(
                disable: true,
                label: "Area",
                hint: "Area",
                items: agentList,
                onChanged: (value) {
                  setState(() {
                    selectedarea = value;
                  });
                  widget.onareaselected(value!);
                }),
            SizedBox(
              height: 8,
            ),
            AppDropDown(
                disable: true,
                label: "Task Title",
                hint: "Task Title",
                items: dataTask.keys.toList(),
                onChanged: (value) {
                  print(value);
                  // widget.onTask(value!);
                  selectedTask = value;
                  setState(() {
                    // selectedTask = value;
                  });
                  //widget.onTask(value);
                }),
            SizedBox(
              height: 8,
            ),
            AppDropDown(
                disable: false,
                label: "Sub Task",
                hint: "Sub Task",
                items: dataTask[selectedTask] ?? [],
                onChanged: (value) {
                  print(value);
                  setState(() {
                     selectedSubTask = value!;
                  });
                  widget.onSubTask!(value!);
                }),
            SizedBox(
              height: 8,
            ),
            if (selectedTask == 'Portfolio Quality' && selectedSubTask != null)
              Column(
                children: [
                  Portfolio(
                      subtask: selectedSubTask,
                      onSave: (value) {
                        widget.taskResult(value);
                      }
                  ),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ActionScreen(
                                  customers: [selectedarea],
                                  onChange:
                                      (value) {
                                  }, Area: selectedarea!,
                                  region: regionselected,
                                  task: selectedTask,
                                  subtask: selectedSubTask,)));
                      }, child: Text('Next'))
                ],
              ),
            if (selectedTask == 'Team Management' && selectedSubTask != null)
              Column(
                children: [
                  Team(
                    onSave: (value) {
                      widget.taskResult(value);
                    },
                    subtask: selectedSubTask??'',),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TeamActionScreen(
                                  customers: ['_myActivities',"gg"],
                                  onChange:
                                      (value) {
                                  },
                                  Area: selectedarea!,
                                  region: regionselected,
                                  task: selectedTask,
                                  subtask: selectedSubTask,)));
                      }, child: Text('Next'))
                ],
              ),
            if (selectedTask == 'Collection Drive' && selectedSubTask != null)
              Column(
                children: [
                  TaskAdd(),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ActionScreen(
                                  customers: [selectedarea],
                                  onChange:
                                      (value) {
                                  }, Area: selectedarea!,
                                  region: regionselected,
                                  task: selectedTask,
                                  subtask: selectedSubTask,)));
                      }, child: Text('Next'))
                ],
              ),
            if (selectedTask == 'Pilot/Process Management' && selectedSubTask != null)
              Column(
                children: [
                  TaskAdd(),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ActionScreen(
                                  customers: [selectedarea],
                                  onChange:
                                      (value) {
                                  }, Area: selectedarea!,
                                  region: regionselected,
                                  task: selectedTask,
                                  subtask: selectedSubTask,)));
                      }, child: Text('Next'))
                ],
              ),
            if (selectedTask == 'Customer Management' && selectedSubTask != null)
              Column(
                children: [
                  TaskAdd(),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ActionScreen(
                                  customers: [selectedarea],
                                  onChange:
                                      (value) {
                                  }, Area: selectedarea!,
                                  region: regionselected,
                                  task: selectedTask,
                                  subtask: selectedSubTask,)));
                      }, child: Text('Next'))
                ],
              ),

          ],
        ),
      ),
    );
  }
}




class TaskAdd extends StatefulWidget{
  @override
  TaskAddState createState() => new TaskAddState();

}
class TaskAddState extends State<TaskAdd>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Column(
    );
  }

}