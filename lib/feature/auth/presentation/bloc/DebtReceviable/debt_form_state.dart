enum DebtFormStatus { idle, submitting, success, failure }

class DebtFormState {
  final DebtFormStatus status;
  final String? message;
  const DebtFormState({this.status = DebtFormStatus.idle, this.message});
}