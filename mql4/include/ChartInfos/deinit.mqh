/**
 * Deinitialisierung Preprocessing-Hook
 *
 * @return int - Fehlerstatus
 */
int onDeinit() {
   DeleteRegisteredObjects(NULL);
   QC.StopChannels();

   // ggf. OfflineTicker deinstallieren
   if (tickTimerId > NULL) {
      int id = tickTimerId; tickTimerId = NULL;
      if (!RemoveTickTimer(id)) return(catch("onDeinit(1)->RemoveTickTimer(timerId="+ id +") failed", ERR_RUNTIME_ERROR));
   }

   // in allen deinit()-Szenarien Fensterstatus  speichern
   if (!StoreWindowStatus())
      return(last_error);
   return(last_error);
}


/**
 * außerhalb iCustom(): bei Parameteränderung
 * innerhalb iCustom(): nie
 *
 * @return int - Fehlerstatus
 */
int onDeinitParameterChange() {
   // LFX-Status in Library zwischenspeichern, um in init() Neuladen zu vermeiden
   if (ChartInfos.CopyLfxStatus(true, lfxOrders, lfxOrders.ivolatile, lfxOrders.dvolatile) == -1)
      return(SetLastError(ERR_RUNTIME_ERROR));
   return(NO_ERROR);
}


/**
 * außerhalb iCustom(): bei Symbol- oder Timeframewechsel
 * innerhalb iCustom(): nie
 *
 * @return int - Fehlerstatus
 */
int onDeinitChartChange() {
   // LFX-Status in Library zwischenspeichern, um in init() Neuladen zu vermeiden
   if (ChartInfos.CopyLfxStatus(true, lfxOrders, lfxOrders.ivolatile, lfxOrders.dvolatile) == -1)
      return(SetLastError(ERR_RUNTIME_ERROR));
   return(NO_ERROR);
}


/**
 * außerhalb iCustom(): Indikator von Hand entfernt oder Chart geschlossen, auch vorm Laden eines Profils oder Templates
 * innerhalb iCustom(): in allen deinit()-Fällen
 *
 * @return int - Fehlerstatus
 */
int onDeinitRemove() {
   // Terminal-Exit und bei Profilwechsel

   // volatilen LFX-Status in globalen Variablen speichern
   if (!SaveVolatileLfxStatus())
      return(last_error);
   return(NO_ERROR);
}


/**
 * außerhalb iCustom(): bei Recompilation
 * innerhalb iCustom(): nie
 *
 * @return int - Fehlerstatus
 */
int onDeinitRecompile() {
   // volatilen LFX-Status in globalen Variablen speichern
   if (!SaveVolatileLfxStatus())
      return(last_error);
   return(NO_ERROR);
}