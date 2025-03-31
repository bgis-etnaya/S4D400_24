CLASS lsc_/lrn/437h_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

  PRIVATE SECTION.

    METHODS
      map_message
        IMPORTING
          i_msg        TYPE symsg
        RETURNING
          VALUE(r_msg) TYPE REF TO if_abap_behv_message.

ENDCLASS.

CLASS lsc_/lrn/437h_r_travel IMPLEMENTATION.

  METHOD save_modified.

    DATA(model) = NEW /lrn/cl_s4d437_tritem(
                        i_table_name = '/LRN/437h_TRITEM'
                      ).

    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).

* Without message handling
*        model->delete_item( i_uuid = <item_d>-itemuuid ).
* With message handling
      DATA(msg_d) = model->delete_item( i_uuid = <item_d>-itemuuid ).

      IF msg_d IS NOT INITIAL.
        APPEND VALUE #( %tky-itemuuid = <item_d>-itemuuid
                        %msg = map_message( msg_d )
                      )
            TO reported-item.
      ENDIF.

    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>).

*      model->create_item(
*               i_item = CORRESPONDING #( <item_c> MAPPING FROM ENTITY )
*            ).

      DATA(msg_c) = model->create_item(
                       i_item = CORRESPONDING #( <item_c> MAPPING FROM ENTITY )
                    ).

      IF msg_c IS NOT INITIAL.
        APPEND VALUE #( %tky-itemuuid = <item_c>-itemuuid
                        %msg = map_message( msg_c )
                      )
            TO reported-item.
      ENDIF.

    ENDLOOP.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item_u>).

*       model->update_item(
*               i_item  = CORRESPONDING #( <item_u> MAPPING FROM ENTITY )
*               i_itemx = CORRESPONDING #( <item_u> MAPPING FROM ENTITY
*                                                   USING CONTROL )
*             ).

      DATA(msg_u) = model->update_item(
               i_item  = CORRESPONDING #( <item_u> MAPPING FROM ENTITY )
               i_itemx = CORRESPONDING #( <item_u> MAPPING FROM ENTITY
                                                   USING CONTROL )
             ).

      IF msg_u IS NOT INITIAL.
        APPEND VALUE #( %tky-itemuuid = <item_u>-itemuuid
                        %msg = map_message( msg_u )
                      )
            TO reported-item.
      ENDIF.

    ENDLOOP.

* Raise Business Event travel created
    IF create-travel IS NOT INITIAL.

      RAISE ENTITY EVENT /lrn/437h_r_travel~travelcreated
          FROM VALUE #( FOR <new_travel> IN create-travel
                        (
                          agencyid = <new_travel>-agencyid
                          travelid = <new_travel>-travelid
                          origin = '/LRN/437G_R_TRAVEL'
                        )
                       ).
    ENDIF.

  ENDMETHOD.

  METHOD map_message.

* Map message type to severity
    DATA(severity) = SWITCH #( i_msg-msgty
          WHEN 'S' THEN if_abap_behv_message=>severity-success
          WHEN 'I' THEN if_abap_behv_message=>severity-information
          WHEN 'W' THEN if_abap_behv_message=>severity-warning
          WHEN 'E' THEN if_abap_behv_message=>severity-error
          ELSE          if_abap_behv_message=>severity-none
          ).

* More old-fashioned alternative with CASE ... ENDCASE structure
*    DATA severity TYPE if_abap_behv_message=>t_severity.
*    CASE i_msg-msgty.
*      WHEN 'S'.
*        severity = if_abap_behv_message=>severity-success.
*      WHEN 'I'.
*        severity = if_abap_behv_message=>severity-information.
*      WHEN 'W'.
*        severity = if_abap_behv_message=>severity-warning.
*      WHEN 'E'.
*        severity = if_abap_behv_message=>severity-error.
*      WHEN OTHERS.
*        severity = if_abap_behv_message=>severity-none.
*    ENDCASE.

