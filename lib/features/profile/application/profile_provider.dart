import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../me/data/me_api.dart';
import '../domain/student_profile.dart';

final profileProvider = FutureProvider<StudentProfile>((ref) async {
  final data = await ref.read(meApiProvider).profile();
  return StudentProfile.fromMap(data);
});
