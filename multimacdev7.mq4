//+------------------------------------------------------------------+
//|                                                    MultiMacd.mq4 |
//|                                            Copyright © 2011, DLC |
//|                                                                  |
//+------------------------------------------------------------------+


extern bool Hedging = true;

//---- input parameters
extern int       MagicNumber = 30082010;

extern double               Lots = 1;

extern int                 StopLoss = 50;

extern int              OffSet = 1;

extern int          AttivazioneTR =  0;   //Soglia di attivazione del trailing stop
extern int       RitracciamentoTR = 50;   //Ritracciamento del trailing stop

extern bool      BreakEven = true;
extern double    AttivazioneBreak = 10;
bool CheckBusy;



extern int SignalMin1 = 9;
extern int SignalMin5 = 9;
extern int SignalMin15 = 9;
extern int SignalMin30  = 9;
extern int SignalHour1 = 9;
extern int SignalHour4 = 9;
extern int SignalDaily = 9;
extern int SignalWeekly = 9;
 
extern bool M1 = false;
extern bool M5 = false;
extern bool M15 = true;
extern bool M30 = true;
extern bool H1 = true;
extern bool H4 = false;
extern bool D1 = false;

extern color M1Color = Red;
extern color M5Color = DeepPink;
extern color M15Color = CornflowerBlue;
extern color M30Color = Lime;
extern color H1Color = DarkOrange;
extern color H4Color = Yellow;
extern color D1Color= Silver;


extern int StartRange1 = 0;
extern int StopRange1 = 2359;


extern bool CloseOnFriday = true;
extern int FridayCloseHour = 21;
extern int FridayStopHourSignal = 19;


double Poin;
double i;
double y;
string Unit;

string name;

static datetime time;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
if (Point == 0.00001) Poin = 0.0001; 
else if (Point == 0.001) Poin = 0.01;
else Poin = Point;  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
if(IsTesting() == false) ObjectsDeleteAll();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
ClassicTrailing(AttivazioneTR, RitracciamentoTR);

if(CloseOnFriday==true)CloseOnFriday();

 if(BreakEven) BreakEven();
if(!Hedging)
{
   if (OpenedOnBar() == false && VerificaLong(SignalMin1,SignalMin5,SignalMin15,SignalMin30,SignalHour1,SignalHour4,SignalDaily,SignalWeekly)== true && OpenedOrders(0, MagicNumber) == 0 && VerificaOrario() == true)
      {
        OrderSend(Symbol(),OP_BUY, Lots, Ask, 3, Bid - StopLoss * Poin, 0, "MultiMacd", MagicNumber, Blue);   
      }
   if (OpenedOnBar() == false && VerificaShort(SignalMin1,SignalMin5,SignalMin15,SignalMin30,SignalHour1,SignalHour4,SignalDaily,SignalWeekly)== true && OpenedOrders(0,MagicNumber) == 0 && VerificaOrario() && true)
      {
        OrderSend(Symbol(),OP_SELL, Lots, Bid, 3, Ask + StopLoss * Poin, 0, "MultiMacd", MagicNumber, Red);
      } 

}
else
{
   if ( OpenedOnBar() == false && VerificaLong(SignalMin1,SignalMin5,SignalMin15,SignalMin30,SignalHour1,SignalHour4,SignalDaily,SignalWeekly)== true && OpenedOrders(1, MagicNumber) == 0 && VerificaOrario() == true)
      {
        OrderSend(Symbol(),OP_BUY, Lots, Ask, 3, Bid - StopLoss * Poin, 0, "MultiMacd", MagicNumber, Blue);   
      }
   if ( OpenedOnBar() == false && VerificaShort(SignalMin1,SignalMin5,SignalMin15,SignalMin30,SignalHour1,SignalHour4,SignalDaily,SignalWeekly)== true && OpenedOrders(-1,MagicNumber) == 0 && VerificaOrario() && true)
      {
        OrderSend(Symbol(),OP_SELL, Lots, Bid, 3, Ask + StopLoss * Poin, 0, "MultiMacd", MagicNumber, Red);
      } 
}

   
//----
   return(0);
  }


