//+------------------------------------------------------------------+
//|                                                    Propagate.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Propagator
  {
protected:


public:
   int               exponent_record_[];
   int               streak_record_[];
   void              Propagate(double& MA[]);
   void              CopyArray(double& source[], double& destination[]);
   double            Deviation(double& shedskin[], int start_index,int end_index); //to-do
   double            KDeviation(double& shedskin[], int start_index,int end_index); //to-do
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Propagator::Propagate(double &MA[])
  {
   double layer_old[];
   double layer_new[];
   int function_pointsA[];
   int function_pointsB[];

   int layer_number = 0;
   int function_number = 0;
   int inxd_rEc[];
   int exp_rEc[];
   int inxd_rEcA[];
   int inxd_rEcB[];

   ArrayResize(inxd_rEc, ArraySize(MA));

   for(int i=0; i<ArraySize(MA); i++)
     {
      inxd_rEc[i] = i;
     }

   ArraySetAsSeries(layer_new, true);
   ArraySetAsSeries(layer_new, true);
   CopyArray(MA,layer_old);
   while(true)
     {

      //raw operation
      int function_starts[];
      int function_ends[];
      int function_num=0;
      int r_tot_streaks=0;
      int r_streak = 0;
      int r_end_of_last_streak=0;


      Print("Initial check on old layer: ");
      ArrayPrint(layer_old);
      Print("layer_number: ",layer_number);
      //check for spines



      for(int i = 0; i<ArraySize(layer_old); i++)
        {
         //Print(Deviation(layer_new, end_of_last_streak, i));
         int end_pt = r_end_of_last_streak+2+r_streak-1;
         //Print("gugu: ", r_end_of_last_streak, " ", end_pt);
         if(end_pt >= ArraySize(layer_old))
           {
            break;
           }
         if(MathAbs(Deviation(layer_old, r_end_of_last_streak, end_pt)) <= 3)
           {

            r_streak++;
            r_tot_streaks++;
            //Print(end_pt+1, " ", r_end_of_last_streak-1, " ", layer_old[end_pt+layer_number-1], " ",layer_old[end_pt+layer_number]);
            if(end_pt >= ArraySize(layer_old)-1)
              {

               printf("ended on w");
               ArrayResize(function_ends, ArraySize(function_ends)+1);
               ArrayResize(function_starts, ArraySize(function_starts)+1);
               //Print(end_pt+1, " ", r_end_of_last_streak-1, " ", layer_old[end_pt+layer_number-1], " ",layer_old[end_pt+layer_number]);
               function_ends[function_num] = end_pt+layer_number-1;
               function_starts[function_num] = r_end_of_last_streak;

               function_number++;
               function_num++;
              }
           }
         if(MathAbs(Deviation(layer_old, r_end_of_last_streak, end_pt)) > 3)
           {
            if(r_streak>5)
              {
               //record function point
               printf("init function point");
               ArrayResize(function_ends, ArraySize(function_ends)+1);
               ArrayResize(function_starts, ArraySize(function_starts)+1);
               //Print(end_pt+1, " ", r_end_of_last_streak-1, " ", layer_old[end_pt-1], " ",layer_old[end_pt], " ",layer_old[end_pt+1]);
               function_ends[function_num] = end_pt+layer_number-1;
               function_starts[function_num] = r_end_of_last_streak;

               function_num++;
              }
            //Print("cut short...", end_pt);
            r_end_of_last_streak = end_pt;
            r_streak = 0;
           }
        }

      //keep track
      ArrayPrint(function_starts);
      ArrayPrint(function_ends);
      double pseudo_layer[];
      int temp_rEc[];
      if(ArraySize(function_starts)>0)
        {
         Print("chippie ", function_num, " ", ArraySize(function_starts));
         int buffer = 0;
         if(ArraySize(function_pointsB)>0)
           {
            buffer = function_pointsB[ArraySize(function_pointsB)-1]+1;
           }
         for(int x = 0; x < ArraySize(function_starts); x++)
           {
            ArrayResize(function_pointsA, ArraySize(function_pointsA)+1);
            ArrayResize(function_pointsB, ArraySize(function_pointsB)+1);
            function_pointsA[ArraySize(function_pointsA)-1] = function_starts[x]+buffer;
            function_pointsB[ArraySize(function_pointsB)-1] = function_ends[x]+buffer;

            ArrayResize(exp_rEc, ArraySize(exp_rEc)+1);
            ArrayResize(inxd_rEcA, ArraySize(inxd_rEcA)+1);
            ArrayResize(inxd_rEcB, ArraySize(inxd_rEcB)+1);

            Print(function_starts[x], " ", function_ends[x]);
            ArrayPrint(inxd_rEc);

            inxd_rEcA[ArraySize(inxd_rEcA)-1] = inxd_rEc[function_starts[x]];
            inxd_rEcB[ArraySize(inxd_rEcB)-1] = inxd_rEc[function_ends[x]-1]+1;
            exp_rEc[ArraySize(exp_rEc)-1] = layer_number;
            if(MA[inxd_rEcA[ArraySize(inxd_rEcA)-1]] > MA[inxd_rEcA[ArraySize(inxd_rEcA)-1]+1])
              {
               exp_rEc[ArraySize(exp_rEc)-1] *= -1;
              }

            //Print(MA[function_pointsA[ArraySize(function_pointsA)-1]], " ", MA[function_pointsB[ArraySize(function_pointsB)-1]], "layer no: ", layer_number);

           }

         for(int i = 0; i < ArraySize(layer_old); i++)
           {
            bool in_region = true;
            for(int x = 0; x < ArraySize(function_starts); x++)
              {
               if(i >= function_starts[x] && i <= function_ends[x])
                 {
                  in_region = false;
                 }
              }
            if(in_region)
              {
               ArrayResize(pseudo_layer, ArraySize(pseudo_layer)+1);
               pseudo_layer[ArraySize(pseudo_layer)-1] = layer_old[i];

               ArrayResize(temp_rEc, ArraySize(temp_rEc)+1);
               temp_rEc[ArraySize(temp_rEc)-1] = inxd_rEc[i];
              }
           }

         ArrayResize(layer_old,0);
         ArrayResize(inxd_rEc,0);
         for(int i = 0; i<ArraySize(pseudo_layer); i++)
           {
            ArrayResize(layer_old, ArraySize(layer_old)+1);
            layer_old[ArraySize(layer_old)-1] = pseudo_layer[i];

            ArrayResize(inxd_rEc, ArraySize(inxd_rEc)+1);
            inxd_rEc[ArraySize(inxd_rEc)-1] = temp_rEc[i];
           }
         Print("new old layer: ");
         ArrayPrint(layer_old);
         ArrayPrint(inxd_rEc);
         Print("new old layer: ");
        }





      Print("Initial check done.");
      ArrayPrint(function_starts);
      Print("Initial check done.");



      Print("from the top! ", layer_number);
      //ArrayPrint(layer_old);
      //ArrayPrint(layer_new);
      //Print("from the top! ", layer_number);
      int tot_streaks = 0;
      for(int i = 1; i<ArraySize(layer_old); i++)
        {
         ArrayResize(layer_new, ArraySize(layer_new)+1);
         layer_new[i-1] = layer_old[i]-layer_old[i-1];

        }

      //dawn of a new story
      //Print("last layer: ");
      //ArrayPrint(layer_new);

      if(layer_number >= 4 || ArraySize(layer_new)<=0)
        {
         Print("REACHED SPINE: ",r_tot_streaks, " ",ArraySize(layer_new)," ",layer_number);

         inxd_rEcB[ArrayMaximum(inxd_rEcB, 0, WHOLE_ARRAY)] += 1;
         //ArrayPrint(MA);

         ArrayPrint(exp_rEc);
         ArrayPrint(inxd_rEcA);
         ArrayPrint(inxd_rEcB);
         ArrayPrint(inxd_rEc);

         int streak_lengths[];
         ArrayResize(streak_lengths,  ArraySize(inxd_rEcA));
         int organized_inxd_rEcA[];
         ArrayResize(organized_inxd_rEcA,  ArraySize(inxd_rEcA));

         for(int i=0; i<ArraySize(inxd_rEcA); i++)
           {
            Print(MA[inxd_rEcA[i]], " ", MA[inxd_rEcB[i]]);
            streak_lengths[i] = inxd_rEcB[i] - inxd_rEcA[i];
            organized_inxd_rEcA[i] = inxd_rEcA[i];

           }

         ArraySort(organized_inxd_rEcA);


         ArrayResize(exponent_record_,  ArraySize(exp_rEc));
         ArrayResize(streak_record_,  ArraySize(streak_lengths));

         ArrayPrint(organized_inxd_rEcA);

         for(int i=0; i<ArraySize(organized_inxd_rEcA); i++)
           {
            int ordered_index = 0;
            for(int x=0; x<ArraySize(inxd_rEcA); x++)
              {
               if(inxd_rEcA[x] == organized_inxd_rEcA[i])
                 {
                  ordered_index = x;
                 }
              }
            exponent_record_[i] = exp_rEc[ordered_index];
            streak_record_[i] = streak_lengths[ordered_index];
           }

         Print("final product");
         break;
        }

      //Print("new story!", r_tot_streaks, " ",ArraySize(layer_new)," ",layer_number);
      if(ArraySize(layer_new)>0)
        {
         //Print("new story!", tot_streaks, " ",ArraySize(layer_new)," ",layer_number);
         CopyArray(layer_new,layer_old);
         ArrayResize(layer_new,0);
         layer_number++;

        }


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Propagator::CopyArray(double &source[],double &destination[])
  {
   ArraySetAsSeries(destination, true);
   ArrayResize(destination, ArraySize(source));
   for(int i = 0; i<ArraySize(source); i++)
     {
      destination[i] = source[i];
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Propagator::Deviation(double &shedskin[],int start_index,int end_index)
  {

//Print("new round");
   double sum_of_difference=0;
   Print(start_index," ",end_index);

   for(int i = start_index; i<end_index; i++)
     {

      sum_of_difference += (shedskin[i+1]-shedskin[i]);
      //Print(shedskin[i+1], " ", shedskin[i], " ", sum_of_difference);

     }

   int deviation=sum_of_difference/(end_index-start_index);
   Print(deviation);
   return deviation;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

