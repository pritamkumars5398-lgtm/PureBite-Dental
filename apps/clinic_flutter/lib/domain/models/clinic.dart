class ClinicMembership {
  const ClinicMembership({
    required this.id,
    required this.name,
    required this.role,
    required this.subscriptionActive,
    this.subscriptionEndDate,
  });

  final String id;
  final String name;
  final String role;
  final bool subscriptionActive;
  final String? subscriptionEndDate;
}

class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.taxId,
    required this.timezone,
    required this.currency,
    this.legalName,
    this.phone,
    this.email,
    this.address = const {},
  });

  final String id;
  final String name;
  final String taxId;
  final String? legalName;
  final String? phone;
  final String? email;
  final String timezone;
  final String currency;
  final Map<String, String> address;
}

class ClinicUpdate {
  const ClinicUpdate({
    this.name,
    this.taxId,
    this.legalName,
    this.phone,
    this.email,
    this.timezone,
    this.address,
  });

  final String? name;
  final String? taxId;
  final String? legalName;
  final String? phone;
  final String? email;
  final String? timezone;
  final Map<String, String>? address;
}
