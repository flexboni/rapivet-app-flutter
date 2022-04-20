

class Test_Guide_subFuncs{

  String millsec_to_MMssmm(int remained_milSec){

    if(remained_milSec<=0) return "00:00:00";

    int sec = (remained_milSec/1000).toInt();

    int milsec = remained_milSec%1000;
    milsec = (milsec/10).round();

    String sec_str = sec.toString();
    if(sec_str.length==1) sec_str = "0"+sec_str;

    String milsec_str = milsec.toString();
    if(milsec_str.length==1) milsec_str ="0"+milsec_str;
    if(milsec_str.length==3) milsec_str="00";

    String MMssmm = "00:"+sec_str+":"+milsec_str;

    return MMssmm;
  }

}