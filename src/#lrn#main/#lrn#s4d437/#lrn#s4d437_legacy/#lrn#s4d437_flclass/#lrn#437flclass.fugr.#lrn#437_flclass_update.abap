FUNCTION /lrn/437_flclass_update.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_CLASS) TYPE  /LRN/437_S_CLASS
*"     REFERENCE(IS_CLASSX) TYPE  /LRN/437_S_CLASSX
*"  EXPORTING
*"     REFERENCE(ET_MESSAGES) TYPE  SYMSG_TAB
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      NOT_FOUND
*"      NO_AUTH
*"      ALREADY_LOCKED
*"----------------------------------------------------------------------
  DATA ls_class_db TYPE /lrn/437_s_class.
  DATA lt_messages LIKE et_messages.
  DATA ls_message LIKE LINE OF et_messages.

  FIELD-SYMBOLS
       <ls_class> LIKE LINE OF gt_update_buffer.

  CLEAR et_messages.

* Check for empty key
  IF is_class-class_id IS INITIAL.
    ls_message-msgid = 'DEVS4D437'.
    ls_message-msgno = '504'.
    ls_message-msgty = 'E'.
    APPEND ls_message TO et_messages.
    RAISE wrong_input.
  ENDIF.

* Check authorization
  CALL FUNCTION '/LRN/437_FLCLASS_AUTH'
    EXPORTING
      iv_class_id  = is_class-class_id
      iv_activity  = '02'
    EXCEPTIONS
      no_authority = 2.

  IF sy-subrc <> 0.
    ls_message-msgid = 'DEVS4D437'.
    ls_message-msgno = '502'.
    ls_message-msgty = 'E'.
    ls_message-msgv1 = is_class-class_id.
    APPEND ls_message TO et_messages.
    RAISE no_auth.
  ENDIF.

* set lock
  CALL FUNCTION '/LRN/437_FLCLASS_LOCK'
    EXPORTING
      iv_class_id    = is_class-class_id
    IMPORTING
      et_messages    = lt_messages
    EXCEPTIONS
      already_locked = 1.
  IF sy-subrc <> 0.
    APPEND LINES OF lt_messages TO et_messages.
    RAISE already_locked.
  ENDIF.

* Check if alread marked for deletion
  READ TABLE gt_delete_buffer TRANSPORTING NO FIELDS WITH TABLE KEY class_id = is_class-class_id.

  IF sy-subrc = 0.
    ls_message-msgid = 'DEVS4D437'.
    ls_message-msgno = '515'.
    ls_message-msgty = 'W'.
    ls_message-msgv1 = is_class-class_id.
    APPEND ls_message TO et_messages.
    RETURN.
  ENDIF.

* Check if already in create buffer
  READ TABLE gt_create_buffer ASSIGNING <ls_class> WITH KEY class_id = is_class-class_id.

  IF sy-subrc <> 0.
* Check if already in update buffer
    READ TABLE gt_update_buffer ASSIGNING <ls_class> WITH KEY class_id = is_class-class_id.
    IF sy-subrc <> 0.
* usual case
* Read active data from DB

      SELECT SINGLE * FROM (gv_tabname_text)
             WHERE class_id = @is_class-class_id
               AND language = @sy-langu
             INTO CORRESPONDING FIELDS OF @ls_class_db.

      SELECT SINGLE * FROM (gv_tabname_class)
              WHERE class_id = @is_class-class_id
              INTO CORRESPONDING FIELDS OF @ls_class_db.

      IF sy-subrc <> 0.
        ls_message-msgid = 'DEVS4D437'.
        ls_message-msgno = '500'.
        ls_message-msgty = 'E'.
        ls_message-msgv1 = is_class-class_id.
        APPEND ls_message TO et_messages.
        RAISE not_found.
      ELSE.
*  ... and add original data to update buffer
        INSERT ls_class_db INTO TABLE gt_update_buffer ASSIGNING <ls_class>.
      ENDIF.

    ENDIF.

    ASSERT <ls_class> IS ASSIGNED.

* Merge data
    if is_classx-priority = abap_true.
    <ls_class>-priority = is_class-priority.
    endif.

    IF is_classx-language = abap_true.
      <ls_class>-language = is_class-language.
    ENDIF.
    IF is_classx-description = abap_true.
      <ls_class>-description = is_class-description.
    ENDIF.

  ENDIF.

ENDFUNCTION.
