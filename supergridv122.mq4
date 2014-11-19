//+------------------------------------------------------------------+
//|                                                amcFarmerGrid.mq4 |
//|                                                 Assinnata Matteo |
//|                                                                  |
//+------------------------------------------------------------------+

//--- input parameters

extern string     s1 = "---General Settings---";
extern bool      Stampate = false;
extern color      StopUpColor = Gold;
extern color    StopDownColor = Silver;
extern bool       Statistiche = true;
extern bool ResetCounterTP = true;
extern int        MagicNumber = 29082011;
extern int      PipsFromPrice = 6;
extern bool              Stop = false;
extern double          Spread = 2;
extern int        SpreadRatio = 2;
extern double       LottoBase = 0.10;
extern int       PipsDistance = 25;
extern double       Variabile = 1;
extern int           PipsTake = 15;
extern bool         ActivateK = true;
extern double               K = 1;
extern int             KStart = 0;
extern bool       CheckEquity = false;
extern int   PercentCloseLoss = -20;
bool      FixedBalance = false;
int         FixedValue = 10000;
extern bool  EmergencyEquity = true;
extern bool   ControlOpenGap = false;
extern int           DayOpen = 1;
extern int          HourOpen = 0;

extern string s2 = "---Time Of Trade---";
extern bool       bTimeRange = false;
extern int             Start = 8;
extern int               End = 22;
extern bool       StopFriday = true;
extern int    StopFridayHour = 12;

extern string s3 = "---Settings For G1G2---";
extern bool EquazionespreadG1G2 = false;
extern double AproxLotsG1G2 = 0.01;
extern bool   TpDinamico = true;
extern double LotsIncrement = 0.1;

extern string s4 = "---Settings For N-Grid---";
extern bool            NGrid = false;
extern int         NumMaxGrid = 2;
extern double   DeltaPipsGrid = 0;
extern bool EquazioneSpreadGN = true;
extern int               Mode = 0;
extern double       DeltaPips = 10;
extern double   SpreadRatioG3 = 2;
extern double    AproxLotsG3 = 0.01;
extern bool    NoKeepOpenOnG3 = true;
extern double  LostFirstOrderG3 = 1;
extern bool    PipsStartGrid = true;
extern int     ValuePipsStartGrid = 25;

extern string s5 = "---DDW Settings Reduction---";
extern int    ModeEmergencyEquity = 0;
extern double    AlertEquity = -1;
extern double DeltaPipsAlert = -5;
extern double DeltaPipsAlertStep = -1;
extern double DeltaPipsAlertStop = -10;
extern double VariabileAlert = -5;
extern double VariabileAlertStep = -1;
extern double VariabileAlertStop = -10;
extern bool  AlertEquityG3 = false;
extern bool  AcceptLossSpread = true;
extern bool       EqSpreadOff = true;
extern bool      EnoughProfit = true;
extern double          Profit = 10;
extern bool TrasformateNegInPos = false;
extern bool A = true;

bool G3;
bool EquazioneSpreadG3;
bool DebugCalcoli = false;

bool DebugPosizione = false;

bool DebugMLots = false;

string ChiusuraG1G2;
string ClosingTPN;
#define MAX_HOLYDAYS   11
int holydaysdays[MAX_HOLYDAYS]   = {24, 25, 26, 31, 1, 4, 17, 10};
int holydaysmonths[MAX_HOLYDAYS] = {12, 12, 12, 12, 1, 6, 1, 10};


double Poin;
double iStopLevel;
int Ticket;
bool Esito;
double AccBalance;
double FreezeLevel;

double BalanceValue;

double PipsD;

static double TP1;
static double TP2;
static double TPN;

static double G3Reset;
static double AccoEquity;
static bool bActivateEmergency;

static double TempVariabile;
static double TempDeltaPips;

static double TPPrint;
static int counter;

double tempTP;
double tempTP1 = -1;
double ClosedGridWithTP = false;

double ValorePip;

string ActualGrid;

double TPar[40];
datetime StartAr[40];
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

G3 = NGrid;
EquazioneSpreadG3 = EquazioneSpreadGN;
if (Point == 0.00001) Poin = 0.0001;
else if (Point == 0.001) Poin = 0.01;
else Poin = Point;
AccoEquity = AccountEquity();

iStopLevel = (MarketInfo(Symbol(), MODE_STOPLEVEL) / 10);


iStopLevel *= Poin;


PipsD = (PipsDistance + (PipsDistance / 2));

PipsD = NormalizeDouble(PipsD,0);

PipsD *= Poin;

if(AlertEquityG3 == true) G3 = false;

if(Statistiche == true)
{
ObjectCreate("STOPUP",OBJ_HLINE,0,iTime(Symbol(),PERIOD_M1,0),PriceStopPipsTake(1));
ObjectCreate("STOPDOWN",OBJ_HLINE,0,iTime(Symbol(),PERIOD_M1,0),PriceStopPipsTake(-1));
}

ValorePip = MarketInfo(Symbol(),MODE_TICKVALUE);

if(TpDinamico == true) EquazionespreadG1G2 = false;

counter = 1;

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


if( 0.01 <  MarketInfo(Symbol(),MODE_MINLOT) )
{
Print("Il lotto minimo richiesto dal broker è "+ MarketInfo(Symbol(),MODE_MINLOT)+". Pertanto questa strategia richiedendo 0.01 non può funzionare correttamente." );
return(0);
}
//---
//if(SaldoPipsEmergency() <= (-58.75)) if(Stampate)  Print("Gatto " + Time[0]);
//Print(MarketInfo(Symbol(), MODE_MINLOT));

if(OpenedOrders(0,MagicNumber) == 0 && FixedBalance == false) AccBalance = AccountBalance();

if(FixedBalance == true) AccBalance = FixedValue;

if(CheckEquity == true && OpenedOrders(0,MagicNumber) > 0)CheckEquity();

if(ControlOpenGap == true) ExecuteControlOpenGap();

if(EmergencyEquity == true && CurrentStatus() <= AlertEquity && CurrentStatus() < 0 && bActivateEmergency == false) ExecuteEmergencyEquity();

if(EnoughProfit == true) ExecuteEnoughProfit();

if(Statistiche == true)
{
string msg;
msg = msg + " \n MagicNumber= " + MagicNumber + " Symbol= " + Symbol() + " TF= " + Period() + " \n";
msg = msg + " \n \n Account no: " + AccountNumber() + " Owner " + AccountName();
msg = msg + " \n TimeLocal: " + TimeToStr(TimeLocal()) + " TimeServer: " + TimeToStr(TimeCurrent());
//msg = msg + " \n Profit attuale in pips: " + PipsGain();
msg = msg + " \n \n TP calcolato: " + TP();
msg = msg + " \n TP1 calcolato: " + TP1;
msg = msg + " \n \n OpenedOrdersGrid G1 :" + OpenedOrdersGrid("G1");
msg = msg + " \n OpenedOrdersGrid G2 :" + OpenedOrdersGrid("G2");
if(OpenedOrders(0,MagicNumber) > 0 && PriceStop(1) > 1 && PriceStop(-1) > 1)msg = msg + " \n \n Target price UP: " + PriceStop(1);
if(OpenedOrders(0,MagicNumber) > 0 && PriceStop(-1) > 1 && PriceStop(1) > 1)msg = msg + " \n Target price DOWN: " + PriceStop(-1);
if(ModeEmergencyEquity != 0 && EmergencyEquity == true)msg = msg + " \n TP2 calcolato: " + TP2 + " \n ";
//msg = msg + " \n " + LottiG3() + " " + LottiG1R() + " " + LottiG2R(-1) + " " + LottiG2R(1);
msg = msg + " \n \n Lotti totali contati: " + ContaLotti();
msg = msg + " \n Lotti aperti attualmente: " + LottiCorrenti();
if(OpenedOrders(0,MagicNumber) == 0)msg = msg + " \n Lotti medi per operazione: " + 0;
if(OpenedOrders(0,MagicNumber) > 0)msg = msg + " \n Lotti medi per operazione: " + (LottiCorrenti() / OpenedOrders(0,MagicNumber));
/* ATTIVARE PER DEBUG:
msg = msg + " \n \n PrimeOpenPriceA: " + PrimeOpenPrice(1);
msg = msg + " \n PrimeOpenPriceR: " + PrimeOpenPrice(-1);
msg = msg + " \n SecondOpenPriceA: " + SecondOpenPrice(1);
msg = msg + " \n SecondOpenPriceR: " + SecondOpenPrice(-1);
*/
if(EnoughProfit == true)msg = msg + " \n \n Target profit da raggiungere: " + (Profit * MarketInfo(Symbol(),MODE_TICKVALUE));
if(EnoughProfit == true)msg = msg + " \n Saldo in valuta attuale: " + (AccountEquity() - AccoEquity);
msg = msg + " \n \n Variabile: " + Variabile;
msg = msg + " \n DeltaPips: " + DeltaPips;
msg = msg + " \n EqSpread: " + EquazionespreadG1G2;
msg = msg + " \n EqSpreadG3: " + EquazioneSpreadG3;
msg = msg + " \n \n CurrentStatusEquity: " + CurrentStatus() + " Emergency Equity: " + EmergencyEquity;
if(EmergencyEquity == true && bActivateEmergency == true)msg = msg + " \n EXPERT AUTOADATTATO - FUNX RIENTRO DDW ATTIVATA - Mode Emergency Equity: " + ModeEmergencyEquity;
msg = msg + Spread();
Comment(msg);
Draw();

msg = "Al momento sono attive: ";
ObjectCreate("actualgrid",OBJ_LABEL,0,0,0);
ObjectSet("actualgrid",OBJPROP_XDISTANCE,5);
ObjectSet("actualgrid",OBJPROP_YDISTANCE,5);
ObjectSet("actualgrid",OBJPROP_CORNER,1);
ObjectSet("actualgrid",OBJPROP_COLOR, White );
ObjectSetText("actualgrid", msg, 8);
CheckActiveGrid();

}


ExecuteStop();


if(StopConditions(TimeHour(iTime(Symbol(),PERIOD_M1,0))) == true)
{
if(OpenedOrders(0,MagicNumber) == 0)
{
PanicClosePendenti(1);
PanicClosePendenti(-1);
return(0);
}
}

//Print(TimeHour(iTime(Symbol(),PERIOD_M1,0)));

if(OpenedOrders(0,MagicNumber) == 0 && OpenedOrders(2,MagicNumber) == 0 && OpenedOrders(3,MagicNumber) == 0)
{
AccoEquity = AccountEquity();

G3Reset = iTime( Symbol(), PERIOD_M1, 0);
for(int i = 0; i < NumMaxGrid - 1; i ++ )
StartAr[i] = iTime( Symbol(), PERIOD_M1, 0);

if(EmergencyEquity == true && bActivateEmergency == true) RestoreSettings();

TP1 = 0;

TP2 = 0;

TPPrint = 0;

tempTP1 = -1;

if(ResetCounterTP == true)counter = 0;

OrderSend(Symbol(),OP_SELLLIMIT, LottoBase,NormalizeDouble((Ask + PipsFromPrice * Poin),Digits),3,0,0,"G2 - SuperGrid",MagicNumber,0,Red);

OrderSend(Symbol(),OP_SELLSTOP,LottoBase,NormalizeDouble((Bid - PipsFromPrice * Poin),Digits),3,0,0,"G2 - SuperGrid",MagicNumber,0,Red);
}

CancPendentiOrfani();

ExecuteManagePosition();

//if(TpDinamico == true)TP();

