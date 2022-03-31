import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:contactlist/model/contact.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(RootRestorationScope(child: const MyApp(), restorationId: "root",));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
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

class _contactbodyState extends State<contactbody> with RestorationMixin {
  @override


  bool switching=false;
  bool ori=false;
  int currentpos=1;
  final RestorableInt _Tindex = RestorableInt(0);
  String get restorationId => 'contactbody';

  List <contactinfo> items=[];
   List <contactinfo> show=[];
   int count=0;
    int maxcount=0;
   int refreshcount=0;
  ScrollController _controller = new ScrollController();


  void dispose() {
    _Tindex.dispose();
    super.dispose();
  }
  Future<List<contactinfo>> readJson() async {
    final response = await rootBundle.loadString('assets/contactlist.json');
    final list = await json.decode(response) as List<dynamic> ;
    return list.map((e) => contactinfo.fromJson(e)).toList();
  }
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {

    registerForRestoration(_Tindex, 'toggle');
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
  void retrieve() async
  {

    items = await readJson() as List<contactinfo>;
    maxcount=items.length;

    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

                String string = dateFormat.format(DateTime.now());
                DateTime DT = dateFormat.parse(string);
                items.sort((b,a){
                  return a.checkin.compareTo(b.checkin);
                }

                );

                if (count==0)
                {
                  for (int k=0;k<10;k++)
                {
                  show.add(items[k]);
                  count++;
                }
                }

  }
 void initState()
 {
   super.initState();
  retrieve();

   _controller.addListener(() {
     if(_controller.position.pixels == _controller.position.maxScrollExtent){

       if (count<maxcount)
       {


         appendNewData();
       }
     }
   });
 }
double halfnum=0;
  Widget build(BuildContext context) {

    return Column(
      children: [

        SizedBox(height: 20,),
        Center(
          child:ToggleSwitch(
            changeOnTap: true,

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
         child:  FutureBuilder(
               future: readJson(),
               builder: (context,data){
                  if(data.hasError)
              {
                return Center(child: Text("${data.error}"));
              }
              else if(data.hasData)
              {



                show.forEach((element){

                });

               return RefreshIndicator(
                   onRefresh: _onRefresh,
                   child:  Column(
                     children: [
                       Expanded(
                         child: ListView.builder(
                                   controller: _controller,
                                   physics: BouncingScrollPhysics(),

                                   shrinkWrap: true,
                                             itemCount: show.length,
                                             itemBuilder:(context,index)
                                             {
                                               return ListTile(
                                    leading: Text((index+1).toString()),
                                    title: Text(show[index].user),
                                    subtitle: ori?Text(show[index].checkin.toString().substring(0,show[index].checkin.toString().indexOf('.'))):Text(convertToTimeAgo(show[index].checkin)),
                                    trailing: IconButton(icon: Icon(Icons.share)
                                    ,onPressed: () async{
                                      await Share.share(show[index].phone.toString());
                                    }
                                    ),

                                  );




                                             }

                                             ),
                       ),
                       endOfList()
                     ],
                   ),
                 );}
                 else
                 {
                    return Center(
                  child: CircularProgressIndicator(),
                );

                 }
               })
         )

      ],
    );
  }
  void appendNewData ()
  {
    if (count!=maxcount&&items.length!=0)
    {

       Future.delayed(Duration(seconds: 0)).then((value) {

      for (int g=count;g<items.length;g++)
      {

        show.add(items[g]);

        count++;
      }
    }
  );
  setState(() {
      switching=false;
  });
    }



  }

  Widget endOfList ()
  {
    if (count==maxcount&&maxcount!=0){
      return Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),


        child: Center(child:
        Text("You have reached end of the list",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15

        )
        )

        ));
    }
    else
    {
      return Center();
    }

  }
  Future _onRefresh  () async
  {
      await Future.delayed(Duration(seconds: 1)).then((e){

           refreshcount++;
          int tot=10+refreshcount*5;
          show.clear();

        if (count==maxcount)
        {
          for (int p=0;p<items.length;p++)
          {
            show.add(items[p]);
          }
        }
        else
        {
          for (int p=0;(p<tot)&&(p<items.length);p++)
          {
show.add(items[p]);
              if (p>=count)
              {
                count++;
              };
          }
        }

        setState(() {

          switching=true;
        });

  });}
}