* create Message object
    r_msg = me->new_message(
              id       = i_msg-msgid
              number   = i_msg-msgno
              severity = severity
              v1       = i_msg-msgv1
              v2       = i_msg-msgv2
              v3       = i_msg-msgv3
              v4       = i_msg-msgv4
            ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
*
  PRIVATE SECTION.
*
    METHODS validateflightdate FOR VALIDATE ON SAVE
      IMPORTING keys FOR item~validateflightdate.
*
    METHODS determinetraveldates FOR DETERMINE ON SAVE
      IMPORTING keys FOR item~determinetraveldates.


ENDCLASS.
*
CLASS lhc_item IMPLEMENTATION.
*
*
  METHOD validateflightdate.

    CONSTANTS c_area TYPE string VALUE `FLIGHTDATE`.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
       ENTITY item
       FIELDS ( agencyid travelid flightdate )
       WITH CORRESPONDING #(  keys )
       RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

      APPEND VALUE #( %tky = <item>-%tky
                      %state_area = c_area
                      %path = CORRESPONDING #(  <item> )
                     )
          TO reported-item.

      IF <item>-flightdate IS INITIAL.

        APPEND VALUE #(  %tky = <item>-%tky )
            TO failed-item.

        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-flightdate = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> )
                       )
            TO reported-item.
      ELSEIF <item>-flightdate < cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #(  %tky = <item>-%tky )
            TO failed-item.

        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     textid     = /lrn/cm_s4d437=>flight_date_past
                                   )
                        %element-flightdate = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> )
                       )
        TO reported-item.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.
*
  METHOD determinetraveldates.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
         ENTITY item

         FIELDS ( flightdate )
         WITH CORRESPONDING #(  keys )
         RESULT DATA(items)

         BY \_travel
         FIELDS ( begindate enddate )
         WITH CORRESPONDING #(  keys )
         RESULT DATA(travels)
         LINK DATA(link).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

*      ASSIGN travels[ %tky = link[ source-%tky = <item>-%tky ]-target-%tky ]
*          TO FIELD-SYMBOL(<travel>).

*      READ TABLE travels ASSIGNING FIELD-SYMBOL(<travel>)
*            WITH KEY %tky = link[ source-%tky = <item>-%tky ]-target-%tky.
*
      ASSIGN travels[ KEY id %tky = link[ KEY id source-%tky = <item>-%tky ]-target-%tky ]
          TO FIELD-SYMBOL(<travel>).

      IF <travel>-enddate < <item>-flightdate.
        <travel>-enddate = <item>-flightdate.
      ENDIF.

      IF <item>-flightdate >= cl_abap_context_info=>get_system_date( )
         AND <item>-flightdate  < <travel>-begindate.
        <travel>-begindate = <item>-flightdate.
      ENDIF.


    ENDLOOP.

    MODIFY ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
    ENTITY travel
      UPDATE
      FIELDS ( begindate enddate )
         WITH CORRESPONDING #(  travels ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION travel~cancel_travel.
    METHODS validatedescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedescription.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.
    METHODS validatebegindate FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatebegindate.

    METHODS validatedatesequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedatesequence.

    METHODS validateenddate FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateenddate.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.



ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING #( keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).

      DATA(rc) =  /lrn/cl_s4d437_model=>authority_check(
                              i_agencyid  = <result>-agencyid
                              i_actvt     = '02' ).

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

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
      ENTITY travel
        ALL FIELDS
       WITH CORRESPONDING #( keys )
     RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).

      IF travel-status <> 'C'.

        MODIFY ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
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
                        %msg = NEW /lrn/cm_s4d437(
                                     textid = /lrn/cm_s4d437=>already_canceled
                                   )
                      )
            TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validatedescription.

    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
      ENTITY travel
      FIELDS ( description )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.

      IF <travel>-description IS INITIAL.

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-description = if_abap_behv=>mk-on
                        %state_area = c_area
                       )
            TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatecustomer.

    CONSTANTS c_area TYPE string VALUE `CUST`.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
      ENTITY travel
      FIELDS ( customerid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.

      IF <travel>-customerid IS INITIAL.

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-customerid = if_abap_behv=>mk-on
                        %state_area = c_area
                       )
            TO reported-travel.
      ELSE.

        SELECT SINGLE
          FROM /dmo/i_customer
        FIELDS customerid
         WHERE customerid = @<travel>-customerid
          INTO @DATA(dummy).

        IF sy-subrc <> 0.

          APPEND VALUE #(  %tky = <travel>-%tky )
              TO failed-travel.

          APPEND VALUE #( %tky = <travel>-%tky
                          %msg = NEW /lrn/cm_s4d437(
                                       textid     = /lrn/cm_s4d437=>customer_not_exist
                                       customerid = <travel>-customerid
                                     )
                          %element-customerid = if_abap_behv=>mk-on
                          %state_area = c_area
                         )
          TO reported-travel.

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatebegindate.

    CONSTANTS c_area TYPE string VALUE `BEGINDATE`.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( begindate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.
      IF <travel>-begindate IS INITIAL.

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-begindate = if_abap_behv=>mk-on
                        %state_area = c_area
                       )
            TO reported-travel.
      ELSEIF <travel>-begindate < cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     textid     = /lrn/cm_s4d437=>begin_date_past
                                   )
                        %element-begindate = if_abap_behv=>mk-on
                        %state_area = c_area
                       )
        TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateenddate.
    CONSTANTS c_area TYPE string VALUE `ENDDATE`.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( enddate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.

      IF <travel>-enddate IS INITIAL.

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-enddate = if_abap_behv=>mk-on
                      %state_area = c_area
                       )
            TO reported-travel.
      ELSEIF <travel>-enddate < cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     textid     = /lrn/cm_s4d437=>end_date_past
                                   )
                        %element-enddate = if_abap_behv=>mk-on
                      %state_area = c_area
                       )
        TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedatesequence.
    CONSTANTS c_area TYPE string VALUE `SEQUENCE`.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( begindate enddate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.

      IF <travel>-enddate < <travel>-begindate.
        APPEND VALUE #(  %tky = <travel>-%tky )
           TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>dates_wrong_sequence
                                   )
                    %element = VALUE #(
                                     begindate = if_abap_behv=>mk-on
                                     enddate   = if_abap_behv=>mk-on
                                )
                    %state_area = c_area
                       )
             TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user(  ).

    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-agencyid = agencyid.
      <mapping>-travelid = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( status begindate enddate changedby )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND CORRESPONDING #( <travel> ) TO result
                 ASSIGNING FIELD-SYMBOL(<result>).

      IF <travel>-%is_draft = if_abap_behv=>mk-on. " Special Handling for Drafts
        " Try to Read BeginDate and EndDate from active instance
        READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
        ENTITY travel
          FIELDS ( begindate enddate )
          WITH VALUE #( ( %key = <travel>-%key
                          %is_draft = if_abap_behv=>mk-off   "optional
                      ) )
          RESULT DATA(travels_activ).
        IF travels_activ IS NOT INITIAL.
          " edit draft (active instance exists)
          " use BeginDate and EndDate in active instance for feature control
          <travel>-begindate = travels_activ[ 1 ]-begindate.
          <travel>-enddate   = travels_activ[ 1 ]-enddate.
        ELSE.
          " new draft - use initial values for feature control.
          CLEAR <travel>-begindate.
          CLEAR <travel>-enddate.
        ENDIF.
      ENDIF.

