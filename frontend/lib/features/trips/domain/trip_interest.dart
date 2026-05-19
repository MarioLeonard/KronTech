enum TripInterest {
  nature('nature', 'Nature'),
  culture('culture', 'Culture'),
  food('food', 'Food'),
  relaxation('relaxation', 'Relaxation'),
  nightlife('nightlife', 'Nightlife'),
  shopping('shopping', 'Shopping'),
  adventure('adventure', 'Adventure'),
  history('history', 'History'),
  familyKids('family_kids', 'Family/kids'),
  lowBudget('low_budget', 'Low budget'),
  luxuryPremium('luxury_premium', 'Luxury/premium');

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
