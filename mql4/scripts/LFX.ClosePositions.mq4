/**
 * Schlie�t die angegebenen LFX-Positionen.
 */
#include <stdlib.mqh>
#include <win32api.mqh>

#property show_inputs


//////////////////////////////////////////////////////////////// Externe Parameter ////////////////////////////////////////////////////////////////

extern string Position.Labels = "";                      // Label-1 [, Label-n [, ...]]      (Pr�fung per OrderComment().StringIStartsWith(value))

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


int Strategy.Id = 102;                                   // eindeutige ID der Strategie (Bereich 101-1023)

string labels[];
int    sizeOfLabels;


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int init() {
   init = true; init_error = NO_ERROR; __SCRIPT__ = WindowExpertName();
   stdlib_init(__SCRIPT__);

   // Parametervalidierung
   Position.Labels = StringTrim(Position.Labels);
   if (StringLen(Position.Labels) == 0)
      return(catch("init(1)  Invalid input parameter Position.Labels = \""+ Position.Labels +"\"", ERR_INVALID_INPUT_PARAMVALUE));

   // Parameter splitten und die einzelnen Label trimmen
   sizeOfLabels = Explode(Position.Labels, ",", labels, NULL);

   for (int i=0; i < sizeOfLabels; i++) {
      labels[i] = StringTrim(labels[i]);
   }
   return(catch("init(2)"));
}


/**
 * Deinitialisierung
 *
 * @return int - Fehlerstatus
 */
int deinit() {
   return(catch("deinit()"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int start() {
   init = false;
   if (init_error != NO_ERROR)
      return(init_error);
   // ------------------------


   int    orders = OrdersTotal();
   string positions[]; ArrayResize(positions, 0);
   int    tickets  []; ArrayResize(tickets, 0);


   // (1) zu schlie�ende Positionen selektieren
   for (int i=0; i < orders; i++) {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))      // FALSE: w�hrend des Auslesens wird in einem anderen Thread eine aktive Order geschlossen oder gestrichen
         break;

      if (IsMyOrder()) {
         if (OrderType()!=OP_BUY) /*&&*/ if ( OrderType()!=OP_SELL)
            continue;

         for (int n=0; n < sizeOfLabels; n++) {
            if (StringIStartsWith(OrderComment(), labels[n])) {
               string label = LFX.Currency(OrderMagicNumber()) +"."+ LFX.Counter(OrderMagicNumber());
               if (!StringInArray(label, positions))
                  ArrayPushString(positions, label);
               if (!IntInArray(OrderTicket(), tickets))
                  ArrayPushInt(tickets, OrderTicket());
               break;
            }
         }
      }
   }


   // (2) Positionen schlie�en
   int sizeOfPositions = ArraySize(positions);
   if (sizeOfPositions > 0) {
      PlaySound("notify.wav");
      int button = MessageBox("Do you really want to close the specified "+ ifString(sizeOfPositions==1, "", sizeOfPositions +" ") +"position"+ ifString(sizeOfPositions==1, "", "s") +"?", __SCRIPT__, MB_ICONQUESTION|MB_OKCANCEL);
      if (button == IDOK) {
         if (!OrderCloseMultiple(tickets, 0.1, Orange))
            return(processError(stdlib_PeekLastError()));


         // (3) Positionen aus ...\SIG\external_positions.ini l�schen
         string file    = TerminalPath() +"\\experts\\files\\SIG\\external_positions.ini";
         string section = ShortAccountCompany() +"."+ AccountNumber();
         for (i=0; i < sizeOfPositions; i++) {
            int error = DeletePrivateProfileKey(file, section, positions[i]);
            if (error != NO_ERROR)
               return(processError(error));
         }
      }
   }
   else {
      PlaySound("notify.wav");
      MessageBox("No matching positions found.", __SCRIPT__, MB_ICONEXCLAMATION|MB_OK);
   }

   return(catch("start()"));
}


/**
 * Ob die aktuell selektierte Order zu dieser Strategie geh�rt.
 *
 * @return bool
 */
bool IsMyOrder() {
   return(StrategyId(OrderMagicNumber()) == Strategy.Id);
}
