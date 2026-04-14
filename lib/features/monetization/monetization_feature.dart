enum BebiaPlan { free, plus }

class MonetizationFeature {
  const MonetizationFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.includedInFree,
    required this.businessReason,
    required this.plusPillar,
    required this.launchPhase,
    required this.upgradeMoment,
  });

  final String id;
  final String title;
  final String description;
  final bool includedInFree;
  final String businessReason;
  final String plusPillar;
  final String launchPhase;
  final String upgradeMoment;
}