//----
return(0);
}
//|----------------------------------------------------------------------------------------+
int OpenedOrders(int Dir = 0, int MagicNumber = 0)
{
int i;
int Tot;

for(i = OrdersTotal() -1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS);
if(Dir == 0) if ((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
if(Dir == 1) if ((OrderType() == OP_BUY ) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
if(Dir ==-1) if ((OrderType() == OP_SELL ) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
if(Dir == 2) if ((OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
if(Dir == 3) if ((OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
if(Dir == 4) if ((OrderType() == OP_BUYSTOP) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
if(Dir == 5) if ((OrderType() == OP_SELLSTOP) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
if(Dir == 6) if ((OrderType() == OP_SELLLIMIT) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;
if(Dir == 7) if ((OrderType() == OP_BUYLIMIT) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Tot++;

}
return(Tot);
}

//|----------------------------------------------------------------------------------------+
void CancPendentiOrfani()
{


if(OpenedOrders(5,MagicNumber) == 0)
{
PanicClosePendenti(4);
if(OpenedOrders(1,MagicNumber) == 0){ OrderSend(Symbol(),OP_BUY,LottoBase,NormalizeDouble(Ask,Digits),3,0,0,"G1 - SuperGrid",MagicNumber,0,Blue);
}
}

if(OpenedOrders(6,MagicNumber) == 0)
{
PanicClosePendenti(2);
if(OpenedOrders(1,MagicNumber) == 0){ OrderSend(Symbol(),OP_BUY,LottoBase,NormalizeDouble(Ask,Digits),3,0,0,"G1 - SuperGrid",MagicNumber,0,Blue);
}
}

}

//|---------------------------------------------------------------------------------------+
void PanicClosePendenti(int Dir)
{

for(int i=OrdersTotal()-1;i>=0;i--)
{
OrderSelect(i,SELECT_BY_POS);
if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
{
if(Dir == 1)if(OrderType()==OP_BUYSTOP) {OrderDelete(OrderTicket(),Green);continue;}
if(Dir == 2)if(OrderType()==OP_SELLSTOP){OrderDelete(OrderTicket(),Red);continue;}
if(Dir == 3)if(OrderType()==OP_BUYLIMIT){OrderDelete(OrderTicket(),Green);continue;}
if(Dir == 4)if(OrderType()==OP_SELLLIMIT){OrderDelete(OrderTicket(),Red);continue;}
}
}

}

//+------------------------------------------------------------------+
void ExecuteManagePosition()
{
//Questa funzione controlla se ci sono ordini della prima griglia in perdita di *Distance*
//Se ci sono ordini della prima griglia in perdita di *Distance*, allora lo chiude e esegue
//Le operazioni di routine per continuare la griglia

double ProfitXPip;

int PipsChiusura;

//double TempProfit;

int TempTicket;

int Dir;
double Lots;
//double ValoreOrdine;

double LotsB, LotsS;


PipsChiusura = (-1 * PipsDistance);

//Print(PrimeOpenPrice() + PipsDistance * Poin);

for(int i = OrdersTotal() -1; i >= 0; i--)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() <= OP_SELL)
{

TempTicket = OrderTicket();


if(OrderType() == OP_BUY)
{
ProfitXPip = ((NormalizeDouble(Bid,Digits) - OrderOpenPrice())/Poin);
//ProfitXPip -= Spread;
}

if(OrderType() == OP_SELL)ProfitXPip = ((OrderOpenPrice() - NormalizeDouble(Ask,Digits))/Poin);



if(OrderComment() == "G1 - SuperGrid")
{
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{

//Print(PrimeOpenPrice(1) - ((PipsDistance / 2) * Poin));

if(ProfitXPip <= PipsChiusura && ProfitXPip < 0)
{
OrderSelect(TempTicket,SELECT_BY_TICKET,MODE_TRADES);

Dir = OrderType();

Lots = OrderLots();

if(Dir == 0)
{
if(ActivateK == false || (ActivateK == true && OpenedOrdersGrid("G2") < KStart))while(Ticket <= 0)
{ Ticket = OrderSend(Symbol(),OP_BUY,(LottoBase + LottoBase),NormalizeDouble(Ask,Digits),3,0,0,"G2 - SuperGrid",MagicNumber,Blue);
Print(" * Apertura ordine Buy per G2 al prezzo "+Ask+" - lotto da "+ (LottoBase + LottoBase) );
}
if(ActivateK == true && OpenedOrdersGrid("G2") >= KStart )while(Ticket <= 0)
{ Ticket = OrderSend(Symbol(),OP_BUY,NormalizeDouble((LottoBase * K),2),NormalizeDouble(Ask,Digits),3,0,0,"G2 - SuperGrid",MagicNumber,Blue);
Print(" * Apertura ordine Buy per G2 al prezzo "+Ask+" - lotto da "+ NormalizeDouble((LottoBase * K),2));
}
Ticket = 0;

if(TpDinamico == false)LotsS = ManagementLotsG1G2(-1);

if(TpDinamico == true)LotsS = Lots + LotsIncrement;

if((OpenedOrdersGrid("G1")+ OpenedOrdersGrid("G2"))> 1 && G3 == true)
{
if(ModeEmergencyEquity != 0 && EmergencyEquity == true && bActivateEmergency == true)
{
TP2 = TP2(1);
}

if(Stampate)  Print("*Risultato equazione per operazione BUY prima dell'immissione su G3: " + ManagementLotsG3(1) + " *");

if(NoKeepOpenOnG3 == true)SeekAndDestroyG3();
double Lotsg3 = ManagementLotsG3(1);
while(Ticket <= 0) Ticket = OrderSend(Symbol(),OP_BUY,Lotsg3,NormalizeDouble(Ask,Digits),3,0,0,"G3 - SuperGrid",MagicNumber,Silver);
Print(" * Apertura ordine Buy per G3 al prezzo "+Ask+" - lotto da "+ Lotsg3);
OpenGridOrders( 0, 1);

Ticket = 0;
}

if(Stampate) Print("*Risultato equazione per operazione SELL prima dell'immissione su G1: " + LotsS  + " *");

if(Stampate)  Print("Lotti G1: " + LottiG1R() + "Lotti G2(1): " + LottiG2R(1)+ "Lotti G2(-1): " + LottiG2R(-1));

while(Ticket <= 0){ Ticket = OrderSend(Symbol(),OP_SELL,LotsS,NormalizeDouble(Bid,Digits),3,0,0,"G1 - SuperGrid",MagicNumber,Red);
Print(" * Apertura ordine Sell per G1 al prezzo "+Bid+" - lotto da "+ LotsS);
}
if(Ticket > 0)
{
OrderSelect(TempTicket,SELECT_BY_TICKET,MODE_TRADES);

while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green);

Esito = false;

TempTicket = 0;

Ticket = 0;
}
}

if(Dir == 1)
{
if( ActivateK == false || (ActivateK == true && OpenedOrdersGrid("G2") < KStart))while(Ticket <= 0){
Ticket = OrderSend(Symbol(),OP_SELL,(LottoBase + LottoBase),NormalizeDouble(Bid,Digits),3,0,0,"G2 - SuperGrid",MagicNumber,Blue);
Print(" * Apertura ordine Sell per G2 al prezzo "+Bid+" - lotto da "+ (LottoBase + LottoBase));
}
if( ActivateK == true && OpenedOrdersGrid("G2") >= KStart)while(Ticket <= 0){
Ticket = OrderSend(Symbol(),OP_SELL,NormalizeDouble((LottoBase * K),2),NormalizeDouble(Bid,Digits),3,0,0,"G2 - SuperGrid",MagicNumber,Blue);
Print(" * Apertura ordine Sell per G2 al prezzo "+Bid+" - lotto da "+ NormalizeDouble((LottoBase * K),2));
}
Ticket = 0;

if( TpDinamico == false)LotsB = ManagementLotsG1G2(1);

if( TpDinamico == true)LotsB = Lots + LotsIncrement;

if( (OpenedOrdersGrid("G1")+ OpenedOrdersGrid("G2"))> 1 && G3 == true)
{
if(ModeEmergencyEquity != 0 && EmergencyEquity == true && bActivateEmergency == true)
{
TP2 = TP2(-1);
}

if( Stampate)  Print("*Risultato equazione per operazione SELL prima dell'immissione su G3: " + ManagementLotsG3(-1) + " *");

if( NoKeepOpenOnG3 == true) SeekAndDestroyG3();
Lotsg3 = ManagementLotsG3(-1);
while( Ticket <= 0) Ticket = OrderSend(Symbol(),OP_SELL,Lotsg3,NormalizeDouble(Bid,Digits),3,0,0,"G3 - SuperGrid",MagicNumber,Silver);
Print(" * Apertura ordine Sell per G3 al prezzo "+Bid+" - lotto da "+ Lotsg3);
OpenGridOrders( 0, -1);

Ticket = 0;
}

if( Stampate) Print("*Risultato equazione per operazione BUY prima dell'immissione su G1: " + LotsB + " *");

if( Stampate) Print("Lotti G1: " + LottiG1R() + "Lotti G2(1): " + LottiG2R(1)+ "Lotti G2(-1): " + LottiG2R(-1));

while( Ticket <= 0) {
Ticket = OrderSend(Symbol(),OP_BUY,LotsB,NormalizeDouble(Ask,Digits),3,0,0,"G1 - SuperGrid",MagicNumber,Red);
Print(" * Apertura ordine Buy per G1 al prezzo "+Ask+" - lotto da "+ LotsB);
}
if( Ticket > 0)
{
OrderSelect( TempTicket, SELECT_BY_TICKET,MODE_TRADES );

while( Esito == false ) Esito = OrderClose( OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green);

Esito = false;

TempTicket = 0;

Ticket = 0;
}
}

if(EmergencyEquity == true && bActivateEmergency == true)
{
if(DeltaPips != DeltaPipsAlertStop) DeltaPips += DeltaPipsAlertStep;
if(Variabile != VariabileAlertStop) Variabile += VariabileAlertStep;
}
}
}
}

//Print(OrderComment() + " " + SecondOpenPrice(-1) + " " + PrimeOpenPrice(-1));



if(OrderComment() == "G2 - SuperGrid")
{
if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
//Print("Gatto");

if(ProfitXPip <= PipsChiusura && ProfitXPip < 0)
{
OrderSelect(TempTicket,SELECT_BY_TICKET,MODE_TRADES);

Dir = OrderType();

Lots = OrderLots();

if(Dir == 0)
{
if( ActivateK == false || (ActivateK == true && OpenedOrdersGrid("G1") < KStart))while(Ticket <= 0){
Ticket = OrderSend(Symbol(),OP_BUY,(LottoBase + LottoBase),NormalizeDouble(Ask,Digits),3,0,0,"G1 - SuperGrid",MagicNumber,Blue);
Print(" * Apertura ordine Buy per G1 al prezzo "+Ask+" - lotto da "+ (LottoBase + LottoBase));
}
if( ActivateK == true && OpenedOrdersGrid("G1") >= KStart)while(Ticket <= 0) {
Ticket = OrderSend(Symbol(),OP_BUY,NormalizeDouble((LottoBase * K),2),NormalizeDouble(Ask,Digits),3,0,0,"G1 - SuperGrid",MagicNumber,Blue);
Print(" * Apertura ordine Buy per G1 al prezzo "+Ask+" - lotto da "+ NormalizeDouble((LottoBase * K),2));
}
Ticket = 0;

if(TpDinamico == false) LotsS = ManagementLotsG1G2(-1);

if(TpDinamico == true) LotsS = Lots + LotsIncrement;

if((OpenedOrdersGrid("G1")+ OpenedOrdersGrid("G2")) > 1 && G3 == true)
{
if(ModeEmergencyEquity != 0 && EmergencyEquity == true && bActivateEmergency == true)
{
TP2 = TP2(1);
}

if(Stampate) Print("*Risultato equazione per operazione BUY prima dell'immissione su G3: " + ManagementLotsG3(1)  + " *");

if(NoKeepOpenOnG3 == true)SeekAndDestroyG3();

Lotsg3 = ManagementLotsG3(1);
while(Ticket <= 0) Ticket = OrderSend(Symbol(),OP_BUY, Lotsg3,NormalizeDouble(Ask,Digits),3,0,0,"G3 - SuperGrid",MagicNumber,Silver);
Print(" * Apertura ordine Buy per G3 al prezzo "+Ask+" - lotto da "+ Lotsg3);

OpenGridOrders( 0, 1);

Ticket = 0;
}

if(Stampate) Print("*Risultato equazione per operazione SELL prima dell'immissione su G2: " + LotsS  + " *");

if(Stampate) Print("Lotti G1: " + LottiG1A() + "Lotti G2(1): " + LottiG2A(1)+ "Lotti G2(-1): " + LottiG2A(-1));

while(Ticket <= 0)
Ticket = OrderSend(Symbol(),OP_SELL,LotsS,NormalizeDouble(Bid,Digits),3,0,0,"G2 - SuperGrid",MagicNumber,Red);
Print(" * Apertura ordine Sell per G2 al prezzo "+Bid+" - lotto da "+ LotsS);

if(Ticket > 0)
{
OrderSelect(TempTicket,SELECT_BY_TICKET,MODE_TRADES);

while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green);

Esito = false;

TempTicket = 0;

Ticket = 0;
}
}

if(Dir == 1)
{
if(ActivateK == false || (ActivateK == true && OpenedOrdersGrid("G1") < KStart))while(Ticket <= 0){
Ticket = OrderSend(Symbol(),OP_SELL,(LottoBase + LottoBase),NormalizeDouble(Bid,Digits),3,0,0,"G1 - SuperGrid",MagicNumber,Blue);
} Print(" * Apertura ordine Sell per G1 al prezzo "+Bid+" - lotto da "+ (LottoBase + LottoBase));

if(ActivateK == true && OpenedOrdersGrid("G1") >= KStart)while(Ticket <= 0){ Ticket = OrderSend(Symbol(),OP_SELL,NormalizeDouble((LottoBase * K),2),NormalizeDouble(Bid,Digits),3,0,0,"G1 - SuperGrid",MagicNumber,Blue);
} Print(" * Apertura ordine Sell per G1 al prezzo "+Bid+" - lotto da "+ NormalizeDouble((LottoBase * K),2));

Ticket = 0;

if(TpDinamico == false) LotsB = ManagementLotsG1G2(1);

if(TpDinamico == true) LotsB = Lots + LotsIncrement;

if((OpenedOrdersGrid("G1")+ OpenedOrdersGrid("G2")) > 1 && G3 == true)
{
if(ModeEmergencyEquity != 0 && EmergencyEquity == true && bActivateEmergency == true)
{
TP2 = TP2(-1);
}

if(Stampate) Print("*Risultato equazione per operazione SELL prima dell'immissione su G3: " + ManagementLotsG3(-1) + " *");

if(NoKeepOpenOnG3 == true)SeekAndDestroyG3();
Lotsg3 = ManagementLotsG3(-1);
while(Ticket <= 0) Ticket = OrderSend(Symbol(),OP_SELL, Lotsg3,NormalizeDouble(Bid,Digits),3,0,0,"G3 - SuperGrid",MagicNumber,Silver);
Print(" * Apertura ordine Sell per G3 al prezzo "+Bid+" - lotto da "+ Lotsg3);
OpenGridOrders( 0, -1);

Ticket = 0;
}

if(Stampate) Print("*Risultato equazione per operazione BUY prima dell'immissione su G2: " + LotsB + " *");

if(Stampate) Print("Lotti G1: " + LottiG1A() + "Lotti G2(1): " + LottiG2A(1)+ "Lotti G2(-1): " + LottiG2A(-1));

while(Ticket <= 0)Ticket = OrderSend(Symbol(),OP_BUY,LotsB,NormalizeDouble(Ask,Digits),3,0,0,"G2 - SuperGrid",MagicNumber,Red);

Print(" * Apertura ordine Buy per G2 al prezzo "+Ask+" - lotto da "+ LotsB);
if(Ticket > 0)
{
OrderSelect(TempTicket,SELECT_BY_TICKET,MODE_TRADES);

while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green);

Esito = false;

TempTicket = 0;

Ticket = 0;
}
}

if(EmergencyEquity == true && bActivateEmergency == true)
{
if(DeltaPips != DeltaPipsAlertStop) DeltaPips += DeltaPipsAlertStep;
if(Variabile != VariabileAlertStop) Variabile += VariabileAlertStep;
}

}

}

}
}
}
}
//|---------------------------------------------------------------------------------------+
void PanicClose()
{
bool Esito;
G3Reset = iTime( Symbol(), PERIOD_M1, 0 );

for( int i = NumMaxGrid-1; i >=0 ; i-- )
StartAr[i] = iTime( Symbol(), PERIOD_M1, 0 );
for( i=OrdersTotal()-1;i>=0;i--)
{
OrderSelect(i,SELECT_BY_POS);
if( OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber )
{
if(OrderType()==OP_BUY)
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green);
Print(" * Chiusura ordine Buy di "+ StringSubstr(OrderComment(), 0, 2) +" al prezzo "+OrderClosePrice()+" lotto "+OrderLots()+" per ritracciamento in A o A+1");
Esito = false;
continue;
}

else if(OrderType()==OP_SELL)
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green);
Print(" * Chiusura ordine Sell di "+ StringSubstr(OrderComment(), 0, 2) +" al prezzo "+OrderClosePrice()+" lotto "+OrderLots()+" per ritracciamento in A o A+1");
Esito = false;
continue;
}
}
}


if(Statistiche == true)
{
ObjectSet("STOPUP",OBJPROP_PRICE1,0);
ObjectSet("STOPDOWN",OBJPROP_PRICE1,0);
}


}

//|---------------------------------------------------------------------------------------+
void PanicCloseG3()
{
bool Esito;

for(int i=OrdersTotal()-1;i>=0;i--)
{
G3Reset = iTime( Symbol(), PERIOD_M1, 0 );
OrderSelect(i,SELECT_BY_POS);
if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderComment() == "G3 - SuperGrid" )
{
if(OrderType()==OP_BUY)
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green);
Print(" * Chiusura ordine Buy di G3 al prezzo "+OrderClosePrice()+" lotto "+OrderLots()+" per TP3");
Esito = false;
ClosedGridWithTP = true;
continue;
}

else if(OrderType()==OP_SELL)
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green);
Print(" * Chiusura ordine Sell di G3 al prezzo "+OrderClosePrice()+" lotto "+OrderLots()+" per TP3");
Esito = false;
ClosedGridWithTP = true;
continue;
}
}
}

}
//|---------------------------------------------------------------------------------------+
void PanicCloseG1G2()
{
bool Esito;

for(int i=OrdersTotal()-1;i>=0;i--)
{
G3Reset = iTime( Symbol(), PERIOD_M1, 0 );
OrderSelect(i,SELECT_BY_POS);
if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && ( OrderComment() == "G1 - SuperGrid" || OrderComment() == "G2 - SuperGrid" ) )
{
if(OrderType()==OP_BUY)
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green);

Print(" * Chiusura ordine Buy per "+StringSubstr(OrderComment(),0,2)+" al prezzo "+OrderClosePrice()+" - lotto da "+OrderLots()+" per "+ChiusuraG1G2);
Esito = false;
continue;
}

