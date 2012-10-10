/**
 * TestExpert
 */
#include <core.define.mqh>
#define __TYPE__          T_EXPERT
int   __INIT_FLAGS__[] = {INIT_PIPVALUE};
int __DEINIT_FLAGS__[];
#include <stddefine.mqh>
#include <stdlib.mqh>
#include <win32api.mqh>

#include <core.expert.mqh>


bool done;


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int onTick() {
   if (!done) {
      done = true;
   }
   return(last_error|catch("onTick()"));
}


