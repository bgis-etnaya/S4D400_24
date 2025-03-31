CLASS lhc_class DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR class RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE class.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE class.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE class.

    METHODS read FOR READ
      IMPORTING keys FOR READ class RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK class.

ENDCLASS.

CLASS lhc_class IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " helper variable to fill response parameter result
    DATA l_result LIKE LINE OF result.

* Loop over keys of affected travel agencies
**********************************************************************

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      CLEAR l_result.

      l_result-%tky = <key>-%tky.

      IF requested_authorizations-%update = if_abap_behv=>mk-on.

* call legacy function module to check authorization for update
**********************************************************************

        CALL FUNCTION '/LRN/437_FLCLASS_AUTH'
          EXPORTING
            iv_class_id  = <key>-classid
            iv_activity  = '02'
          EXCEPTIONS
            no_authority = 1.
        IF sy-subrc <> 0.
          l_result-%update = if_abap_behv=>auth-unauthorized.
        ENDIF.
      ENDIF.

      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
        CALL FUNCTION '/LRN/437_FLCLASS_AUTH'
          EXPORTING
            iv_class_id  = <key>-classid
            iv_activity  = '06'
          EXCEPTIONS
            no_authority = 1.
        IF sy-subrc <> 0.
          l_result-%delete = if_abap_behv=>auth-unauthorized.
        ENDIF.
      ENDIF.

* Add outcome to response parameter result
**********************************************************************

      APPEND l_result
          TO result.

    ENDLOOP.
  ENDMETHOD.

  METHOD create.

    " actual parameters for function module call
    DATA class TYPE /lrn/437_s_class.
    DATA messages TYPE symsg_tab.
    DATA class_id TYPE /lrn/437_s_class-class_id.

* Loop over affected travel agencies (entities)
**********************************************************************

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

* Prepare call of legacy function module
**********************************************************************

      class = CORRESPONDING #(  <entity>
                                    MAPPING FROM ENTITY
                                    USING CONTROL ).


* Call legacy function module for create in buffer
**********************************************************************

      CALL FUNCTION '/LRN/437_FLCLASS_CREATE'
        EXPORTING
          is_class       = class
        IMPORTING
          et_messages    = messages
        EXCEPTIONS
          wrong_input    = 1
          already_locked = 4.
      IF sy-subrc <> 0.
        " in case of error
        " mark as failed
        APPEND VALUE #( %cid = <entity>-%cid  )
            TO failed-class.

        " and map messages
        LOOP AT messages ASSIGNING FIELD-SYMBOL(<ls_message>)
                             WHERE msgty = 'E' OR msgty = 'A'.
          APPEND VALUE #( %cid = <entity>-%cid
                          %msg = me->new_message(
                                   id       = <ls_message>-msgid
                                   number   = <ls_message>-msgno
                                   severity = me->ms-error
                                   v1       = <ls_message>-msgv1
                                   v2       = <ls_message>-msgv2
                                   v3       = <ls_message>-msgv3
                                   v4       = <ls_message>-msgv4
                                 )
                          )
              TO reported-class.

        ENDLOOP.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    " actual parameters for function module call
    DATA class  TYPE /lrn/437_s_class.
    DATA classx TYPE /lrn/437_s_classx.
    DATA messages TYPE symsg_tab.

* Loop over affected travel agencies (entities)
**********************************************************************

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

* Prepare call of legacy function module
**********************************************************************

* map data structure from RAP field names to legacy field names

      class = CORRESPONDING #(  <entity>
                                    MAPPING FROM ENTITY ).

      classx = CORRESPONDING #(  <entity>
                                    MAPPING FROM ENTITY
                                    USING CONTROL ).

* Call legacy function module for update in buffer
**********************************************************************

      CALL FUNCTION '/LRN/437_FLCLASS_UPDATE'
        EXPORTING
          is_class       = class
          is_classx      = classx
        IMPORTING
          et_messages    = messages
        EXCEPTIONS
          wrong_input    = 1
          not_found      = 2
          already_locked = 3
          no_auth        = 4.
      IF sy-subrc <> 0.
        " in case of error
        " mark as failed
        APPEND VALUE #( %tky = <entity>-%tky  )
            TO failed-class.

        " and map messages
        LOOP AT messages ASSIGNING FIELD-SYMBOL(<message>)
                             WHERE msgty = 'E' OR msgty = 'A'.
          APPEND VALUE #( %tky = <entity>-%tky
                          %msg = me->new_message(
                                   id       = <message>-msgid
                                   number   = <message>-msgno
                                   severity = me->ms-error
                                   v1       = <message>-msgv1
                                   v2       = <message>-msgv2
                                   v3       = <message>-msgv3
                                   v4       = <message>-msgv4
                                 )
                          )
              TO reported-class.

        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.
    " actual parameters for function module call
    DATA messages TYPE symsg_tab.