else if(OrderType()==OP_SELL)
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green);
Print(" * Chiusura ordine Sell per "+StringSubstr(OrderComment(),0,2)+" al prezzo "+OrderClosePrice()+" - lotto da "+OrderLots()+" per "+ChiusuraG1G2);
Esito = false;
continue;
}
}
}

}

//|---------------------------------------------------------------------------------------+
string Spread()
{
string msg;

RefreshRates();

double CurrentSpread = MarketInfo(Symbol(), MODE_SPREAD);


if (Poin == 0.0001) CurrentSpread = CurrentSpread /10;
if (Poin ==0.001) CurrentSpread = CurrentSpread / 100;
if (Poin ==0.01) CurrentSpread = CurrentSpread /10;
if (Point == Poin) CurrentSpread = CurrentSpread *10;

CurrentSpread = NormalizeDouble(CurrentSpread,2);

msg = msg + " \n \n Spread Attuale: " + CurrentSpread + " Broker: " + AccountCompany();


return(msg);
}

//---------------------------------------------------------------------------------//
double ManagementLotsG1G2(int Dir)
{
double result;

double MinLots, MaxLots, LotStep;


MinLots = MarketInfo(Symbol(), MODE_MINLOT);

MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);

LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);


if(DebugMLots == true && SecondOpenPrice(1) == PrimeOpenPrice(1) && PrimeOpenPrice(1) != 0)if(Stampate) Print("ERRORE CONTROLLARE PRIME E SECOND PRICE * 1");

if(DebugMLots == true && SecondOpenPrice(-1) == PrimeOpenPrice(-1) && PrimeOpenPrice(-1) != 0)if(Stampate) Print("ERRORE CONTROLLARE PRIME E SECOND PRICE * -1");


if(EquazionespreadG1G2 == false)
{
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
if(Dir == 1)
{
result = ( LottiG1R() * PipsDistance );

result -= ((PipsDistance + PipsTake) * LottiG2R(1) );

result += ( LottiG2R(-1) * PipsTake );

result += (Variabile );

result /= (PipsTake );
}

if(Dir == -1)
{
result = (LottiG1R() * PipsDistance) ;

result -= (LottiG2R(-1)  * (PipsDistance + PipsTake));

result += (LottiG2R(1) * PipsTake );

result += (Variabile );

result /= (PipsTake );

}
}

if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if(Dir == 1)
{

result = (LottiG1A() * PipsDistance) ;

result -= ((PipsDistance + PipsTake)  * LottiG2A(1) );

result += (LottiG2A(-1) * PipsTake );

result += (Variabile );

result /= (PipsTake );
}


if(Dir == -1)
{

result = (LottiG1A() * PipsDistance) ;

result -= ((PipsDistance + PipsTake)  * LottiG2A(-1) );

result += (LottiG2A(1) * PipsTake );

result += (Variabile );

result /= (PipsTake);
}
}
}

if(EquazionespreadG1G2 == true)
{
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
if(Dir == 1)
{
result = (LottiG1R() * PipsDistance) ;
//    if(Stampate) Print("********LottiG1R() * pipd = " + LottiG1R() + "*" + PipsDistance + " = "+ (LottiG1R() * PipsDistance) );

result -= ((PipsDistance + PipsTake) * LottiG2R(1));
//   if(Stampate) Print("********(PipsDistance + PipsTake) * LottiG2R(1) = (" + PipsDistance + "+" + PipsTake + ")* "+LottiG2R(1)+" = "+ ((PipsDistance + PipsTake) * LottiG2R(1))  );

result += (LottiG2R(-1) * PipsTake );
//  if(Stampate) Print("******** LottiG2R(-1) * pipd = " + LottiG2R(-1) + "*" + PipsTake + " = "+ (LottiG2R(-1) * PipsTake ) );

result += (SpreadRatio * Spread) * (LottiG1R() + LottiG2R(1) + LottiG2R(-1));
//  if(Stampate) Print("********(SpreadRatio * Spread) * (LottiG1R() + LottiG2R(1) + LottiG2R(-1)) = "+  " ( "+SpreadRatio +" * "+ Spread +" ) * ( "+LottiG1R() +" + "+ LottiG2R(1)+ " + " +LottiG2R(-1)+" )" +" = "+( (SpreadRatio * Spread) * (LottiG1R() + LottiG2R(1) + LottiG2R(-1)) ) );

result += (Variabile );
//   if(Stampate) Print("******** variabile = "+ Variabile);

result /= (PipsTake - (SpreadRatio * Spread)) ;
//   if(Stampate) Print("******** PipsTake - (SpreadRatio * Spread) = " + PipsTake + " - ( "+SpreadRatio +" * "+ Spread +" ) = " + (PipsTake - (SpreadRatio * Spread)));

//     if(Stampate) Print("******************************** dir 1  RESULT ="+result);
}


if(Dir == -1)
{
result = (LottiG1R() * PipsDistance) ;

result -= ((PipsDistance + PipsTake)  * LottiG2R(-1));

result += (LottiG2R(1) * PipsTake );

result += (SpreadRatio * Spread)  * (LottiG1R() + LottiG2R(1) + LottiG2R(-1));

result += (Variabile  );

result /= (PipsTake - (SpreadRatio * Spread)) ;
}
}

if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{

if(Dir == 1)
{
result = (LottiG1A() * PipsDistance) ;

result -= ((PipsDistance + PipsTake)  * LottiG2A(-1) );

result += (LottiG2A( 1) * PipsTake );

result += (SpreadRatio * Spread)  * (LottiG1A() + LottiG2A(1) + LottiG2A(-1));

result += (Variabile );

result /= (PipsTake - (SpreadRatio * Spread));
}


if(Dir == -1)
{
//
result = (LottiG1A() * PipsDistance) ;
//   if(Stampate) Print("******************************** 1sotto dir -1  RESULT ="+result);

result -= ((PipsDistance + PipsTake)  *  LottiG2A( 1) );
//   if(Stampate) Print("******************************** 2sotto dir -1  RESULT ="+result);

result += (LottiG2A(-1) * PipsTake );
//   if(Stampate) Print("******************************** 3sotto dir -1  RESULT ="+result);

result += (SpreadRatio * Spread)  * (LottiG1A() + LottiG2A(1) + LottiG2A(-1));

//   if(Stampate) Print("******************************** 4sotto dir -1  RESULT ="+result);
result += (Variabile );

//   if(Stampate) Print("******************************** 5sotto dir -1  RESULT ="+result);
result /= (PipsTake - (SpreadRatio * Spread));
//   if(Stampate) Print("******************************** 6sotto dir -1  RESULT ="+result);
}
}
}


