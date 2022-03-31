import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:contactlist/model/contact.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact List',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: Scaffold(

        appBar: AppBar(
          centerTitle: true,
          title: Text("ContactList"),
        ),
        body:contactbody()

         )
    );
  }
}
class contactbody extends StatefulWidget {
  const contactbody({ Key? key }) : super(key: key);

  @override
  State<contactbody> createState() => _contactbodyState();
}

class _contactbodyState extends State<contactbody> {
  @override
  List contactListFromFile=[];
  List contact=[];
  var mpage=0;
  bool ori=false;
  int currentpos=1;
  ScrollController _controller = new ScrollController();
  Future<List<contactinfo>> readJson() async {
    final response = await rootBundle.loadString('assets/contactlist.json');
    final list = await json.decode(response) as List<dynamic> ;
    return list.map((e) => contactinfo.fromJson(e)).toList();
  }
  String convertToTimeAgo (DateTime DT)
  {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
 String string = dateFormat.format(DateTime.now());
  DateTime CDT = dateFormat.parse(string);
  Duration difference=CDT.difference(DT);
  String timeago;
  if (difference.inDays>0)
  {
    timeago=difference.inDays.toString()+" days ago";
  }
  else{
    if (difference.inHours>0)
    {
        timeago=difference.inHours.toString()+" hours ago";
    }
    else
    {
      timeago=difference.inMinutes.toString()+" minutes ago";
    }

  }


  return timeago;
  }

  Widget build(BuildContext context) {

    return Column(
      children: [
        SizedBox(height: 20,),
        Center(
          child:ToggleSwitch(
  minWidth: 90.0,
  cornerRadius: 20.0,
  activeBgColors: [[Colors.green[800]!], [Colors.red[800]!]],
  activeFgColor: Colors.white,
  inactiveBgColor: Colors.grey,
  inactiveFgColor: Colors.white,
  initialLabelIndex: currentpos,
  totalSwitches: 2,
  labels: ['Original\nTime', 'Time\nAgo'],
  radiusStyle: true,
  onToggle: (index) {
if(ori)
    {
      ori=false;
     currentpos=1;
    }
    else
    {
      ori=true;
     currentpos=0;
    }
    setState(() {

    });


  },
),
        ),
        SizedBox(height: 20,)
        ,
        Expanded(
          child: FutureBuilder(
            future: readJson(),
            builder: (context,data)
            {
              if(data.hasError)
              {
                return Center(child: Text("${data.error}"));
              }
              else if(data.hasData)
              {
                var items = data.data as List<contactinfo>;
                DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

                String string = dateFormat.format(DateTime.now());
                DateTime DT = dateFormat.parse(string);
                items.sort((b,a){
                  return a.checkin.compareTo(b.checkin);
                }

                );


                print(DT);
               return  ListView.builder(
                 scrollDirection: Axis.vertical,
                 shrinkWrap: true,
              itemCount: items.length,
              itemBuilder:(context,index)
              {
                print("no");
                return ListTile(
                  leading: Text((index+1).toString()),
                  title: Text(items[index].user),
                  subtitle: ori?Text(items[index].checkin.toString()):Text(convertToTimeAgo(items[index].checkin)),
                  trailing: IconButton(icon: Icon(Icons.share)
                  ,onPressed: () async{
                    await Share.share(items[index].phone.toString());
                  }
                  ),

                );
              }

              );

              }
               else {
                return Center(
                  child: CircularProgressIndicator(),
                );
               }
            }
          ),
        ),
      ],
    );
  }
}