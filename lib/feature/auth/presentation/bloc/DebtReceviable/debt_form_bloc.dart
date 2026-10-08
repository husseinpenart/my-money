import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/bloc/DebtReceviable/debt_form_event.dart';
import 'package:money/feature/auth/presentation/bloc/DebtReceviable/debt_form_state.dart';
import 'package:money/feature/data/dataResource/debt_remote_data_source.dart';
import 'package:money/feature/model/DebtReceviable/debt_form_data.dart';


class DebtFormBloc extends Bloc<DebtFormEvent, DebtFormState> {
  final DebtRemoteDataSource remoteDataSource;

  DebtFormBloc({required this.remoteDataSource}) : super(const DebtFormState()) {
    on<DebtSubmitted>(_onSubmitted, transformer: droppable());
  }

  Future<void> _onSubmitted(
    DebtSubmitted event,
    Emitter<DebtFormState> emit,
  ) async {
    emit(const DebtFormState(status: DebtFormStatus.submitting));
    try {
      final isEdit = event.data.payId != null;
      if (isEdit) {
        await remoteDataSource.update(event.data);
      } else {
        await remoteDataSource.create(event.data);
      }
      emit(DebtFormState(
        status: DebtFormStatus.success,
        message: isEdit ? 'با موفقیت ویرایش شد' : 'با موفقیت ثبت شد',
      ));
    } catch (e) {
      emit(DebtFormState(
        status: DebtFormStatus.failure,
        message: e is DebtApiException ? e.message : backendMessage(e),
      ));
    }
  }
}