* Loop over affected travel agencies (entities)
**********************************************************************

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

* Call legacy function module to delete in buffer
**********************************************************************

      CALL FUNCTION '/LRN/437_FLCLASS_DELETE'
        EXPORTING
          iv_class_id    = <key>-classid
        IMPORTING
          et_messages    = messages
        EXCEPTIONS
          wrong_input    = 1
          not_found      = 2
          already_locked = 3
          no_auth        = 4.
      IF sy-subrc <> 0.
        " in case of error
        " mark as failed
        APPEND VALUE #( %tky = <key>-%tky  )
            TO failed-class.

        " and map messages
        LOOP AT messages ASSIGNING FIELD-SYMBOL(<ls_message>)
                             WHERE msgty = 'E' OR msgty = 'A'.
          APPEND VALUE #( %tky = <key>-%tky
                          %msg = me->new_message(
                                   id       = <ls_message>-msgid
                                   number   = <ls_message>-msgno
                                   severity = me->ms-error
                                   v1       = <ls_message>-msgv1
                                   v2       = <ls_message>-msgv2
                                   v3       = <ls_message>-msgv3
                                   v4       = <ls_message>-msgv4
                                 )
                          )
              TO reported-class.

        ENDLOOP.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
    " helper variable to fill response parameter result
    DATA l_result LIKE LINE OF result.

    " actual parameters for function module call
    DATA class  TYPE /lrn/437_s_class.
    DATA messages TYPE symsg_tab.

* Loop over keys of requested booking classes
**********************************************************************

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

* call legacy function module to read from buffer or DB
**********************************************************************

      CALL FUNCTION '/LRN/437_FLCLASS_READ'
        EXPORTING
          iv_class_id   = <key>-classid
          iv_use_buffer = abap_true
        IMPORTING
          et_messages   = messages
        EXCEPTIONS
          not_found     = 1.
      IF sy-subrc <> 0.
        " in case of error
        " mark as failed
        APPEND VALUE #( %tky = <key>-%tky  )
            TO failed-class.

        " and map messages
        LOOP AT messages ASSIGNING FIELD-SYMBOL(<message>)
                             WHERE msgty = 'E' OR msgty = 'A'.
          APPEND VALUE #( %tky = <key>-%tky
                          %msg = me->new_message(
                                   id       = <message>-msgid
                                   number   = <message>-msgno
                                   severity = me->ms-error
                                   v1       = <message>-msgv1
                                   v2       = <message>-msgv2
                                   v3       = <message>-msgv3
                                   v4       = <message>-msgv4
                                 )
                          )
              TO reported-class.
        ENDLOOP.

      ELSE.
        " map outcome to response parameter result
        l_result = CORRESPONDING #( class MAPPING TO ENTITY ).

        "and calculate concatenated field for etag handling
        l_result-allelements = l_result-priority &&
                               l_result-description.

* Add outcome to response parameter result
**********************************************************************

        APPEND l_result TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD lock.

    " actual parameters for function module call
    DATA messages TYPE symsg_tab.

* Loop over keys of affected travel agencies
**********************************************************************

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

* call legacy function module to set lock
**********************************************************************
      CALL FUNCTION '/LRN/437_FLCLASS_LOCK'
        EXPORTING
          iv_class_id    = <key>-classid
        IMPORTING
          et_messages    = messages
        EXCEPTIONS
          already_locked = 1.
      IF sy-subrc <> 0.

        " in case of error
        " mark as failed
        APPEND VALUE #( classid = <key>-classid  )
            TO failed-class.

        " and map messages
        LOOP AT messages ASSIGNING FIELD-SYMBOL(<ls_message>)
                             WHERE msgty = 'E' OR msgty = 'A'.
          APPEND VALUE #( classid = <key>-classid
                          %msg = me->new_message(
                                   id       = <ls_message>-msgid
                                   number   = <ls_message>-msgno
                                   severity = me->ms-error
                                   v1       = <ls_message>-msgv1
                                   v2       = <ls_message>-msgv2
                                   v3       = <ls_message>-msgv3
                                   v4       = <ls_message>-msgv4
                                 )
                          )
              TO reported-class.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_437_r_class DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_437_r_class IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    CALL FUNCTION '/LRN/437_FLCLASS_SAVE'
      EXCEPTIONS
        error_in_create = 1
        error_in_update = 2
        error_in_delete = 3
        OTHERS          = 4.
    IF sy-subrc <> 0.

      APPEND  me->new_message(
                   id       = '/LRN/S4D437'
                   number   = '650'
                   severity = me->ms-error
                            )
          TO reported-%other.

    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
