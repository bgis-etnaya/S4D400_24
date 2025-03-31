CLASS /lrn/cl_s4d437_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! <p class="shorttext synchronized" lang="en">Retrieve the Travel Agency a User is assigned to</p>
    CLASS-METHODS get_agency_by_user
      IMPORTING
        i_user          TYPE syuname DEFAULT sy-uname
      RETURNING
        VALUE(r_result) TYPE /dmo/agency_id .
    "! <p class="shorttext synchronized" lang="en">This method simulates a number range object</p>
    CLASS-METHODS get_next_travelid
      RETURNING
        VALUE(r_result) TYPE /dmo/travel_id .
    "! <p class="shorttext synchronized" lang="en">This method simulates an authority check</p>
    CLASS-METHODS authority_check
      IMPORTING
        i_agencyid      TYPE /dmo/agency_id
        i_actvt         TYPE activ_auth
      RETURNING
        VALUE(r_result) TYPE sysubrc .
protected section.
  PRIVATE SECTION.

    CONSTANTS  cv_nr_interval        TYPE cl_numberrange_runtime=>nr_interval VALUE '01'.
    CONSTANTS  cv_nr_object          TYPE cl_numberrange_runtime=>nr_object   VALUE '/DMO/TRAVL' ##NO_TEXT.

ENDCLASS.



CLASS /LRN/CL_S4D437_MODEL IMPLEMENTATION.


  METHOD authority_check.

* This method simulates an authority check

    IF i_actvt = '06'.
      " disallow deletion for all existing Agencies
      r_result = 4.

    ELSEIF i_actvt = '01' OR i_actvt = '02'.
      " use mockup for create and update
      r_result = 4.
      SELECT SINGLE
        FROM /lrn/437_users
      FIELDS 0
      WHERE user_id = @sy-uname
      AND agency_id = @i_agencyid
    INTO @r_result.

    ELSE.
      " use real authority check for read
      AUTHORITY-CHECK OBJECT '/LRN/AGCY'
      ID '/LRN/AGCY' FIELD i_agencyid
      ID 'ACTVT'     FIELD i_actvt.

      r_result = sy-subrc.
    ENDIF.

  ENDMETHOD.


  METHOD get_agency_by_user.
* this method simulates a User/Travel Agency assignment
    SELECT SINGLE FROM /lrn/437_users
    FIELDS *
     WHERE user_id = @i_user
      INTO @DATA(mapping).

    IF sy-subrc = 0.
      r_result = mapping-agency_id.
    ELSE.                    " User not like TRAIN-## or user in learning system access
      r_result = '070000'.  " Use travel agency 070000
    ENDIF.

  ENDMETHOD.


  METHOD get_next_travelid.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = cv_nr_interval
            object      = cv_nr_object
          IMPORTING
            number      = DATA(new_number)
          ).

        r_result = EXACT #(  new_number ).

      CATCH cx_number_ranges.
        "handle exception
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