result = StrToDouble( DoubleToStr(result,2));

if(result > MaxLots) result = MaxLots;

if(result < MinLots)
{
if(Stampate) Print("* ATTENZIONE EQUAZIONE NEGATIVA O ZERO, risultato prima di sostituirlo con il lotto minimo: " + result);
result = MinLots;
}

return(result);
}
//--------------------------------------------------------------------------/
double LottiG1R()
{
double result;

datetime Start;



for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}


for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}


for(i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}


return(result);
}
//--------------------------------------------------------------------------/
double OpenedLottiG1R()
{
double result;

datetime Start;



for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}


for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}

/*
for(i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
*/

return(result);
}

//--------------------------------------------------------------------------/
double LottiG2R(int Dir)
{
double result;

datetime Start;

int TempTicket;

for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}


if(Dir == 1)
{
for( i = OrdersHistoryTotal()-1; i >= 0; i--)
{
OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );

if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
}


if(Dir == -1)
{
for( i = OrdersHistoryTotal()-1; i >= 0; i--)
{
OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );

if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
}



return(result);
}
//--------------------------------------------------------------------------/
double LottiG1A()
{
double result;

datetime Start;



for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}


for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}


for(i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}


return(result);
}
//--------------------------------------------------------------------------/
double OpenedLottiG1A()
{
double result;

datetime Start;



for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}


for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}

/*
for(i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
*/

return(result);
}

//--------------------------------------------------------------------------/
double LottiG2A(int Dir)
{
double result;

datetime Start;

int TempTicket;

for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}


if(Dir == 1)
{
for( i = OrdersHistoryTotal()-1; i >= 0; i--)
{
OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );

if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
}


if(Dir == -1)
{
for( i = OrdersHistoryTotal()-1; i >= 0; i--)
{
OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );
//------------OP_SELL
if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}
}



return(result);
}
//-------------------------------------------------------------------------//
double PrimeOpenPrice(int Dir)
{
datetime TempOpenTime;
double result;


if(Dir == 1) //Avanzamento - G1 fissa
{
for(int i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid")
{
if(OrderOpenTime() <= TempOpenTime || TempOpenTime == 0)
{
TempOpenTime = OrderOpenTime();
result = OrderOpenPrice();
}
}
}
}


if(Dir == -1) //Regressione - G2 fissa
{
for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() <= OP_SELL && OrderComment() == "G2 - SuperGrid")
{
if(OrderOpenTime() <= TempOpenTime || TempOpenTime == 0)
{
TempOpenTime = OrderCloseTime();
result = OrderOpenPrice();
}
}
}
}


NormalizeDouble(result,Digits);

return(result);
}
//-----------------------------------------------------------------------------//
double SecondOpenPrice(int Dir)
{
datetime Start;
datetime fool;
double result;

int i;


if(Dir == 1) //Avanzamento - G1 fissa
{
for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() <= OP_SELL && OrderComment() == "G1 - SuperGrid")
{
if(OrderOpenTime() <= Start || Start == 0)
{
Start = OrderOpenTime();
//result = OrderOpenPrice();
}
}
}



for(i = OrdersTotal() -1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() > Start)
{
//Print(TimeToStr(Start) + " " + TimeToStr(OrderOpenTime()) + " " + OrderTicket());

if((OrderOpenTime() < fool || fool == 0))
{
fool = OrderOpenTime();
result = OrderOpenPrice();
}
}
}
}




if(Dir == -1) //Regressione - G2 fissa
{
for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() <= OP_SELL && OrderComment() == "G2 - SuperGrid")
{
if(OrderOpenTime() <= Start || Start == 0)
{
Start = OrderOpenTime();
//result = OrderOpenPrice();
}
}
}


for(i = OrdersTotal() -1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderOpenTime() > Start)
{
//Print(TimeToStr(Start) + " " + TimeToStr(OrderOpenTime()) + " " + OrderTicket());

if((OrderOpenTime() < fool || fool == 0))
{
fool = OrderOpenTime();
result = OrderOpenPrice();
}
}
}
}



NormalizeDouble(result,Digits);

return(result);

}
//|--------------------------------------------------------------------------------------+
double ContaLotti()
{
double result;

for(int i = OrdersHistoryTotal() -1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)result += OrderLots();
}



return(result);
}
//-------------------------------------------------------------------------------+
double LottiCorrenti()
{
double result;

for(int i = OrdersTotal() -1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
{
result += OrderLots();
}
}


return(result);
}

//|----------------------------------------------------------------------------------|//
int OpenedOrdersGrid(string Grid)
{

int result;

for(int i = OrdersTotal() -1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() <= OP_SELL)
{
if(Grid == "G1" && OrderComment() == "G1 - SuperGrid") result +=1;
if(Grid == "G2" && OrderComment() == "G2 - SuperGrid") result +=1;
if(Grid == "G3" && OrderComment() == "G3 - SuperGrid") result +=1;
}
}

//Print(result + " " + Grid + " " + OrderComment() + " " + OrderType());

return(result);
}
//-------------------------------------------------------------/
void CheckEquity()
{

if(CurrentStatus() <= PercentCloseLoss && CurrentStatus() < 0)
{
PanicClose();
if(Stampate) Print("Chiusura Panic per divergenza liquidità a " + CurrentStatus() + " " + AccBalance);
if(FixedBalance ==false) AccBalance = AccountBalance();
if(FixedBalance ==true) AccBalance = BalanceValue;
}


}
//---------------------------------------------------------------------------------//
double ManagementLotsG3(int Dir)
{
double result;

double MinLots, MaxLots, LotStep;

TP1 = 0;

MinLots = MarketInfo(Symbol(), MODE_MINLOT);

MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);

LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);


if(DebugMLots == true && SecondOpenPrice(1) == PrimeOpenPrice(1) && PrimeOpenPrice(1) != 0)if(Stampate) Print("ERRORE CONTROLLARE PRIME E SECOND PRICE * 1");

if(DebugMLots == true && SecondOpenPrice(-1) == PrimeOpenPrice(-1) && PrimeOpenPrice(-1) != 0)if(Stampate) Print("ERRORE CONTROLLARE PRIME E SECOND PRICE * -1");


if (PipsStartGrid)
{
TPN = ValuePipsStartGrid + ValuePipsStartGrid*DeltaPips/100;
Print(" * Calcolato TP3 = "+TPN);
TP1 = TPN;
}else

{
if( OpenedOrdersGrid("G1") + OpenedOrdersGrid("G2") >= 4 )
//Regressione
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{


if(Dir == 1)
{

if((bActivateEmergency == false || AcceptLossSpread == false) && TpDinamico == false )
{

if( EquazioneSpreadG3 )
{

TP1  = ( PipsDistance * ( LottiG1R() - LastLotG1() ) );

TP1 -= (( LottiG2R( 1)- LastLotG2( 0)) * PipsDistance );

TP1 += ( LottiG2R(1) - LastLotG2( 1)- LastLotG2( 0)+ LottiG2R(-1) + LottiG1R()  )* SpreadRatioG3 * Spread ;

TP1 /= ( LastLotG1() - LottiG2R(-1)  + LottiG2R(1) + LastLotG2( 1)- LastLotG2( 0) );
}
else
{
TP1 = ( PipsDistance * LottiG1R() );
TP1 -= ( LottiG2R(-1) * PipsDistance );
TP1 /= (ManagementLotsG1G2(-1) + LottiG2R(-1)  - LottiG2R(1) );
TP1 = StrToDouble( DoubleToStr(TP1,7));
}
}


if(bActivateEmergency == true && AcceptLossSpread == true)
{

TP1 = (PipsDistance * LottiG1R());

TP1 -= (LottiG2R(-1) * PipsDistance);

TP1 /= (ManagementLotsG1G2(-1) + LottiG2R(-1)  - LottiG2R(1));

TP1 = StrToDouble( DoubleToStr(TP1,7));
}

//Print("LottiG1: " + LottiG1R() + " LottiG2(-1): " + LottiG2R(-1) + " LottiG2(1): " + LottiG2R(1) +
}


if(Dir == -1)
{

if((bActivateEmergency == false || AcceptLossSpread == false) && TpDinamico == false)
{
if( EquazioneSpreadG3 )
{

TP1  = ( PipsDistance * ( LottiG1R() - LastLotG1() ) );
TP1 -= (( LottiG2R( -1)- LastLotG2( 1)) * PipsDistance );

TP1 += ( LottiG2R(-1)- LastLotG2(0) + LottiG2R(1)- LastLotG2( 1) + LottiG1R()  )* SpreadRatioG3 * Spread ;
TP1 /= ( LastLotG1() + ( LottiG2R(-1) - LastLotG2(1))  - ( LottiG2R(1) - LastLotG2( 0) ) );
}
else
{
TP1 = ( PipsDistance * LottiG1R() );

TP1 -= ( LottiG2R(1) * PipsDistance );

TP1 /= (ManagementLotsG1G2(1) + LottiG2R(1)  - LottiG2R(-1) );

TP1 = StrToDouble( DoubleToStr(TP1,7));
}
}




if(bActivateEmergency == true && AcceptLossSpread == true)
{
TP1 = (PipsDistance * LottiG1R());

TP1 -= (LottiG2R(-1) * PipsDistance);

TP1 /= (ManagementLotsG1G2(-1) + LottiG2R(-1)  - LottiG2R(1));

TP1 = StrToDouble( DoubleToStr(TP1,7));

}
}
}
//Avanzamento

if( OpenedOrdersGrid("G1") + OpenedOrdersGrid("G2") >= 4 )
if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{


if(Dir == 1)
{

if((bActivateEmergency == false || AcceptLossSpread == false) && TpDinamico == false)
{
if( EquazioneSpreadG3 )
{

TP1  = ( PipsDistance * ( LottiG1A() - LastLotG2(0) - LastLotG2(1) ) );

TP1 -= ( (LottiG2A(1) - LastLotG12( 1 ))* PipsDistance );

TP1 += ( LottiG2A(1) - LastLotG12( 1)- LastLotG12( 0)+ LottiG2A(-1) + LottiG1A()  )* SpreadRatioG3 * Spread ;

TP1 /= ( (LastLotG2(1) + LastLotG2(0)) + ( LottiG2A(1) - LastLotG12(1) ) - (LottiG2A(-1) - LastLotG12(0) ) );

}
else
{
TP1 = (PipsDistance * LottiG1A());

TP1 -= (LottiG2A(-1) * PipsDistance);

TP1 /= (ManagementLotsG1G2(-1) + LottiG2A(-1) - LottiG2A(1));

TP1 = StrToDouble( DoubleToStr(TP1,7));
}

}

if(bActivateEmergency == true && AcceptLossSpread == true)
{
TP1 = (PipsDistance * LottiG1R());

TP1 -= (LottiG2R(-1) * PipsDistance);

TP1 /= (ManagementLotsG1G2(-1) + LottiG2R(-1)  - LottiG2R(1));

TP1 = StrToDouble( DoubleToStr(TP1,7));
}
}

if(Dir == -1)
{

if((bActivateEmergency == false || AcceptLossSpread == false) && TpDinamico == false)
{
if( EquazioneSpreadG3 )
{

TP1  = ( PipsDistance * ( LottiG1A() - (LastLotG2(1) + LastLotG2(0)) ) );
TP1 -= ( (LottiG2A(-1) - LastLotG12( 1))* PipsDistance );

TP1 += ( LottiG2A(-1) - LastLotG12( 1)- LastLotG12( 0)+ LottiG2A(1) + LottiG1A()  )* SpreadRatioG3 * Spread ;

TP1 /= ( (LastLotG2(1) + LastLotG2(0)) - ( LottiG2A(-1) - LastLotG12( 0) ) + (LottiG2A(1) - LastLotG12( 1) ) );

}
else
{
TP1 = (PipsDistance * LottiG1A());

TP1 -= (LottiG2A(1) * PipsDistance);

if( EquazioneSpreadG3 )
TP1 += ( LottiG2A(-1) + LottiG2A(1) + LottiG1A() )* SpreadRatioG3 * Spread ;

TP1 /= (ManagementLotsG1G2(1) + LottiG2A(1) - LottiG2A(-1));

TP1 = StrToDouble( DoubleToStr(TP1,7));
}
}

if(bActivateEmergency == true && AcceptLossSpread == true)
{
TP1 = (PipsDistance * LottiG1R());

TP1 -= (LottiG2R(-1) * PipsDistance);

TP1 /= (ManagementLotsG1G2(-1) + LottiG2R(-1)  - LottiG2R(1));

TP1 = StrToDouble( DoubleToStr(TP1,7));
}
}

}

}


