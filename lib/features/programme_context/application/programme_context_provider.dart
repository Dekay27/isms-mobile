import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../me/data/me_api.dart';
import '../domain/programme_context.dart';

final programmeContextProvider = FutureProvider<ProgrammeContext>((ref) async {
  final data = await ref.read(meApiProvider).programmeContext();
  return ProgrammeContext.fromMap(data);
});
