import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_event.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_state.dart';
import 'package:money/feature/data/dataResource/budget_remote_data_source.dart';
import 'package:money/feature/model/budget/budget_models.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRemoteDataSource ds;

  BudgetBloc({required this.ds}) : super(const BudgetState()) {
    on<BudgetRefreshed>(_onRefreshed, transformer: droppable());
    on<BudgetCycleSelected>(_onCycle, transformer: restartable());
    on<BudgetProfileSaved>(
      (e, emit) => _mutate(
        emit,
        () => ds.saveProfile(e.profile),
        'اطلاعات حقوق ذخیره شد',
      ),
      transformer: sequential(),
    );
    on<BudgetSalaryConfirmed>(
      (e, emit) => _mutate(
        emit,
        () => ds.confirmSalary(e.amount, state.plan?.cycleKey),
        'حقوق این دوره ثبت شد',
      ),
      transformer: sequential(),
    );
    on<BudgetItemSaved>(
      (e, emit) => _mutate(
        emit,
        () => ds.saveItem(e.item),
        e.item.itemId == null ? 'به برنامه اضافه شد' : 'با موفقیت ویرایش شد',
      ),
      transformer: sequential(),
    );
    on<BudgetItemDeleted>(
      (e, emit) => _mutate(emit, () => ds.deleteItem(e.id), 'از برنامه حذف شد'),
      transformer: sequential(),
    );
    on<BudgetExpenseAdded>(
      (e, emit) => _mutate(
        emit,
        () => ds.addExpense(
          itemId: e.itemId,
          title: e.title,
          category: e.category,
          amount: e.amount,
          date: e.date,
          note: e.note,
        ),
        'هزینه ثبت شد',
      ),
      transformer: sequential(),
    );
    on<BudgetExpenseDeleted>(
      (e, emit) => _mutate(emit, () => ds.deleteExpense(e.id), 'هزینه حذف شد'),
      transformer: sequential(),
    );
  }

  String _msg(Object e) =>
      e is BudgetApiException ? e.message : backendMessage(e);

  Future<void> _loadAll(Emitter<BudgetState> emit) async {
    final r = await Future.wait<dynamic>([
      ds.getPlan(state.cycle),
      ds.getHistory(),
      ds.getItems(),
      ds.getProfile(),
    ]);
    emit(
      state.copyWith(
        status: BudgetStatus.success,
        plan: r[0] as BudgetPlan,
        history: r[1] as List<CycleSummary>,
        items: r[2] as List<BudgetItem>,
        profile: r[3] as SalaryProfile?,
        clearError: true,
      ),
    );
  }

  Future<void> _onRefreshed(
    BudgetRefreshed e,
    Emitter<BudgetState> emit,
  ) async {
    try {
      if (state.plan == null)
        emit(state.copyWith(status: BudgetStatus.loading, clearError: true));
      await _loadAll(emit);
    } catch (err) {
      if (state.plan == null) {
        emit(state.copyWith(status: BudgetStatus.failure, error: _msg(err)));
      } else {
        emit(state.copyWith(feedback: BudgetFeedback.error(_msg(err))));
      }
    } finally {
      if (e.done != null && !e.done!.isCompleted) e.done!.complete();
    }
  }

  Future<void> _onCycle(
    BudgetCycleSelected e,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(cycle: e.key, resetCycle: e.key == null));
    try {
      final plan = await ds.getPlan(e.key);
      emit(
        state.copyWith(
          plan: plan,
          cycle: plan.isCurrent ? null : plan.cycleKey,
          resetCycle: plan.isCurrent,
        ),
      );
    } catch (err) {
      emit(state.copyWith(feedback: BudgetFeedback.error(_msg(err))));
    }
  }

  Future<void> _mutate(
    Emitter<BudgetState> emit,
    Future<void> Function() op,
    String ok,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await op();
      await _loadAll(emit);
      emit(
        state.copyWith(
          isSubmitting: false,
          version: state.version + 1,
          feedback: BudgetFeedback.success(ok),
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: BudgetFeedback.error(_msg(err)),
        ),
      );
    }
  }
}
