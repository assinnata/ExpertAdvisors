

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_buffers 1
#property indicator_color1 Yellow

double PesoDDW = -1; // ogni 1% di ddw registrato
double PercentDDW = 1;//percentuale ddw
double PesoProfitto = 1; // ogni 1% registrato
double PercentProfit = 1; // percentuale profitto sul totale account
double PesoMargine = -1;// ogni 5% sul totale dell'account
double PercentMargin = 5;//percentuale margine
double PesoVolume = 1;// ogni 1.00 di volume registrato
double LottaggioRichiesto = 1;
static double Punteggio = 100;
bool DowngradeByDDW = true;

string file_extension = ".csv";
int handler;
string oldfilename = "";

datetime StartTimeCheck;
datetime StartForLots;
int LastTime;
double Factor;

double try1[];
double try[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
// 
int init()
  {
  
     SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, try);
   SetIndexLabel(0, "DDW");
   IndicatorShortName("DLC -- Rec to DDW Program -- ");
//---- indicators
if(PERIOD_MN1 == Period())
   Factor = 0.07;
if(PERIOD_W1 == Period())
   Factor = 0.3;
if(PERIOD_D1 == Period())
   Factor = 0.8;
if(PERIOD_H4 == Period())
   Factor = 17;
if(PERIOD_H1 == Period())
   Factor = 67;
if(PERIOD_M30 == Period() )
   Factor = 133;
if(PERIOD_M15 == Period() )
   Factor = 266;
if(PERIOD_M5 == Period())
   Factor = 800;
if(PERIOD_M1 == Period())
   Factor = 4000;

  ObjectCreate("Time",OBJ_LABEL,0,0,0);
      ObjectSet("Time",OBJPROP_XDISTANCE,5);
      ObjectSet("Time",OBJPROP_YDISTANCE,5);
      ObjectSet("Time",OBJPROP_CORNER,3);

StartTimeCheck = Time[0];
//TIME_SECONDS
//----
StartForLots = StartTimeCheck;
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
   
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  //Comment( "girotondo"+Time[0] +"  " +LastTime +"\n"+ CheckDDW()+"\n"+CheckMargin()+"\n"+CheckProfit()+"\n"+CheckLots()+"\n"+Punteggio);
  ObjectSetText("Time",DoubleToStr(Punteggio,2),40);
  if( Time[0] - LastTime == 0 )return(0);
  LastTime = Time[0];
   int    counted_bars=IndicatorCounted();
   Punteggio = Punteggio + CheckDDW();
   Punteggio = Punteggio + CheckMargin();
   Punteggio = Punteggio + CheckProfit();
   Punteggio = Punteggio + CheckLots();
   try[0] = Punteggio;
    string filename = Symbol() + "_RecScore_" + Month() + "_" + Year() + file_extension;
   if(oldfilename == "") 
      {
      oldfilename = filename;
      handler = FileOpen(filename, FILE_CSV|FILE_WRITE, "\t");
      }
   if(oldfilename != filename){
      FileClose(handler);
      handler = FileOpen(filename, FILE_CSV|FILE_WRITE, "\t");
      oldfilename = filename;
      }
   

   //failed create handle
   if(handler < 1)
   {
   
      return(0);
   }


   //string olddata = FileReadString(handler,FileSize(handler));
   //reset string
   string strline = "";
   
         //assign contents
         strline = TimeToStr(iTime(Symbol(), 0, 0),TIME_DATE|TIME_SECONDS);
         strline = StringSubstr(strline, 0, 4) + StringSubstr(strline, 5, 2) + StringSubstr(strline, 8, 2) + "," + StringSubstr(strline, 11, 5);
         strline = strline + "," +Punteggio;
         //writing contents
         FileWrite(handler, strline);

   
   
   
//----
RefreshRates();
   return(0);
  }
//+------------------------------------------------------------------+
//comunque ti volevo chiedere se ti trovi bene con me

double GetDDW()
{
   double result = (AccountBalance()-AccountEquity())/AccountBalance()*100;
   
   return (result);
}

double CheckDDW()
{
   return( - GetDDW()/Factor );
}

double CheckProfit()
{

   return( GetProfit()/ AccountBalance()*100 /Factor);
   
}
double CheckMargin()
{
   return( - AccountMargin()/AccountBalance()*5/Factor);
}
double CheckLots()
{
   return (GetLots()/Factor);
}

double GetProfit()
{
double profit;
   for(int i = OrdersTotal()-1; i >= 0; i --)
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   
      if(OrderSymbol() == Symbol() && OrderOpenTime() > StartTimeCheck)
         { 
         profit = profit+OrderProfit();
         
         }
      }
   return(profit);


}


double GetLots()
{
double lots;
datetime temp;
   for(int i = OrdersTotal()-1; i >= 0; i --)
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   
      if(OrderSymbol() == Symbol() && OrderOpenTime() > StartTimeCheck)
         { 
         lots = lots+OrderLots();
         if (temp < OrderOpenTime()) temp = OrderOpenTime();
         }
      }
      StartForLots = temp;
   return(lots);


}