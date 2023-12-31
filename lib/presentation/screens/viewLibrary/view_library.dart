import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/presentation/screens/viewLibrary/item_view_library.dart';
import 'package:click_it_app/presentation/screens/viewLibrary/view_library_response.dart';
import 'package:click_it_app/utils/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../preferences/app_preferences.dart';

class ViewLibraryScreen extends StatefulWidget{

  const ViewLibraryScreen({Key? key}) : super(key: key);

  @override
  State<ViewLibraryScreen> createState() {
    return _ViewLibraryScreenState();
  }

}

class _ViewLibraryScreenState extends State<ViewLibraryScreen>{

  List<Data> viewLibraryData = List.empty();
  var page = 1;
  ScrollController _scController = new ScrollController();
  bool _isLoadMoreRunning = true;

  bool showProgressBar = true;
  bool isConnected = true;

  @override
  void initState() {
    //_isLoadMoreRunning = true;

    dynamic uid = AppPreferences.getValueShared('uid')??"0";
    dynamic roleid = AppPreferences.getValueShared('role_id')??0;
    dynamic companyId =  AppPreferences.getValueShared('company_id');

    Utils.isConnected().then((value){
      if(value) {
        ClickItApis.getViewLibraryData(page,uid,companyId,roleid).then(
                (value) {
              viewLibraryData = value!;
              if (mounted) {
                setState(() {
                  isConnected = true;
                  showProgressBar = false;
                  _isLoadMoreRunning = false;
                });
              }
            }
        );
      }else{
        if(mounted) {
          setState(() {
            isConnected = false;
          });
        }
      }



    });

    _scController.addListener(() {
      if (_scController.position.pixels ==
          _scController.position.maxScrollExtent) {
        page++;
        if(mounted) {
          setState(() {
            _isLoadMoreRunning = true;
          });
        }

        ClickItApis.getViewLibraryData(page,uid,companyId,roleid).then(
                (value) {
                  viewLibraryData.addAll(value!);
                  if (mounted) {
                    setState(() {
                      _isLoadMoreRunning = false;
                    });
                  }
                }
        );
      }
    });

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
            Text("View Library"),
            Spacer()
        ],
      )),
      body:
          isConnected?
          showProgressBar?
          Center(
            child: CircularProgressIndicator(),
          )
              :
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                  controller: _scController,
                  itemCount: viewLibraryData.length,
                  itemBuilder: (BuildContext buildContext,int index){
                    return ItemViewLibrary(viewLibraryResponse: viewLibraryData[index]);
                  }),
            ),

            if (_isLoadMoreRunning == true&&viewLibraryData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.deepOrange,
                  ),
                ),
              ),
          ]
        ),
      )
              : Center(
            child: Text('Please connect to internet to load data'),),
    );
  }

  @override
  void dispose() {
    _scController.dispose();
    super.dispose();
  }

}

