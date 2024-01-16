//+------------------------------------------------------------------+
//|                                                 CandleExpert.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <Propagate.mqh>
#include <Math\Stat\Math.mqh>
Propagator prop;
Propagator prop2;

input int window = 100;
int rawnd = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("*---[STARTED]---*");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("*---[ENDED]---*");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   static datetime timestamp;
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);

// if new candle is formed
   if(timestamp != time)
     {
      timestamp = time;

      // Generate moving average window
      static int MA = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
      double MAArray[];
      int total_journey = 1000;
      int cropper = 10;
      
      CopyBuffer(MA, 0, 0, total_journey, MAArray);
      ArraySetAsSeries(MAArray, true);
      //ArrayPrint(MAArray);

      double pMA[];
      ArraySetAsSeries(pMA, true);

      double tMA[];
      ArraySetAsSeries(tMA, true);

      if(rawnd == 0)
        {
         
         for(int i = 0; i<(total_journey/2); i++)
           {

            double temp_array[];
            ArraySetAsSeries(temp_array, true);

            double ave = 0;

            ArrayCopy(temp_array, MAArray, 0, 0, i+1);

            if(i>=cropper-1)
              {
               ArrayResize(temp_array, 0);
               ArrayResize(temp_array, cropper);
               ArrayCopy(temp_array, MAArray, 0, i-(cropper-1), cropper);
               //Print(i-(cropper-1), " ", cropper);
              }

            Print("ma arr");
            ArrayPrint(MAArray);
            Print("temp arr");
            ArrayPrint(temp_array);

            ArrayResize(pMA, ArraySize(pMA)+1);
            ave = MathSum(temp_array)/(ArraySize(temp_array));
            //Print(ave);
            pMA[ArraySize(pMA)-1] = round(ave * 1000000);
           }

         for(int i = (total_journey/2); i<total_journey; i++)
           {

            double temp_array[];
            ArraySetAsSeries(temp_array, true);

            double ave = 0;

            ArrayCopy(temp_array, MAArray, 0, (total_journey/2), i+1);

            if(i>=cropper-1)
              {
               ArrayResize(temp_array, 0);
               ArrayResize(temp_array, cropper);
               ArrayCopy(temp_array, MAArray, 0, i-(cropper-1), cropper);
               //Print(i-(cropper-1), " ", cropper);
              }

            Print("ma arr");
            ArrayPrint(MAArray);
            Print("temp arr");
            ArrayPrint(temp_array);

            ArrayResize(tMA, ArraySize(tMA)+1);
            ave = MathSum(temp_array)/(ArraySize(temp_array));
            //Print(ave);
            tMA[ArraySize(tMA)-1] = round(ave * 1000000);
           }
        }

      if((ArraySize(pMA) >=5) &&
         rawnd == 0)
        {
         ArrayPrint(pMA);
         for(int i = 0; i<ArraySize(pMA); i++)
           {
            Print(pMA[i]);
           }
         prop.Propagate(pMA);
         prop2.Propagate(tMA);
         
         ArrayPrint(prop.exponent_record_);
         ArrayPrint(prop.streak_record_);
         ArrayPrint(prop2.exponent_record_);
         ArrayPrint(prop2.streak_record_);
         rawnd += 1;
        }
      //printf("New hour");

     }
  }

//+------------------------------------------------------------------+

