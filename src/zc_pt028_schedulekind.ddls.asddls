@AbapCatalog.sqlViewName: 'zvcpt028_schkind'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Schedule Kind'

define view ZC_PT028_ScheduleKind as select distinct from t550a {
    key tprog
} where regel = 'KZ' and motpr = '67' and endda = '99991231'
