  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
  import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'main.dart';

  class Exam {
    final String title;
    final DateTime dateTime;
  
    Exam({required this.title, required this.dateTime});
  }
  
  class HomePage extends StatefulWidget {
    const HomePage({Key? key})
        : super(key: key);
  
    @override
    _HomePageState createState() => _HomePageState();
  }
  
  class _HomePageState extends State<HomePage> {
    List<Exam> myObjects = [
      Exam(title: 'VIS', dateTime: DateTime(2023, 11, 30, 13, 30)),
      Exam(title: 'CALCULUS', dateTime: DateTime(2024, 1, 22, 14, 20)),
      Exam(title: 'DM', dateTime: DateTime(2024, 2, 2, 10, 0)),
    ];

    TextEditingController titleController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();
    bool isAddingElement = false;


    void _scheduleNotification(Exam exam) async {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
      );

      NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Exam Reminder',
        'You have ${exam.title} exam on ${exam.dateTime}',
        platformChannelSpecifics,
      );
    }

    @override
    void initState() {
    // TODO: implement initState
    super.initState();
    for(Exam exam in myObjects){
      final today = DateTime.now();
      final fotmatted = DateTime(today.year, today.month, today.day, today.hour, today.minute);

      if (exam.dateTime.difference(fotmatted).inDays <= 1) {
        _scheduleNotification(exam);
      }
    }
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('191521'),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            actions: <Widget>[
              InkResponse(
                onTap: () {
                  // Add your button onPressed logic here
                  setState(() {
                    isAddingElement = !isAddingElement;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue, // Set the background color of the circle
                    child: Icon(
                      Icons.add,
                      color: Colors.white, // Set the color of the icon
                    ),
                  ),
                ),
              ),
            ],
          ),
        body: Stack(
          children: [
            _buildGridView(),
            if (isAddingElement) _buildAddElementOverlay(),
          ],
        ),
      );
    }





    Widget _buildGridView() {
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Exam Schedule:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: myObjects.length,
              itemBuilder: (context, index) {
                final day = myObjects[index].dateTime.day.toString().padLeft(2, '0');
                final month = myObjects[index].dateTime.month.toString().padLeft(2, '0');
                final year = myObjects[index].dateTime.year.toString();
                final hour = myObjects[index].dateTime.hour.toString().padLeft(2, '0');
                final minute = myObjects[index].dateTime.minute.toString().padLeft(2, '0');
                final formattedDateTime = '$day/$month/$year $hour:$minute';
                return Card(
                  child: ListTile(
                    title: Text(myObjects[index].title, style: const TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text(formattedDateTime),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamed(context, "/login");
                  },
                  child: Container(
                    height: 45,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Sign out",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    // HERE CHAT GPT HEREEEEEE
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarScreen(exams: myObjects),
                      ),
                    );
  
                  },
                  child: Container(
                    height: 45,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Calendar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  
    Widget _buildAddElementOverlay() {
      return Positioned.fill(
        child: GestureDetector(
          onTap: () {
            _toggleAddElement();
          },
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _selectDateTime(context);
                      },
                      child: const Text('Select Date and Time'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _addElement();
                      },
                      child: const Text('Add Element'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _toggleAddElement();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  
  
  
    Future<void> _selectDateTime(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
  
      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        );
  
        if (pickedTime != null) {
          setState(() {
            selectedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      }
    }
  
    void _toggleAddElement() {
      setState(() {
        isAddingElement = !isAddingElement;
      });
    }
  
    void _addElement() {
      if (titleController.text.isNotEmpty) {
        final newElement = Exam(
          title: titleController.text,
          dateTime: selectedDateTime,
        );
        setState(() {
          myObjects.add(newElement);
          _toggleAddElement();
          titleController.clear();
        });

        final now = DateTime.now();
        final fotmatted = DateTime(now.year, now.month, now.day, now.hour, now.minute);

        print(newElement.dateTime.difference(fotmatted).inDays);

        if (newElement.dateTime.difference(fotmatted).inDays <= 1) {
          _scheduleNotification(newElement);
        }


      }
    }
  }
  // lab 4 >>>
  class CalendarScreen extends StatelessWidget {
    final List<Exam> exams;
  
    CalendarScreen({required this.exams});
  
    @override
    Widget build(BuildContext context) {
      EventList<Event> markedDateMap = EventList<Event>(events: {});
  
      for (var exam in exams) {
        final date = DateTime(
          exam.dateTime.year,
          exam.dateTime.month,
          exam.dateTime.day,
        );
        markedDateMap.add(
          date,
          Event(
            date: date,
            title: exam.title,
          ),
        );
      }
  
      return Scaffold(
        appBar: AppBar(
          title: Text('Exam Calendar'),
          backgroundColor: Colors.deepPurple,
        ),
        body: CalendarCarousel<Event>(
          markedDatesMap: markedDateMap,
          height: 420.0,
          daysHaveCircularBorder: true,
          todayBorderColor: Colors.blue,
          todayButtonColor: Colors.transparent,
          todayTextStyle: TextStyle(color: Colors.black),
          markedDateCustomTextStyle: TextStyle(color: Colors.blue),
        ),
      );
    }
  }
