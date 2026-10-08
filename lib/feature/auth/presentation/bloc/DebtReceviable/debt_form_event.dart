import 'package:money/feature/model/DebtReceviable/debt_form_data.dart';

abstract class DebtFormEvent {
  const DebtFormEvent();
}

class DebtSubmitted extends DebtFormEvent {
  final DebtFormData data;
  const DebtSubmitted(this.data);
}
