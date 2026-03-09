import 'dart:io';
import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:path/path.dart'; // For basename function

class Crud{
  getRequest(String url) async{

    try{
      var response=await http.get(Uri.parse(url));
      if(response.statusCode==200){
        var responseBody=jsonDecode(response.body);
        return responseBody;
      }else{
        print("Error ${response.statusCode}");
        return {"status": "fail", "message": "HTTP Error ${response.statusCode}"};
      }
    }catch(e){
      print("Error catch $e");
      return {"status": "fail", "message": "Network error: $e"};
    }
  }

  postRequest(String url,Map data) async{
    try{
      var response=await http.post(Uri.parse(url), body:data);
      if(response.statusCode==200){
        var responseBody=jsonDecode(response.body);
        return responseBody;
      }else{
        print("Error ${response.statusCode}");
        return {"status": "fail", "message": "HTTP Error ${response.statusCode}"};
      }
    }catch(e){
      print("Error catch $e");
      return {"status": "fail", "message": "Network error: $e"};
    }
  }

  postRequestWithFile(String url, Map<String, String> data, File file) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));

      // Add the file
      var length = await file.length();
      var stream = http.ByteStream(file.openRead());
      var multipartFile = http.MultipartFile(
          "file",
          stream,
          length,
          filename: basename(file.path)
      );
      request.files.add(multipartFile);

      // Add form data
      data.forEach((key, value) {
        request.fields[key] = value;
      });

      var myrequest = await request.send();
      var response = await http.Response.fromStream(myrequest);

      if (myrequest.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error ${myrequest.statusCode}");
        return {"status": "fail", "message": "HTTP Error ${myrequest.statusCode}"};
      }
    } catch (e) {
      print("Error catch $e");
      return {"status": "fail", "message": "Network error: $e"};
    }
  }

  // Create HTTP client with proper configuration
  static http.Client _getHttpClient() {
    return http.Client();
  }

}