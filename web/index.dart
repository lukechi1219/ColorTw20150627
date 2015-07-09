// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library google_maps;

// This code is derived from
// https://developers.google.com/maps/documentation/javascript/tutorial#HelloWorld
// You can view the original JavaScript example at
// https://developers.google.com/maps/documentation/javascript/examples/map-simple

import 'dart:html' show window;
import 'dart:html' show Geoposition;
import 'dart:html' show querySelector;
import 'dart:html' show PositionError;
import 'dart:html' show HttpRequest;

import 'dart:convert';

import 'dart:js' show context, JsObject;

final String apiKey = "";

final String placeServer = "130.211.249.171:8090";

var mapObj = null;

List citiAndHospitalNameHurtDegreeList = new List();

List citiAndHospitalNameStatusList = new List();

/*
 * 
 */
void main() {

  // call the web server asynchronously
//    String govUrl = 'http://www.gov.taipei/public/Attachment/57313552553.json';
  String govUrl = 'http://tonyq.org/kptaipei/api-20150628.php';

  HttpRequest.getString(govUrl).then(onGovDataLoaded);

  // The top-level getter context provides a JsObject that represents the global
  // object in JavaScript.
  final google_maps = context['google']['maps'];

  var mapTypeId = google_maps['MapTypeId']['ROADMAP'];

  // new JsObject() constructs a new JavaScript object and returns a proxy to it.
  var center = new JsObject(google_maps['LatLng'], [25.0738269, 121.56555359999993]);

  // new JsObject.jsify() recursively converts a collection of Dart objects
  // to a collection of JavaScript objects and returns a proxy to it.
  var mapOptions = new JsObject.jsify(
      {"center": center, "zoom": 14, "mapTypeId": mapTypeId});

  // Nodes are passed though, or transferred, not proxied.
  mapObj = new JsObject(
      google_maps['Map'], [querySelector('#map-canvas'), mapOptions]);

  /*
   * 
   */
//  Geoposition startPosition;

  window.navigator.geolocation
      .getCurrentPosition()
      .then((Geoposition position) {
    //
    var newCenter = new JsObject(google_maps['LatLng'], [
      position.coords.latitude,
      position.coords.longitude
    ]);

//    window.alert(newCenter.toString());

    mapObj.callMethod("panTo", [newCenter]);

//    var markerOptions = new JsObject.jsify(
//        {'position': newCenter, 'map': mapObj, 'title': 'Hello World!'});

//    var marker = new JsObject(google_maps['Marker'], [markerOptions]);

//    window.alert(mapObj.callMethod("getCenter").toString());

    //
  }, onError: (error) => alertError(error));
}

// Don't use alert() in real code ;)
void alertError(PositionError error) {
  window.alert("Error occurred. Error code: ${error.code} ${error.message}");
}

