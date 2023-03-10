CLASS zcl_pt028_report DEFINITION INHERITING FROM zcl_py000_odata
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_sadl_stream_runtime.

    METHODS:
*      constructor,
      zif_sadl_mpc~define           REDEFINITION,
      zif_sadl_read_runtime~execute REDEFINITION.

  PROTECTED SECTION.

    METHODS:
      _get_period_fields REDEFINITION.

  PRIVATE SECTION.
    TYPES:
*        BEGIN OF ts_org_texts,
*          begda     TYPE begda,        " Importing
*          plans     TYPE p0001-plans,  " Importing
*          plans_txt TYPE text150,      " Exporting
*        END OF ts_org_texts,

      tt_tprog TYPE STANDARD TABLE OF zvcpt028_0001-tprog WITH DEFAULT KEY.

    CONSTANTS:
      BEGIN OF ms_const,
        photo TYPE char1 VALUE '9',
      END OF ms_const.

    METHODS:
      _make_report IMPORTING io_xtt                 TYPE REF TO zif_xtt
                             iv_filter              TYPE string
                   RETURNING VALUE(rv_file_content) TYPE xstring,

      _change_schedule_filter EXPORTING et_tprog     TYPE tt_tprog
                                        ev_days_from TYPE zvcpt028_0001-days_from_key_date
                              CHANGING  cv_filter    TYPE string.
ENDCLASS.



CLASS ZCL_PT028_REPORT IMPLEMENTATION.


  METHOD zif_sadl_mpc~define.
    super->zif_sadl_mpc~define( io_model  = io_model
                                iv_entity = iv_entity ).
    DATA(lo_entity) = io_model->get_entity_type( 'ZC_PT028_REPORTType' ).

    lo_entity->set_is_media( abap_true ).
    lo_entity->get_property( 'pernr' )->set_as_content_type( ).
    lo_entity->get_property( 'begda' )->set_as_content_type( ).
    lo_entity->get_property( 'endda' )->set_as_content_type( ).

**********************************************************************
    DATA(lc_fixed_values) = /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values.

    io_model->get_entity_type( 'ZC_PT028_ScheduleRuleType' )->get_property( 'zzbwpa' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_PT028_REPORTType' )->get_property( 'zzbwpa' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'ZC_PT028_ScheduleKindType' )->get_property( 'tprog' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_PT028_REPORTType' )->get_property( 'tprog' )->set_value_list( lc_fixed_values ).
  ENDMETHOD.


  METHOD zif_sadl_read_runtime~execute.
    super->zif_sadl_read_runtime~execute( EXPORTING iv_node_name       = iv_node_name
                                                    it_range           = it_range
                                                    iv_where           = iv_where
                                                    is_requested       = is_requested
                                          CHANGING  ct_data_rows       = ct_data_rows
                                                    cv_number_all_hits = cv_number_all_hits ).
**********************************************************************
**********************************************************************
***      DATA(lv_read_org_txt) = xsdbool( line_exists( is_requested-elements[ table_line = |PLANS_TXT| ] ) ).
***      "DATA(lv_datum) = sy-datum. "TODO read current period


*      LOOP AT ct_data_rows ASSIGNING FIELD-SYMBOL(<ls_row>).

*        DO 1 TIMES.
*          CHECK lv_read_org_txt = abap_true.
*          DATA(ls_org_texts) = CORRESPONDING ts_org_texts( <ls_row> ).
*
*          ls_org_texts-plans_txt = zcl_hr_om_utilities=>get_object_full_name( im_otype = 'S'
*                                                                              im_objid = ls_org_texts-plans
*                                                                              im_subty = 'ZR02'
*                                                                              im_datum = ls_org_texts-begda "lv_datum
*                                                                             ).
*          MOVE-CORRESPONDING ls_org_texts TO <ls_row>.
*        ENDDO.

*      ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_stream_runtime~create_stream.
  ENDMETHOD.


  METHOD zif_sadl_stream_runtime~get_stream.
    TYPES: BEGIN OF ts_key,
             pernr       TYPE pernr-pernr,
             begda       TYPE begda,
             endda       TYPE endda,
             stream_type TYPE char1,
           END OF ts_key.
    DATA(ls_key) = VALUE ts_key( ).
    LOOP AT it_key_tab ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN COMPONENT <ls_key>-name OF STRUCTURE ls_key TO FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = <ls_key>-value.
    ENDLOOP.

