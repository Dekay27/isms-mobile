class ProgrammeContext {
  const ProgrammeContext({
    this.admissionNo,
    this.formNo,
    this.studentName,
    this.programmeCode,
    this.programmeName,
    this.departmentCode,
    this.departmentName,
    this.facultyCode,
    this.facultyName,
    this.school,
    this.academicYear,
    this.semester,
    this.semesterId,
    this.level,
    this.levelDescription,
    this.intake,
    this.status,
    this.cgpa,
    this.fgpa,
    this.fgpaStatus,
    this.lastResultAcademicYear,
    this.lastResultSemester,
    this.lastResultSemesterId,
    this.asOf,
  });

  final String? admissionNo;
  final String? formNo;
  final String? studentName;
  final String? programmeCode;
  final String? programmeName;
  final String? departmentCode;
  final String? departmentName;
  final String? facultyCode;
  final String? facultyName;
  final String? school;
  final String? academicYear;
  final String? semester;
  final String? semesterId;
  final String? level;
  final String? levelDescription;
  final String? intake;
  final String? status;
  final double? cgpa;
  final double? fgpa;
  final int? fgpaStatus;
  final String? lastResultAcademicYear;
  final String? lastResultSemester;
  final String? lastResultSemesterId;
  final String? asOf;

  factory ProgrammeContext.fromMap(Map<String, dynamic> map) {
    String? readString(String key) {
      final value = map[key];
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    double? readDouble(String key) {
      final value = map[key];
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? readInt(String key) {
      final value = map[key];
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return ProgrammeContext(
      admissionNo: readString('admission_no'),
      formNo: readString('form_no'),
      studentName: readString('student_name'),
      programmeCode: readString('programme_code'),
      programmeName: readString('programme_name'),
      departmentCode: readString('department_code'),
      departmentName: readString('department_name'),
      facultyCode: readString('faculty_code'),
      facultyName: readString('faculty_name'),
      school: readString('school'),
      academicYear: readString('academic_year'),
      semester: readString('semester'),
      semesterId: readString('semester_id'),
      level: readString('level'),
      levelDescription: readString('level_description'),
      intake: readString('intake'),
      status: readString('status'),
      cgpa: readDouble('cgpa'),
      fgpa: readDouble('fgpa'),
      fgpaStatus: readInt('fgpa_status'),
      lastResultAcademicYear: readString('last_result_academic_year'),
      lastResultSemester: readString('last_result_semester'),
      lastResultSemesterId: readString('last_result_semester_id'),
      asOf: readString('as_of'),
    );
  }
}
