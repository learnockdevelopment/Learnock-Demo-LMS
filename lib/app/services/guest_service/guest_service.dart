import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:webinar/app/models/currency_model.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/common/data/api_public_data.dart';
import '../../../common/utils/constants.dart';
import '../../../common/utils/http_handler.dart';

class GuestService {

  static Future<List<CurrencyModel>> getCurrencyList() async {
    List<CurrencyModel> data = [];
    try {
      String url = '${Constants.baseUrl}currency/list';

      Response res = await httpGet(url);
      var jsonRes = jsonDecode(res.body);

      ////print'currence $url');
      // //print the response
      ////print'getCurrencyList Response: $jsonRes');

      if (jsonRes['success']) {
        jsonRes['data'].forEach((json) {
          data.add(CurrencyModel.fromJson(json));
        });

        PublicData.currencyListData = data;
        return data;
      } else {
        return data;
      }
    } catch (e) {
      ////print'Error in getCurrencyList: $e');
      return data;
    }
  }

  static Future config()async{
    try{
      String url = '${Constants.baseUrl}config';

      Response res = await httpGet(
        url,
      );
      ////print'coooo $url');

      var jsonResponse = jsonDecode(res.body);

      // //print the response
      ////print'getTimeZone Response: $jsonResponse');

      if(res.statusCode == 200){

        PublicData.apiConfigData = jsonResponse;
        return jsonResponse;
      }else{

        return null;
      }

    }catch(e){
      return null;
    }
  }


  static Future<List<String>> getTimeZone() async {
    List<String> data = [];
    try {
      String url = '${Constants.baseUrl}timezones';

      Response res = await httpGet(url);
      var jsonRes = jsonDecode(res.body);
      ////print'zone $url');

      // //print the response
      ////print'getTimeZone Response: $jsonRes');

      if (jsonRes['success']) {
        return List.from(jsonRes['data']);
      } else {
        return data;
      }
    } catch (e) {
      ////print'Error in getTimeZone: $e');
      return data;
    }
  }

  static Future systemsettings() async {
    try {
      String url = '${Constants.baseUrl}system-settings';

      Response res = await httpGet(url);
      var jsonResponse = jsonDecode(res.body);
      ////print'zone $url');

      // //print the response
      ////print'config Response: $jsonResponse');

      if (res.statusCode == 200) {
        PublicData.apiConfigData = jsonResponse;
        return jsonResponse;
      } else {
        return null;
      }
    } catch (e) {
      ////print'Error in config: $e');
      return null;
    }
  }

  static Future<RegisterConfigModel?> registerConfig(String role) async {
    try {
      String url = '${Constants.baseUrl}config/register/$role';

      Response res = await httpGet(url);
      var jsonResponse = jsonDecode(res.body);
      ////print'role $url');

      // //print the response
      ////print'registerConfig Response for role $role: $jsonResponse');

      if (res.statusCode == 200) {
        return RegisterConfigModel.fromJson(jsonResponse['data']);
      } else {
        return null;
      }
    } catch (e) {
      ////print'Error in registerConfig: $e');
      return null;
    }
  }
}
