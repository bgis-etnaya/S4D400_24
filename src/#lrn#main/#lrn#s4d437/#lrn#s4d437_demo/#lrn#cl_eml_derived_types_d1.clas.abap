CLASS /lrn/cl_eml_derived_types_d1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /LRN/CL_EML_DERIVED_TYPES_D1 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


* Derived types for READ
**********************************************************************
" For EML (Internal tables)
DATA travels_in  TYPE TABLE FOR READ IMPORT /lrn/437b_r_travel.
DATA travels_res TYPE TABLE FOR READ RESULT /lrn/437b_r_travel.

" Work areas
DATA travel_in  TYPE STRUCTURE FOR READ IMPORT /lrn/437b_r_travel.
DATA travel_res TYPE Structure FOR READ RESULT /lrn/437b_r_travel.

* Derived types for UPDATE
**********************************************************************
" For EML (Internal table)
DATA travels_upd TYPE TABLE FOR UPDATE /lrn/437b_r_travel.

" Work area
DATA travel_upd TYPE STRUCTURE FOR UPDATE /lrn/437b_r_travel.

* Derived types for DELETE
**********************************************************************
" For EML (Internal table)
DATA travels_del TYPE TABLE FOR DELETE /lrn/437b_r_travel.

" Work area
DATA travel_del TYPE STRUCTURE FOR DELETE /lrn/437b_r_travel.

* Derived types for CREATE
**********************************************************************
" For EML(Internal table)
DATA travels_new TYPE TABLE FOR CREATE /lrn/437b_r_travel.

" Work area
DATA travel_new TYPE STRUCTURE FOR CREATE /lrn/437b_r_travel.

* Derived types for EXECUTE
**********************************************************************
" For EML (Internal tables)
DATA travels_exec_in    TYPE TABLE FOR ACTION IMPORT  /lrn/437b_r_travel~cancel_travel.
*DATA travels_exec_res   TYPE TABLE FOR ACTION RESULT  /lrn/437b_r_travel~cancel_travel.
*DATA travels_exec_req TYPE TABLE FOR ACTION REQUEST /lrn/437b_r_travel~cancel_travel.

" Work areas
DATA travel_exec_in    TYPE STRUCTURE FOR ACTION IMPORT  /lrn/437b_r_travel~cancel_travel.
*DATA travel_exec_res   TYPE STRUCTURE FOR ACTION RESULT  /lrn/437b_r_travel~cancel_travel.
*DATA travel_exec_req   TYPE STRUCTURE FOR ACTION REQUEST /lrn/437b_r_travel~cancel_travel.

  ENDMETHOD.
ENDCLASS.
