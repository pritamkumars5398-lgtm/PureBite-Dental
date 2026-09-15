import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/di.dart';
import '../domain/models/patient.dart';
import '../ui/core/layout/adaptive_master_detail.dart';
import '../ui/core/layout/app_chrome.dart';
import '../ui/features/agenda/view_models/agenda_view_model.dart';
import '../ui/features/agenda/views/agenda_view.dart';
import '../ui/features/auth/views/login_view.dart';
import '../ui/features/home/view_models/home_view_model.dart';
import '../ui/features/home/views/home_view.dart';
import '../ui/features/copilot/views/copilot_view.dart';
import '../ui/features/invoices/views/invoice_detail_view.dart';
import '../ui/features/invoices/views/invoices_view.dart';
import '../ui/features/notes/views/notes_view.dart';
import '../ui/features/payments/views/payment_detail_view.dart';
import '../ui/features/payments/views/payments_view.dart';
import '../ui/features/plans/views/treatment_plans_view.dart';
import '../ui/features/quotes/views/quote_detail_view.dart';
import '../ui/features/quotes/views/quotes_view.dart';
import '../ui/features/recalls/views/recalls_view.dart';
import '../ui/features/reports/views/reports_view.dart';
import '../ui/features/odontogram/views/odontogram_view.dart';
import '../ui/features/patients/view_models/patient_create_view_model.dart';
import '../ui/features/patients/view_models/patient_detail_view_model.dart';
import '../ui/features/patients/view_models/patient_list_view_model.dart';
import '../ui/features/patients/views/patient_create_sheet.dart';
import '../ui/features/patients/views/patient_detail_view.dart';
import '../ui/features/patients/views/patient_list_view.dart';
import '../ui/features/settings/views/settings_view.dart';
import '../ui/features/shell/view_models/session_controller.dart';

GoRouter createRouter() {
  final session = getIt<SessionController>();
  return GoRouter(
    initialLocation: '/',
    refreshListenable: session,
    redirect: (context, state) {
      if (!session.isReady) return null;
      final loggingIn = state.matchedLocation == '/login';
      if (!session.isAuthenticated) return loggingIn ? null : '/login';
      if (loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginView(viewModel: getIt()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              final vm = getIt<HomeViewModel>();
              return HomeView(
                viewModel: vm,
                session: getIt(),
                onOpenSchedule: () => context.go('/appointments'),
                onOpenPatients: () => context.go('/patients'),
              );
            },
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) {
              final id = state.uri.queryParameters['id'];
              return _PatientsPage(selectedId: id);
            },
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) {
              final vm = getIt<AgendaViewModel>();
              vm.load();
              return AgendaView(viewModel: vm);
            },
          ),
          GoRoute(path: '/recalls', builder: (context, state) => const RecallsView()),
          GoRoute(
            path: '/treatment-plans',
            builder: (context, state) => const TreatmentPlansView(),
          ),
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const _QuotesPage(),
          ),
          GoRoute(
            path: '/invoices',
            builder: (context, state) => const _InvoicesPage(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const _PaymentsPage(),
          ),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsView()),
          GoRoute(path: '/copilot', builder: (context, state) => const CopilotView()),
          GoRoute(path: '/chart', builder: (context, state) => const OdontogramView()),
          GoRoute(
            path: '/notes',
            builder: (context, state) => NotesView(viewModel: getIt()),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => SettingsView(
              categoryId: 'general',
              session: session.session,
              onSelectCategory: (id) => context.go('/settings/$id'),
            ),
            routes: [
              GoRoute(
                path: ':category',
                builder: (context, state) {
                  final id = state.pathParameters['category'] ?? 'general';
                  return SettingsView(
                    categoryId: id,
                    session: session.session,
                    onSelectCategory: (next) => context.go('/settings/$next'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionController>();
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        return AppChrome(
          location: location,
          onNavigate: (path) => context.go(path),
          session: session.session,
          offline: !session.isOnline,
          onLogout: session.logout,
          body: child,
        );
      },
    );
  }
}

class _PatientsPage extends StatefulWidget {
  const _PatientsPage({this.selectedId});

  final String? selectedId;

  @override
  State<_PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<_PatientsPage> {
  late final _listVm = getIt<PatientListViewModel>();
  late final _detailVm = getIt<PatientDetailViewModel>();
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
    _listVm.load();
    if (_selectedId != null) _detailVm.load(_selectedId!);
  }

  Future<void> _openCreate() async {
    final createVm = getIt<PatientCreateViewModel>();
    final created = await showModalBottomSheet<Patient>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PatientCreateSheet(viewModel: createVm),
    );
    createVm.dispose();
    if (!mounted || created == null) return;
    await _listVm.load();
    setState(() => _selectedId = created.id);
    _detailVm.load(created.id);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveMasterDetail(
      showDetail: _selectedId != null,
      master: PatientListView(
        viewModel: _listVm,
        onPatientSelected: (p) {
          setState(() => _selectedId = p.id);
          _detailVm.load(p.id);
        },
        onAdd: _openCreate,
      ),
      detail: PatientDetailView(viewModel: _detailVm),
    );
  }
}

class _QuotesPage extends StatefulWidget {
  const _QuotesPage();

  @override
  State<_QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<_QuotesPage> {
  QuoteListItem? _selected;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMasterDetail(
      showDetail: _selected != null,
      master: QuotesView(
        onSelected: (item) => setState(() => _selected = item),
      ),
      detail: QuoteDetailView(
        title: _selected?.title,
        patientName: _selected?.patientName,
        status: _selected?.status,
      ),
    );
  }
}

class _InvoicesPage extends StatefulWidget {
  const _InvoicesPage();

  @override
  State<_InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<_InvoicesPage> {
  InvoiceListItem? _selected;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMasterDetail(
      showDetail: _selected != null,
      master: InvoicesView(
        onSelected: (item) => setState(() => _selected = item),
      ),
      detail: InvoiceDetailView(
        title: _selected?.title,
        patientName: _selected?.patientName,
        status: _selected?.status,
      ),
    );
  }
}

class _PaymentsPage extends StatefulWidget {
  const _PaymentsPage();

  @override
  State<_PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<_PaymentsPage> {
  PaymentListItem? _selected;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMasterDetail(
      showDetail: _selected != null,
      master: PaymentsView(
        onSelected: (item) => setState(() => _selected = item),
      ),
      detail: PaymentDetailView(
        title: _selected?.title,
        patientName: _selected?.patientName,
        status: _selected?.status,
      ),
    );
  }
}