*      " Special Handling for Edit Drafts (ChangedBy not initial)
*      IF <travel>-%is_draft IS NOT INITIAL and <travel>-ChangedBy is not initial.
*      " Read BeginDate and EndDate from active instance
*        READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
*        ENTITY travel
*          FIELDS ( begindate enddate )
*          WITH VALUE #( ( %key = <travel>-%key ) )
*          RESULT DATA(travels_activ).
*        IF travels_activ IS NOT INITIAL.
*        " use BeginDate and EndDate of active instance for feature control
*          <travel>-begindate = travels_activ[ 1 ]-begindate.
*          <travel>-enddate   = travels_activ[ 1 ]-enddate.
*        ENDIF.
*      ENDIF.

      IF <travel>-status = 'C' OR
         ( <travel>-enddate IS NOT INITIAL AND
           <travel>-enddate < cl_abap_context_info=>get_system_date( )
         ).

        <result>-%update               = if_abap_behv=>fc-o-disabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.

      ELSE.

        <result>-%update               = if_abap_behv=>fc-o-enabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.

      ENDIF.

      IF <travel>-begindate IS NOT INITIAL AND
         <travel>-begindate < cl_abap_context_info=>get_system_date( ).

        <result>-%field-customerid = if_abap_behv=>fc-f-read_only.
        <result>-%field-begindate  = if_abap_behv=>fc-f-read_only.

      ELSE.

        <result>-%field-customerid = if_abap_behv=>fc-f-mandatory.
        <result>-%field-begindate  = if_abap_behv=>fc-f-mandatory.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD determineduration.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
       ENTITY travel
       FIELDS (  begindate enddate )
       WITH CORRESPONDING #( keys )
       RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-duration = <travel>-enddate - <travel>-begindate.
    ENDLOOP.


    MODIFY ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
       ENTITY travel
         UPDATE
         FIELDS ( duration )
         WITH CORRESPONDING #( travels ).

  ENDMETHOD.

ENDCLASS.
