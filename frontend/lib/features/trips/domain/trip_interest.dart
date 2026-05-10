enum TripInterest {
  nature('nature', 'Natura'),
  culture('culture', 'Cultura'),
  food('food', 'Mancare'),
  relaxation('relaxation', 'Relaxare'),
  nightlife('nightlife', 'Nightlife'),
  shopping('shopping', 'Shopping'),
  adventure('adventure', 'Aventura'),
  history('history', 'Istorie'),
  familyKids('family_kids', 'Familie/copii'),
  lowBudget('low_budget', 'Buget redus'),
  luxuryPremium('luxury_premium', 'Lux/premium');

  const TripInterest(this.value, this.label);

  final String value;
  final String label;

  static TripInterest fromValue(String value) {
    return TripInterest.values.firstWhere(
      (interest) => interest.value == value,
      orElse: () => TripInterest.culture,
    );
  }
}
