/// The current SEEDS per USD
class RateModel {
  final double seedsPerUSD;

  const RateModel(this.seedsPerUSD);

  double? seedsToUSD(double seedsAmount) {
    return seedsPerUSD > 0 ? seedsAmount / seedsPerUSD : null;
  }

  double? usdToSeeds(double usdAmount) {
    return seedsPerUSD > 0 ? usdAmount * seedsPerUSD : null;
  }

  factory RateModel.fromJson(Map<String, dynamic>? json) {
    if (json != null && json['rows'].isNotEmpty) {
      final value = json['rows'][0]['current_seeds_per_usd'] ?? 0.toString();
      final amount = double.parse(value.split(' ').first);
      return RateModel(amount);
    } else {
      return const RateModel(0);
    }
  }
}
