CLASS zcl_pt028_schedule DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC

  GLOBAL FRIENDS zcl_aqo_option.

  PUBLIC SECTION.

    INTERFACES:
      zif_sadl_exit,
      zif_sadl_read_runtime.

    TYPES:
      tt_schedule TYPE STANDARD TABLE OF zc_pt028_schedule WITH DEFAULT KEY,

      BEGIN OF ts_kind,
        kind  TYPE zdpt028_schedule-kind,
        name  TYPE text70,
        tprog TYPE RANGE OF char7, "zdpt028_schedule-tprog,
        color TYPE char7,
      END OF ts_kind,
      tt_kind TYPE STANDARD TABLE OF ts_kind WITH DEFAULT KEY.

    DATA:
      t_kind TYPE tt_kind READ-ONLY.

    METHODS:
      constructor,

      get_schedule IMPORTING iv_pernr        TYPE pernr-pernr
                             is_dates        TYPE zcl_hr_month=>ts_range
                   RETURNING VALUE(rt_pdpsp) TYPE zcl_214=>pdpsp_tab.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ts_key,
             pernr TYPE pernr-pernr,
             datum TYPE d,
           END OF ts_key.

    METHODS:
      _get_transformed IMPORTING it_pdpsp           TYPE zcl_214=>pdpsp_tab
                       RETURNING VALUE(rt_schedule) TYPE  tt_schedule.
ENDCLASS.



CLASS ZCL_PT028_SCHEDULE IMPLEMENTATION.


  METHOD constructor.
    zcl_aqo_option=>create( io_data      = me
                            iv_option_id = 'SCHEDULE' ).
  ENDMETHOD.


  METHOD get_schedule.
    DATA(lt_auth)  = VALUE hrsp_tty_auth_infty_tab( ).
    DO 3 TIMES.
      DATA(lt_pernr)   = VALUE zcl_214=>pdpnr_tab( ( pernr = iv_pernr ) ).
      DATA(lt_pdsppsp) = VALUE zcl_214=>pdsppsp_tab( ).
      rt_pdpsp         = VALUE #( ).

      CALL FUNCTION 'HR_PERSON_READ_WORK_SCHEDULE'
        EXPORTING
          begin_date        = is_dates-begda
          end_date          = is_dates-endda
        TABLES
          pernr_tab         = lt_pernr
          day_psp           = lt_pdsppsp
          psp               = rt_pdpsp
        CHANGING
          ch_auth_infty_tab = lt_auth[]
        EXCEPTIONS
          OTHERS            = 0.

      " Next attempt
      IF line_exists( lt_auth[ is_authorized = '-' ] ). "#EC CI_SORTSEQ
        LOOP AT lt_auth ASSIGNING FIELD-SYMBOL(<ls_auth>).
          <ls_auth>-is_authorized = 'X'.
        ENDLOOP.
        CONTINUE.
      ENDIF.

      CHECK rt_pdpsp[] IS NOT INITIAL.

      RETURN.
    ENDDO.
  ENDMETHOD.


  METHOD zif_sadl_read_runtime~execute.
    DATA(ls_key) = CORRESPONDING ts_key( is_filter ).

    DATA(ls_range) = zcl_hr_month=>get_range( ls_key-datum(6) && '01' ).
*    ADD: -1 TO ls_range-begda,
*          1 TO ls_range-endda.

    DATA(lt_pdpsp) = get_schedule( iv_pernr    = ls_key-pernr
                                   is_dates    = ls_range ).
    ct_data_rows = CORRESPONDING #( _get_transformed( lt_pdpsp ) ).
  ENDMETHOD.


  METHOD _get_transformed.
    SELECT DISTINCT motpr, tprog, sobeg, soend INTO TABLE @DATA(lt_info) "#EC CI_BYPASS "#EC CI_GENBUFF
    FROM t550a
    WHERE endda = '99991231' AND regel = 'KZ'
    ORDER BY motpr, tprog.

    DATA(lv_prev_tprog) = VALUE tprog( ).
    LOOP AT it_pdpsp ASSIGNING FIELD-SYMBOL(<ls_pdpsp>).
      IF lv_prev_tprog <> <ls_pdpsp>-tprog.
        APPEND CORRESPONDING #( <ls_pdpsp> ) TO rt_schedule ASSIGNING FIELD-SYMBOL(<ls_schedule>).
        <ls_schedule>-begda = <ls_schedule>-endda = <ls_pdpsp>-datum.
      ELSE.
        <ls_schedule>-endda = <ls_pdpsp>-datum.
        CONTINUE.
      ENDIF.
      lv_prev_tprog = <ls_pdpsp>-tprog.

*       Change color
      LOOP AT t_kind ASSIGNING FIELD-SYMBOL(<ls_kind>).
        CHECK <ls_schedule>-tprog IN <ls_kind>-tprog[].

        <ls_schedule>-kind  = <ls_kind>-kind.
        <ls_schedule>-color = <ls_kind>-color.
        EXIT. " 1st rule
      ENDLOOP.

      READ TABLE lt_info ASSIGNING FIELD-SYMBOL(<ls_info>) BINARY SEARCH
       WITH KEY  motpr = <ls_pdpsp>-motpr tprog = <ls_pdpsp>-tprog.

      " IS NOT INITIAL
      CHECK sy-subrc = 0 AND <ls_info>-sobeg <> `      ` AND <ls_info>-soend <> `      `.
      <ls_schedule>-info = |{ <ls_info>-sobeg(2) }:{ <ls_info>-sobeg+2(2) } - { <ls_info>-soend(2) }:{ <ls_info>-soend+2(2) }|.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
