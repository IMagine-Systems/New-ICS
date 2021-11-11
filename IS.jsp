<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<!DOCTYPE html>
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <link rel="stylesheet" type="text/css" href="j.css">
      <title>ISNV</title>
      <script   src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
      <script src="https://apis.openapi.sk.com/tmap/jsv2?version=1&appKey=l7xx899515de5a4f47c5a62978a685b3fec9"></script>
<script type="text/javascript">

         var map, marker1, marker2;
         var portmarker1, portmarker2;
         var markerPosition, markerPosition2;
         var markers = [];
         var marker;
         var polyline;
         
         function initTmap() {

            // 1. 지도 띄우기
            map = new Tmapv2.Map("map_div", {
               center : new Tmapv2.LatLng(36.16932, 128.46797),      //초기 좌표 값 (경운대)
               width : "100%",
               height : "800px",
               zoom : 8,
               zoomControl : true,
               scrollwheel : true

            });
            
            
        	var positions = [//다중 마커 저장 배열
    			{
     				title: '구미역', 
     				lonlat: new Tmapv2.LatLng(36.1284581800925, 128.33072279764565)//좌표 지정
     			},
     			{
     				title: '금오공과대학교', 
     				lonlat: new Tmapv2.LatLng(36.14606248008849, 128.393437497646)
     			},
     			{
     				title: '수원역', 
     				lonlat: new Tmapv2.LatLng(37.26666378872338, 126.99943239928938)
     			},
     			{
     				title: '서울역',
     				lonlat: new Tmapv2.LatLng(37.55315651655645, 126.97254344333736)
     			},
     			{
    	     		title: '강변체육공원',
    	     		lonlat: new Tmapv2.LatLng(36.1137610491927, 128.3934586111375)
    	     	},
     			{
     				title: '부산역',
     				lonlat: new Tmapv2.LatLng(35.114980312517744, 129.04207216327933)
     			}
    		];
    		 
    		for (var i = 0; i< positions.length; i++){//for문을 통하여 배열 안에 있는 값을 마커 생성
    			var lonlat = positions[i].lonlat;
    			var title = positions[i].title;
    			//Marker 객체 생성.
    			marker = new Tmapv2.Marker({
    				icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_p.png",
    				position : lonlat, //Marker의 중심좌표 설정.
    				map : map, //Marker가 표시될 Map 설정.
    				title : title //Marker 타이틀.
    			});
    		};
         
            // 마커 초기화 출발
            marker1 = new Tmapv2.Marker(
               {
                  icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_r_m_a.png",
                  iconSize : new Tmapv2.Size(24, 38),
                  map : map
               });
            // 도착
            marker2 = new Tmapv2.Marker(
               {
                  icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_r_m_e.png",
                  iconSize : new Tmapv2.Size(24, 38),
                  map : map
               });
            
            //포트
            portmarker1 = new Tmapv2.Marker(
               {
                  icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_p.png",
                  iconSize : new Tmapv2.Size(24, 38),
                  map : map
               });
            
            portmarker2 = new Tmapv2.Marker(
                {
                   icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_p.png",
                   iconSize : new Tmapv2.Size(24, 38),
                   map : map
                });
            

            var optionObj = {
               reqCoordType:"WGS84GEO", //요청 좌표계 옵셥 설정입니다.
               resCoordType:"EPSG3857"  //응답 좌표계 옵셥 설정입니다.
             }
            
            

            $("#btn_select").click(function() {
               // 2. API 사용요청
               var fullAddr = $("#fullAddr").val();
               $.ajax({
                  method : "GET",
                  url : "https://apis.openapi.sk.com/tmap/geo/fullAddrGeo?version=1&format=json&callback=result",
                  async : false,
                  data : {
                     "appKey" : "l7xx899515de5a4f47c5a62978a685b3fec9",
                     "coordType" : "WGS84GEO",
                     "fullAddr" : fullAddr
                  },
                  success : function(response) {

                     var resultInfo = response.coordinateInfo; // .coordinate[0];
                     console.log(resultInfo);

                     // 기존 마커 삭제
                     marker1.setMap(null);

                     // 3.마커 찍기
                     // 검색 결과 정보가 없을 때 처리
                     if (resultInfo.coordinate.length == 0) {
                        $("#result").text(
                        "요청 데이터가 올바르지 않습니다.");
                     } else {
                        var lon, lat;
                        var resultCoordinate = resultInfo.coordinate[0];
                        if (resultCoordinate.lon.length > 0) {
                           // 구주소
                           lon = resultCoordinate.lon;
                           lat = resultCoordinate.lat;
                        } else {
                           // 신주소
                           lon = resultCoordinate.newLon;
                           lat = resultCoordinate.newLat
                        }

                        var lonEntr, latEntr;

                        if (resultCoordinate.lonEntr == undefined && resultCoordinate.newLonEntr == undefined) {
                           lonEntr = 0;
                           latEntr = 0;
                        } else {
                           if (resultCoordinate.lonEntr.length > 0) {
                              lonEntr = resultCoordinate.lonEntr;
                              latEntr = resultCoordinate.latEntr;
                           } else {
                              lonEntr = resultCoordinate.newLonEntr;
                              latEntr = resultCoordinate.newLatEntr;
                           }
                        }

                        markerPosition = new Tmapv2.LatLng(Number(lat),Number(lon));

                        // 마커 올리기
                        marker1 = new Tmapv2.Marker(
                           {
                              position : markerPosition,
                              icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_r_m_s.png",
                              iconSize : new Tmapv2.Size(
                              24, 38),
                              map : map
                           });
                        map.setCenter(markerPosition);

                        // 검색 결과 표출
                        var matchFlag, newMatchFlag;
                        // 검색 결과 주소를 담을 변수
                        var address = '', newAddress = '';
                        var city, gu_gun, eup_myun, legalDong, adminDong, ri, bunji;
                        var buildingName, buildingDong, newRoadName, newBuildingIndex, newBuildingName, newBuildingDong;

                        // 새주소일 때 검색 결과 표출
                        // 새주소인 경우 matchFlag가 아닌
                        // newMatchFlag가 응답값으로
                        // 온다
                        if (resultCoordinate.newMatchFlag.length > 0) {
                           // 새(도로명) 주소 좌표 매칭
                           // 구분 코드
                           newMatchFlag = resultCoordinate.newMatchFlag;

                           // 시/도 명칭
                           if (resultCoordinate.city_do.length > 0) {
                              city = resultCoordinate.city_do;
                              newAddress += city + "\n";
                           }

                           // 군/구 명칭
                           if (resultCoordinate.gu_gun.length > 0) {
                              gu_gun = resultCoordinate.gu_gun;
                              newAddress += gu_gun + "\n";
                           }

                           // 읍면동 명칭
                           if (resultCoordinate.eup_myun.length > 0) {
                              eup_myun = resultCoordinate.eup_myun;
                              newAddress += eup_myun + "\n";
                           } else {
                              // 출력 좌표에 해당하는
                              // 법정동 명칭
                              if (resultCoordinate.legalDong.length > 0) {
                                 legalDong = resultCoordinate.legalDong;
                                 newAddress += legalDong + "\n";
                              }
                              // 출력 좌표에 해당하는
                              // 행정동 명칭
                              if (resultCoordinate.adminDong.length > 0) {
                                 adminDong = resultCoordinate.adminDong;
                                 newAddress += adminDong + "\n";
                              }
                           }
                           // 출력 좌표에 해당하는 리 명칭
                           if (resultCoordinate.ri.length > 0) {
                              ri = resultCoordinate.ri;
                              newAddress += ri + "\n";
                           }
                           // 출력 좌표에 해당하는 지번 명칭
                           if (resultCoordinate.bunji.length > 0) {
                              bunji = resultCoordinate.bunji;
                              newAddress += bunji + "\n";
                           }
                           // 새(도로명)주소 매칭을 한
                           // 경우, 길 이름을 반환
                           if (resultCoordinate.newRoadName.length > 0) {
                              newRoadName = resultCoordinate.newRoadName;
                              newAddress += newRoadName + "\n";
                           }
                           // 새(도로명)주소 매칭을 한
                           // 경우, 건물 번호를 반환
                           if (resultCoordinate.newBuildingIndex.length > 0) {
                              newBuildingIndex = resultCoordinate.newBuildingIndex;
                              newAddress += newBuildingIndex + "\n";
                           }
                           // 새(도로명)주소 매칭을 한
                           // 경우, 건물 이름를 반환
                           if (resultCoordinate.newBuildingName.length > 0) {
                              newBuildingName = resultCoordinate.newBuildingName;
                              newAddress += newBuildingName + "\n";
                           }
                           // 새주소 건물을 매칭한 경우
                           // 새주소 건물 동을 반환
                           if (resultCoordinate.newBuildingDong.length > 0) {
                              newBuildingDong = resultCoordinate.newBuildingDong;
                              newAddress += newBuildingDong + "\n";
                           }
                           // 검색 결과 표출
                           /*if (lonEntr > 0) {
                              var docs = "<a style='color:orange' href='#webservice/docs/fullTextGeocoding'>Docs</a>"
                              var text = "검색결과(새주소) : " + newAddress + ",\n 응답코드:" + newMatchFlag + "(상세 코드 내역은 " + docs + " 에서 확인)" + "</br> 위경도좌표(중심점) : " + lat + ", " + lon + "</br>위경도좌표(입구점) : " + latEntr + ", " + lonEntr;
                              $("#result").html(text);
                           } else {
                              var docs = "<a style='color:orange' href='#webservice/docs/fullTextGeocoding'>Docs</a>"
                              var text = "검색결과(새주소) : " + newAddress + ",\n 응답코드:" + newMatchFlag + "(상세 코드 내역은 " + docs + " 에서 확인)" + "</br> 위경도좌표(입구점) : 위경도좌표(입구점)이 없습니다.";
                              $("#result").html(text);
                           }*/
                        }

                        // 구주소일 때 검색 결과 표출
                        // 구주소인 경우 newMatchFlag가
                        // 아닌 MatchFlag가 응닶값으로
                        // 온다
                        if (resultCoordinate.matchFlag.length > 0) {
                           // 매칭 구분 코드
                           matchFlag = resultCoordinate.matchFlag;

                           // 시/도 명칭
                           if (resultCoordinate.city_do.length > 0) {
                              city = resultCoordinate.city_do;
                              address += city + "\n";
                           }
                           // 군/구 명칭
                           if (resultCoordinate.gu_gun.length > 0) {
                              gu_gun = resultCoordinate.gu_gun;
                              address += gu_gun+ "\n";
                           }
                           // 읍면동 명칭
                           if (resultCoordinate.eup_myun.length > 0) {
                              eup_myun = resultCoordinate.eup_myun;
                              address += eup_myun + "\n";
                           }
                           // 출력 좌표에 해당하는 법정동
                           // 명칭
                           if (resultCoordinate.legalDong.length > 0) {
                              legalDong = resultCoordinate.legalDong;
                              address += legalDong + "\n";
                           }
                           // 출력 좌표에 해당하는 행정동
                           // 명칭
                           if (resultCoordinate.adminDong.length > 0) {
                              adminDong = resultCoordinate.adminDong;
                              address += adminDong + "\n";
                           }
                           // 출력 좌표에 해당하는 리 명칭
                           if (resultCoordinate.ri.length > 0) {
                              ri = resultCoordinate.ri;
                              address += ri + "\n";
                           }
                           // 출력 좌표에 해당하는 지번 명칭
                           if (resultCoordinate.bunji.length > 0) {
                              bunji = resultCoordinate.bunji;
                              address += bunji + "\n";
                           }
                           // 출력 좌표에 해당하는 건물 이름
                           // 명칭
                           if (resultCoordinate.buildingName.length > 0) {
                              buildingName = resultCoordinate.buildingName;
                              address += buildingName + "\n";
                           }
                           // 출력 좌표에 해당하는 건물 동을
                           // 명칭
                           if (resultCoordinate.buildingDong.length > 0) {
                              buildingDong = resultCoordinate.buildingDong;
                              address += buildingDong + "\n";
                           }
                           // 검색 결과 표출
                           /*if (lonEntr > 0) {
                              var docs = "<a style='color:orange' href='#webservice/docs/fullTextGeocoding'>Docs</a>";
                              var text = "검색결과(지번주소) : "+ address+ ","+ "\n"+ "응답코드:"+ matchFlag+ "(상세 코드 내역은 "+ docs+ " 에서 확인)"+ "</br>"+ "위경도좌표(중심점) : "+ lat+ ", "+ lon+ "</br>"+ "위경도좌표(입구점) : "+ latEntr+ ", "+ lonEntr;
                              $("#result").html(text);
                           } else {
                              var docs = "<a style='color:orange' href='#webservice/docs/fullTextGeocoding'>Docs</a>";
                              var text = "검색결과(지번주소) : "+ address+ ","+ "\n"+ "응답코드:"+ matchFlag+ "(상세 코드 내역은 "+ docs+ " 에서 확인)"+ "</br>"+ "위경도좌표(입구점) : 위경도좌표(입구점)이 없습니다.";
                              $("#result").html(text);
                           }*/
                        }
                     }
                  },
                  error : function(request, status, error) {
                     console.log(request);
                     console.log("code:"+request.status + "\n message:" + request.responseText +"\n error:" + error);
                     // 에러가 발생하면 맵을 초기화함
                     // markerStartLayer.clearMarkers();
                     // 마커초기화
                     map.setCenter(new Tmapv2.LatLng(37.570028, 126.986072));
                     $("#result").html("");

                  }
               });
            });

            $("#btn_select2").click(function() {
               // 2. API 사용요청
               var fullAddr2 = $("#fullAddr2").val();
               $.ajax({
                  method : "GET",
                  url : "https://apis.openapi.sk.com/tmap/geo/fullAddrGeo?version=1&format=json&callback=result",
                  async : false,
                  data : {
                     "appKey" : "l7xx899515de5a4f47c5a62978a685b3fec9",
                     "coordType" : "WGS84GEO",
                     "fullAddr" : fullAddr2
                  },
                  success : function(response) {

                     var resultInfo = response.coordinateInfo; // .coordinate[0];
                     console.log(resultInfo);

                     // 기존 마커 삭제
                     marker2.setMap(null);

                     // 3.마커 찍기
                     // 검색 결과 정보가 없을 때 처리
                     if (resultInfo.coordinate.length == 0) {
                        $("#result").text(
                        "요청 데이터가 올바르지 않습니다.");
                     } else {
                        var lon, lat;
                        var resultCoordinate = resultInfo.coordinate[0];
                        if (resultCoordinate.lon.length > 0) {
                           // 구주소
                           lon = resultCoordinate.lon;
                           lat = resultCoordinate.lat;
                        } else {
                           // 신주소
                           lon = resultCoordinate.newLon;
                           lat = resultCoordinate.newLat
                        }

                        var lonEntr, latEntr;

                        if (resultCoordinate.lonEntr == undefined && resultCoordinate.newLonEntr == undefined) {
                           lonEntr = 0;
                           latEntr = 0;
                        } else {
                           if (resultCoordinate.lonEntr.length > 0) {
                              lonEntr = resultCoordinate.lonEntr;
                              latEntr = resultCoordinate.latEntr;
                           } else {
                              lonEntr = resultCoordinate.newLonEntr;
                              latEntr = resultCoordinate.newLatEntr;
                           }
                        }

                        markerPosition2 = new Tmapv2.LatLng(Number(lat),Number(lon));

                        // 마커 올리기
                        marker2 = new Tmapv2.Marker(
                           {
                              position : markerPosition2,
                              icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_r_m_e.png",
                              iconSize : new Tmapv2.Size(
                              24, 38),
                              map : map
                           });
                        map.setCenter(markerPosition2);

                        // 검색 결과 표출
                        var matchFlag, newMatchFlag;
                        // 검색 결과 주소를 담을 변수
                        var address = '', newAddress = '';
                        var city, gu_gun, eup_myun, legalDong, adminDong, ri, bunji;
                        var buildingName, buildingDong, newRoadName, newBuildingIndex, newBuildingName, newBuildingDong;

                        // 새주소일 때 검색 결과 표출
                        // 새주소인 경우 matchFlag가 아닌
                        // newMatchFlag가 응답값으로
                        // 온다
                        if (resultCoordinate.newMatchFlag.length > 0) {
                           // 새(도로명) 주소 좌표 매칭
                           // 구분 코드
                           newMatchFlag = resultCoordinate.newMatchFlag;

                           // 시/도 명칭
                           if (resultCoordinate.city_do.length > 0) {
                              city = resultCoordinate.city_do;
                              newAddress += city + "\n";
                           }

                           // 군/구 명칭
                           if (resultCoordinate.gu_gun.length > 0) {
                              gu_gun = resultCoordinate.gu_gun;
                              newAddress += gu_gun + "\n";
                           }

                           // 읍면동 명칭
                           if (resultCoordinate.eup_myun.length > 0) {
                              eup_myun = resultCoordinate.eup_myun;
                              newAddress += eup_myun + "\n";
                           } else {
                              // 출력 좌표에 해당하는
                              // 법정동 명칭
                              if (resultCoordinate.legalDong.length > 0) {
                                 legalDong = resultCoordinate.legalDong;
                                 newAddress += legalDong + "\n";
                              }
                              // 출력 좌표에 해당하는
                              // 행정동 명칭
                              if (resultCoordinate.adminDong.length > 0) {
                                 adminDong = resultCoordinate.adminDong;
                                 newAddress += adminDong + "\n";
                              }
                           }
                           // 출력 좌표에 해당하는 리 명칭
                           if (resultCoordinate.ri.length > 0) {
                              ri = resultCoordinate.ri;
                              newAddress += ri + "\n";
                           }
                           // 출력 좌표에 해당하는 지번 명칭
                           if (resultCoordinate.bunji.length > 0) {
                              bunji = resultCoordinate.bunji;
                              newAddress += bunji + "\n";
                           }
                           // 새(도로명)주소 매칭을 한
                           // 경우, 길 이름을 반환
                           if (resultCoordinate.newRoadName.length > 0) {
                              newRoadName = resultCoordinate.newRoadName;
                              newAddress += newRoadName + "\n";
                           }
                           // 새(도로명)주소 매칭을 한
                           // 경우, 건물 번호를 반환
                           if (resultCoordinate.newBuildingIndex.length > 0) {
                              newBuildingIndex = resultCoordinate.newBuildingIndex;
                              newAddress += newBuildingIndex + "\n";
                           }
                           // 새(도로명)주소 매칭을 한
                           // 경우, 건물 이름를 반환
                           if (resultCoordinate.newBuildingName.length > 0) {
                              newBuildingName = resultCoordinate.newBuildingName;
                              newAddress += newBuildingName + "\n";
                           }
                           // 새주소 건물을 매칭한 경우
                           // 새주소 건물 동을 반환
                           if (resultCoordinate.newBuildingDong.length > 0) {
                              newBuildingDong = resultCoordinate.newBuildingDong;
                              newAddress += newBuildingDong + "\n";
                           }
                           // 검색 결과 표출
                           /*if (lonEntr > 0) {
                              var docs = "<a style='color:orange' href='#webservice/docs/fullTextGeocoding'>Docs</a>"
                              var text = "검색결과(새주소) : " + newAddress + ",\n 응답코드:" + newMatchFlag + "(상세 코드 내역은 " + docs + " 에서 확인)" + "</br> 위경도좌표(중심점) : " + lat + ", " + lon + "</br>위경도좌표(입구점) : " + latEntr + ", " + lonEntr;
                              $("#result").html(text);
                           } else {
                              var docs = "<a style='color:orange' href='#webservice/docs/fullTextGeocoding'>Docs</a>"
                              var text = "검색결과(새주소) : " + newAddress + ",\n 응답코드:" + newMatchFlag + "(상세 코드 내역은 " + docs + " 에서 확인)" + "</br> 위경도좌표(입구점) : 위경도좌표(입구점)이 없습니다.";
                              $("#result").html(text);
                           }*/
                        }

                        // 구주소일 때 검색 결과 표출
                        // 구주소인 경우 newMatchFlag가
                        // 아닌 MatchFlag가 응닶값으로
                        // 온다
                        if (resultCoordinate.matchFlag.length > 0) {
                           // 매칭 구분 코드
                           matchFlag = resultCoordinate.matchFlag;

                           // 시/도 명칭
                           if (resultCoordinate.city_do.length > 0) {
                              city = resultCoordinate.city_do;
                              address += city + "\n";
                           }
                           // 군/구 명칭
                           if (resultCoordinate.gu_gun.length > 0) {
                              gu_gun = resultCoordinate.gu_gun;
                              address += gu_gun+ "\n";
                           }
                           // 읍면동 명칭
                           if (resultCoordinate.eup_myun.length > 0) {
                              eup_myun = resultCoordinate.eup_myun;
                              address += eup_myun + "\n";
                           }
                           // 출력 좌표에 해당하는 법정동
                           // 명칭
                           if (resultCoordinate.legalDong.length > 0) {
                              legalDong = resultCoordinate.legalDong;
                              address += legalDong + "\n";
                           }
                           // 출력 좌표에 해당하는 행정동
                           // 명칭
                           if (resultCoordinate.adminDong.length > 0) {
                              adminDong = resultCoordinate.adminDong;
                              address += adminDong + "\n";
                           }
                           // 출력 좌표에 해당하는 리 명칭
                           if (resultCoordinate.ri.length > 0) {
                              ri = resultCoordinate.ri;
                              address += ri + "\n";
                           }
                           // 출력 좌표에 해당하는 지번 명칭
                           if (resultCoordinate.bunji.length > 0) {
                              bunji = resultCoordinate.bunji;
                              address += bunji + "\n";
                           }
                           // 출력 좌표에 해당하는 건물 이름
                           // 명칭
                           if (resultCoordinate.buildingName.length > 0) {
                              buildingName = resultCoordinate.buildingName;
                              address += buildingName + "\n";
                           }
                           // 출력 좌표에 해당하는 건물 동을
                           // 명칭
                           if (resultCoordinate.buildingDong.length > 0) {
                              buildingDong = resultCoordinate.buildingDong;
                              address += buildingDong + "\n";
                           }
                           // 검색 결과 표출
                           /*if (lonEntr > 0) {
                              var docs = "<a style='color:orange' href='#webservice/docs/fullTextGeocoding'>Docs</a>";
                              var text = "검색결과(지번주소) : "+ address+ ","+ "\n"+ "응답코드:"+ matchFlag+ "(상세 코드 내역은 "+ docs+ " 에서 확인)"+ "</br>"+ "위경도좌표(중심점) : "+ lat+ ", "+ lon+ "</br>"+ "위경도좌표(입구점) : "+ latEntr+ ", "+ lonEntr;
                              $("#result").html(text);
                           } else {
                              var docs = "<a style='color:orange' href='#webservice/docs/fullTextGeocoding'>Docs</a>";
                              var text = "검색결과(지번주소) : "+ address+ ","+ "\n"+ "응답코드:"+ matchFlag+ "(상세 코드 내역은 "+ docs+ " 에서 확인)"+ "</br>"+ "위경도좌표(입구점) : 위경도좌표(입구점)이 없습니다.";
                              $("#result").html(text);
                           }*/
                        }
                     }
                  },
                  error : function(request, status, error) {
                     console.log(request);
                     console.log("code:"+request.status + "\n message:" + request.responseText +"\n error:" + error);
                     // 에러가 발생하면 맵을 초기화함
                     // markerStartLayer.clearMarkers();
                     // 마커초기화
                     map.setCenter(new Tmapv2.LatLng(37.570028, 126.986072));
                     $("#result").html("");

                  }
               });
            });
            
            $("#port_select1").click(function(){
               var selected_port1 = $("#port1 option:selected").val();
               portmarker1.setMap(null);
               if (selected_port1 == "구미역"){
                  portmarker1 = new Tmapv2.Marker({
                     position: new Tmapv2.LatLng(36.1284581800925, 128.33072279764565),
                     icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_1.png",
                     iconSize : new Tmapv2.Size(24, 38),
                     map:map
                  });
                  markers.push(portmarker1);
                  map.setCenter(new Tmapv2.LatLng(36.1284581800925, 128.33072279764565));
               }
               if (selected_port1 == "금오공과대학교"){
                  portmarker1 = new Tmapv2.Marker({
                     position: new Tmapv2.LatLng(36.14606248008849, 128.393437497646),
                     icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_1.png",
                     iconSize : new Tmapv2.Size(24, 38),
                     map:map
                  });
                  markers.push(portmarker1);
                  map.setCenter(new Tmapv2.LatLng(36.14606248008849, 128.393437497646));
               }
               if (selected_port1 == "수원역"){
                  portmarker1 = new Tmapv2.Marker({
                     position: new Tmapv2.LatLng(37.26666378872338, 126.99943239928938),
                     icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_1.png",
                     iconSize : new Tmapv2.Size(24, 38),
                     map:map
                  });
                  markers.push(portmarker1);
                  map.setCenter(new Tmapv2.LatLng(37.26666378872338, 126.99943239928938));
               }
               if (selected_port1 == "서울역"){
                   portmarker1 = new Tmapv2.Marker({
                      position: new Tmapv2.LatLng(37.55315651655645, 126.97254344333736),
                      icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_1.png",
                      iconSize : new Tmapv2.Size(24, 38),
                      map:map
                   });
                   markers.push(portmarker1);
                   map.setCenter(new Tmapv2.LatLng(37.55315651655645, 126.97254344333736));
                }
               if (selected_port1 == "강변체육공원"){
                   portmarker1 = new Tmapv2.Marker({
                      position: new Tmapv2.LatLng(36.1137610491927, 128.3934586111375),
                      icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_1.png",
                      iconSize : new Tmapv2.Size(24, 38),
                      map:map
                   });
                   markers.push(portmarker1);
                   map.setCenter(new Tmapv2.LatLng(36.1137610491927, 128.3934586111375));
                }
               if (selected_port1 == "부산역"){
                   portmarker1 = new Tmapv2.Marker({
                      position: new Tmapv2.LatLng(35.114980312517744, 129.04207216327933),
                      icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_1.png",
                      iconSize : new Tmapv2.Size(24, 38),
                      map:map
                   });
                   markers.push(portmarker1);
                   map.setCenter(new Tmapv2.LatLng(35.114980312517744, 129.04207216327933));
                }
            });
            
            
            $("#port_select2").click(function(){
               var selected_port2 = $("#port2 option:selected").val();
               portmarker2.setMap(null);
               if (selected_port2 == "구미역"){
                  portmarker2 = new Tmapv2.Marker({
                     position: new Tmapv2.LatLng(36.1284581800925, 128.33072279764565),
                     icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_2.png",
                     iconSize : new Tmapv2.Size(24, 38),
                     map:map
                  });
                  markers.push(portmarker2);
                  map.setCenter(new Tmapv2.LatLng(36.1284581800925, 128.33072279764565));
               }
               if (selected_port2 == "금오공과대학교"){
                  portmarker2 = new Tmapv2.Marker({
                     position: new Tmapv2.LatLng(36.14606248008849, 128.393437497646),
                     icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_2.png",
                     iconSize : new Tmapv2.Size(24, 38),
                     map:map
                  });
                  markers.push(portmarker2);
                  map.setCenter(new Tmapv2.LatLng(36.14606248008849, 128.393437497646));
               }
               if (selected_port2 == "수원역"){
                  portmarker2 = new Tmapv2.Marker({
                     position: new Tmapv2.LatLng(37.26666378872338, 126.99943239928938),
                     icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_2.png",
                     iconSize : new Tmapv2.Size(24, 38),
                     map:map
                  });
                  markers.push(portmarker2);
                  map.setCenter(new Tmapv2.LatLng(37.26666378872338, 126.99943239928938));
               }
               if (selected_port2 == "서울역"){
                   portmarker2 = new Tmapv2.Marker({
                      position: new Tmapv2.LatLng(37.55315651655645, 126.97254344333736),
                      icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_2.png",
                      iconSize : new Tmapv2.Size(24, 38),
                      map:map
                   });
                   markers.push(portmarker2);
                   map.setCenter(new Tmapv2.LatLng(37.55315651655645, 126.97254344333736));
                }
               if (selected_port2 == "강변체육공원"){
                   portmarker2 = new Tmapv2.Marker({
                      position: new Tmapv2.LatLng(36.1137610491927, 128.3934586111375),
                      icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_2.png",
                      iconSize : new Tmapv2.Size(24, 38),
                      map:map
                   });
                   markers.push(portmarker2);
                   map.setCenter(new Tmapv2.LatLng(36.1137610491927, 128.3934586111375));
                }
               if (selected_port2 == "부산역"){
                   portmarker2 = new Tmapv2.Marker({
                      position: new Tmapv2.LatLng(35.114980312517744, 129.04207216327933),
                      icon : "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_2.png",
                      iconSize : new Tmapv2.Size(24, 38),
                      map:map
                   });
                   markers.push(portmarker2);
                   map.setCenter(new Tmapv2.LatLng(35.114980312517744, 129.04207216327933));
                }
            });
            
         };
         
         function getRP(){
            var s_latlng = markerPosition;            //출발지
            var e_latlng = markerPosition2;         //도착지
                
            var optionObj = {
                  reqCoordType:"WGS84GEO", //요청 좌표계 옵셥 설정입니다.
                  resCoordType:"WGS84GEO",  //응답 좌표계 옵셥 설정입니다.
                  trafficInfo:"Y"
            };
                
            var params = {
                  onComplete:onComplete,
                  onProgress:onProgress,
                  onError:onError
            };
                
               // TData 객체 생성
            var tData = new Tmapv2.extension.TData();
               
               // TData 객체의 경로요청 함수
            tData.getRoutePlanJson(s_latlng, e_latlng, optionObj, params);
         }
         
         function getRP2(){
            var selected_port1 = $("#port1 option:selected").val();
             var selected_port2 = $("#port2 option:selected").val();
             
             var s_latlng = markerPosition;
             var e_latlng = markerPosition2;
             
             var optionObj = {
                   reqCoordType:"WGS84GEO", //요청 좌표계 옵셥 설정입니다.
                   resCoordType:"WGS84GEO",  //응답 좌표계 옵셥 설정입니다.
                   trafficInfo:"Y"
             };
             
             var params = {
                   onComplete:onComplete,
                   onProgress:onProgress,
                   onError:onError
             };
             
             var tData = new Tmapv2.extension.TData();
             var tData2 = new Tmapv2.extension.TData();
             
             if (selected_port1 == "구미역" && selected_port2 == "금오공과대학교"){
                var s_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                var e_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                
                tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                polyline = new Tmapv2.Polyline({
                     path: [
                    	 s_port, // 선의 꼭짓점 좌표
                    	 e_port
                     ],
                     strokeColor: "#FF0000", // 라인 색상
                     strokeWeight: 6, // 라인 두께
                     strokeStyle: "solid", // 선의 종류
                     direction: true,
                     map: map // 지도 객체
                 });
                tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
            
                
             }
             if (selected_port1 == "구미역" && selected_port2 == "수원역"){
                var s_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                var e_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                
                tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                polyline = new Tmapv2.Polyline({
                     path: [
                    	 s_port, // 선의 꼭짓점 좌표
                    	 e_port
                     ],
                     strokeColor: "#FF0000", // 라인 색상
                     strokeWeight: 6, // 라인 두께
                     strokeStyle: "solid", // 선의 종류
                     direction: true,
                     map: map // 지도 객체
                 });
                tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
             }
             if (selected_port1 == "구미역" && selected_port2 == "서울역"){
                 var s_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                 var e_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "구미역" && selected_port2 == "강변체육공원"){
                 var s_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                 var e_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "구미역" && selected_port2 == "부산역"){
                 var s_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                 var e_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "구미역" && selected_port2 == "동락공원"){
                 var s_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                 var e_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             
             
             if (selected_port1 == "금오공과대학교" && selected_port2 == "구미역"){
                var s_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                var e_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                
                tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                polyline = new Tmapv2.Polyline({
                     path: [
                    	 s_port, // 선의 꼭짓점 좌표
                    	 e_port
                     ],
                     strokeColor: "#FF0000", // 라인 색상
                     strokeWeight: 6, // 라인 두께
                     strokeStyle: "solid", // 선의 종류
                     direction: true,
                     map: map // 지도 객체
                 });
                tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
             }
             if (selected_port1 == "금오공과대학교" && selected_port2 == "수원역"){
                var s_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                var e_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                
                tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                polyline = new Tmapv2.Polyline({
                     path: [
                    	 s_port, // 선의 꼭짓점 좌표
                         e_port
                     ],
                     strokeColor: "#FF0000", // 라인 색상
                     strokeWeight: 6, // 라인 두께
                     strokeStyle: "solid", // 선의 종류
                     direction: true,
                     map: map // 지도 객체
                 });
                tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
             }
             if (selected_port1 == "금오공과대학교" && selected_port2 == "서울역"){
                 var s_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                 var e_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                          e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "금오공과대학교" && selected_port2 == "강변체육공원"){
                 var s_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                 var e_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                          e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "금오공과대학교" && selected_port2 == "부산역"){
                 var s_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                 var e_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                          e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "금오공과대학교" && selected_port2 == "동락공원"){
                 var s_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                 var e_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                          e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             
             
             if (selected_port1 == "수원역" && selected_port2 == "구미역"){
                var s_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                var e_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                
                tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                polyline = new Tmapv2.Polyline({
                     path: [
                    	 s_port, // 선의 꼭짓점 좌표
                    	 e_port
                     ],
                     strokeColor: "#FF0000", // 라인 색상
                     strokeWeight: 6, // 라인 두께
                     strokeStyle: "solid", // 선의 종류
                     direction: true,
                     map: map // 지도 객체
                 });
                tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
             }
             if (selected_port1 == "수원역" && selected_port2 == "금오공과대학교"){
                var s_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                var e_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                
                tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                polyline = new Tmapv2.Polyline({
                     path: [
                    	 s_port, // 선의 꼭짓점 좌표
                    	 e_port
                     ],
                     strokeColor: "#FF0000", // 라인 색상
                     strokeWeight: 6, // 라인 두께
                     strokeStyle: "solid", // 선의 종류
                     direction: true,
                     map: map // 지도 객체
                 });
                tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
             }
             if (selected_port1 == "수원역" && selected_port2 == "서울역"){
                 var s_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                 var e_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "수원역" && selected_port2 == "강변체육공원"){
                 var s_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                 var e_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "수원역" && selected_port2 == "부산역"){
                 var s_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                 var e_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "수원역" && selected_port2 == "동락공원"){
                 var s_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                 var e_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             
             if (selected_port1 == "서울역" && selected_port2 == "구미역"){
                 var s_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 var e_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "서울역" && selected_port2 == "금오공과대학교"){
                 var s_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 var e_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "서울역" && selected_port2 == "수원역"){
                 var s_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 var e_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "서울역" && selected_port2 == "강변체육공원"){
                 var s_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 var e_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "서울역" && selected_port2 == "부산역"){
                 var s_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 var e_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "서울역" && selected_port2 == "동락공원"){
                 var s_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 var e_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             
             
             if (selected_port1 == "강변체육공원" && selected_port2 == "구미역"){
                 var s_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 var e_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "강변체육공원" && selected_port2 == "금오공과대학교"){
                 var s_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 var e_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "강변체육공원" && selected_port2 == "수원역"){
                 var s_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 var e_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "강변체육공원" && selected_port2 == "서울역"){
                 var s_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 var e_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "강변체육공원" && selected_port2 == "부산역"){
                 var s_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 var e_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "강변체육공원" && selected_port2 == "동락공원"){
                 var s_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 var e_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             
             
             if (selected_port1 == "부산역" && selected_port2 == "구미역"){
                 var s_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 var e_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "부산역" && selected_port2 == "금오공과대학교"){
                 var s_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 var e_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "부산역" && selected_port2 == "수원역"){
                 var s_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 var e_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "부산역" && selected_port2 == "서울역"){
                 var s_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 var e_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "부산역" && selected_port2 == "강변체육공원"){
                 var s_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 var e_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "부산역" && selected_port2 == "동락공원"){
                 var s_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 var e_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             
             
             if (selected_port1 == "동락공원" && selected_port2 == "구미역"){
                 var s_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 var e_port = new Tmapv2.LatLng(36.1284581800925, 128.33072279764565);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "동락공원" && selected_port2 == "금오공과대학교"){
                 var s_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 var e_port = new Tmapv2.LatLng(36.14606248008849, 128.393437497646);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "동락공원" && selected_port2 == "수원역"){
                 var s_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 var e_port = new Tmapv2.LatLng(37.26666378872338, 126.99943239928938);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "동락공원" && selected_port2 == "서울역"){
                 var s_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 var e_port = new Tmapv2.LatLng(37.55315651655645, 126.97254344333736);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "동락공원" && selected_port2 == "강변체육공원"){
                 var s_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 var e_port = new Tmapv2.LatLng(36.1137610491927, 128.3934586111375);
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
             if (selected_port1 == "동락공원" && selected_port2 == "부산역"){
                 var s_port = new Tmapv2.LatLng(36.10133827508044, 128.4013857335879);
                 var e_port = new Tmapv2.LatLng(35.114980312517744, 129.04207216327933);
                 
                 
                 
                 
                 
                 
                 
                 tData.getRoutePlanJson(s_latlng, s_port, optionObj, params);
                 polyline = new Tmapv2.Polyline({
                      path: [
                     	 s_port, // 선의 꼭짓점 좌표
                     	 e_port
                      ],
                      strokeColor: "#FF0000", // 라인 색상
                      strokeWeight: 6, // 라인 두께
                      strokeStyle: "solid", // 선의 종류
                      direction: true,
                      map: map // 지도 객체
                  });
                 tData2.getRoutePlanJson(e_port, e_latlng, optionObj, params);
              }
         }
             
             
         function onComplete() {
            console.log(this._responseData); //json으로 데이터를 받은 정보들을 콘솔창에서 확인할 수 있습니다.
            var jsonObject = new Tmapv2.extension.GeoJSON();
            var jsonForm = jsonObject.rpTrafficRead(this._responseData);
            
            //교통정보 표출시 생성되는 LineColor 입니다.
            var trafficColors = {
                 // 교통정보 옵션 - 라인색상
                 trafficDefaultColor:"#0000CC", //교통 정보가 없을 때
                 trafficType1Color:"#0000CC", //원활
                 trafficType2Color:"#0000CC", //서행
                 trafficType3Color:"#0000CC",  //정체
                 trafficType4Color:"#0000CC"  //정체
            };
            jsonObject.drawRouteByTraffic(map, jsonForm, trafficColors);
            map.setZoom(14);
         }
         
       //데이터 로드중 실행하는 함수입니다.
       function onProgress(){}
       
       //데이터 로드 중 에러가 발생시 실행하는 함수입니다.
       function onError(){
          alert("onError");
       }
         
         
         

      </script>
     <input class="burger-check" type="checkbox" id="burger-check" />
      <label class="burger-icon" for="burger-check">
      <span class="burger-sticks"></span></label>
      <div class="menu">
         <input width="0pt" height="0pt" type="text" class="text_custom" id="fullAddr"
         name="fullAddr" placeholder="출발지(ex:강동로 730)">
         <button id="btn_select">적용</button>
         <br>
         <input type="text" class="text_custom2" id="fullAddr2"
            name="fullAddr2" placeholder="도착지(ex:송원동로 72)">
         <button id="btn_select2">적용</button>
         
         
         <br>
         <select id="port1" name="port1" size="1">
            <option value="출발포트" selected>출발포트</option>
            <option value="구미역">구미역</option>
            <option value="금오공과대학교">금오공과대학교</option>
            <option value="수원역">수원역</option>
            <option value="서울역">서울역</option>
            <option value="강변체육공원">강변체육공원</option>
            <option value="부산역">부산역</option>
         </select>
         <button id="port_select1">적용하기</button>
         <br>
         <select id="port2" name="port2" size="1">
            <option value="도착포트" selected>도착포트</option>
            <option value="구미역">구미역</option>
            <option value="금오공과대학교">금오공과대학교</option>
            <option value="수원역">수원역</option>
            <option value="서울역">서울역</option>
            <option value="강변체육공원">강변체육공원</option>
            <option value="부산역">부산역</option>
         </select>
         <button id="port_select2">적용하기</button>
         <br>
         
         <button onClick="getRP()">길찾기 (포트미사용)</button>
         <button onClick="getRP2()">길찾기 (포트사용)</button>
         
         
         
         
         
        <div style="width: 500px;"></div>
      </div>
   </head>
   <body onload=initTmap();>
      <p id="result"></p>
      <br />
      
      <div id="map_wrap" class="map_wrap">
      
         <div id="map_div"></div>
         <div class="container">
         
            
            
      </div>
      <div class="map_act_btn_wrap clear_box"></div>
   </body>
</html>
