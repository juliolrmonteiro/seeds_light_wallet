class FiatRateModel {
  Map<String, double> rates;
  String base;

  FiatRateModel(this.rates, {this.base = "USD"});

  factory FiatRateModel.fromJson(Map<String, dynamic> json) {
    if (json != null && json.isNotEmpty) {
      return FiatRateModel(Map<String, double>.from(json["rates"]));
    } else {
      return null;
    }
  }

  factory FiatRateModel.fromJsonFixer(Map<String, dynamic> json) {
    if (json != null && json.isNotEmpty) {
      var model = FiatRateModel(Map<String, double>.from(json["rates"]), base: json["base"]);
      model.rebase("USD");
      return model;
    } else {
      return null;
    }
  }

  double usdTo(double usdValue, String currency) {
    double rate = rates[currency];
    assert(rate != null);
    return usdValue * rate;
  }

  double toUSD(double currencyValue, String currency) {
    double rate = rates[currency];
    assert(rate != null);
    return rate > 0 ? currencyValue / rate : 0;
  }

  void rebase(String symbol) {
    var rate = rates[symbol];
    if (rate != null) {
      base = symbol;
      rates = rates.map((key, value) => MapEntry(key, value / rate));
    } else {
      print("error - can't rebase to " + symbol);
    }
  }

  void merge(FiatRateModel other) => rates.addAll(other.rates);
}