//Calcolo G3

if(EquazioneSpreadG3 == false)
{
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
Print(" **** GATTO GATTO "+ TP1);
if( LottiG3() > 0 && (DeltaPips + TP1 != 0) || ( Mode == 1 && LastCloseG3()&& (DeltaPips + TP1 != 0) ) )
result = ((PipsDistance * LottiG3()) / (DeltaPips + TP1));

if( LottiG3() == 0 && (DeltaPips + TP1 == 0)  || ( Mode == 1 && LastCloseG3()&& (DeltaPips + TP1 != 0) ) )
{
if (DeltaPips + TP1 == 0)
if(Stampate) Print("Attenzione divisione per zero: Deltapips+Tp1 = 0 pertanto G3 ricomincia i lotti.");
result = ( LostFirstOrderG3 / TP1 );
if(Stampate) Print(" Aperto primo ordine G3: LostFirstOrderG3: " + LostFirstOrderG3 + " PipsTake: " + PipsTake);

}
}

//Avanzamento

if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if( LottiG3() > 0 && (DeltaPips + TP1) != 0 || ( Mode == 1 && LastCloseG3() ) )

result = ((PipsDistance * LottiG3()) / (DeltaPips + TP1));


if( LottiG3() == 0 && (DeltaPips + TP1) == 0 || ( Mode == 1 && LastCloseG3() ) )
{
if (DeltaPips + TP1 == 0)
if(Stampate) Print("Attenzione divisione per zero: Deltapips+Tp1 = 0 pertanto G3 ricomincia i lotti.");

result = (LostFirstOrderG3 / TP1);

if(Stampate) Print("Aperto primo ordine G3: LostFirstOrderG3: " + LostFirstOrderG3 + " PipsTake: "+ PipsTake);

}
}

if(TpDinamico == false)if(Stampate) Print(" * Calcolato TP3: " + TP1);
}

//Calcolo G3
if(EquazioneSpreadG3 == true)
{
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
if( LottiG3() > 0 || ( Mode == 1 && LastCloseG3() ) )
result = (  LottiG3() * ( PipsDistance - SpreadRatioG3 * Spread ) / (DeltaPips +TP1 + SpreadRatioG3 * Spread ) );


if(TpDinamico == false)if(Stampate) Print(" * Calcolato TP3: " + TP1);

if( LottiG3() == 0 || ( Mode == 1 && LastCloseG3() ) )
{
result = LostFirstOrderG3 / ( TP1 + ( SpreadRatioG3 * Spread ) );
if(Stampate) Print("********* LostFirstOrderG3 = " + LostFirstOrderG3 +" pipstake " +PipsTake );
if(Stampate) Print("Aperto primo ordine G3: LostFirstOrderG3: " + LostFirstOrderG3 + " PipsTake: " + PipsTake + " SpreadRagioG3: " + SpreadRatioG3 + " Spread: " + Spread);
}
}

//Avanzamento

if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if( LottiG3() > 0 || ( Mode == 1 && LastCloseG3() ) )
result = (  LottiG3() * ( PipsDistance - SpreadRatioG3 * Spread ) / (DeltaPips +TP1 + SpreadRatioG3 * Spread ) );


if(TpDinamico == false)if(Stampate) Print(" * Calcolato TP3: " + TP1);

if( LottiG3() == 0 || ( Mode == 1 && LastCloseG3() ) )
{
result = LostFirstOrderG3 / (TP1 + (SpreadRatioG3 * Spread));
if(Stampate) Print("********* LostFirstOrderG3 = " + LostFirstOrderG3 +" pipstake " +PipsTake );

if(Stampate) Print("Aperto primo ordine G3: LostFirstOrderG3: " + LostFirstOrderG3 + " PipsTake: " + PipsTake + " SpreadRagioG3: " + SpreadRatioG3 + " Spread: " + Spread);
}
}
}

result = NormalizeDouble (StrToDouble( StringSubstr( DoubleToStr(result,4),0,7 ) ), 2) ;

if(result > MaxLots) result = MaxLots;

if(result < MinLots)
{
if(Stampate) Print("* ATTENZIONE EQUAZIONE NEGATIVA O ZERO PER G3, risultato prima di sostituirlo con il lotto minimo: " + result);
result = MinLots;
}

return(result);
}
//--------------------------------------------------------------------------/
double LottiG3()
{
double result;

datetime Start;

if( Mode == 1 )
Start = G3Reset;
else
{
for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G3 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}


for(i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G3 - SuperGrid" && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}


return(result);
}
//----------------------------------------------------------//
void ExecuteStop()
{


if(OpenedOrders(0,MagicNumber) > 2)
{
if(bActivateEmergency == false)
{

if(Mode == 1)
{

for(int j = 0; j < NumMaxGrid; j++)
{
if ( ( PipsTake < TP1 || PipsTake < TPar[j] ) && !A )
ChiusuraRGB();
else
ChiusuraRGA();

}

}

if( Mode == 0 || ( Mode == 1 && TpDinamico == false && TP() == PipsTake ))
{
if((NormalizeDouble(Bid,Digits) >= PriceStop(1)) || (NormalizeDouble(Ask,Digits) <= PriceStop(-1)))
{
if(Stampate) Print("* *Normal Equity* MODE " +Mode+" TP: " + TP() + " Eseguito PanicClose, livello raggiunto up: " + NormalizeDouble(Bid,Digits) + " livello raggiunto down: " + NormalizeDouble(Ask,Digits) + " chiusura a: " + SaldoPipsEmergency() + " datetime: " + TimeToStr(iTime(Symbol(),PERIOD_M1,0)) +"*");
PanicClose();
}
}
/*

if( Mode == 1 && G3 == true )
{
if( (NormalizeDouble(Bid,Digits) <= PriceStop(1) || NormalizeDouble(Ask,Digits) >= PriceStop(-1)) && TP() < PipsTake )
{
PanicCloseG3();
if(Stampate) Print("* *Normal Equity* MODE 1 TP: Eseguito PanicClose, livello raggiunto up: " + NormalizeDouble(Bid,Digits) + " livello raggiunto down: " + NormalizeDouble(Ask,Digits) + " chiusura a: " + SaldoPipsEmergency() + " datetime: " + TimeToStr(iTime(Symbol(),PERIOD_M1,0)) +"*");
if(Stampate) Print("* Chiusura solo G3; TP() < PipsTake * ");
TP1 = 0;
}

if( NormalizeDouble(Bid,Digits) >= PriceStop(1) || NormalizeDouble(Ask,Digits) <= PriceStop(-1) )
{
if( TP() > PipsTake && A )
{
PanicClose();
if(Stampate) Print("* *Normal Equity* MODE 1 TP: " + TP() + " Eseguito PanicClose, livello raggiunto up: " + NormalizeDouble(Bid,Digits) + " livello raggiunto down: " + NormalizeDouble(Ask,Digits) + " chiusura a: " + SaldoPipsEmergency() + " datetime: " + TimeToStr(iTime(Symbol(),PERIOD_M1,0)) +"*");
if(Stampate) Print("* ...e anche G1G2: !!!! TP > PipsTake !!!! * ");
TP1 = 0;
}

if( OpenedOrdersGrid("G3") > 0 || (TP() > PipsTake && !A) )
{
if(Stampate) Print("* *Normal Equity* MODE 1 TP: " + TP() + " Eseguito PanicClose, livello raggiunto up: " + NormalizeDouble(Bid,Digits) + " livello raggiunto down: " + NormalizeDouble(Ask,Digits) + " chiusura a: " + SaldoPipsEmergency() + " datetime: " + TimeToStr(iTime(Symbol(),PERIOD_M1,0)) +"*");
if(Stampate) Print("* Chiusura solo G3 *");
PanicCloseG3();
TP1 = 0;
}
}
if ( !A  && (NormalizeDouble(Bid,Digits) <= PriceStopPipsTake(1) || NormalizeDouble(Ask,Digits) >= PriceStopPipsTake(-1)) )
{
PanicCloseG1G2();
Print("* *Normal Equity* MODE 1 TP: " + TP() + " Eseguito PanicClose su g1 e g2, ritracciamento dopo la chiusura di g3: " + NormalizeDouble(Bid,Digits) + " livello raggiunto down: " + NormalizeDouble(Ask,Digits) + " chiusura a: " + SaldoPipsEmergency() + " datetime: " + TimeToStr(iTime(Symbol(),PERIOD_M1,0)) +"*");
}
if( !A && (OpenedOrdersGrid("G1") + OpenedOrdersGrid("G2")) == 0 && (NormalizeDouble(Bid,Digits) <= PriceForG3(1) || NormalizeDouble(Ask,Digits) >= PriceForG3(-1)) )
{
if(Stampate) Print("* *Normal Equity* MODE 1 TP: " + TP() + " Eseguito PanicClose, livello raggiunto up: " + NormalizeDouble(Bid,Digits) + " livello raggiunto down: " + NormalizeDouble(Ask,Digits) + " chiusura a: " + SaldoPipsEmergency() + " datetime: " + TimeToStr(iTime(Symbol(),PERIOD_M1,0)) +"*");
if(Stampate) Print("* Chiusura solo G3 *");
PanicCloseG3();
TP1 = 0;
}

}
*/

}



if(bActivateEmergency == true && EmergencyEquity == true && (NormalizeDouble(Bid,Digits) >= PriceStop(1) || NormalizeDouble(Ask,Digits) <= PriceStop(-1)))
{
if(Stampate) Print("* *EMERGENCY EQUITY* Eseguito PanicClose, livello raggiunto up: " + NormalizeDouble(Bid,Digits) + " livello raggiunto down: " + NormalizeDouble(Ask,Digits) + " chiusura a: " + SaldoPipsEmergency() + " datetime: " + TimeToStr(iTime(Symbol(),PERIOD_M1,0)) +"*");
PanicClose();
}
}

}
//--------------------------------------------------------------------
bool IsHolidayTime (datetime Date)
{
bool result;
int DateDay = TimeDay(Date);
int DateMonth = TimeMonth(Date);
int i=0;


while (holydaysdays[i] != 0)
{
if ((DateDay==holydaysdays[i]) && (DateMonth==holydaysmonths[i]))
{
result = true;
}
i++;
}

/*
datetime NextTradingDay;
int DateDayOfWeek = TimeDayOfWeek(Date);

if (DateDayOfWeek == 5)
NextTradingDay = Date + 3*60*60*24;
else if (DateDayOfWeek>=0 && DateDayOfWeek<5)
NextTradingDay = Date + 1*60*60*24;

int NextDateDay = TimeDay(NextTradingDay);
int NextDateMonth = TimeMonth(NextTradingDay);
i=0;

while (holydaysdays[i] != 0)
{
if ((NextDateDay==holydaysdays[i]) && (NextDateMonth==holydaysmonths[i]))
return (true);

i++;
}
*/

return(result);
}
//--------------------------------------------------------------------//
bool StopConditions(datetime HNow)
{
bool result;


if(Stop == true) result = true;

if(bTimeRange == true)
{
if((HNow < Start) || (HNow >= End))
{
result = true;
}
}

//Print(End + " " + TimeHour(iTime(Symbol(),PERIOD_M1,0)));


if(StopFriday == true && TimeDayOfWeek(iTime(Symbol(),PERIOD_M1,0)) == 5 && (TimeHour(iTime(Symbol(),PERIOD_M1,0)) >= StopFridayHour)) result = true;

if(result == true)
{
PanicClosePendenti(1);
PanicClosePendenti(-1);
}

if(IsHolidayTime(iTime(Symbol(),PERIOD_M1,0)) == true)result = true;



return(result);
}
//---------------------------------------------------------------------------------------------------//
void ExecuteControlOpenGap()
{

if(TimeDayOfWeek(iTime(Symbol(),PERIOD_M1,0)) == DayOpen && TimeHour(iTime(Symbol(),PERIOD_M1,0)) == HourOpen && TimeMinute(iTime(Symbol(),PERIOD_M1,0)) == 0)
{
if(SaldoPipsEmergency() <= 0)
{
PanicClose();
}
}

}
//----------------------------------------------------------------------------------------//
double TP()
{
double result;

double fool;


//Subuito devo calcolare il TP1 per non interferire nella chiusura TP1 + DeltaPips. Il calcolo del TP1 all'interno di TP() è anomalo
//Dovrebbe calcolarsi all'interno di ManagementLotsG3 ma siccome è "nel mezzo" alle procedure di inversioni di griglia
//(e ci deve restare poichè è ancorato ad altre funzioni) allora l'ho dovuto mettere qui dentro

if(tempTP1 != TP1 && TpDinamico == true && G3 == true && (OpenedOrdersGrid("G2") > 2 || OpenedOrdersGrid("G1") > 2)  && OpenedOrders(2,MagicNumber) == 0 && OpenedOrders(3,MagicNumber) == 0)
{
//Regressione
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
fool = PipsDistance * (LottiG1R()-OpenedLottiG1R()- LottiG2R(1));

//Print("1 - DEBUG TP1: " + (PipsDistance * (LottiG1R()-OpenedLottiG1R()- LottiG2R(1))));

fool += Spread * SpreadRatio * (LottiG1R() + LottiG2R(1) + LottiG2R(-1));

//Print("2 - DEBUG TP1: " + fool + " + " + (Spread * SpreadRatio * (LottiG1R() + LottiG2R(1) + LottiG2R(-1))));

//Print("3 - DEBUG TP1: " + fool + " / " + ((OpenedLottiG1R() -LottiG2R(-1) + LottiG2R(1))));

fool /=  (OpenedLottiG1R() -LottiG2R(-1) + LottiG2R(1));
}

//Avanzamento
if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
fool = PipsDistance * (LottiG1A()-OpenedLottiG1A() - LottiG2A(-1));

//Print("1 - DEBUG TP1: " + (PipsDistance * (LottiG1A()-OpenedLottiG1A()- LottiG2A(-1))));

fool += Spread * SpreadRatio * (LottiG1A() + LottiG2A(1) + LottiG2A(-1));

//Print("2 - DEBUG TP1: "  + fool + " + " +  (Spread * SpreadRatio * (LottiG1A() + LottiG2A(1) + LottiG2A(-1))));

//Print("3 - DEBUG TP1: " + fool + " / " + ((OpenedLottiG1A()-LottiG2A(1) + LottiG2A(-1))));

fool /= (OpenedLottiG1A()-LottiG2A(1) + LottiG2A(-1));
}

if(fool  == 0)
{

//if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD) && (SecondOpenPrice(-1) < PrimeOpenPrice(-1)))
if(SecondOpenPrice(-1) < PrimeOpenPrice(-1) && SecondOpenPrice(1) == 0)
{
fool = PipsDistance * (LottiG1R()-OpenedLottiG1R()- LottiG2R(1));

//Print("1 - DEBUG TP1: " + (PipsDistance * (LottiG1R()-OpenedLottiG1R()- LottiG2R(1))));

fool += Spread * SpreadRatio * (LottiG1R() + LottiG2R(1) + LottiG2R(-1));

//Print("2 - DEBUG TP1: "  + fool + " + " +  (Spread * SpreadRatio * (LottiG1R() + LottiG2R(1) + LottiG2R(-1))));

//Print("3 - DEBUG TP1: " + fool + " / " + ((OpenedLottiG1R() -LottiG2R(-1) + LottiG2R(1))));

fool /=  (OpenedLottiG1R() -LottiG2R(-1) + LottiG2R(1));
}

//if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD))&& NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)))
if(SecondOpenPrice(1) > PrimeOpenPrice(1) && SecondOpenPrice(-1) == 0)
{
fool = PipsDistance * (LottiG1A()-OpenedLottiG1A() - LottiG2A(-1));

//Print("1 - DEBUG TP1: " + (PipsDistance * (LottiG1A()-OpenedLottiG1A()- LottiG2A(-1))));

fool += Spread * SpreadRatio * (LottiG1A() + LottiG2A(1) + LottiG2A(-1));

//Print("2 - DEBUG TP1: "  + fool + " + " +  (Spread * SpreadRatio * (LottiG1A() + LottiG2A(1) + LottiG2A(-1))));

//Print("3 - DEBUG TP1: " + fool + " / " + ((OpenedLottiG1A()-LottiG2A(1) + LottiG2A(-1))));

fool /= (OpenedLottiG1A()-LottiG2A(1) + LottiG2A(-1));
}
}
if(fool == 0)if(Stampate) Print("* *ALERT!! result = 0 - chiusura anticipata*");


TP1 = StrToDouble( DoubleToStr(TP1,7));

tempTP1 = TP1;

Print(" * TP(): TP1 Calcolato: " + TP1 + " *");
}


