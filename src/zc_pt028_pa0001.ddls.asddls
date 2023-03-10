@AbapCatalog.sqlViewName: 'zvcpt028_0001'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Org. Assignment'



define view ZC_PT028_PA0001 as select from ZC_PY000_OrgAssignment as _org_assign                                                  
{
    key _org_assign.pernr,
    key _org_assign.endda,
    key _org_assign.begda,
          
        datum as key_date,
        cast( ' ' as abap.char( 4 ) ) as tprog,
        cast( '31' as abap.numc( 2 ) ) as days_from_key_date,
        
        ename,
        
        persg,   
        persk,
        persa,
        btrtl,
        ansvh,
        kokrs,
        kosar,
        kostl,
        orgeh,
        plans,
        stell,

        _EmployeeGroup,
        _EmployeeSubgroup,
        _PersonnelArea,
        _PersonnelSubArea,
        _WorkContract,
        _CostCenter,
        _CostCenterType,
        _OrgUnit,
        _Position,
        _Job
} 