// print the raw json response text from the server
void onGovDataLoaded(response) {
  var jsonString = response;

  Map jsonMap = JSON.decode(jsonString);

  window.alert('最後更新時間: ' + jsonMap['lastmodify']);
//  window.alert(jsonMap['license']);
//  window.alert(jsonMap['source']);
  List data = jsonMap['data'];

  Map citiAndHospitalNamesCount = new Map();

  for (var i = 0; i < data.length; i++) {
    Map info = data[i];

    String citiAndHospitalName = info['縣市別'].toString() + info['收治單位'].toString();

    if (citiAndHospitalName == '桃園市三重市醫') {
      citiAndHospitalName = '新北市三重市醫';
    }
    if (citiAndHospitalName == '桃園市新泰') {
      citiAndHospitalName = '新北市新泰';
    }
    if (citiAndHospitalName == '新北市衛部台北') {
      citiAndHospitalName = '新北市衛生福利部台北醫院';
    }
    if (citiAndHospitalName == '基隆市衛部基') {
      citiAndHospitalName = '基隆市衛生福利部基隆醫院';
    }
    if (citiAndHospitalName == '彰化縣彰基') {
      citiAndHospitalName = '彰化基督教醫院南郭總院';
    }
    if (citiAndHospitalName.indexOf("臺") > 0) {
      citiAndHospitalName = citiAndHospitalName.replaceAll("臺", "台");
    }
//    if (citiAndHospitalName == '台中市臺中醫院') {
//      citiAndHospitalName = '台中市衛生福利部臺中醫院';
//    }

    citiAndHospitalName = citiAndHospitalName.replaceFirst('聯醫', '聯合醫院');
    citiAndHospitalName = citiAndHospitalName.replaceFirst('附醫', '附設醫院');
    citiAndHospitalName = citiAndHospitalName.replaceFirst('榮總', '榮民總醫院');
    citiAndHospitalName = citiAndHospitalName.replaceFirst('三總', '三軍總醫院');
    citiAndHospitalName = citiAndHospitalName.replaceFirst('嘉基', '嘉義基督教');

    if (citiAndHospitalName.indexOf("醫") == -1) {
      citiAndHospitalName = citiAndHospitalName + "醫院";
    }

    num count = citiAndHospitalNamesCount[citiAndHospitalName];
    if (count == null) {
      count = 0;
    }
    count++;
    citiAndHospitalNamesCount.remove(citiAndHospitalName);
    citiAndHospitalNamesCount[citiAndHospitalName] = count;

//    info['編號'];
//    info['縣市別'];
//    info['收治單位'];
//    info['檢傷編號'];
//    info['姓名'];
//    info['性別'];
//    info['國籍'];
//    info['年齡'];
//    info['醫療檢傷'];

    /*
     * 
     */
    String hurtDegree = info['救護檢傷'].toString();
    String status = info['即時動向'].toString();

    var hurtDegreeCount = null;

    for (var i=0; i<citiAndHospitalNameHurtDegreeList.length; i++) {
      var obj = citiAndHospitalNameHurtDegreeList[i];
      if (obj['hospital'] == citiAndHospitalName) {
        hurtDegreeCount = obj;
      }
    }

    if (hurtDegreeCount == null) {
      hurtDegreeCount = {'hospital': citiAndHospitalName};
      citiAndHospitalNameHurtDegreeList.add(hurtDegreeCount);
    }

    if (status.indexOf('出院') == -1) {

      int count1 = hurtDegreeCount[hurtDegree];
      if (count1 == null) {
        count1 = 0;
        hurtDegreeCount[hurtDegree] = count1;
      }
      //
      count1++;
      hurtDegreeCount[hurtDegree] = count1;
    }

    /*
     * 
     */
    var statusCount = null;

    for (var i=0; i<citiAndHospitalNameStatusList.length; i++) {
      var obj = citiAndHospitalNameStatusList[i];
      if (obj['hospital'] == citiAndHospitalName) {
        statusCount = obj;
      }
    }

    if (statusCount == null) {
      statusCount = {'hospital': citiAndHospitalName};
      citiAndHospitalNameStatusList.add(statusCount);
    }

    num count2 = statusCount[status];
    if (count2 == null) {
      count2 = 0;
    }
    //
    count2++;
    statusCount[status] = count2;

//    info['轉診要求'];
//    info['刪除註記'];
  }

//  window.alert(citiAndHospitalNamesCount.keys.length.toString());

  for (String citiAndHospitalName in citiAndHospitalNamesCount.keys) {

    String url =
        "http://${placeServer}/color/place/queryLocation";

//    String url = "/color/place/queryLocation";

//    String encodedUrl = Uri.encodeFull(url);

    var data = {'keyword': citiAndHospitalName};

    HttpRequest.postFormData(url, data).then((HttpRequest req) {

      Map jsonMap = JSON.decode(req.responseText);

      var place = jsonMap['place'];

      if (place == null) {
        // query google GoeCode API
        String url =
            "https://maps.googleapis.com/maps/api/geocode/json?address=${citiAndHospitalName}&key=${apiKey}&language=zh-TW";

        var request = new HttpRequest();
        request.open('GET', url);
        request.onLoad.listen((event) {
          onGeoCodeDataLoaded(event.target.responseText, citiAndHospitalName);
        });

        request.send();

      } else {
        var marker = addMarker(place['lat'], place['lng'], place['shortName']);

        addInfoWindow(marker, place, citiAndHospitalName);
      }
    });
  }

//    // call the web server asynchronously
//    var request = HttpRequest.getString(url).then(onGeoCodeDataLoaded);

}

/*
 * print the raw json response text from the server
 */
