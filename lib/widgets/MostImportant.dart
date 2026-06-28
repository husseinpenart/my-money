import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/helper/list/mount_money.dart';

class Mostimportant extends StatefulWidget {
  const Mostimportant({super.key});

  @override
  State<Mostimportant> createState() => _MostimportantState();
}

class _MostimportantState extends State<Mostimportant> {
  final List<MountMoney> cardItems = [
    MountMoney(
      firstCharacter: 'ح',
      name: 'حسین اسدی',
      price: '13,000,000',
      title: 'طلب',
      priceTypeColor: Colors.green,
    ),
    MountMoney(
      firstCharacter: 'س',
      name: 'سارا احمدی',
      price: '13,000,000',
      title: 'بدهی',
      priceTypeColor: Colors.red,
    ),
    MountMoney(
      firstCharacter: 'ع',
      name: 'علی اصغر اسدی',
      price: '13,000,000',
      title: 'بدهی',
      priceTypeColor: Colors.green,
    ),
    MountMoney(
      firstCharacter: 'ا',
      name: 'افشین اسدی',
      price: '13,000,000',
      title: 'طلب',
      priceTypeColor: Colors.red,
    ),
    MountMoney(
      firstCharacter: 'م',
      name: 'مهین اسدی',
      price: '13,000,000',
      title: 'بدهی',
      priceTypeColor: Colors.green,
    ),
    MountMoney(
      firstCharacter: 'ع',
      name: 'علی اردبیل',
      price: '13,000,000',
      title: 'طلب',
      priceTypeColor: Colors.red,
    ),
    MountMoney(
      firstCharacter: 'م',
      name: 'مهدی شرافتی',
      price: '13,000,000',
      title: 'بدهی',
      priceTypeColor: Colors.green,
    ),
    MountMoney(
      firstCharacter: 'ل',
      name: 'لیلا جهانی',
      price: '13,000,000',
      title: 'طلب',
      priceTypeColor: Colors.red,
    ),
    MountMoney(
      firstCharacter: 'ز',
      name: 'زری جهانی',
      price: '13,000,000',
      title: 'طلب',
      priceTypeColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          padding: EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 124,
            children: [
              Text(
                ScreenDictionary.mostSee,
                style: TextStyle(fontSize: 14, fontFamily: 'sans'),
              ),

              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                  SizedBox(width: 15,),
                  Text(
                    ScreenDictionary.importantOnes,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'sans',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: 180,
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cardItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(left: 15),
                  padding: const EdgeInsets.all(15),
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black.withValues(alpha: 0.06),
                        offset: Offset(0, 0.5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  transform: GradientRotation(10),
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Color.fromRGBO(56, 0, 146, 1),
                                    Color.fromRGBO(102, 26, 224, 1),
                                    Color.fromRGBO(160, 112, 236, 1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  item.firstCharacter,
                                  style: TextStyle(
                                    fontFamily: 'sans',
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontFamily: 'sans',
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontFamily: 'sans',
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.price,
                            style: TextStyle(
                              fontFamily: 'sans',
                              color: item.priceTypeColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'تومان',
                            style: TextStyle(
                              fontFamily: 'sans',
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
