import 'package:flutter/material.dart';
import 'package:over_taxi_driver/constant/colors.dart';
import 'package:over_taxi_driver/constant/styleText.dart';

class OrdersTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          height: 100,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(0.7, 0.7),
                    spreadRadius: 0)
              ]),
          child: order(),
        );
      },
    );
  }

  Widget order() {
    return ListTile(
      onTap: () {},
      trailing: Container(
        padding: EdgeInsets.all(7),
        height: 30,
        decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(0.7, 0.7),
                  spreadRadius: 0)
            ]),
        child: Text(
          'طلب معلق',
          style: kstatusOrder,
        ),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(
                'img/place.png',
                height: 20,
                width: 20,
              ),
              SizedBox(
                width: 10,
                height: 18,
              ),
              Text(
                ' من :',
                style: klistorder,
              ),
              SizedBox(
                width: 10,
                height: 18,
              ),
              Expanded(
                child: Text(
                  ' الحريقة دمشق بنك سوريا والمهجر ',
                  style: klistorder,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Image.asset(
                'img/place.png',
                height: 20,
                width: 20,
              ),
              SizedBox(
                width: 10,
                height: 18,
              ),
              Text(
                ' الى : ',
                style: klistorder,
              ),
              SizedBox(
                width: 10,
                height: 18,
              ),
              Expanded(
                child: Text(
                  'المزة برج تالا ',
                  style: klistorder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
