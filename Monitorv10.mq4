extern int SLValue = 200;
extern bool EquityControlOnly = true;
extern bool SearchForMagicNumber = true;
extern int MagicNumber;
extern bool SearchForComment = true;
extern string StringComment = "";
extern bool   PercentEquityClose = true;
extern double PercentStop = -2.6;
extern bool TEST_MODE = false;
bool CloseAll;
double Poin;


static double PersonalAccountEquity;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if (Point == 0.00001) Poin = 0.0001; 
else if (Point == 0.001) Poin = 0.01;
else Poin = Point;    


PersonalAccountEquity = AccountBalance(); 


if( TEST_MODE  )
{

OrderSend(Symbol(),OP_BUY,0.2,Ask,3,0,0,"Test",123,Blue);
OrderSend(Symbol(),OP_BUY,0.1,Ask,3,0,0,"Test",123,Blue);
OrderSend(Symbol(),OP_SELL,0.1,Bid,3,0,0,"Test",123,Blue);


}


//----
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

Comment("Current Status: " + CurrentStatus());

   
   if(PercentStop >= CurrentStatus() && PercentEquityClose )
      {
      CloseAll = true;
      //PersonalAccountEquity = AccountBalance();
      }
   for(int i = OrdersTotal()-1; i >= 0; i --)
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   
      if(SearchForMagicNumber && !SearchForComment)
         if( OrderMagicNumber() == MagicNumber )
         {
            if( CloseAll && OrderMagicNumber() == MagicNumber )
            {
               if(OrderType()==OP_BUY) 
               {
                  while( !OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green) ){}
                  continue;
               }
      
            else if(OrderType()==OP_SELL)
               {
                  while( !OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green) ){}
                  continue;
               }
            Print("Chiusura CloseAll PercentStop >= Current status");
            PersonalAccountEquity = AccountBalance();              
            }
            if(!EquityControlOnly && OrderStopLoss() == 0 ){
               if(OrderType() == OP_BUY)
                  OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble ( (OrderOpenPrice() - SLValue * Poin), Digits), OrderTakeProfit(),OrderExpiration());
               if(OrderType() == OP_SELL)
                  OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble ( (OrderOpenPrice() + SLValue * Poin), Digits), OrderTakeProfit(),OrderExpiration());
            }
            //PersonalAccountEquity = AccountBalance();
         }
      if(!SearchForMagicNumber && SearchForComment)
         if( OrderComment() == StringComment )
         {
            if( CloseAll && OrderComment() == StringComment )
            {
               if(OrderType()==OP_BUY) 
               {
                  while( !OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green) ){}
                  continue;
               }
      
            else if(OrderType()==OP_SELL)
               {
                  while( !OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green) ){}
                  continue;
               }
            Print("Chiusura CloseAll PercentStop >= Current status");
            PersonalAccountEquity = AccountBalance();              
            }
            if(!EquityControlOnly && OrderStopLoss() == 0 ){
               if(OrderType() == OP_BUY)
                  OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble ( (OrderOpenPrice() - SLValue * Poin), Digits), OrderTakeProfit(),OrderExpiration());
               if(OrderType() == OP_SELL)
                  OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble ( (OrderOpenPrice() + SLValue * Poin), Digits), OrderTakeProfit(),OrderExpiration());
            }      
            //PersonalAccountEquity = AccountBalance();
         }
      if( SearchForMagicNumber && SearchForComment)
         if( OrderMagicNumber() == MagicNumber && OrderComment() == StringComment )
         {
            if( CloseAll && OrderMagicNumber() == MagicNumber && OrderComment() == StringComment )
            {
               if(OrderType()==OP_BUY) 
               {
                  while( !OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green) ){}
                  continue;
               }
      
            else if(OrderType()==OP_SELL)
               {
                  while( !OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green) ){}
                  continue;
               }
            Print("Chiusura CloseAll PercentStop >= Current status");
            PersonalAccountEquity = AccountBalance();
            }
            if(!EquityControlOnly && OrderStopLoss() == 0 ){
               if(OrderType() == OP_BUY)
                  OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble ( (OrderOpenPrice() - SLValue * Poin), Digits), OrderTakeProfit(),OrderExpiration());
               if(OrderType() == OP_SELL)
                  OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble ( (OrderOpenPrice() + SLValue * Poin), Digits), OrderTakeProfit(),OrderExpiration());
            Print("OrderModify: settato stoploss");
            }
            //PersonalAccountEquity = AccountBalance();
         }
      }

   CloseAll = false;
//----
   return(0);
  }
//+------------------------------------------------------------------+


//---------------------------------------------------------------------------------//
double CurrentStatus()
{
double result;

result = (( ( PersonalAccountEquity + GetProfit() - AccountBalance()) / AccountBalance()) * 100);

return(result);
}
//-------------------------------------------------------------------------------+


double GetProfit()
{
double result;
   for(int i = OrdersTotal()-1; i >= 0; i --)
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(SearchForMagicNumber && !SearchForComment)
            if( OrderMagicNumber() == MagicNumber )
                 result = result + OrderProfit();
         if(!SearchForMagicNumber && SearchForComment)
            if( OrderComment() == StringComment )
                 result = result + OrderProfit();
         if( SearchForMagicNumber && SearchForComment)
            if( OrderMagicNumber() == MagicNumber && OrderComment() == StringComment )
              result = result + OrderProfit();
     }
     return (result);
}

