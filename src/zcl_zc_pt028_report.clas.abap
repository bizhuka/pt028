class ZCL_ZC_PT028_REPORT definition
  public
  inheriting from CL_SADL_GTK_EXPOSURE_MPC
  final
  create public .

public section.
protected section.

  methods GET_PATHS
    redefinition .
  methods GET_TIMESTAMP
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZC_PT028_REPORT IMPLEMENTATION.


  method GET_PATHS.
et_paths = VALUE #(
( `CDS~ZC_PT028_REPORT` )
).
  endmethod.


  method GET_TIMESTAMP.
RV_TIMESTAMP = 20230323134326.
  endmethod.
ENDCLASS.
