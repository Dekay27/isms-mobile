import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_controller.dart';
import 'router.dart';
import 'theme.dart';

class IsmsMobileApp extends ConsumerStatefulWidget {
  const IsmsMobileApp({super.key});

  @override
  ConsumerState<IsmsMobileApp> createState() => _IsmsMobileAppState();
}

class _IsmsMobileAppState extends ConsumerState<IsmsMobileApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).bootstrap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ISMS Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.materialLight(),
      routerConfig: router,
    );
  }
}
