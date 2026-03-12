class StudentProfile {
  const StudentProfile({
    required this.admissionNo,
    this.formNo,
    this.fullName,
    this.surname,
    this.firstName,
    this.otherNames,
    this.sex,
    this.programmeCode,
    this.programmeName,
    this.level,
    this.levelDescription,
    this.semester,
    this.semesterId,
    this.departmentCode,
    this.departmentName,
    this.facultyCode,
    this.facultyName,
    this.school,
    this.academicYear,
    this.status,
    this.telephone,
    this.telephone1,
    this.telephone2,
    this.email,
    this.email2,
    this.region,
    this.countryOfOrigin,
    this.admissionDate,
    this.admissionYear,
    this.intake,
    this.photoPath,
  });

  final String admissionNo;
  final String? formNo;
  final String? fullName;
  final String? surname;
  final String? firstName;
  final String? otherNames;
  final String? sex;
  final String? programmeCode;
  final String? programmeName;
  final String? level;
  final String? levelDescription;
  final String? semester;
  final String? semesterId;
  final String? departmentCode;
  final String? departmentName;
  final String? facultyCode;
  final String? facultyName;
  final String? school;
  final String? academicYear;
  final String? status;
  final String? telephone;
  final String? telephone1;
  final String? telephone2;
  final String? email;
  final String? email2;
  final String? region;
  final String? countryOfOrigin;
  final String? admissionDate;
  final dynamic admissionYear;
  final String? intake;
  final String? photoPath;

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    String? readString(String key) {
      final value = map[key];
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return StudentProfile(
      admissionNo: readString('admission_no') ?? '',
      formNo: readString('form_no'),
      fullName: readString('full_name'),
      surname: readString('surname'),
      firstName: readString('first_name'),
      otherNames: readString('other_names'),
      sex: readString('sex'),
      programmeCode: readString('programme_code'),
      programmeName: readString('programme_name'),
      level: readString('level'),
      levelDescription: readString('level_description'),
      semester: readString('semester'),
      semesterId: readString('semester_id'),
      departmentCode: readString('department_code'),
      departmentName: readString('department_name'),
      facultyCode: readString('faculty_code'),
      facultyName: readString('faculty_name'),
      school: readString('school'),
      academicYear: readString('academic_year'),
      status: readString('status'),
      telephone: readString('telephone'),
      telephone1: readString('telephone_1'),
      telephone2: readString('telephone_2'),
      email: readString('email'),
      email2: readString('email_2'),
      region: readString('region'),
      countryOfOrigin: readString('country_of_origin'),
      admissionDate: readString('admission_date'),
      admissionYear: map['admission_year'],
      intake: readString('intake'),
      photoPath: readString('photo_path'),
    );
  }
}
