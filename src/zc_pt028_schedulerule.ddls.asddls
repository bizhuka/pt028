@AbapCatalog.sqlViewName: 'zvcpt028_schrule'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Schedule Rule'
@Search.searchable

define view ZC_PT028_ScheduleRule as select distinct from pa0007 {
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
    key zzbwpa
} where sprps = ' ' and zzbwpa <> ''