void onGeoCodeDataLoaded(String responseText, String citiAndHospitalName) {

  print('citiAndHospitalName: ' + citiAndHospitalName);

  var jsonString = responseText;

  Map jsonMap = JSON.decode(jsonString);

  if (jsonMap['status'].toString().toLowerCase() == 'ok') {
    var targetHospital = null;

    bool foundHospital = false;
    bool foundUniversity = false;

    List results = jsonMap['results'];

    for (var i = 0; i < results.length; i++) {
      var result = results[i];

      List types = result['types'];

      for (var j = 0; j < types.length; j++) {
        String type = types[j];

        if (type == 'hospital') {
          targetHospital = result;
          foundHospital = true;
          break;
        } else if (type == 'university') {
          targetHospital = result;
          foundUniversity = true;
          break;
        }
        if (citiAndHospitalName == '彰化基督教醫院南郭總院' &&
            type == 'point_of_interest') {
          targetHospital = result;
          foundHospital = true;
          break;
        }
      }

      if (foundHospital || foundUniversity) {
        break;
      }
    }

    if ((foundHospital || foundUniversity) && mapObj != null) {
      var shortName = '';
      var longName = '';

      var country = '';
      var areaLevel1 = '';
      var areaLevel2 = '';
      var areaLevel3 = '';

      var address_components = targetHospital['address_components'];

      shortName = address_components[0]['short_name'];
      longName = address_components[0]['long_name'];

      for (var i = 0; i < address_components.length; i++) {
        var component = address_components[i];

        for (var j = 0; j < component['types'].length; j++) {
          if (component['types'][j] == 'country') {
            country = component['long_name'];
            break;
          } else if (component['types'][j] == 'administrative_area_level_1') {
            areaLevel1 = component['long_name'];
            break;
          } else if (component['types'][j] == 'administrative_area_level_2') {
            areaLevel2 = component['long_name'];
            break;
          } else if (component['types'][j] == 'administrative_area_level_3') {
            areaLevel3 = component['long_name'];
            break;
          }
        }
      }

      var location = targetHospital['geometry']['location'];

      var marker = addMarker(location['lat'], location['lng'], shortName);

      var place = {};
      place['shortName'] = shortName;
      place['formattedAddress'] = targetHospital['formatted_address'];

      addInfoWindow(marker, place, citiAndHospitalName);

      /*
       * save place
       */
      String url = "http://${placeServer}/color/addPlace";
//      String url = "/color/place/addPlace";

      var types = targetHospital['types'].toString();

      var data = {
        'keyword': citiAndHospitalName,
        'place_id': targetHospital['place_id'],
        'lat': location['lat'].toString(),
        'lng': location['lng'].toString(),
        'types': types,
        'country': country,
        'administrative_area_level_1': areaLevel1,
        'administrative_area_level_2': areaLevel2,
        'administrative_area_level_3': areaLevel3,
        'short_name': shortName,
        'long_name': longName,
        'formatted_address': targetHospital['formatted_address']
      };

      //
      HttpRequest.postFormData(url, data).then((HttpRequest req) {
        //
//        window.alert(req.responseText);
      });
    }
  }
}

/*
 * 
 */
addMarker(lat, lng, title) {

  final google_maps = context['google']['maps'];

  var newCenter = new JsObject(google_maps['LatLng'], [lat, lng]);

  var markerOptions = new JsObject.jsify(
      {'position': newCenter, 'map': mapObj, 'title': title});

  var marker = new JsObject(google_maps['Marker'], [markerOptions]);

  //
//  mapObj.callMethod("panTo", [newCenter]);

  return marker;
}

/*
 * 
 */
void addInfoWindow(marker, place, citiAndHospitalName) {

  final google_maps = context['google']['maps'];

  String title = place['shortName'].toString() + '<br/>' + place['formattedAddress'].toString();

  String hurtDegreeInfo = '';

  Map hurtDegreeCount = {};
  for (var i=0; i<citiAndHospitalNameHurtDegreeList.length; i++) {
    var obj = citiAndHospitalNameHurtDegreeList[i];
    if (obj['hospital'] == citiAndHospitalName) {
      hurtDegreeCount = obj;
    }
  }
  for (String hurtDegree in hurtDegreeCount.keys) {
    if (hurtDegree == 'hospital') {
      continue;
    }
    if (hurtDegreeInfo != '') {
      hurtDegreeInfo = hurtDegreeInfo + '&nbsp;';
    }
    String hurtClass = '';
    if (hurtDegree == '重傷') {
      hurtClass = 'label-danger';
    } else if (hurtDegree == '中傷') {
      hurtClass = 'label-warning';
    } else if (hurtDegree == '輕傷') {
      hurtClass = 'label-minor-hurt';
    }
    hurtDegreeInfo = hurtDegreeInfo + '<span class="label ${hurtClass}">' + hurtDegree + ':' + hurtDegreeCount[hurtDegree].toString() + '</span>';
  }

//  print(hurtDegreeInfo);

  //
  String statusInfo = '';

  Map statusCount = {};
  for (var i=0; i<citiAndHospitalNameStatusList.length; i++) {
    var obj = citiAndHospitalNameStatusList[i];
    if (obj['hospital'] == citiAndHospitalName) {
      statusCount = obj;
    }
  }

  for (String status in statusCount.keys) {
    if (status == 'hospital') {
      continue;
    }
    if (statusInfo != '') {
      statusInfo = statusInfo + '&nbsp;';
    }
    statusInfo = statusInfo + '<span>' + status + ':' + statusCount[status].toString() + '</span>';
  }
  //
  String contentString = '<div id="content">${title}<br/>${hurtDegreeInfo}<br/>${statusInfo}</div>';

  var infowindow = new JsObject(google_maps['InfoWindow'], [new JsObject.jsify({
    "content": contentString
    })]);

  google_maps['event'].callMethod("addListener", [marker, 'click', (event) {
    infowindow.callMethod("open", [mapObj, marker]);
  }]);
}