***********************************************************************
    IF ls_key-pernr IS INITIAL AND iv_filter IS NOT INITIAL.
      DATA(lv_content) = _make_report( io_xtt    = NEW zcl_xtt_excel_xlsx( NEW zcl_xtt_file_smw0( 'ZR_PT028.XLSX' ) )
                                       iv_filter = iv_filter ).
      DATA(lv_mime_type) = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|.

      io_srv_runtime->set_header(
           VALUE #( name  = 'Content-Disposition'
                    value = |attachment; filename="ZR_PT028.xlsx"| ) ).
    ELSE.
      " Dump ?
      RETURN.
    ENDIF.

    " Any binary file
    er_stream = NEW /iwbep/cl_mgw_abs_data=>ty_s_media_resource(
      value     = lv_content
      mime_type = lv_mime_type ).
  ENDMETHOD.


  METHOD _change_schedule_filter.
    CLEAR: et_tprog,
           ev_days_from.

    " №1 Count
    CONSTANTS cv_needle_count TYPE string VALUE `and ( DAYS_FROM_KEY_DATE = '`.
    CHECK cv_filter CS cv_needle_count.
    DATA(lv_from) = sy-fdpos + strlen( cv_needle_count ).
    ev_days_from = cv_filter+lv_from(2).
    REPLACE FIRST OCCURRENCE OF |{ cv_needle_count }{ ev_days_from }' )| IN cv_filter WITH ||.

    " №2 TPROG
    CONSTANTS cv_needle_tprog TYPE string VALUE `and ( TPROG = '`.
    CHECK cv_filter CS cv_needle_tprog.
    DATA(lv_start) = sy-fdpos.
    lv_from = lv_start + strlen( cv_needle_tprog ).

    FIND FIRST OCCURRENCE OF |' )| IN SECTION OFFSET lv_from OF cv_filter MATCH OFFSET DATA(lv_end).
    lv_end = lv_end - lv_from.
    DATA(lv_all_tprog) = cv_filter+lv_from(lv_end).
    SPLIT lv_all_tprog AT ',' INTO TABLE et_tprog.

    REPLACE FIRST OCCURRENCE OF |{ cv_needle_tprog }{ lv_all_tprog }' )| IN cv_filter WITH ||.
  ENDMETHOD.


  method _get_period_fields.
    rt_period_field = super->_get_period_fields( ).

    DATA(lt_period_field) = VALUE tt_period_field( nullable = abap_true
      ( begda = |BEGDA_DOC|           endda = |ENDDA_DOC| )
      ( begda = |BEGDA_FIO|           endda = |ENDDA_FIO| )
      ( begda = |BEGDA_ADDR|          endda = |ENDDA_ADDR| )
      ( begda = |BEGDA_POS|           endda = |ENDDA_POS| )
      ( begda = |BEGDA_POS_LTEXT|     endda = |ENDDA_POS_LTEXT| ) ).
    APPEND LINES OF lt_period_field TO rt_period_field.
  ENDMETHOD.


  METHOD _make_report.
    DATA(lv_filter) = iv_filter.

    _change_period_filter(   IMPORTING ev_key_date  = DATA(lv_key_date)
                             CHANGING  cv_filter    = lv_filter ).

    _change_schedule_filter( IMPORTING et_tprog     = DATA(lt_tprog)
                                       ev_days_from = DATA(lv_days_from)
                             CHANGING  cv_filter    = lv_filter ).

    _change_org_unit_filter( CHANGING  cv_filter    = lv_filter ).

    DATA lt_alv TYPE STANDARD TABLE OF zc_pt028_report.
    SELECT pernr, begda, endda, ename, rus_fio, birth_date, zzbirthplace, perid, nomer, datbg, passl,
           plans, plans_txt, phone,
           bezei, btext, state, ort01, ort02, stras, hsnmr, posta
       INTO CORRESPONDING FIELDS OF TABLE @lt_alv
    FROM ('ZC_PT028_REPORT')
    WHERE (lv_filter).

**********************************************************************
**********************************************************************
    TYPES: BEGIN OF ts_column,
             datum TYPE datum,
             fm    TYPE string,
           END OF ts_column,
           tt_column TYPE STANDARD TABLE OF ts_column WITH DEFAULT KEY,

           BEGIN OF ts_row.
             INCLUDE TYPE zc_pt028_report.
           TYPES:
             unq_t TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line,
             unq_s TYPE string,
             days  TYPE string_table,
           END OF ts_row,
           tt_row TYPE STANDARD TABLE OF ts_row WITH DEFAULT KEY,

           BEGIN OF ts_root,
             a TYPE tt_column,
             t TYPE tt_row,
           END OF ts_root.
**********************************************************************
**********************************************************************
    DATA(lt_row) = CORRESPONDING tt_row( lt_alv ).

*      " fill plans_txt
*      zif_sadl_read_runtime~execute( EXPORTING is_requested = VALUE #( elements = VALUE #( ( |PLANS_TXT| ) ) )
*                                     CHANGING  ct_data_rows = lt_row ).

    " fill schedule
    DATA(lo_schedule) = NEW zcl_pt028_schedule( ).
    DATA(ls_range)    = VALUE zcl_hr_month=>ts_range( begda = lv_key_date ).
    ls_range-endda    = ls_range-begda + lv_days_from - 1.

    SORT lt_tprog BY table_line.
    LOOP AT lt_row ASSIGNING FIELD-SYMBOL(<ls_row>).
      DATA(lt_pdpsp) = lo_schedule->get_schedule( iv_pernr = <ls_row>-pernr
                                                  is_dates = ls_range ).
      " if no schedule then fill with blanks
      DO lv_days_from TIMES.
        APPEND INITIAL LINE TO <ls_row>-days ASSIGNING FIELD-SYMBOL(<lv_day>).
        ASSIGN lt_pdpsp[ sy-tabix ] TO FIELD-SYMBOL(<ls_pdpsp>).
        CHECK sy-subrc = 0.

        <lv_day> = <ls_pdpsp>-tprog.

        READ TABLE lt_tprog TRANSPORTING NO FIELDS BINARY SEARCH
          WITH KEY table_line = <ls_pdpsp>-tprog.
        CHECK sy-subrc = 0.

        INSERT |#{ <lv_day> }| INTO TABLE <ls_row>-unq_t.
      ENDDO.
    ENDLOOP.

    LOOP AT lt_row ASSIGNING <ls_row> WHERE unq_t IS NOT INITIAL.
      <ls_row>-unq_s = concat_lines_of( table = <ls_row>-unq_t sep = |,| ) && `,`.
    ENDLOOP.

    rv_file_content = io_xtt->merge( VALUE ts_root(
                                       a = VALUE #( FOR i = 0 UNTIL i >= lv_days_from ( datum = lv_key_date + i
                                                                                        fm    = |\{R-T:v-days[ { i + 1 } ]\}| ) )
                                       t = lt_row
                                     )
                           )->get_raw( ).
  ENDMETHOD.
ENDCLASS.
