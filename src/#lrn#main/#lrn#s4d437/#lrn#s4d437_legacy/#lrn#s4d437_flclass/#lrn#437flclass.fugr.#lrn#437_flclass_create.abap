FUNCTION /lrn/437_flclass_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_CLASS) TYPE  /LRN/437_S_CLASS
*"  EXPORTING
*"     REFERENCE(ET_MESSAGES) TYPE  SYMSG_TAB
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      ALREADY_LOCKED
*"----------------------------------------------------------------------
  DATA lt_messages TYPE symsg_tab.
  DATA ls_message LIKE LINE OF et_messages.

  DATA ls_class LIKE is_class.

  CLEAR et_messages.

* reject initial input
  IF is_class IS INITIAL.

    ls_message-msgid = '/LRN/S4D437'.
    ls_message-msgno = '510'.
    ls_message-msgty = 'E'.
    APPEND ls_message TO et_messages.

    RAISE wrong_input.
  ENDIF.

* Set lock
  CALL FUNCTION '/LRN/437_FLCLASS_LOCK'
    EXPORTING
      iv_class_id    = is_class-class_id
    IMPORTING
      et_messages    = lt_messages
    EXCEPTIONS
      already_locked = 1.
  CASE sy-subrc.
    WHEN 1.
      APPEND LINES OF lt_messages TO et_messages.
      RAISE already_locked.
  ENDCASE.

* Process data.

  ls_class = is_class.

  IF ls_class-language IS INITIAL.
    ls_class-language = sy-langu.
  ENDIF.

  APPEND ls_class TO gt_create_buffer.

ENDFUNCTION.
