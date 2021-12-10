import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TodayAttendanceList extends StatelessWidget {
  var controller;
  var firestore;
  var selectedDate;

  TodayAttendanceList(
    this.firestore,
    this.selectedDate,
  );

  Stream<QuerySnapshot> searchData() async* {
    if (selectedDate != null) {
      var _search1 = await firestore
          .collection('attendance')
          .where('date', isEqualTo: selectedDate.toString().substring(0, 10))
          .orderBy('time', descending: false)
          .snapshots();
      yield* _search1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: searchData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final orders = snapshot.data!.docs.reversed;
        List<Widget> orderList = [];
        for (var item in orders) {
          final date = item['date'];
          final shopId = item['shop_id'];
          final shopName = item['shop_name'];
          final time = item['time'];
          final repName = item['rep_name'];
          final repID = item['rep_id'];

          if (selectedDate == null) {
            orderList.add(repListBuilder(
              date,
              context,
              shopId,
              shopName,
              time,
              repName,
              repID,
            ));
          } else {
            if (selectedDate.toString().substring(0, 10) == date) {
              orderList.add(repListBuilder(
                date,
                context,
                shopId,
                shopName,
                time,
                repName,
                repID,
              ));
            }
          }
        }

        return orderList.isNotEmpty
            ? Expanded(
                child: Container(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: orderList.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: orderList[index],
                      );
                    },
                  ),
                ),
              )
            : Expanded(
                child: Container(
                  child: Center(
                      child: Text(
                    'No attendance yet',
                    style: TextStyle(
                      fontFamily: 'Exo2',
                      fontSize: mediaData.size.height * 0.023,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              );
      },
    );
  }

  Widget repListBuilder(
    date,
    context,
    shopId,
    shopName,
    time,
    repName,
    repID,
  ) {
    final mediaData = MediaQuery.of(context);

    return Container(
      margin: EdgeInsets.only(top: mediaData.size.height * 0.015),
      width: mediaData.size.width * 0.95,
      height: mediaData.size.height * 0.15,
      decoration: BoxDecoration(
          boxShadow: boxShadowsReps(),
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/images/attendanceRound.png'),
            alignment: Alignment.topRight,
            fit: BoxFit.fitHeight,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.5), BlendMode.dstATop),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 14.0),
            child: Text(
              shopName,
              style: TextStyle(
                fontSize: mediaData.size.height * 0.028,
                fontFamily: 'Exo2',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 14.0),
            child: Text(
              'Date \t\t\t\t\t\t\t: ' + date.substring(0, 10),
              style: TextStyle(
                fontSize: mediaData.size.height * 0.02,
                fontFamily: 'Exo2',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0, left: 14.0),
            child: Text(
              'Time \t\t\t\t\t\t :' + time.substring(0, 6),
              style: TextStyle(
                fontSize: mediaData.size.height * 0.02,
                fontFamily: 'Exo2',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 14.0),
            child: Text(
              'Rep \t\t\t\t\t\t\t  : $repName',
              style: TextStyle(
                fontSize: mediaData.size.height * 0.02,
                fontFamily: 'Exo2',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
