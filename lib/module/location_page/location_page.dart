import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riderunnertask1/module/location_page/add_location.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Object?>> streamData(){
    CollectionReference datamagang = firestore.collection("riderunner");

    return datamagang.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Text("List Location"),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddLocationPage()));
              },
              icon: Icon(Icons.add),
          )
        ],
      ),

      body:  StreamBuilder<QuerySnapshot<Object?>>(
        stream: streamData(),
        builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.active) {
              var lisAllLocation = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(10),
                child: GridView.builder(
                    itemCount: lisAllLocation?.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7),
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              lisAllLocation?[index]["imgUrl"] != null
                                  ? Image.network(lisAllLocation?[index]["imgUrl"])
                                  : CircularProgressIndicator(),

                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(lisAllLocation?[index]["lokasi"],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: Text(lisAllLocation?[index]["latitude"]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: Text(lisAllLocation?[index]["longitude"]),
                              ),

                          ],
                        ),
                      );
                    },
                ),
              );

            }

            return CircularProgressIndicator();
        },

      ),
    );
  }
}
