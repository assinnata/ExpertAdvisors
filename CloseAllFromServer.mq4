

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+

#import "MetaMessage.dll"
   void StopEA(int hWnd);
   void UnloadEA(int hWnd, int all);
#import

/*********************Samples*************************
   StopEA(WindowHandle(Symbol(),Period()));        //Disable all EA (can be used anywhere)
   UnloadEA(WindowHandle(Symbol(),Period()),0);    //Unload only current EA (can be used anywhere)
   UnloadEA(WindowHandle(Symbol(),Period()),1);    //Unload all EA in terminal (can be used anywhere)
*****************************************************/
extern double Lots = 0.1;
extern int Type = 0;
 string file_extension =".csv";
int handler;
int init()
  {   
//----
   
//----
if(Type > 1) {Alert("Type deve essere <= a 1");
      UnloadEA(WindowHandle(Symbol(),Period()),0);
      return (0);
}
if(Type == 0)
{
   int start=GetTickCount();
   int ticket= OrderSend(Symbol(),Type, Lots, NormalizeDouble(Ask,Digits),3,0,0,"",87879233,0,Red); 
  int ms= GetTickCount()-start;
  
   int start2=GetTickCount();
   OrderModify(ticket, NormalizeDouble(Ask,Digits),0, NormalizeDouble(Ask,Digits)+0.1,0,Red);
  int ms2= GetTickCount()-start2;
  
   int start3=GetTickCount();
   OrderClose(ticket,0.1, NormalizeDouble(Ask,Digits),0,Red); 
  int ms3= GetTickCount()-start3;
}
if(Type == 1)
{
    start=GetTickCount();
    ticket= OrderSend(Symbol(),Type, Lots, NormalizeDouble(Bid,Digits),3,0,0,"",87879233,0,Red); 
   ms= GetTickCount()-start;
  
    start2=GetTickCount();
   OrderModify(ticket, NormalizeDouble(Bid,Digits),0, NormalizeDouble(Bid,Digits)-0.1,0,Red);
   ms2= GetTickCount()-start2;
  
    start3=GetTickCount();
   OrderClose(ticket,0.1, NormalizeDouble(Bid,Digits),0,Red); 
   ms3= GetTickCount()-start3;
}
//----
   string filename = "ReportLatency_Data_" + Day() + "_" + Month() + "_" + Year() + "_ora_" + Hour() + "_" + Minute() + "_" + Seconds() + file_extension;
      
       handler = FileOpen( (filename), FILE_CSV|FILE_WRITE, "\t");
  // FileReadString(handler,FileSize(handler));
      
   //failed create handle
   if(handler < 1)
   {
   
      return(0);
   }

   string strline = "";
   //failed create handle
   if(handler < 1)
   {
   
      return(0);
   }
         //assign contents
         strline = TimeToStr(iTime(Symbol(), 0, 0),TIME_DATE|TIME_SECONDS);
         strline = StringSubstr(strline, 0, 4) + StringSubstr(strline, 5, 2) + StringSubstr(strline, 8, 2) + "," + StringSubstr(strline, 11, 5);
         
         //writing contents
         FileWrite(handler, (strline+";"));
         strline = "Lots:                " + Lots ;
         FileWrite(handler, (strline+";"));
         strline = "Type:                " + Type ;
         FileWrite(handler, (strline+";"));
         strline = "Server domain:       " + AccountServer();
         FileWrite(handler, (strline+";"));
         strline = "OrderSend ping ms:   " + ms ;
         FileWrite(handler, (strline+";"));
         strline = "OrderModify ping ms: " + ms2 ;
         FileWrite(handler, (strline+";"));
         strline = "OrderClose ping ms:  " + ms3 ;
         FileWrite(handler, (strline+";"));
         FileClose(handler);
      UnloadEA(WindowHandle(Symbol(),Period()),0);
   return(0);
  }
  
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+