if( bActivateEmergency == false || EmergencyEquity == false )
{
if(TP1 != 0)
{
result = TP1;

result += (TP1 / 100) * DeltaPips;
}

if(TP1 == 0) result = PipsTake;

//if(TP1 < 0)if(Stampate) Print(" * TP(): Registrato TP1 < 0 * ");

//if(result < 0 && (DeltaPips < TP1 || DeltaPips > TP1))if(Stampate) Print(" * TP(): Registrato DeltaPips < TP1 * ");
}

if(TpDinamico == true && Mode == 0 && G3 == false && (OpenedOrdersGrid("G2") > 1 || OpenedOrdersGrid("G1") > 1) && OpenedOrders(2,MagicNumber) == 0 && OpenedOrders(3,MagicNumber) == 0)
{
//Regressione
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
result = PipsDistance * (LottiG1R()-OpenedLottiG1R()- LottiG2R(1));

result += Spread * SpreadRatio * (LottiG1R() + LottiG2R(1) + LottiG2R(-1));

result += Variabile;

result /=  (OpenedLottiG1R() -LottiG2R(-1) + LottiG2R(1));
}

if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
result = PipsDistance * (LottiG1A()-OpenedLottiG1A() - LottiG2A(-1));

result += Spread * SpreadRatio * (LottiG1A() + LottiG2A(1) + LottiG2A(-1));

result += Variabile;

result /= (OpenedLottiG1A()-LottiG2A(1) + LottiG2A(-1));
}

if(result == 0)
{

//if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD) && (SecondOpenPrice(-1) < PrimeOpenPrice(-1)))
if(SecondOpenPrice(-1) < PrimeOpenPrice(-1) && SecondOpenPrice(1) == 0)
{
result = PipsDistance * (LottiG1R()-OpenedLottiG1R()- LottiG2R(1));

result += Spread * SpreadRatio * (LottiG1R() + LottiG2R(1) + LottiG2R(-1));

result += Variabile;

result /=  (OpenedLottiG1R() -LottiG2R(-1) + LottiG2R(1));
}

//if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD))&& NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)))
if(SecondOpenPrice(1) > PrimeOpenPrice(1) && SecondOpenPrice(-1) == 0)
{
result = PipsDistance * (LottiG1A()-OpenedLottiG1A() - LottiG2A(-1));

result += Spread * SpreadRatio * (LottiG1A() + LottiG2A(1) + LottiG2A(-1));

result += Variabile;

result /= (OpenedLottiG1A()-LottiG2A(1) + LottiG2A(-1));
}

/*
if(Stampate) Print(PrimeOpenPrice(1));
if(Stampate) Print(PrimeOpenPrice(-1));
if(Stampate) Print(SecondOpenPrice(1));
if(Stampate) Print(SecondOpenPrice(-1));
if(Stampate) Print(Bid);
if(Stampate) Print(Ask);
if(Stampate) Print(PipsD);
*/
}
if(result == 0)if(Stampate) Print("* *ALERT!! result = 0 - chiusura anticipata*");

if(result < 0)
{
if(Stampate) Print("* *ALERT!! result < 0 - chiusura anticipata*");
if(Stampate) Print(PrimeOpenPrice(1));
if(Stampate) Print(PrimeOpenPrice(-1));
if(Stampate) Print(SecondOpenPrice(1));
if(Stampate) Print(SecondOpenPrice(-1));
if(Stampate) Print(Bid);
if(Stampate) Print(Ask);
if(Stampate) Print(PipsD);
}

}




//Print(((LotsIncrement * (OpenedOrdersGrid("G1") -1) + LottoBase)));

if( bActivateEmergency == true && EmergencyEquity == true )
{
if(ModeEmergencyEquity == 0 && TP1 != 0)
{
if(TP1 != 0)
{
result = TP1;

result += (TP1 / 100) * DeltaPips;
}
if(TP1 == 0) result = PipsTake;

// if(TP1 < 0)if(Stampate) Print(" * TP(): Registrato TP1 < 0 * ");

//  if(result < 0 && (DeltaPips < TP1 || DeltaPips > TP1))if(Stampate) Print(" * TP(): Registrato DeltaPips < TP1 * ");
}
/*

CONTROLLI FUTURI PER IL TP2   RIVEDERE SU TP1 PRIMA DI APPLICARE
if(ModeEmergencyEquity == 3)
{
if(TP2 != 0)
{
result = TP2 + DeltaPips;

if(TrasformateNegInPos == true)if(result < 0) result *= -1;
}

if(TP2 == 0)result = TP1;

}
*/
}

//result = NormalizeDouble(result,Digits);
//Utilizzare TP piu preciso possibile

if(result != TPPrint)
{
if(Stampate) Print(" * Storia del TP numero " + counter + " " + TimeToStr(iTime(Symbol(),PERIOD_M1,0)) + " : " + result + " * ");
counter += 1;
TPPrint = result;
}

//if( result < 0 )if(Stampate) Print(" * TP(): Registrato TP Negativo * "); // possibile conflitto con LastCloseG3()


return(result);
}
//----------------------------------------------------------------------------------------//
void SeekAndDestroyG3()
{
int Ticket;


for(int i = OrdersTotal() -1; i >= 0; i --)
{
OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G3 - SuperGrid")
{
Ticket = OrderTicket();
break;
}
}

if(Ticket > 0)
{
OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES);

if(OrderType() == OP_BUY) while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits), 3, Green);

if(OrderType() == OP_SELL) while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits), 3, Green);

Esito = false;
}

}
//-------------------------------------------------------------------------------+

double CurrentStatus()
{
double result;

result = (((AccountEquity() - AccBalance) / AccBalance) * 100);

return(result);
}
//-------------------------------------------------------------------------------+
double SaldoPipsEmergency()
{

double result;
double Pips;
double Lotti;
datetime Start;

if(OpenedOrders(0, MagicNumber) > 0)
{
for (int y = OrdersTotal() -1; y >= 0; y --)
{
OrderSelect(y,SELECT_BY_POS,MODE_TRADES);

if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType() <= OP_SELL)
{
if(OrderType() == OP_BUY)
{
Pips = (NormalizeDouble(Bid,Digits) - OrderOpenPrice())/Poin;

Lotti = OrderLots();

result += (Pips + (Lotti / LottoBase));

//Print(Pips + (Lotti / LottoBase));

//result -= Spread;
}
if(OrderType() == OP_SELL)
{
Pips = (OrderOpenPrice() - NormalizeDouble(Ask,Digits))/Poin;

Lotti = OrderLots();

result += (Pips + (Lotti / LottoBase));

//Print(Pips + (Lotti / LottoBase));
}
}
}
}

for(int i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}

for(i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

//Print(OrderSymbol() + " " + OrderMagicNumber() + " " + OrderType() + " " + OrderComment());

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() > Start)Start = OrderCloseTime();
//Print("Gatto");
}
}

//Print(TimeToStr(Start));

if(OpenedOrders(0, MagicNumber) > 0)
{
for (i=OrdersHistoryTotal() -1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderOpenTime() >= Start && OrderType() <= OP_SELL)
{
if(OrderType() == OP_BUY)
{
Pips = (OrderClosePrice() - OrderOpenPrice())/Poin;

Lotti = OrderLots();

result += (Pips + (Lotti / LottoBase));
}
if(OrderType() == OP_SELL)
{
Pips = (OrderOpenPrice() - OrderClosePrice())/Poin;

Lotti = OrderLots();

result += (Pips + (Lotti / LottoBase));
}
}
}
}

//result *= MarketInfo(Symbol(),MODE_TICKVALUE);
result *= LottoBase;

