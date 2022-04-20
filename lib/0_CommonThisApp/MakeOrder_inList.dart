

import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/forData/JArea.dart';

class MakeOrder_inList{

  List<int> makeOrder_byMax(List<int> inList){

    List<int> outList = [];

    while(true){

      int maxVal = -9999999;
      int max_i = -9999999;

      for(int i=0; i<inList.length; i++){
        if(inList[i]>maxVal){
          maxVal = inList[i];
          max_i = i ;
        }
      }

      outList.add(inList[max_i]);
      inList.removeAt(max_i);

      if(inList.length==0) break;
    }

    return outList;
  }

  List<JArea> makekOrder_byStartPos(List<JArea> inList){
    List<JArea> outList = [];

    while(true){

      int min_start_pos = 888888;
      int min_i = -1;

      for(int i=0; i<inList.length; i++){
        int this_startPos =inList[i].start_pos;
        if(this_startPos < min_start_pos){
          min_start_pos = this_startPos;
          min_i = i;
        }
      }

      outList.add(inList[min_i]);
      inList.removeAt(min_i);

      if(inList.length==0) break;
    }

    return outList;
  }

}