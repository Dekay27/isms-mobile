import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/platform_adaptive.dart';
import '../../auth/application/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (isCupertinoPlatform(context)) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Student Home'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            child: const Icon(CupertinoIcons.square_arrow_right),
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CupertinoProfileHeader(
                name: auth.user?.fullname ?? auth.user?.username ?? 'Student',
                rights: auth.user?.rights ?? 0,
              ),
              const SizedBox(height: 12),
              _CupertinoMenuTile(
                icon: CupertinoIcons.person_crop_circle,
                title: 'Profile',
                subtitle: 'View your student profile details',
                onTap: () => context.push('/profile'),
              ),
              _CupertinoMenuTile(
                icon: CupertinoIcons.book,
                title: 'Programme Context',
                subtitle:
                    'Current programme, level, semester and CGPA snapshot',
                onTap: () => context.push('/programme-context'),
              ),
              _CupertinoMenuTile(
                icon: CupertinoIcons.chart_bar,
                title: 'Results',
                subtitle: 'Summary, semester details and result slip',
                onTap: () => context.push('/results'),
              ),
              _CupertinoMenuTile(
                icon: CupertinoIcons.money_dollar_circle,
                title: 'Fees',
                subtitle: 'Summary, payments and billing records',
                onTap: () => context.push('/fees'),
              ),
              _CupertinoMenuTile(
                icon: CupertinoIcons.lock,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => context.push('/change-password'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(
                auth.user?.fullname ?? auth.user?.username ?? 'Student',
              ),
              subtitle: Text('Rights: ${auth.user?.rights ?? 0}'),
              leading: const CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Profile'),
              subtitle: const Text('View your student profile details'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/profile'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('Programme Context'),
              subtitle: const Text(
                'Current programme, level, semester and CGPA snapshot',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/programme-context'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Results'),
              subtitle: const Text('Summary, semester details and result slip'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/results'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Fees'),
              subtitle: const Text('Summary, payments and billing records'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/fees'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/change-password'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoProfileHeader extends StatelessWidget {
  const _CupertinoProfileHeader({required this.name, required this.rights});

  final String name;
  final int rights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1A696CFF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(CupertinoIcons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                ),
                Text(
                  'Rights: $rights',
                  style: CupertinoTheme.of(context).textTheme.textStyle
                      .copyWith(color: CupertinoColors.systemGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoMenuTile extends StatelessWidget {
  const _CupertinoMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1A696CFF)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF696CFF)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: CupertinoTheme.of(
                        context,
                      ).textTheme.navTitleTextStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            color: CupertinoColors.systemGrey,
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_forward,
                color: CupertinoColors.systemGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
