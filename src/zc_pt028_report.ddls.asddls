@AbapCatalog.sqlViewName: 'zvcpt028_report'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Report'
@Search.searchable

@UI: {
    headerInfo: {
        typeName: 'Employee',
        typeNamePlural: 'Employees',
        title: {
            type: #STANDARD, value: 'ename'
        },
        description: {
            value: 'pernr'
        }
    }
}    
@OData.publish: true

@ZABAP.virtualEntity: 'ZCL_PT028_REPORT'

define view ZC_PT028_REPORT as select from ZC_PY000_OrgAssignment as _org_assign
inner join pa0002 as _pers_info on _pers_info.pernr =  _org_assign.pernr
                               and _pers_info.begda <= _org_assign.begda
                               and _pers_info.endda >= _org_assign.begda   
                                         
inner join pa0000 as p0 on p0.pernr = _org_assign.pernr
                       and p0.stat2 = '3'
                       and p0.begda <= _org_assign.begda
                       and p0.endda >= _org_assign.begda
                       and p0.sprps = ' '    
                                                                                         
inner join pa0007 as p7 on p7.pernr  = _org_assign.pernr
                       and p7.begda <= _org_assign.begda
                       and p7.endda >= _org_assign.begda
                       and p7.sprps = ' '  
                        
//left outer join 
 association[0..1] to pa0290               as _document   on _document.pernr =  _org_assign.pernr
                                                   and _document.begda <= _org_assign.endda //begda
                                                   and _document.endda >= _org_assign.begda
                                                   and _document.subty = 'KZ05'
                                                   and _document.sprps = ' '                                                   
////left outer join
// association[0..1] to pa0105                  as _phone   on _phone.pernr =  _org_assign.pernr
//                                                   and _phone.begda <= _org_assign.endda //begda
//                                                   and _phone.endda >= _org_assign.begda
//                                                   and _phone.subty = 'CELL'
//                                                   and _phone.sprps = ' '
//                                                   and _phone.seqnr = '000'                                                  
//left outer join
 association[0..1] to pa9002                as _rus_fio   on _rus_fio.pernr =  _org_assign.pernr
                                                   and _rus_fio.begda <= _org_assign.endda //begda
                                                   and _rus_fio.endda >= _org_assign.begda
                                                   and _rus_fio.sprps = ' '                                                   
//left outer join
 association[0..1] to ZC_PY000_Address      as _Address on _Address.pernr =  _org_assign.pernr
                                                 and _Address.begda <= _org_assign.endda //begda
                                                 and _Address.endda >= _org_assign.begda
                                                 and _Address.subty = 'Z1'
                                                                                                             
association[0..*] to ZC_PT028_ScheduleRule as _ScheduleRule on _ScheduleRule.zzbwpa = p7.zzbwpa

association[0..*] to ZC_PT028_ScheduleKind as _ScheduleKind on _ScheduleKind.tprog = $projection.tprog

association[0..*] to ZC_PT028_Schedule as _Schedule   on _Schedule.pernr =  _org_assign.pernr
                                                     and _Schedule.begda <= _org_assign.begda
                                                     and _Schedule.endda >= _org_assign.begda  
                                            

