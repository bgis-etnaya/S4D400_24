CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION travel~cancel_travel.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING #( keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).

      DATA(rc) =  /lrn/cl_s4d437_model=>authority_check(
                              i_agencyid  = <result>-agencyid
                              i_actvt     = '03' ).

      IF rc <> 0.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        <result>-%update               = if_abap_behv=>auth-unauthorized.
      ELSE.
        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
        <result>-%update               = if_abap_behv=>auth-allowed.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD cancel_travel.

    READ ENTITIES OF /lrn/437b_r_travel IN LOCAL MODE
      ENTITY travel
        ALL FIELDS
       WITH CORRESPONDING #( keys )
     RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).

      IF travel-status <> 'C'.

        MODIFY ENTITIES OF /lrn/437b_r_travel IN LOCAL MODE
          ENTITY travel
            UPDATE
            FIELDS ( status )
            WITH VALUE #( (
                   %tky   = travel-%tky
                   status = 'C'
                 ) ).
      ELSE.
        APPEND VALUE #( %tky = travel-%tky )
            TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
*                        %msg = NEW /lrn/cm_s4D437(
*                                     textid = /lrn/cm_s4D437=>already_canceled
                        %msg = NEW /lrn/cm_437b_travel(
                                     textid = /lrn/cm_437b_travel=>already_canceled
                                   )
                      )
            TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
