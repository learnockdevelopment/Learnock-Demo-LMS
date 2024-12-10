import 'package:intl/intl.dart';
import 'package:webinar/app/models/currency_model.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/data/app_data.dart';

class CurrencyUtils {
  static Map<String, String> customCurrencySymbols = {
    'USD': '\$',
    'EGP': 'EGP',
  };

  static late String userCurrency;

  CurrencyUtils() {
    AppData.getCurrency().then((value) {
      userCurrency = value;

      // Fetch system settings and configuration
      GuestService.getCurrencyList();
      GuestService.config();
      GuestService.systemsettings().then((config) {
        // Check user_multi_currency from the config response
        var userMultiCurrency = config['data']['general_settings']['user_multi_currency'];

        ////print"User Multi Currency: $userMultiCurrency"); // Debugging line

        // Clear the currency list and apply the filter if userMultiCurrency is 0
        if (userMultiCurrency == 0) {
          List<String> regionCurrencies = [];

          // Extract region-specific currencies from the active payment methods
          for (var paymentMethod in config['data']['payment_channels']['active']) {
            regionCurrencies.addAll(paymentMethod['currencies']);
          }

          ////print"Region Currencies: $regionCurrencies"); // Debugging line

          // **Clear** the list and **filter** the currencies
          PublicData.currencyListData.clear();

          // Filter and update the list with the region-specific currencies
          PublicData.currencyListData.addAll(
            PublicData.currencyListData
                .where((currency) => regionCurrencies.contains(currency.currency))
                .toList(),
          );

          // Ensure the list is updated properly
          ////print"Filtered Currency List after update: ${PublicData.currencyListData}");
        } else {
          // If userMultiCurrency is not 0, retain the full list
          ////print"All Currencies: ${PublicData.currencyListData}");
        }

        // After updating the currency list, ensure the UI is refreshed if necessary
        // For example, if you need to call state() to refresh the UI in StatefulWidgets
        // state(() {}); // Uncomment this if you're in a StatefulWidget
      });
    });
  }


  static String getSymbol(String currency) {
    if (customCurrencySymbols.containsKey(currency)) {
      return customCurrencySymbols[currency]!;
    }

    // Fallback to default symbol if custom symbol is not found
    var format = NumberFormat.simpleCurrency(name: currency);
    return format.currencySymbol;
  }

  static String calculator(var price) {
    String symbol = getSymbol(userCurrency);
    if (PublicData.currencyListData.indexWhere((element) => element.currency == userCurrency) == -1) {
      return PublicData.apiConfigData['currency_position']?.toString().toLowerCase() == 'right'
          ? '$price$symbol'
          : '$symbol$price';
    }

    CurrencyModel currency = PublicData.currencyListData[PublicData.currencyListData.indexWhere((element) => element.currency == userCurrency)];
    double newPrice = (price ?? 0.0) * (currency.exchangeRate ?? 1.0);

    return currency.currencyPosition?.toString().toLowerCase() == 'right'
        ? '${newPrice.toStringAsFixed(currency.currencyDecimal ?? 0)}$symbol'
        : '$symbol${newPrice.toStringAsFixed(currency.currencyDecimal ?? 0)}';
  }
}
