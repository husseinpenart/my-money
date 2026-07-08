import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/widgets/global/GlassContainer.dart';
import 'dart:math' as math;

class Herocontainergrid extends StatelessWidget {
  const Herocontainergrid({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GlassContainer(            
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.rotate(
                    angle: 180 * math.pi / 180,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.arrow_outward,
                        color: Colors.greenAccent,
                        size: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ScreenDictionary.demandText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'sans',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '12,500,000',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'sans',
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        ScreenDictionary.moenyUnit,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 64, 255, 39),
                          fontFamily: 'sans',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 30),
          Expanded(
            child: GlassContainer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 123, 113),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_outward,
                      color: Color.fromARGB(255, 158, 33, 24),
                      size: 12,
                    ),
                  ),
            
                  const SizedBox(width: 10),
            
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ScreenDictionary.debtsText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'sans',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '4,500,000',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'sans',
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        ScreenDictionary.moenyUnit,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 123, 113),
                          fontFamily: 'sans',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
     
        ],
      ),
    );
  }
}
