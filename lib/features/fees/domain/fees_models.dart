class FeesSummary {
  const FeesSummary({
    required this.admissionNo,
    required this.paybalance,
    required this.payments,
    required this.billing,
    this.asOf,
  });

  final String admissionNo;
  final PayBalanceSummary paybalance;
  final PaymentsSummary payments;
  final BillingSummary billing;
  final String? asOf;

  factory FeesSummary.fromEnvelope(Map<String, dynamic> map) {
    final data = (map['data'] as Map<String, dynamic>? ?? <String, dynamic>{});

    return FeesSummary(
      admissionNo: (data['admission_no'] ?? '').toString(),
      paybalance: PayBalanceSummary.fromMap(
        (data['paybalance'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      payments: PaymentsSummary.fromMap(
        (data['payments'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      billing: BillingSummary.fromMap(
        (data['billing'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      asOf: _s(data['as_of']),
    );
  }
}

class PayBalanceSummary {
  const PayBalanceSummary({
    this.balanceDate,
    this.balancePrevious,
    this.totalAmountDue,
    this.balance,
    this.accountNo,
    this.exempt,
    this.oldBalance,
    this.convertedBalance,
    this.semCode,
    this.semCodePrev,
  });

  final String? balanceDate;
  final double? balancePrevious;
  final double? totalAmountDue;
  final double? balance;
  final String? accountNo;
  final String? exempt;
  final double? oldBalance;
  final double? convertedBalance;
  final String? semCode;
  final String? semCodePrev;

  factory PayBalanceSummary.fromMap(Map<String, dynamic> map) {
    return PayBalanceSummary(
      balanceDate: _s(map['balance_date']),
      balancePrevious: _d(map['balance_previous']),
      totalAmountDue: _d(map['total_amount_due']),
      balance: _d(map['balance']),
      accountNo: _s(map['account_no']),
      exempt: _s(map['exempt']),
      oldBalance: _d(map['old_balance']),
      convertedBalance: _d(map['converted_balance']),
      semCode: _s(map['sem_code']),
      semCodePrev: _s(map['sem_code_prev']),
    );
  }
}

class PaymentsSummary {
  const PaymentsSummary({
    required this.count,
    required this.totalPaid,
    this.lastPaymentDate,
  });

  final int count;
  final double totalPaid;
  final String? lastPaymentDate;

  factory PaymentsSummary.fromMap(Map<String, dynamic> map) {
    return PaymentsSummary(
      count: _i(map['count']) ?? 0,
      totalPaid: _d(map['total_paid']) ?? 0,
      lastPaymentDate: _s(map['last_payment_date']),
    );
  }
}

class BillingSummary {
  const BillingSummary({
    required this.billLines,
    required this.totalPayable,
    required this.totalBilledPaid,
    required this.totalBillBalance,
    this.lastBillingDate,
    this.academicYear,
    this.semester,
  });

  final int billLines;
  final double totalPayable;
  final double totalBilledPaid;
  final double totalBillBalance;
  final String? lastBillingDate;
  final String? academicYear;
  final String? semester;

  factory BillingSummary.fromMap(Map<String, dynamic> map) {
    return BillingSummary(
      billLines: _i(map['bill_lines']) ?? 0,
      totalPayable: _d(map['total_payable']) ?? 0,
      totalBilledPaid: _d(map['total_billed_paid']) ?? 0,
      totalBillBalance: _d(map['total_bill_balance']) ?? 0,
      lastBillingDate: _s(map['last_billing_date']),
      academicYear: _s(map['academic_year']),
      semester: _s(map['semester']),
    );
  }
}

class FeesPageMeta {
  const FeesPageMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  factory FeesPageMeta.fromMap(Map<String, dynamic> map) {
    return FeesPageMeta(
      currentPage: _i(map['current_page']) ?? 1,
      lastPage: _i(map['last_page']) ?? 1,
      perPage: _i(map['per_page']) ?? 20,
      total: _i(map['total']) ?? 0,
    );
  }
}

class FeesPaymentsQuery {
  const FeesPaymentsQuery({
    this.page = 1,
    this.perPage = 20,
    this.academicYear,
    this.dateFrom,
    this.dateTo,
    this.semester,
  });

  final int page;
  final int perPage;
  final String? academicYear;
  final String? dateFrom;
  final String? dateTo;
  final String? semester;

  @override
  bool operator ==(Object other) {
    return other is FeesPaymentsQuery &&
        other.page == page &&
        other.perPage == perPage &&
        other.academicYear == academicYear &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo &&
        other.semester == semester;
  }

  @override
  int get hashCode =>
      Object.hash(page, perPage, academicYear, dateFrom, dateTo, semester);
}

class FeesBillingQuery {
  const FeesBillingQuery({
    this.page = 1,
    this.perPage = 20,
    this.academicYear,
    this.semester,
    this.dateFrom,
    this.dateTo,
  });

  final int page;
  final int perPage;
  final String? academicYear;
  final String? semester;
  final String? dateFrom;
  final String? dateTo;

  @override
  bool operator ==(Object other) {
    return other is FeesBillingQuery &&
        other.page == page &&
        other.perPage == perPage &&
        other.academicYear == academicYear &&
        other.semester == semester &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo;
  }

  @override
  int get hashCode =>
      Object.hash(page, perPage, academicYear, semester, dateFrom, dateTo);
}

class FeesPaymentsPage {
  const FeesPaymentsPage({
    required this.admissionNo,
    required this.rows,
    required this.meta,
  });

  final String admissionNo;
  final List<FeePaymentRow> rows;
  final FeesPageMeta meta;

  factory FeesPaymentsPage.fromEnvelope(Map<String, dynamic> map) {
    final data = (map['data'] as Map<String, dynamic>? ?? <String, dynamic>{});
    final rowsRaw = (data['rows'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    return FeesPaymentsPage(
      admissionNo: (data['admission_no'] ?? '').toString(),
      rows: rowsRaw.map(FeePaymentRow.fromMap).toList(),
      meta: FeesPageMeta.fromMap(
        (map['meta'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}

class FeePaymentRow {
  const FeePaymentRow({
    this.recordKey,
    this.admissionNo,
    this.studentName,
    this.receiptNo,
    this.postDate,
    this.amountReceived,
    this.paymentType,
    this.balance,
    this.narration,
    this.currencyType,
    this.manualReceiptNo,
    this.academicYear,
    this.termId,
    this.accountNo,
    this.valueDate,
  });

  final int? recordKey;
  final String? admissionNo;
  final String? studentName;
  final String? receiptNo;
  final String? postDate;
  final double? amountReceived;
  final String? paymentType;
  final double? balance;
  final String? narration;
  final String? currencyType;
  final String? manualReceiptNo;
  final String? academicYear;
  final String? termId;
  final String? accountNo;
  final String? valueDate;

  factory FeePaymentRow.fromMap(Map<String, dynamic> map) {
    return FeePaymentRow(
      recordKey: _i(map['record_key']),
      admissionNo: _s(map['admission_no']),
      studentName: _s(map['student_name']),
      receiptNo: _s(map['receipt_no']),
      postDate: _s(map['post_date']),
      amountReceived: _d(map['amount_received']),
      paymentType: _s(map['payment_type']),
      balance: _d(map['balance']),
      narration: _s(map['narration']),
      currencyType: _s(map['currency_type']),
      manualReceiptNo: _s(map['manual_receipt_no']),
      academicYear: _s(map['academic_year']),
      termId: _s(map['term_id']),
      accountNo: _s(map['account_no']),
      valueDate: _s(map['value_date']),
    );
  }
}

class FeesBillingPage {
  const FeesBillingPage({
    required this.admissionNo,
    required this.rows,
    required this.meta,
  });

  final String admissionNo;
  final List<FeeBillingRow> rows;
  final FeesPageMeta meta;

  factory FeesBillingPage.fromEnvelope(Map<String, dynamic> map) {
    final data = (map['data'] as Map<String, dynamic>? ?? <String, dynamic>{});
    final rowsRaw = (data['rows'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    return FeesBillingPage(
      admissionNo: (data['admission_no'] ?? '').toString(),
      rows: rowsRaw.map(FeeBillingRow.fromMap).toList(),
      meta: FeesPageMeta.fromMap(
        (map['meta'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}

class FeeBillingRow {
  const FeeBillingRow({
    this.recordKey,
    this.admissionNo,
    this.programme,
    this.level,
    this.school,
    this.semester,
    this.academicYear,
    this.feeDescription,
    this.narration,
    this.balanceBd,
    this.amountPayable,
    this.amountPaid,
    this.balance,
    this.balanceDate,
    this.accountNo,
    this.site,
    this.groups,
  });

  final int? recordKey;
  final String? admissionNo;
  final String? programme;
  final String? level;
  final String? school;
  final String? semester;
  final String? academicYear;
  final String? feeDescription;
  final String? narration;
  final double? balanceBd;
  final double? amountPayable;
  final double? amountPaid;
  final double? balance;
  final String? balanceDate;
  final String? accountNo;
  final String? site;
  final String? groups;

  factory FeeBillingRow.fromMap(Map<String, dynamic> map) {
    return FeeBillingRow(
      recordKey: _i(map['record_key']),
      admissionNo: _s(map['admission_no']),
      programme: _s(map['programme']),
      level: _s(map['level']),
      school: _s(map['school']),
      semester: _s(map['semester']),
      academicYear: _s(map['academic_year']),
      feeDescription: _s(map['fee_description']),
      narration: _s(map['narration']),
      balanceBd: _d(map['balance_bd']),
      amountPayable: _d(map['amount_payable']),
      amountPaid: _d(map['amount_paid']),
      balance: _d(map['balance']),
      balanceDate: _s(map['balance_date']),
      accountNo: _s(map['account_no']),
      site: _s(map['site']),
      groups: _s(map['groups']),
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
