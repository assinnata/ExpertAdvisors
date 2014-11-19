
 extern int MagicNumber = 874687632;
 extern double Lots = 0.10;
 extern int PipsTakeProfit = 100;
 extern int PipsStopLoss = 100;
 extern int Stoch_KPeriodVal = 5;
 extern int Stoch_DPeriodVal = 3;
 extern int Stoch_SlowingVal = 3;
 extern int Stoch_KPeriodSignal = 5;
 extern int Stoch_DPeriodSignal = 3;
 extern int Stoch_SlowingSignal = 3;
 
 
 
 static int Status;
 static int LastTicket;
 
 static datetime LastTime;
 
 double Poin;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if (Point == 0.00001) Poin = 0.0001; 
else if (Point == 0.001) Poin = 0.01;
else Poin = Point; 

 double Val = iStochastic(0,0,Stoch_KPeriodVal,Stoch_DPeriodVal,Stoch_SlowingVal,MODE_SMA,0,MODE_MAIN,0);
 double Signal = iStochastic(0,0,Stoch_KPeriodSignal,Stoch_DPeriodSignal,Stoch_SlowingSignal,MODE_SMA,0,MODE_SIGNAL,0);
 
 if( Val > Signal && Signal >50 )
 {
    Status = 1;
 }
 if( Signal > Val && Val > 50 )
 {
    Status = 2;
 }
 if( Val > Signal && Val < 50 )
 {
    Status = 3;
 }
 if( Signal > Val && Signal < 50 )
 {
    Status = 4;
 }
//----
LastTime = iTime(0,0,0);
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
  if(iTime(0,0,0) < LastTime+Period()*60 ) return(0);
  LastTime = iTime(0,0,0);
 double Val = iStochastic(0,0,Stoch_KPeriodVal,Stoch_DPeriodVal,Stoch_SlowingVal,MODE_SMA,0,MODE_MAIN,0);
 double Signal = iStochastic(0,0,Stoch_KPeriodSignal,Stoch_DPeriodSignal,Stoch_SlowingSignal,MODE_SMA,0,MODE_SIGNAL,0);

   if(Status == 1)
   {
      if( Val < Signal && Val >50)
      {
         Status = 2;
         //sel entry
         entry( OP_SELL );
      }
      if( Val > Signal && Val < 50)
         Status = 3;
      return (0);
   }
   
   if(Status == 2)
   {
      if( Val > Signal && Signal > 50)
         Status = 1;
      if( Val < Signal && Signal < 50)
         Status = 4;
      return (0);
   }
   
   if(Status == 3)
   {
      if( Val < Signal && Signal < 50)
         Status = 4;
      if( Val > Signal && Signal > 50)
         Status = 1;
      return (0);
   }
   
   if(Status == 4)
   {
      if( Val > Signal && Val < 50)
      {
         Status = 3; 
         //buy entry
         entry( OP_BUY );
      }
      if( Val < Signal && Val >50)
         Status = 2;
      return (0);
   }
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

void entry( int type )
{
   double Lots = 0.01;
   double Temp;
   int Ticket = 0;
   double StopLoss;
   double TakeProfit;
   double OpenPrice;
   if(type == OP_BUY) {
      OpenPrice = NormalizeDouble(Ask,Digits);
      StopLoss = OpenPrice - PipsStopLoss*Poin;
      TakeProfit = OpenPrice + PipsTakeProfit*Poin;
      while( Ticket == 0 ){
      OrderClose(LastTicket,Lots,NormalizeDouble(Ask,Digits),3,Blue);
      LastTicket = OrderSend( Symbol(), type ,Lots, OpenPrice , 3,0,0, "Oscillator", MagicNumber,0,Blue );
      Ticket = LastTicket;
      }
   }
   if(type == OP_SELL){
      OpenPrice = NormalizeDouble(Bid,Digits);
      StopLoss = OpenPrice + PipsStopLoss*Poin;
      TakeProfit = OpenPrice - PipsTakeProfit*Poin;
      while( Ticket == 0 ){
        OrderClose(LastTicket,Lots,NormalizeDouble(Bid,Digits),3,Red);
        LastTicket = OrderSend( Symbol(), type ,Lots, OpenPrice , 3,0,0, "Oscillator", MagicNumber,0,Red );
        Ticket = LastTicket;
      }
   }
   
}