return(result);
}
//---------------------------------------------------------------+
void ActivateEmergencySettings()
{

// Prima le salvo

TempVariabile = Variabile;

TempDeltaPips = DeltaPips;


// E poi le assegno


Variabile = VariabileAlert;

DeltaPips = DeltaPipsAlert;


if(EqSpreadOff == true)
{
EquazionespreadG1G2 = false;

EquazioneSpreadG3 = false;
}

if(AlertEquityG3 == true)G3 = true;

bActivateEmergency = true;
}
//---------------------------------------------------------------+
void ExecuteEmergencyEquity()
{

if(CurrentStatus() <= AlertEquity && CurrentStatus() < 0) ActivateEmergencySettings();

}
//---------------------------------------------------------------+
void RestoreSettings()
{

Variabile = TempVariabile;

DeltaPips = TempDeltaPips;


if(EqSpreadOff == true)
{
EquazionespreadG1G2 = true;

EquazioneSpreadG3 = true;
}

TP2 = 0;

if(AlertEquityG3 == true) G3 = false;

bActivateEmergency = false;
}
//----------------------------------------------------------------+
double TP2(int Dir)
{
double result;

bool DebugLotti = false;

if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
if(Dir == 1)
{
result = (PipsDistance * LottiG1R());

result -= (LottiG2R(-1) * PipsDistance);

result -= (LottiG3() * PipsDistance);

result /= (ManagementLotsG1G2(-1) + LottiG2R(-1) - LottiG2R(1) - ManagementLotsG3(1));

if(DebugLotti == true)if(Stampate) Print("Posizione 1 calcoli TP2: " + LottiG1R() + " " + LottiG2R(-1) + " " + LottiG3() + " " + ManagementLotsG3(1) + " " + ManagementLotsG1G2(-1));
}

if(Dir == -1)
{
result = (PipsDistance * LottiG1R());

result -= (LottiG2R(1) * PipsDistance);

result -= (LottiG3() * PipsDistance);

result /= (ManagementLotsG1G2(1) + LottiG2R(1) - LottiG2R(-1) - ManagementLotsG3(-1));

if(DebugLotti == true)if(Stampate) Print("2 " + LottiG1R() + " " + LottiG2R(-1) + " " + LottiG3() + " " + ManagementLotsG3(-1) + " " + ManagementLotsG1G2(1));
}
}

//Avanzamento
if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if(Dir == 1)
{
result = (PipsDistance * LottiG1A());

result -= (LottiG2A(-1) * PipsDistance);

result -= (LottiG3() * PipsDistance);

result /= (ManagementLotsG1G2(-1) + LottiG2A(-1) - LottiG2A(1) - ManagementLotsG3(1));

if(DebugLotti == true)if(Stampate) Print("Posizione 3 calcoli TP2: " +LottiG1A() + " " + LottiG2A(-1) + " " + LottiG3() + " " + ManagementLotsG3(1) + " " + ManagementLotsG1G2(-1));
}

if(Dir == -1)
{
result = (PipsDistance * LottiG1R());

result -= (LottiG2A(1) * PipsDistance);

result -= (LottiG3() * PipsDistance);

result /= (ManagementLotsG1G2(1) + LottiG2A(1) - LottiG2A(-1) - ManagementLotsG3(-1));

if(DebugLotti == true)if(Stampate) Print("Posizione 4 calcoli TP2: " +LottiG1A() + " " + LottiG2A(-1) + " " + LottiG3() + " " + ManagementLotsG3(1) + " " + ManagementLotsG1G2(-1));
}
}

result = NormalizeDouble(result,2);

Print("*TP2 calcolato secondo la funzione di intervento: * " + result);

return(result);
}
//-------------------------------------------------------------------------------+
void ExecuteEnoughProfit()
{

if( AccountEquity() - AccoEquity >= Profit * MarketInfo( Symbol( ), MODE_TICKVALUE ) )
{
PanicClose();
if(Stampate) Print("* Eseguito PanicClose in valuta (saldo op. aperte e chiuse della serie G1+G2+G3). datetime: " + TimeToStr(iTime(Symbol(),PERIOD_M1,0)) +"*");
}
}
//---------------------------------------------------------------+
double PriceStop(int Dir)
{
double result;

//Oltre alla Dir devo definire se sono in Avanzamento oppure in Regressione e regolarmi di conseguenza

if((SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
if(Dir == 1) result = (PrimeOpenPrice(-1)  + ((TP() * Poin)));
if(Dir == -1) result = (SecondOpenPrice(-1) - ((TP() * Poin)));
}

if((SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if(Dir == 1) result = (SecondOpenPrice(1)  + ((TP() * Poin)));
if(Dir == -1) result = (PrimeOpenPrice(1) - ((TP() * Poin)));
}

result = NormalizeDouble(result,Digits);

return(result);
}

//---------------------------------------------------------------+
void Draw()
{

if(OpenedOrders(0,MagicNumber) > 2)
{
if(ObjectGet("STOPUP",OBJPROP_PRICE1) != PriceStop(1))
{
ObjectDelete("STOPUP");
ObjectCreate("STOPUP",OBJ_HLINE,0,iTime(Symbol(),PERIOD_M1,0),PriceStopPipsTake(1));
ObjectSet("STOPUP",OBJPROP_COLOR,StopUpColor);
}


if(ObjectGet("STOPDOWN",OBJPROP_PRICE1) != PriceStop(-1))
{
ObjectDelete("STOPDOWN");
ObjectCreate("STOPDOWN",OBJ_HLINE,0,iTime(Symbol(),PERIOD_M1,0),PriceStopPipsTake(-1));
ObjectSet("STOPDOWN",OBJPROP_COLOR,StopDownColor);
}
}

}
//|----------------------------------------------------------------------------------|//

bool LastCloseG3() // ritorna true se g3 si è chiuso internamente e false se esternamente
{
datetime last;
int ticket;

datetime Start = G3Reset;

for(int i = OrdersHistoryTotal()-1; i >= 0; i--)
{
OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );

if( OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G3 - SuperGrid" )
{
if( OrderCloseTime() > last && OrderOpenTime() >= Start)
{
ticket = OrderTicket();
last = OrderCloseTime();
}
}
}
if( ticket > 0)
{

OrderSelect( ticket, SELECT_BY_TICKET, MODE_HISTORY );

if(
( OrderClosePrice() >= PriceForG3(-1) - ( ( Spread ) * Poin )   && OrderClosePrice() <= PriceForG3(1) + ( ( Spread )*Poin)  ) ||
( OrderClosePrice() <= PriceForG3(1) + ( ( Spread ) * Poin )  && OrderClosePrice() >= PriceForG3(-1) - ( ( Spread ) * Poin ) )
)
{
return ( true );

if ( TP1 + DeltaPips <= ( Spread + 1 )) Alert(" * ALERT: controllare LastCloseG3() per lotto anomalo * ");
}
else
{
return ( false );
}

}

if( TpDinamico == false && ticket == 0 && TP1 != 0) return ( true );
if( ticket == 0 ) return ( false );

}
//-----------------------------------------------------------------------//
double PriceForG3(int Dir)
{
double result;

//Oltre alla Dir devo definire se sono in Avanzamento oppure in Regressione e regolarmi di conseguenza

if((SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
if(Dir == 1) result = PrimeOpenPrice(-1);
if(Dir == -1) result = SecondOpenPrice(-1);
}

if((SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if(Dir == 1) result = SecondOpenPrice(1);
if(Dir == -1) result = PrimeOpenPrice(1);
}

result = NormalizeDouble(result,Digits);

return(result);
}
//---------------------------------------------------------------+
double PriceStopPipsTake(int Dir)
{
double result;

//Oltre alla Dir devo definire se sono in Avanzamento oppure in Regressione e regolarmi di conseguenza
// if( (OrderClosePrice() > PriceForG3(1)   && OrderClosePrice() <= PriceForG3(1) + Spread) || (  (OrderClosePrice() < PriceForG3(-1)   && OrderClosePrice() >= PriceForG3(-1) - Spread)
if((SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
if(Dir == 1) result = (PrimeOpenPrice(-1)  + ((PipsTake * Poin)));
if(Dir == -1) result = (SecondOpenPrice(-1) - ((PipsTake * Poin)));
}

if((SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if(Dir == 1) result = (SecondOpenPrice(1)  + ((PipsTake * Poin)));
if(Dir == -1) result = (PrimeOpenPrice(1) - ((PipsTake * Poin)));
}

result = NormalizeDouble(result,Digits);

return(result);
}
//--------------------------------------------------------------------------/
double LastLotG1() // ritorna l'ultimo lotto di g1 della sessione
{
double result;
datetime Start;

for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(( OrderType() == OP_BUY || OrderType() == OP_SELL ) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderOpenTime() >= Start)
{
Start = OrderOpenTime();
result = OrderLots();
}
}

return (result);
}
//--------------------------------------------------------------------------/

double LastLotG2( int Dir ) // ritorna l'ultimo lotto di g1 della sessione
{
double result;
datetime Start;
int LastType;
int Ticket;

for( int i = OrdersTotal()-1; i >= 0; i -- )
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
if( OrderOpenTime() >= Start && OrderMagicNumber() == MagicNumber && OrderComment() == "G2 - SuperGrid" && OrderSymbol() == Symbol() )
{
Start = OrderOpenTime();
Ticket = OrderTicket();
}
}

OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES);
if( OrderType() == Dir )
result = OrderLots();

return (result);
}
//--------------------------------------------------------------------------/
double LastLotG12( int Dir ) // ritorna l'ultimo lotto di g1 della sessione
{
double result;
datetime Start;
int LastType;
int Ticket;

for( int i = OrdersTotal()-1; i >= 0; i -- )
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
if( OrderOpenTime() >= Start && OrderMagicNumber() == MagicNumber && OrderComment() == "G1 - SuperGrid" && OrderSymbol() == Symbol() )
{
Start = OrderOpenTime();
Ticket = OrderTicket();
}
}

OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES);
if( OrderType() == Dir )
result = OrderLots();

return (result);
}
//--------------------------------------------------------------------------/


void OpenGridOrders( int GridNum, int Dir )
{
if( GridNum == NumMaxGrid - 1)
return;
ActualGrid = "G"+ (4+GridNum) + " - SuperGrid";
string NameGrid ="G"+(4+GridNum);
//------------------- Custom execute ----------------------------
//------------------- starndard execute -------------------------
if( ( GridNum + 1 ) < SessNumOrderGrid("G3") )
{
Ticket = 0;
if (PipsStartGrid)
{
TPN = ValuePipsStartGrid + (GridNum + 1)*ValuePipsStartGrid*DeltaPips/100 + (GridNum + 1)*DeltaPipsGrid*ValuePipsStartGrid/100;
Print(" * Calcolato TP"+(GridNum+4)+" = "+TPN);
TPar[ GridNum - 1] = TPN;
}
else
{
TPN = TP1 + TP1*DeltaPips/100 + (GridNum + 1)*DeltaPipsGrid*TP1/100;
Print(" * Calcolato TP"+(GridNum+4)+" = "+TPN);
TPar[ GridNum - 1] = TPN;
}
double Lots =NormalizeDouble( ManagementLotsGN(),2);
if (Lots <= 0){ Lots = 0.01;
Print(" * Lotti di "+ActualGrid+" con valore zero o negativo. Setto a 0.01");
}

if(Dir == -1)
int tipoordine = OP_SELL;else
tipoordine = OP_BUY;

while( Ticket <= 0){
if(tipoordine == OP_BUY)
{   Print(" * Apertura ordine Buy per "+NameGrid+" al prezzo "+Ask+" - lotto da "+ Lots);
Ticket = OrderSend( Symbol(), tipoordine ,NormalizeDouble ( Lots,2), NormalizeDouble(Ask,Digits),3,0,0, ActualGrid,MagicNumber,Silver );
}
if(tipoordine == OP_SELL) {
Print(" * Apertura ordine Sell per "+NameGrid+" al prezzo "+Bid+" - lotto da "+ Lots);
Ticket = OrderSend( Symbol(), tipoordine ,NormalizeDouble ( Lots,2), NormalizeDouble(Bid,Digits),3,0,0, ActualGrid,MagicNumber,Silver );
}
}
}
//---------------------------------------------------------------

GridNum++;
OpenGridOrders( GridNum, Dir );
return;
}

//--------------------------------------------------------------------------/

double LottiGN( )
{
double result;

datetime Start;

if( Mode == 1 )
Start = StartAr[ ( StrToInteger(StringSubstr( ActualGrid, 1, 1 )) - 4 ) ];
else
{
for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == ActualGrid && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}


for(i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == ActualGrid && OrderOpenTime() >= Start)
{
result += OrderLots();
}
}


return(result);
}

