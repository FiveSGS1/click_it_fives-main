import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:click_it_app/presentation/screens/viewLibrary/view_library_response.dart';
import 'package:click_it_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

class ClickItApis{

 static Future<List<Data>?> getViewLibraryData(int page,String uid, String companyID,int roleId) async{ 
    var queryParams = { 
      'apiId':ClickItConstants.APIID, 
      'apiKey':ClickItConstants.APIKEY, 
      'uid': uid, 
      'company_id': companyID, 
      'role_id': roleId, 
      'page_no': page, 
    }.map((key, value) => MapEntry(key, value.toString())); 
 
    var uri = Uri.https('gs1datakart.org', '/api/v501/recent_uploaded_images', queryParams); 
 
    try{ 
      final response = await http.post( 
        uri, 
        headers: {"content-type": "application/json"}, 
      ).timeout(Duration(seconds: 60)); 
 
      if (response.statusCode == 200) { 
        print(utf8.decoder.convert(response.bodyBytes)); 
        //print(json.decode(response.body)); 
        try{ 
          return ViewLibraryResponse.fromJson(json.decode(utf8.decoder.convert(response.bodyBytes))).data; 
        } catch(e){ 
          return []; 
        } 
      } else { 
        return []; 
      } 
    }on TimeoutException catch(e){ 
      return[]; 
    } 
 
  } 
 
  static Future<Uint8List?> getCompressedImage(String path) async { 
 
    try { 
      var request = http.MultipartRequest( 
          'POST', Uri.parse('http://4.240.61.161:4002/compress')); 
      request.files 
          .add(await http.MultipartFile.fromPath('image', path)); 
           
      http.StreamedResponse response = await request.send().timeout(Duration(seconds: 60)); 
 
      if (response.statusCode == 200) { 
        return await response.stream.toBytes(); 
      } else { 
        print(response.reasonPhrase); 
        //EasyLoading.showError(response.reasonPhrase.toString()); 
        return null; 
      } 
    } on Exception catch (e) { 
      //EasyLoading.showError(e.toString()); 
      return null; 
    } 
  } 
}