{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    @UI.lineItem: [{ position: 10, importance: #HIGH }]
    key _org_assign.pernr,
    
    @UI.lineItem: [{ position: 100 }]
    key _org_assign.begda,
    
    @UI.lineItem: [{ position: 110 }]
    key _org_assign.endda,
             
    key ' ' as stream_type,
            
//       key coalesce( _phone.begda,              '77771231' ) as begda_phone,
//       key coalesce( _phone.endda,              '77771231' ) as endda_phone,
        
        key coalesce( _rus_fio.begda,            '77771231' ) as begda_fio,
        key coalesce( _rus_fio.endda,            '77771231' ) as endda_fio,
        
        key coalesce( _Address.begda,            '77771231' ) as begda_addr,
        key coalesce( _Address.endda,            '77771231' ) as endda_addr,
        
        key coalesce( _document.begda,           '77771231' ) as begda_doc,
        key coalesce( _document.endda,           '77771231' ) as endda_doc,

        key coalesce( _Position.begda,           '77771231' ) as begda_pos,
        key coalesce( _Position.endda,           '77771231' ) as endda_pos,
                
        key coalesce( _Position._LongText.begda, '77771231' ) as begda_pos_ltext,
        key coalesce( _Position._LongText.endda, '77771231' ) as endda_pos_ltext,
            
        // Avatar  cast( ' ' as abap.char( 255 ) ) as photo_path,
        concat( concat('../../../../../opu/odata/sap/ZC_PY000_REPORT_CDS/ZC_PY000_PernrPhoto(pernr=''', _org_assign.pernr),
                       ''')/$value')  as photo_path,          
          
//        @UI.selectionField: [{ position: 1 }]        
//        @Consumption.filter: { mandatory: true } //selectionType: #INTERVAL, multipleSelections: false,
        datum as key_date,
        
        
        @EndUserText.label: 'Days from Key Date' 
        cast( '31' as abap.numc( 2 ) ) as days_from_key_date,
               
        @EndUserText.label: 'Daily WS' 
        @Consumption.valueHelp: '_ScheduleKind' 
        cast( ' ' as abap.char( 4 ) ) as tprog,
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
        @UI.lineItem: [{ position: 30, importance: #HIGH }]
        ename,
        
        @UI.fieldGroup: [{ qualifier: 'Main', position: 10, label: 'Fullname'  }]       
        concat_with_space(_rus_fio.nominative_last_name, concat_with_space(_rus_fio.nominative_first_name, _rus_fio.nominative_middle_name, 1), 1) as rus_fio,                    
        
        @UI.lineItem: [{ position: 40, label: 'Date of Birth' }]
        @UI.fieldGroup: [{ qualifier: 'Main', position: 20, label: 'Date of Birth' }]
        cast (_pers_info.gbdat as abap.dats ) as birth_date,
        
        @UI.lineItem: [{ position: 50 }]
        @UI.fieldGroup: [{ qualifier: 'Main', position: 40 }]
        _pers_info.zzbirthplace,
        @UI.lineItem: [{ position: 60 }]
        @UI.fieldGroup: [{ qualifier: 'Main', position: 30 }]
        @EndUserText.label: 'IIN'
        _pers_info.perid,   
        
        @UI.selectionField: [{ position: 80 }]
        @Consumption.valueHelp: '_ScheduleRule'
        p7.zzbwpa,
                
        @UI.fieldGroup: [{ qualifier: 'Main', position: 35 }] // , label: 'Phone'
        _Address.telnr as phone, //_phone.usrid    
            
        @UI.lineItem: [{ position: 70 }]
        @UI.fieldGroup: [{ qualifier: 'Doc', position: 10 }]
        @EndUserText.label: 'KZ citizenship id'
        _document.nomer,
        @UI.lineItem: [{ position: 80 }]
        @UI.fieldGroup: [{ qualifier: 'Doc', position: 20 }]
        _document.datbg,
        @UI.lineItem: [{ position: 90 }]
        @UI.fieldGroup: [{ qualifier: 'Doc', position: 30 }]        
        _document.passl,
        
        @UI.selectionField: [{ position: 10 }]
        @UI.fieldGroup: [{ qualifier: 'Org', position: 10 }]
        persg,

        @UI.selectionField: [{ position: 20 }]
        @Consumption.filter.defaultValue: '10'
        @UI.fieldGroup: [{ qualifier: 'Org', position: 20 }]
        persk,
      
        @UI.selectionField: [{ position: 30 }]
        @UI.fieldGroup: [{ qualifier: 'Org', position: 30 }]
        @Consumption.filter.defaultValue: '1010'
        persa,
        
        @UI.selectionField: [{ position: 40 }]
        @UI.fieldGroup: [{ qualifier: 'Org', position: 40 }]
        btrtl,
        _PersonnelSubArea.btext,
                
        ansvh,
        
        @UI.selectionField: [{ position: 50 }]
        @UI.fieldGroup: [{ qualifier: 'Org', position: 50 }]
        kostl,
        kokrs,
        kosar,
        
        @UI.selectionField: [{ position: 60 }]
        @UI.fieldGroup: [{ qualifier: 'Org', position: 60 }]
        @Consumption.filter: { selectionType: #SINGLE, multipleSelections: false } //, mandatory: true, defaultValue: '40000000'}
        orgeh,
        
        @UI.fieldGroup: [{ qualifier: 'Org', position: 70 }]
        @ObjectModel.text.element: [ 'plans_txt' ]
        plans,
        _Position._LongText.long_text as plans_txt,

        _EmployeeGroup,
        _EmployeeSubgroup,
        _PersonnelArea,
        _PersonnelSubArea,
        _WorkContract,
        _CostCenter,
        _CostCenterType,
        _OrgUnit,
        _Position,        
        
        // for Excel report
        _Address._Region.bezei,
        _Address.state,
        _Address.ort01,
        _Address.ort02,
        _Address.stras,
        _Address.hsnmr,
        _Address.posta,
        
//        _Address,
        _Schedule,
        _ScheduleRule,
        _ScheduleKind
        
}   //where 