//--------------------------------------------------------------------------/
double ManagementLotsGN()
{
double result;

if(EquazioneSpreadG3 == false)
{
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{

if( LottiGN() > 0 )
result = (  LottiGN() * ( PipsDistance ) / ( TPN  ) );

if( LottiGN() == 0  )
{
if (DeltaPips + TP1 == 0)
if(Stampate) Print(" Attenzione divisione per zero: Deltapips + Tp1 = 0 pertanto G3 ricomincia i lotti.");
result = ( LostFirstOrderG3 / PipsTake );
if(Stampate) Print(" Aperto primo ordine G3: LostFirstOrderG3: " + LostFirstOrderG3 + " PipsTake: " + PipsTake);

}
}

//Avanzamento

if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if( LottiGN() > 0 )
result = (  LottiGN() * ( PipsDistance) / ( TPN ) );

if( LottiGN() == 0 )// || ( Mode == 1 && LastCloseG3() ) )
{
if (DeltaPips + TPN == 0)
if(Stampate) Print(" Attenzione divisione per zero: Deltapips+Tp1 = 0 pertanto G3 ricomincia i lotti.");

result = (LostFirstOrderG3 / PipsTake);

if(Stampate) Print(" Aperto primo ordine G3: LostFirstOrderG3: " + LostFirstOrderG3 + " PipsTake: "+ PipsTake);

}
}

if(TpDinamico == false)if(Stampate) Print("TPN: " + TPN);
}

//Calcolo GN
if(EquazioneSpreadG3 == true)
{
if((NormalizeDouble(Ask,Digits) >= (PrimeOpenPrice(-1) - PipsD)) && NormalizeDouble(Ask,Digits) <= (PrimeOpenPrice(-1)  + PipsD)  && (SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
if( LottiGN() > 0 )
result = (  LottiGN() * ( PipsDistance - SpreadRatioG3 * Spread ) / ( TPN + SpreadRatioG3 * Spread ) );


if(TpDinamico == false)if(Stampate) Print(" * Calcolato TP3: " + TP1);

if( LottiGN() == 0 )// || ( Mode == 1 && LastCloseG3() ) )
{
result = LostFirstOrderG3 / ( PipsTake + ( SpreadRatioG3 * Spread ) );
if(Stampate) Print("********* LostFirstOrderGN = " + LostFirstOrderG3 +" pipstake " +PipsTake );
if(Stampate) Print("Aperto primo ordine GN: LostFirstOrderGN: " + LostFirstOrderG3 + " PipsTake: " + PipsTake + " SpreadRatio: " + SpreadRatioG3 + " Spread: " + Spread);
}
}

//Avanzamento

if((NormalizeDouble(Bid,Digits) <= (PrimeOpenPrice(1) + PipsD)) && NormalizeDouble(Bid,Digits) >= (PrimeOpenPrice(1)  - PipsD)  && (SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if( LottiGN() > 0 )
result = (  LottiGN() * ( PipsDistance - SpreadRatioG3 * Spread ) / ( TPN + SpreadRatioG3 * Spread ) );


if(TpDinamico == false)if(Stampate) Print(" * Calcolato TP3: " + TP1);

if( LottiGN() == 0 )//|| ( Mode == 1 && LastCloseG3() ) )
{
result = LostFirstOrderG3 / (PipsTake + (SpreadRatioG3 * Spread));
if(Stampate) Print("********* LostFirstOrderGN = " + LostFirstOrderG3 +" pipstake " +PipsTake );

if(Stampate) Print("Aperto primo ordine GN: LostFirstOrderGN: " + LostFirstOrderG3 + " PipsTake: " + PipsTake + " SpreadRagio: " + SpreadRatioG3 + " Spread: " + Spread);
}
}
}

result = NormalizeDouble (StrToDouble( StringSubstr( DoubleToStr(result,4),0,7 ) ), 2) ;

return (result);

}

//--------------------------------------------------------------------------/

void PanicCloseGN( string Grid )
{
bool Esito;

StartAr[ ( StrToInteger(StringSubstr(Grid,1,1)) - 4 ) ] = iTime( Symbol(), PERIOD_M1, 0 );

for(int i=OrdersTotal()-1;i>=0;i--)
{
//G3Reset = iTime( Symbol(), PERIOD_M1, 0 );
OrderSelect(i,SELECT_BY_POS);
if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderComment() == Grid )
{
if(OrderType()==OP_BUY)
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green);
Print(" * Chiusura ordine Buy di "+ StringSubstr(OrderComment(), 0, 2) +" al prezzo "+OrderClosePrice()+" lotto "+OrderLots()+" per "+ClosingTPN);
Esito = false;
ClosedGridWithTP = true;
continue;
}

else if(OrderType()==OP_SELL)
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green);
Print(" * Chiusura ordine Sell di "+ StringSubstr(OrderComment(), 0, 2) +" al prezzo "+OrderClosePrice()+" lotto "+OrderLots()+" per "+ClosingTPN);
Esito = false;
ClosedGridWithTP = true;
continue;
}
}
}
}


//--------------------------------------------------------------------------/

void ChiusuraRGA()
{

if( NormalizeDouble(Bid,Digits) >= PriceStopPipsTake(1 ) || NormalizeDouble(Bid,Digits) <= PriceStopPipsTake(-1 )  )
{
ChiusuraG1G2 = "PipsTake";
PanicCloseG1G2( );
}

if( NormalizeDouble(Bid,Digits) >= PriceStopGN(1, TP1 ) || NormalizeDouble(Bid,Digits) <= PriceStopGN(-1, TP1 )  )
{  PanicCloseG3( );
}
for(int i = 0; i < NumMaxGrid-1; i++)
{
string grid = ("G" + (4+i)+" - SuperGrid");
if( NormalizeDouble(Bid,Digits) >= PriceStopGN(1, TPar[i] ) || NormalizeDouble(Bid,Digits) <= PriceStopGN(-1, TPar[i] )  )
{
ClosingTPN = "G" + (4+i);
PanicCloseGN( grid );
}
}
if(OpenedOrdersGrid("G1")+OpenedOrdersGrid("G2") == 0 && (NormalizeDouble(Bid,Digits) <= PriceStopGN(1, PipsTake ) && NormalizeDouble(Ask,Digits) >= PriceStopGN(-1, PipsTake ))  )
{

PanicClose();
}

if(OpenedOrdersGrid("G1")+OpenedOrdersGrid("G2") != 0 && ClosedGridWithTP && true  )
{
//Print(NormalizeDouble(Bid,Digits)+ " "+PriceStopGN(1, TP1 ));
PanicCloseAllGN();
ClosedGridWithTP = false;
}
}

//--------------------------------------------------------------------------/

void ChiusuraRGB()
{
double MaxTp = PipsTake;
if( MaxTp < TP1 )MaxTp = TP1;

if( NormalizeDouble(Bid,Digits) >= PriceStopGN(1, TP1 ) && NormalizeDouble(Bid,Digits) <= PriceStopGN(-1, TP1 )  )
PanicCloseG3( );
for(int i = 0; i < NumMaxGrid-1; i++)
{
if( MaxTp < TPar[i] ) MaxTp = TPar[i];
string grid = ("G" + (4+i)+" - SuperGrid");
if( NormalizeDouble(Bid,Digits) >= PriceStopGN(1, TPar[i] ) && NormalizeDouble(Bid,Digits) <= PriceStopGN(-1, TPar[i] )  )
PanicCloseGN( grid );
}
if( NormalizeDouble(Bid,Digits) >= PriceStopGN(1,MaxTp ) && NormalizeDouble(Bid,Digits) <= PriceStopGN(-1,MaxTp )  )
PanicCloseG1G2( );
if(OpenedOrdersGrid("G1")+OpenedOrdersGrid("G2") == 0 && (NormalizeDouble(Bid,Digits) <= PriceForG3(1) || NormalizeDouble(Ask,Digits) >= PriceForG3(-1))  )
PanicClose();

for( i = NumMaxGrid-1; i >=0 ; i-- )
if(PipsTake > TPar[i])
StartAr[i] = iTime( Symbol(), PERIOD_M1, 0 );
else
{
StartAr[i] = iTime( Symbol(), PERIOD_M1, 0 );
break;
}
}

//--------------------------------------------------------------------------/

double PriceStopGN(int Dir, double tmpTP)
{
double result;
if(tmpTP == 0) tmpTP = PipsTake;
//Oltre alla Dir devo definire se sono in Avanzamento oppure in Regressione e regolarmi di conseguenza

if((SecondOpenPrice(-1) < PrimeOpenPrice(-1) || OpenedOrders(0,MagicNumber) == 2) && SecondOpenPrice(1) == 0)
{
if(Dir == 1) result = (PrimeOpenPrice(-1)  + ( (tmpTP * Poin) ) );
if(Dir == -1) result = (SecondOpenPrice(-1) - ((tmpTP * Poin)));
}

if((SecondOpenPrice(1) > PrimeOpenPrice(1)  || OpenedOrders(0,MagicNumber) == 2)  && SecondOpenPrice(-1) == 0)
{
if(Dir == 1) result = (SecondOpenPrice(1)  + ((tmpTP * Poin)));
if(Dir == -1) result = (PrimeOpenPrice(1) - ((tmpTP * Poin)));
}

result = NormalizeDouble(result,Digits);

return(result);
}


//--------------------------------------------------------------------------/

void PanicCloseAllGN()
{
bool Esito;

for(int j = 0;j<NumMaxGrid; j++)
{
string Grid = "G"+(3+j)+" - SuperGrid";
StartAr[ ( StrToInteger(StringSubstr(Grid,1,1)) - 4 ) ] = iTime( Symbol(), PERIOD_M1, 0 );

for(int i=OrdersTotal()-1;i>=0;i--)
{
//G3Reset = iTime( Symbol(), PERIOD_M1, 0 );
OrderSelect(i,SELECT_BY_POS);
if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderComment() == Grid )
{
if(OrderType()==OP_BUY && NormalizeDouble(Ask,Digits) <= PriceStopGN(-1, PipsTake ) )
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,Green);
Print(" * Chiusura ordine Buy di "+ StringSubstr(OrderComment(), 0, 2) +" al prezzo "+OrderClosePrice()+" lotto "+OrderLots()+" per ritracciamento in A o A+1");
Esito = false;
continue;
}

else if(OrderType()==OP_SELL && NormalizeDouble(Bid,Digits) >= PriceStopGN( 1, PipsTake ) )
{
while(Esito == false) Esito = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,Green);
Print(" * Chiusura ordine Buy di "+ StringSubstr(OrderComment(), 0, 2) +" al prezzo "+OrderClosePrice()+" lotto "+OrderLots()+" per ritracciamento in A o A+1");
Esito = false;
continue;
}
}
}
}
}


int SessNumOrderGrid( string Grid )
{
int result;

datetime Start;

if( Mode == 1 )
Start = G3Reset;
else
{
for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == Grid+" - SuperGrid" && OrderOpenTime() >= Start)
{
result ++;
}
}


for(i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == Grid+" - SuperGrid" && OrderOpenTime() >= Start)
{
result ++;
}
}


return(result);

}


void CheckActiveGrid()
{
string result;
for(int i=1; i <= NumMaxGrid+2; i++)
{
result = "G"+i+"( Lotto: "+ DoubleToStr( LastLotGN( ("G"+i) ), 2 )+" )           ";

ObjectCreate("actualgrid"+i,OBJ_LABEL,0,0,0);
ObjectSet("actualgrid"+i,OBJPROP_XDISTANCE,5);
ObjectSet("actualgrid"+i,OBJPROP_YDISTANCE,5+i*9);
ObjectSet("actualgrid"+i,OBJPROP_CORNER,1);
ObjectSet("actualgrid"+i,OBJPROP_COLOR, White );
ObjectSetText("actualgrid"+i, result, 8);
}

}

double LastLotGN( string Grid )
{
double result;
datetime Start;

for(int i = OrdersHistoryTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderCloseTime() >= Start)Start = OrderCloseTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() > OP_SELL)
{
if(OrderOpenTime() >= Start)Start = OrderOpenTime();
}
}

for(i = OrdersTotal()-1; i >= 0; i --)
{
OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

if(( OrderType() == OP_BUY || OrderType() == OP_SELL ) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == Grid+" - SuperGrid" && OrderOpenTime() >= Start)
{
Start = OrderOpenTime();
result = OrderLots();
}
}

return (result);
}