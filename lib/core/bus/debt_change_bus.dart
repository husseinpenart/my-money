import 'package:flutter/foundation.dart';

class DebtChangeBus extends ChangeNotifier {
  DebtChangeBus._();
  static final DebtChangeBus instance = DebtChangeBus._();
  void notifyChanged() => notifyListeners();
}