//+-----------------------------------------------------------------------------//
bool VerificaShort(int SignalMin1,  int SignalMin5, int SignalMin15, int SignalMin30, int SignalHour1, int SignalHour4, int SignalDaily, int SignalWeekly)

{


bool result;
bool Min1;
bool Min5;
bool Min15;
bool Min30;
bool Hour1;
bool Hour4;
bool bDaily;

double Macd1Min;
double Macd5Min;
double Macd15Min;
double Macd30Min;
double Macd1Hour;
double Macd4Hour;
double MacdDaily;

double Signal1Min;
double Signal5Min;
double Signal15Min;
double Signal30Min;
double Signal1Hour;
double Signal4Hour;
double SignalDaily_;


Macd1Min = iMACD(Symbol(),PERIOD_M1,12,26,SignalMin1,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal1Min = iMACD(Symbol(),PERIOD_M1,12,26,SignalMin1,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd5Min = iMACD(Symbol(),PERIOD_M5,12,26,SignalMin5,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal5Min = iMACD(Symbol(),PERIOD_M5,12,26,SignalMin5,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd15Min = iMACD(Symbol(),PERIOD_M15,12,26,SignalMin15,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal15Min = iMACD(Symbol(),PERIOD_M15,12,26,SignalMin15,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd30Min = iMACD(Symbol(),PERIOD_M30,12,26,SignalMin30,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal30Min = iMACD(Symbol(),PERIOD_M30,12,26,SignalMin30,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd1Hour = iMACD(Symbol(),PERIOD_H1,12,26,SignalHour1,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal1Hour = iMACD(Symbol(),PERIOD_H1,12,26,SignalHour1,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd4Hour = iMACD(Symbol(),PERIOD_H4,12,26,SignalHour4,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal4Hour = iMACD(Symbol(),PERIOD_H4,12,26,SignalHour4,PRICE_CLOSE,MODE_SIGNAL,OffSet);

MacdDaily = iMACD(Symbol(),PERIOD_D1,12,26,SignalDaily,PRICE_CLOSE,MODE_MAIN,OffSet);
SignalDaily_ = iMACD(Symbol(),PERIOD_D1,12,26,SignalDaily,PRICE_CLOSE,MODE_SIGNAL,OffSet);


   if (Macd1Min>0 && Macd1Min<Signal1Min) 
   {
   Min1 = true;
   }
   
   if (Macd5Min>0 && Macd5Min<Signal5Min) 
   {
   Min5 = true;
   }
   
   if (Macd15Min>0 && Macd15Min<Signal15Min) 
   {
   Min15 = true;
   }
   
   if (Macd30Min>0 && Macd30Min<Signal30Min) 
   {
   Min30 = true;
   }
   
   if (Macd1Hour>0 && Macd1Hour<Signal1Hour) 
   {   
   //Print(Time[0] + " " + time);
   Hour1 = true; 
   }
   
   if (Macd4Hour>0 && Macd4Hour<Signal4Hour) 
   {
   Hour4 = true;
   }
   
   if (MacdDaily>0 && MacdDaily<SignalDaily_) 
   {
   bDaily = true;
   }
   
   
   
if(Time[0] != time)
   {
   if(M1 == true && Min1 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0]);
      ObjectSet(name, OBJPROP_COLOR, M1Color);
      time = Time[0];
      }
   
   if(M5 == true && Min5 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 5 * Poin);
      ObjectSet(name, OBJPROP_COLOR, M5Color);
      time = Time[0];
      }
      
   if(M15 == true && Min15 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 10 * Poin);
      ObjectSet(name, OBJPROP_COLOR, M15Color);
      time = Time[0];
      }
   
   if(M30 == true && Min30 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 15 * Poin);
      ObjectSet(name, OBJPROP_COLOR, M15Color);
      time = Time[0];
      }
   
   if(H1 == true && Hour1 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 20 * Poin);
      ObjectSet(name, OBJPROP_COLOR, H1Color);
      time = Time[0];  
      }
  
   if(H4 == true && Hour4 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 25 * Poin);
      ObjectSet(name, OBJPROP_COLOR, H4Color);
      time = Time[0];
      }
      
   if(bDaily == true && D1 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 30 * Poin);
      ObjectSet(name, OBJPROP_COLOR, D1Color);
      time = Time[0];
      }     
   }

if((Min1 == true && M1 == false) || (Min5 == true && M5 == false) || (Min15 == true && M15 == false) || (Min30 == true && M30 == false) || (Hour1 == true && H1 == false) || (Hour4 && true && H4 == false) || (D1 == false && bDaily == true))
   {
   result = true;
   }
 /*
if((Min1 == true || M1 == false) && (Min5 == true || M5 == false) && (Min15 == true || M15 == false) && (Min30 == true && M30 == false) && (Hour1 == true || H1 == false) && (Hour4 && true || H4 == false) && (D1 == false || bDaily == true))
   {
   result = true;
   }
   */
 

return(result);
}
//+-----------------------------------------------------------------------------//
bool VerificaLong(int SignalMin1,  int SignalMin5, int SignalMin15, int SignalMin30, int SignalHour1, int SignalHour4, int SignalDaily, int SignalWeekly)

{


bool result;
bool Min1;
bool Min5;
bool Min15;
bool Min30;
bool Hour1;
bool Hour4;
bool bDaily;

double Macd1Min;
double Macd5Min;
double Macd15Min;
double Macd30Min;
double Macd1Hour;
double Macd4Hour;
double MacdDaily;

double Signal1Min;
double Signal5Min;
double Signal15Min;
double Signal30Min;
double Signal1Hour;
double Signal4Hour;
double SignalDaily_;


Macd1Min = iMACD(Symbol(),PERIOD_M1,12,26,SignalMin1,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal1Min = iMACD(Symbol(),PERIOD_M1,12,26,SignalMin1,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd5Min = iMACD(Symbol(),PERIOD_M5,12,26,SignalMin5,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal5Min = iMACD(Symbol(),PERIOD_M5,12,26,SignalMin5,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd15Min = iMACD(Symbol(),PERIOD_M15,12,26,SignalMin15,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal15Min = iMACD(Symbol(),PERIOD_M15,12,26,SignalMin15,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd30Min = iMACD(Symbol(),PERIOD_M30,12,26,SignalMin30,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal30Min = iMACD(Symbol(),PERIOD_M30,12,26,SignalMin30,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd1Hour = iMACD(Symbol(),PERIOD_H1,12,26,SignalHour1,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal1Hour = iMACD(Symbol(),PERIOD_H1,12,26,SignalHour1,PRICE_CLOSE,MODE_SIGNAL,OffSet);

Macd4Hour = iMACD(Symbol(),PERIOD_H4,12,26,SignalHour4,PRICE_CLOSE,MODE_MAIN,OffSet);
Signal4Hour = iMACD(Symbol(),PERIOD_H4,12,26,SignalHour4,PRICE_CLOSE,MODE_SIGNAL,OffSet);

MacdDaily = iMACD(Symbol(),PERIOD_D1,12,26,SignalDaily,PRICE_CLOSE,MODE_MAIN,OffSet);
SignalDaily_ = iMACD(Symbol(),PERIOD_D1,12,26,SignalDaily,PRICE_CLOSE,MODE_SIGNAL,OffSet);


   if (Macd1Min<0 && Macd1Min>Signal1Min) 
   {
   Min1 = true;
   }
   
   if (Macd5Min<0 && Macd5Min>Signal5Min) 
   {
   Min5 = true;
   }
   
   if (Macd15Min<0 && Macd15Min>Signal15Min) 
   {
   Min15 = true;
   }
   
   if (Macd30Min<0 && Macd30Min>Signal30Min) 
   {
   Min30 = true;
   }
   
   if (Macd1Hour<0 && Macd1Hour>Signal1Hour) 
   {
   Hour1 = true;   
   }
   
   if (Macd4Hour<0 && Macd4Hour>Signal4Hour) 
   {
   Hour4 = true;
   }
   
   if (MacdDaily<0 && MacdDaily>SignalDaily_) 
   {
   bDaily = true;
   }
   
if(Time[0] != time)
   {
   if(M1 == true && Min1 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0]);
      ObjectSet(name, OBJPROP_COLOR, M1Color);
      time = Time[0];
      }
   
   if(M5 == true && Min5 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 5 * Poin);
      ObjectSet(name, OBJPROP_COLOR, M5Color);
      time = Time[0];
      }
      
   if(M15 == true && Min15 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 10 * Poin);
      ObjectSet(name, OBJPROP_COLOR, M15Color);
      time = Time[0];
      }
   
   if(M30 == true && Min30 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 15 * Poin);
      ObjectSet(name, OBJPROP_COLOR, M15Color);
      time = Time[0];
      }
   
   if(H1 == true && Hour1 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 20 * Poin);
      ObjectSet(name, OBJPROP_COLOR, H1Color);
      time = Time[0];  
      }
  
   if(H4 == true && Hour4 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 25 * Poin);
      ObjectSet(name, OBJPROP_COLOR, H4Color);
      time = Time[0];
      }
      
   if(bDaily == true && D1 == true)
      {
      name = "Arrow " + ObjectsTotal();
      ObjectCreate(name,OBJ_ARROW, 0, Time[0],Low[0] - 30 * Poin);
      ObjectSet(name, OBJPROP_COLOR, D1Color);
      time = Time[0];
      }     
   }
   
if((Min1 == true && M1 == false) || (Min5 == true && M5 == false) || (Min15 == true && M15 == false) || (Min30 == true && M30 == false) || (Hour1 == true && H1 == false) || (Hour4 && true && H4 == false) || (D1 == false && bDaily == true))
   {
   result = true;
   }

return(result);

}
//+-------------------------------------------------------------------+

void CloseOnFriday()
{

bool Proceed = false;

if(CloseOnFriday==true && TimeHour(Time[0])>=FridayCloseHour && TimeDayOfWeek(Time[0]) == 5) Proceed=true;

if(Proceed==true)
   {
      int i;
      int total = OrdersTotal();
      for(i=0;i<total;i++)
      {
         OrderSelect(i,SELECT_BY_POS);
         if(OrderType()==OP_BUY  && OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber) {OrderClose(OrderTicket(), OrderLots(), Bid, 3, Red);}
         if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber) {OrderClose(OrderTicket(), OrderLots(), Ask, 3, Red);}
         if(OrderType()>OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber) {OrderDelete(OrderTicket());}
      }
   }
}

//+-------------------------------------------------------------------------------------+


//+-------------------------------------------------------------------+


int OpenedOrders(int Dir = 0, int MagicNumber = 0)
{
   int i;
   int Tot=0;
   for(i=0;i<OrdersTotal();i++)
   {
      OrderSelect(i,SELECT_BY_POS);
      if(Dir == 0) if ((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
      if(Dir == 1) if ((OrderType() == OP_BUY ) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
      if(Dir ==-1) if ((OrderType() == OP_SELL ) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
   }
   return(Tot);
}
//|------------------------------------------------------------------------------------------------------------------+
bool OpenedOnBar()
{

int   CurTk = OrderTicket();
if(GetLastError()!= 0)CurTk = 0;

int       i;
bool result = false;

for(i=OrdersTotal()-1;i>=0;i--)
{
   OrderSelect(i,SELECT_BY_POS);
   if(OrderOpenTime()>=Time[0] && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber){result = true;break;}
}

if(CurTk>0) OrderSelect(CurTk, SELECT_BY_TICKET);

return(result);
}

//+------------------------------------------------------------------+//
//| TRAILING STOP CLASSICO                                           |
//| I parametri sono il livello di attivazione e l'ampiezza dello SL | 
//+------------------------------------------------------------------+
void ClassicTrailing(int ActivationLevel, int iSL) 
{
double PP; 
double SP; 

for(int i = OrdersTotal() -1; i >= 0; i --)
  {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES); 

      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType()<=OP_SELL) 
        {         
      
          // LONG
          if(OrderType() == OP_BUY) 
            {
              if (Close[0] > OrderOpenPrice() + ActivationLevel * Poin)
                 {
                    if (OrderStopLoss() < Bid - iSL * Poin)
                  
                    OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble((Bid - iSL * Poin),Digits), OrderTakeProfit(), 0, Blue);
                 }
            } 
          // SHORT
          else 
          if(OrderType() == OP_SELL)
            {
              if (Close[0] < OrderOpenPrice() - ActivationLevel * Poin)
                 {
                    if (OrderStopLoss() > Ask + iSL * Poin)
                  
                    OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble((Ask + iSL * Poin),Digits), OrderTakeProfit(), 0, Blue);
                 }
            } 
        }
  }

return(0);
}

//+------------------------------------------------------------------+



//|--------------------------------------------------------------------------------------+
void BreakEven()
{

double ProfitXPip;

bool Esito;

int TempTicket;

if(OpenedOrders(0, MagicNumber) > 0)
{
   for (int y = OrdersTotal() -1; y >= 0; y --)
   {
      OrderSelect(y,SELECT_BY_POS,MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
         TempTicket = OrderTicket();
         
         if(OrderType() == OP_BUY)ProfitXPip = ((NormalizeDouble(Ask,Digits) - OrderOpenPrice())/Poin);
         if(OrderType() == OP_SELL)ProfitXPip = ((OrderOpenPrice() - NormalizeDouble(Bid,Digits))/Poin);
         if(ProfitXPip >= AttivazioneBreak)
            {
            if(OrderType() == OP_BUY && OrderSelect(OrderTicket(),SELECT_BY_TICKET,MODE_TRADES) == true && (IsTradeContextBusy() == false || CheckBusy == false) && (IsTradeAllowed() == true || CheckBusy == false))
               {
               //if(OrderStopLoss() + AttivazioneBreak * Poin <= OrderOpenPrice())
               if(OrderStopLoss() < OrderOpenPrice())
                  {
                  while(Esito == false)
                     {
                     if(OrderSelect(TempTicket, SELECT_BY_TICKET, MODE_TRADES) == false) break;
                     
                     OrderSelect(TempTicket,SELECT_BY_TICKET,MODE_TRADES);
                     
                     Esito = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble((Ask - AttivazioneBreak * Poin),Digits), OrderTakeProfit(), 0, Lime);
                     }
                  Print("BreakEven impostato");
                  Esito = false; 
                  }
               }
            if(OrderType() == OP_SELL && OrderSelect(OrderTicket(),SELECT_BY_TICKET,MODE_TRADES) == true && (IsTradeContextBusy() == false || CheckBusy == false) && (IsTradeAllowed() == true || CheckBusy == false))
               {
               //if(OrderStopLoss() - AttivazioneBreak * Poin >= OrderOpenPrice())
               if(OrderStopLoss() > OrderOpenPrice())
                  {
                  while(Esito == false) 
                     {
                     if(OrderSelect(TempTicket, SELECT_BY_TICKET, MODE_TRADES) == false) break;
                     
                     OrderSelect(TempTicket,SELECT_BY_TICKET,MODE_TRADES);
                     
                     Esito = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble((Bid + AttivazioneBreak * Poin),Digits), OrderTakeProfit(), 0, Lime);
                     }
                  Print("BreakEven impostato"); 
                  Esito = false;
                  }
               }           
         }
       }
    }
}

}

//+-------------------------------------------------------------------+ 

bool VerificaOrario()
{

bool result;
int    NowH = TimeHour(iTime(Symbol(),PERIOD_M1,0));
int    NowM = TimeMinute(iTime(Symbol(),PERIOD_M1,0));
int  StartH = StartRange1/100;
int  StartM = StartRange1 - StartH*100;
int   StopH = StopRange1/100;
int   StopM = StopRange1 - StopH*100;
int   Start = StartH*60 + StartM;
int    Stop = StopH*60 + StopM;
int     Now = NowH*60 + NowM;

if(Now>=Start && Now<=Stop)result=true;

//Non apro il venerdì dopo le 18
if(CloseOnFriday == true && TimeDayOfWeek(iTime(Symbol(),PERIOD_M1,0))== 5 && TimeHour(iTime(Symbol(),PERIOD_M1,0))>= FridayStopHourSignal ) result=false;


return(result);

}

//|--------------------------------------------------------------------------------------+
