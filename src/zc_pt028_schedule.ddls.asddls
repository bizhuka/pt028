@AbapCatalog.sqlViewName: 'zvcpt028_sch'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Schedule'

@ZABAP.virtualEntity: 'ZCL_PT028_SCHEDULE'

define view ZC_PT028_Schedule as select from zdpt028_schedule {

    key pernr,
    @UI.lineItem: [{ position: 100 }]
    key datum,
    
        begda,        
        endda,
        
        @UI.lineItem: [{ position: 20 }]
        tprog,
        
        kind,
        info,
        
        cast(' ' as abap.char( 7 ) ) as color
}
