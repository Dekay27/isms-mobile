import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/platform_adaptive.dart';
import '../../auth/application/auth_controller.dart';
import '../application/fees_providers.dart';
import '../domain/fees_models.dart';

class FeesSummaryScreen extends ConsumerWidget {
  const FeesSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(feesSummaryProvider);
    final isCupertino = isCupertinoPlatform(context);

    if (isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Fees Summary'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => ref.invalidate(feesSummaryProvider),
                child: const Icon(CupertinoIcons.refresh),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                child: const Icon(CupertinoIcons.square_arrow_right),
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: asyncSummary.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, _) => _ErrorView(
              isCupertino: true,
              message: error.toString(),
              onRetry: () => ref.invalidate(feesSummaryProvider),
            ),
            data: (summary) => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async =>
                      ref.refresh(feesSummaryProvider.future),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _TopCard(summary: summary, isCupertino: true),
                        const SizedBox(height: 12),
                        _PaybalanceCard(
                          paybalance: summary.paybalance,
                          isCupertino: true,
                        ),
                        const SizedBox(height: 12),
                        _PaymentsCard(
                          payments: summary.payments,
                          isCupertino: true,
                        ),
                        const SizedBox(height: 12),
                        _BillingCard(
                          billing: summary.billing,
                          isCupertino: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              onPressed: () => context.push('/fees/payments'),
                              child: const Text('View Payments'),
                            ),
                            const SizedBox(width: 8),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              onPressed: () => context.push('/fees/billing'),
                              child: const Text('View Billing'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Summary'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(feesSummaryProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: asyncSummary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          isCupertino: false,
          message: error.toString(),
          onRetry: () => ref.invalidate(feesSummaryProvider),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async => ref.refresh(feesSummaryProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TopCard(summary: summary, isCupertino: false),
              const SizedBox(height: 12),
              _PaybalanceCard(
                paybalance: summary.paybalance,
                isCupertino: false,
              ),
              const SizedBox(height: 12),
              _PaymentsCard(payments: summary.payments, isCupertino: false),
              const SizedBox(height: 12),
              _BillingCard(billing: summary.billing, isCupertino: false),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push('/fees/payments'),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('View Payments'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/fees/billing'),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('View Billing'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({required this.summary, required this.isCupertino});

  final FeesSummary summary;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    if (isCupertino) {
      return _AdaptiveCard(
        isCupertino: true,
        child: Row(
          children: [
            const Icon(CupertinoIcons.money_dollar_circle),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admission No: ${summary.admissionNo}'),
                  Text('As at: ${summary.asOf ?? '-'}'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet_outlined),
        title: Text('Admission No: ${summary.admissionNo}'),
        subtitle: Text('As at: ${summary.asOf ?? '-'}'),
      ),
    );
  }
}

class _PaybalanceCard extends StatelessWidget {
  const _PaybalanceCard({required this.paybalance, required this.isCupertino});

  final PayBalanceSummary paybalance;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveCard(
      isCupertino: isCupertino,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: isCupertino
                ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                : Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Balance: ${_money(paybalance.balance)}'),
          Text('Total Amount Due: ${_money(paybalance.totalAmountDue)}'),
          Text('Previous Balance: ${_money(paybalance.balancePrevious)}'),
          Text('Balance Date: ${paybalance.balanceDate ?? '-'}'),
          Text('Account: ${paybalance.accountNo ?? '-'}'),
        ],
      ),
    );
  }
}

class _PaymentsCard extends StatelessWidget {
  const _PaymentsCard({required this.payments, required this.isCupertino});

  final PaymentsSummary payments;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveCard(
      isCupertino: isCupertino,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payments',
            style: isCupertino
                ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                : Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Count: ${payments.count}'),
          Text('Total Paid: ${_money(payments.totalPaid)}'),
          Text('Last Payment Date: ${payments.lastPaymentDate ?? '-'}'),
        ],
      ),
    );
  }
}

class _BillingCard extends StatelessWidget {
  const _BillingCard({required this.billing, required this.isCupertino});

  final BillingSummary billing;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveCard(
      isCupertino: isCupertino,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Billing',
            style: isCupertino
                ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                : Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Lines: ${billing.billLines}'),
          Text('Total Payable: ${_money(billing.totalPayable)}'),
          Text('Total Paid: ${_money(billing.totalBilledPaid)}'),
          Text('Total Bill Balance: ${_money(billing.totalBillBalance)}'),
          Text('Academic Year: ${billing.academicYear ?? '-'}'),
          Text('Semester: ${billing.semester ?? '-'}'),
          Text('Last Billing Date: ${billing.lastBillingDate ?? '-'}'),
        ],
      ),
    );
  }
}

class _AdaptiveCard extends StatelessWidget {
  const _AdaptiveCard({required this.child, required this.isCupertino});

  final Widget child;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    if (isCupertino) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1A696CFF)),
        ),
        child: child,
      );
    }

    return Card(
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.isCupertino,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    final icon = isCupertino
        ? const Icon(CupertinoIcons.exclamationmark_circle, size: 40)
        : const Icon(Icons.error_outline, size: 40);

    final retry = isCupertino
        ? CupertinoButton.filled(onPressed: onRetry, child: const Text('Retry'))
        : ElevatedButton(onPressed: onRetry, child: const Text('Retry'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              'Could not load fees summary',
              style: isCupertino
                  ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                  : Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            retry,
          ],
        ),
      ),
    );
  }
}

String _money(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(2);
}
