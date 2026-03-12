class ResultsTermFilter {
  const ResultsTermFilter({
    required this.academicYear,
    required this.semesterId,
    this.semester,
  });

  final String academicYear;
  final String semesterId;
  final String? semester;

  @override
  bool operator ==(Object other) {
    return other is ResultsTermFilter &&
        other.academicYear == academicYear &&
        other.semesterId == semesterId &&
        other.semester == semester;
  }

  @override
  int get hashCode => Object.hash(academicYear, semesterId, semester);
}

class ResultsSummary {
  const ResultsSummary({
    required this.admissionNo,
    required this.latest,
    required this.overall,
    required this.terms,
  });

  final String admissionNo;
  final LatestSnapshot latest;
  final OverallSummary overall;
  final List<ResultsTermSummary> terms;

  factory ResultsSummary.fromMap(Map<String, dynamic> map) {
    final termsRaw = (map['terms'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    return ResultsSummary(
      admissionNo: (map['admission_no'] ?? '').toString(),
      latest: LatestSnapshot.fromMap(
        (map['latest'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      overall: OverallSummary.fromMap(
        (map['overall'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      terms: termsRaw.map(ResultsTermSummary.fromMap).toList(),
    );
  }
}

class LatestSnapshot {
  const LatestSnapshot({
    this.academicYear,
    this.semester,
    this.semesterId,
    this.level,
    this.programme,
    this.school,
    this.cgpa,
    this.fgpa,
    this.fgpaStatus,
  });

  final String? academicYear;
  final String? semester;
  final String? semesterId;
  final String? level;
  final String? programme;
  final String? school;
  final double? cgpa;
  final double? fgpa;
  final int? fgpaStatus;

  factory LatestSnapshot.fromMap(Map<String, dynamic> map) {
    return LatestSnapshot(
      academicYear: _s(map['academic_year']),
      semester: _s(map['semester']),
      semesterId: _s(map['semester_id']),
      level: _s(map['level']),
      programme: _s(map['programme']),
      school: _s(map['school']),
      cgpa: _d(map['cgpa']),
      fgpa: _d(map['fgpa']),
      fgpaStatus: _i(map['fgpa_status']),
    );
  }
}

class OverallSummary {
  const OverallSummary({
    required this.coursesCount,
    required this.totalCredits,
  });

  final int coursesCount;
  final double totalCredits;

  factory OverallSummary.fromMap(Map<String, dynamic> map) {
    return OverallSummary(
      coursesCount: _i(map['courses_count']) ?? 0,
      totalCredits: _d(map['total_credits']) ?? 0,
    );
  }
}

class ResultsTermSummary {
  const ResultsTermSummary({
    required this.academicYear,
    required this.semester,
    required this.semesterId,
    required this.coursesCount,
    required this.totalCredits,
    this.tgpa,
    this.cgpa,
    this.fgpa,
  });

  final String academicYear;
  final String? semester;
  final String semesterId;
  final int coursesCount;
  final double totalCredits;
  final double? tgpa;
  final double? cgpa;
  final double? fgpa;

  factory ResultsTermSummary.fromMap(Map<String, dynamic> map) {
    return ResultsTermSummary(
      academicYear: _s(map['academic_year']) ?? '',
      semester: _s(map['semester']),
      semesterId: _s(map['semester_id']) ?? '',
      coursesCount: _i(map['courses_count']) ?? 0,
      totalCredits: _d(map['total_credits']) ?? 0,
      tgpa: _d(map['tgpa']),
      cgpa: _d(map['cgpa']),
      fgpa: _d(map['fgpa']),
    );
  }
}

class SemesterResult {
  const SemesterResult({
    required this.admissionNo,
    required this.term,
    required this.rows,
  });

  final String admissionNo;
  final ResultsTermSummary term;
  final List<ResultRow> rows;

  factory SemesterResult.fromMap(Map<String, dynamic> map) {
    final rowsRaw = (map['rows'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    final termMap =
        (map['term'] as Map<String, dynamic>? ?? <String, dynamic>{});
    final normalizedTerm = <String, dynamic>{
      'academic_year': termMap['academic_year'],
      'semester': termMap['semester'],
      'semester_id': termMap['semester_id'],
      'courses_count': rowsRaw.length,
      'total_credits': rowsRaw.fold<double>(
        0,
        (sum, row) => sum + (_d(row['no_of_credit']) ?? 0),
      ),
      'tgpa': null,
      'cgpa': null,
      'fgpa': null,
    };

    return SemesterResult(
      admissionNo: (map['admission_no'] ?? '').toString(),
      term: ResultsTermSummary.fromMap(normalizedTerm),
      rows: rowsRaw.map(ResultRow.fromMap).toList(),
    );
  }
}

class ResultSlip {
  const ResultSlip({
    required this.admissionNo,
    required this.student,
    required this.term,
    required this.summary,
    required this.rows,
  });

  final String admissionNo;
  final SlipStudent student;
  final ResultsTermSummary term;
  final SlipSummary summary;
  final List<ResultRow> rows;

  factory ResultSlip.fromMap(Map<String, dynamic> map) {
    final rowsRaw = (map['rows'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();
    final termMap =
        (map['term'] as Map<String, dynamic>? ?? <String, dynamic>{});
    final summaryMap =
        (map['summary'] as Map<String, dynamic>? ?? <String, dynamic>{});

    final normalizedTerm = <String, dynamic>{
      'academic_year': termMap['academic_year'],
      'semester': termMap['semester'],
      'semester_id': termMap['semester_id'],
      'courses_count': summaryMap['courses_count'] ?? rowsRaw.length,
      'total_credits':
          summaryMap['total_credits'] ??
          rowsRaw.fold<double>(
            0,
            (sum, row) => sum + (_d(row['no_of_credit']) ?? 0),
          ),
      'tgpa': summaryMap['tgpa'],
      'cgpa': summaryMap['cgpa'],
      'fgpa': summaryMap['fgpa'],
    };

    return ResultSlip(
      admissionNo: (map['admission_no'] ?? '').toString(),
      student: SlipStudent.fromMap(
        (map['student'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      term: ResultsTermSummary.fromMap(normalizedTerm),
      summary: SlipSummary.fromMap(summaryMap),
      rows: rowsRaw.map(ResultRow.fromMap).toList(),
    );
  }
}

class SlipStudent {
  const SlipStudent({
    this.fullName,
    this.programme,
    this.programmeName,
    this.level,
    this.departmentName,
    this.facultyName,
    this.school,
  });

  final String? fullName;
  final String? programme;
  final String? programmeName;
  final String? level;
  final String? departmentName;
  final String? facultyName;
  final String? school;

  factory SlipStudent.fromMap(Map<String, dynamic> map) {
    return SlipStudent(
      fullName: _s(map['full_name']),
      programme: _s(map['programme']),
      programmeName: _s(map['programme_name']),
      level: _s(map['level']),
      departmentName: _s(map['department_name']),
      facultyName: _s(map['faculty_name']),
      school: _s(map['school']),
    );
  }
}

class SlipSummary {
  const SlipSummary({
    required this.coursesCount,
    required this.totalCredits,
    this.termGpa,
    this.tgpa,
    this.cgpa,
    this.fgpa,
    this.fgpaStatus,
  });

  final int coursesCount;
  final double totalCredits;
  final double? termGpa;
  final double? tgpa;
  final double? cgpa;
  final double? fgpa;
  final int? fgpaStatus;

  factory SlipSummary.fromMap(Map<String, dynamic> map) {
    return SlipSummary(
      coursesCount: _i(map['courses_count']) ?? 0,
      totalCredits: _d(map['total_credits']) ?? 0,
      termGpa: _d(map['term_gpa']),
      tgpa: _d(map['tgpa']),
      cgpa: _d(map['cgpa']),
      fgpa: _d(map['fgpa']),
      fgpaStatus: _i(map['fgpa_status']),
    );
  }
}

class ResultRow {
  const ResultRow({
    this.courseCode,
    this.courseName,
    this.noOfCredit,
    this.classScore,
    this.examScore,
    this.totalScore,
    this.grade,
    this.remark,
    this.gpa,
  });

  final String? courseCode;
  final String? courseName;
  final double? noOfCredit;
  final double? classScore;
  final double? examScore;
  final double? totalScore;
  final String? grade;
  final String? remark;
  final double? gpa;

  factory ResultRow.fromMap(Map<String, dynamic> map) {
    return ResultRow(
      courseCode: _s(map['course_code']),
      courseName: _s(map['course_name']),
      noOfCredit: _d(map['no_of_credit']),
      classScore: _d(map['class_score']),
      examScore: _d(map['exam_score']),
      totalScore: _d(map['total_score']),
      grade: _s(map['grade']),
      remark: _s(map['remark']),
      gpa: _d(map['gpa']),
    );
  }
}

String? _s(Object? v) {
  if (v == null) return null;
  final t = v.toString().trim();
  return t.isEmpty ? null : t;
}

double? _d(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int? _i(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
