FUNCTION /lrn/437_flclass_delete.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_CLASS_ID) TYPE  /LRN/437_S_CLASS-CLASS_ID
*"  EXPORTING
*"     REFERENCE(ET_MESSAGES) TYPE  SYMSG_TAB
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      NOT_FOUND
*"      ALREADY_LOCKED
*"      NO_AUTH
*"----------------------------------------------------------------------
  DATA ls_class LIKE LINE OF gt_create_buffer ##NEEDED.
  DATA lt_messages LIKE et_messages.
  DATA ls_message LIKE LINE OF et_messages.

  CLEAR et_messages.

* check for empty key
  IF iv_class_id IS INITIAL.
    ls_message-msgid = '/LRN/437'.
    ls_message-msgno = '504'.
    ls_message-msgty = 'E'.
    APPEND ls_message TO et_messages.
    RAISE wrong_input.
  ENDIF.

* Check authorization
  CALL FUNCTION '/LRN/437_FLCLASS_AUTH'
    EXPORTING
      iv_class_id  = iv_class_id
      iv_activity  = '06'
    EXCEPTIONS
      no_authority = 2.
  IF sy-subrc <> 0.
    ls_message-msgid = '/LRN/S4D437'.
    ls_message-msgno = '506'.
    ls_message-msgty = 'E'.
    ls_message-msgv1 = iv_class_id.
    APPEND ls_message TO et_messages.
    RAISE no_auth.
  ENDIF.

* set lock
  CALL FUNCTION '/LRN/437_FLCLASS_LOCK'
    EXPORTING
      iv_class_id    = iv_class_id
    IMPORTING
      et_messages    = lt_messages
    EXCEPTIONS
      already_locked = 1.
  IF sy-subrc <> 0.
    APPEND LINES OF lt_messages TO et_messages.

    RAISE already_locked.
  ENDIF.


* Record in create buffer
  READ TABLE gt_create_buffer INTO ls_class WITH KEY class_id = iv_class_id.
  IF sy-subrc = 0.
    DELETE gt_create_buffer INDEX sy-tabix.
    RETURN.
  ELSE.
* Check on DB
    SELECT c~class_id, priority, language, description FROM /lrn/flclass AS c
            LEFT OUTER JOIN /lrn/flclasst AS t
            ON c~class_id = t~class_id
      WHERE c~class_id = @iv_class_id
      APPENDING TABLE @gt_delete_buffer.

    IF sy-subrc <> 0.
      ls_message-msgid = '/LRN/S4D437'.
      ls_message-msgno = '500'.
      ls_message-msgty = 'E'.
      ls_message-msgv1 = iv_class_id.
      APPEND ls_message TO et_messages.
      RAISE not_found.
    ENDIF.

* just in case: remove from update buffer
    DELETE TABLE gt_update_buffer WITH TABLE KEY class_id = iv_class_id.

  ENDIF.

ENDFUNCTION.
