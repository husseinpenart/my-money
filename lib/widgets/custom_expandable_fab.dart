import 'package:flutter/material.dart';
import 'package:money/layouts/confirm_demand_layout.dart';

class CustomExpandableFab extends StatefulWidget {
  const CustomExpandableFab({super.key});

  @override
  State<CustomExpandableFab> createState() => _CustomExpandableFabState();
}

class _CustomExpandableFabState extends State<CustomExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animateIcon;
  late Animation<double> _translateButton;
  bool _isOpen = false;
  final double _fabHeight = 32.0;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          setState(() {});
        });

    _animateIcon = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _translateButton = Tween<double>(begin: _fabHeight, end: -14.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
  }

  void _toggleMenu() {
    if (!_isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    _isOpen = !_isOpen;
  }

  // متد ساخت ردیف‌های منو
  Widget _buildMenuItem({
    required Color buttonColor,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double index,
  }) {
    final double animationValue = _animationController.value;

    return Transform(
      transform: Matrix4.translationValues(
        0.0,
        _translateButton.value * index,
        0.0,
      ),
      child: Opacity(
        opacity: animationValue,
        child: Visibility(
          visible: animationValue > 0.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: buttonColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181A26),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'sans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5.0,
      children: [
        _buildMenuItem(
          buttonColor: const Color(0xFF2563EB),
          icon: Icons.south_west,
          label: 'ثبت طلب',
          index: 1,
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                enableDrag: true,
                showDragHandle: true,
                constraints: BoxConstraints(maxHeight: 800, maxWidth: 500),
                builder: (BuildContext sheetContext) {
                  return ConfirmDemandLayout(
                    startDateController: _startDateController,
                    endDateController: _endDateController,
                    hasDebt: false,
                  );
                },
              );
              _toggleMenu();
            });
          },
        ),
        // دکمه دوم (ثبت بدهی)
        _buildMenuItem(
          buttonColor: const Color(0xFFE53E3E),
          icon: Icons.north_east,
          label: 'ثبت بدهی',
          index: 2,
          onTap: () {
            _toggleMenu();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                enableDrag: true,
                showDragHandle: true,
                constraints: BoxConstraints(maxHeight: 800, maxWidth: 500),
                builder: (BuildContext sheetContext) {
                  return ConfirmDemandLayout(
                    startDateController: _startDateController,
                    endDateController: _endDateController,
                    hasDebt: true,
                  );
                },
              );
              _toggleMenu();
            });
          },
        ),
        // دکمه سوم (ثبت پرداخت)
        _buildMenuItem(
          buttonColor: const Color(0xFF0EAB7B),
          icon: Icons.credit_card,
          label: 'ثبت پرداخت',
          index: 3,
          onTap: () {
            _toggleMenu();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext sheetContext) {
                  return Container(
                    height: 300,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'فرم ثبت طلب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'sans',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            child: const Text('بستن'),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            });
          },
        ),

        // دکمه اصلی پایین
        GestureDetector(
          onTap: _toggleMenu,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(24, 84, 235, 1),
                  Color.fromRGBO(63, 121, 230, 1),
                  Color.fromRGBO(95, 145, 236, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C3545).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Transform.rotate(
              angle: _animateIcon.value * 3.14159 * 2,
              child: Icon(
                _isOpen ? Icons.close : Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
