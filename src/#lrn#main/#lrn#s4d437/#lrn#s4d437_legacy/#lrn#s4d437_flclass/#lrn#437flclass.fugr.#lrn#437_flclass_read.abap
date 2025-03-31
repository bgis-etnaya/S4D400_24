FUNCTION /LRN/437_FLCLASS_READ.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_CLASS_ID) TYPE  /LRN/437_S_CLASS-CLASS_ID
*"     REFERENCE(IV_USE_BUFFER) TYPE  ABAP_BOOL DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(ES_CLASS) TYPE  /LRN/437_S_CLASS
*"     REFERENCE(ET_MESSAGES) TYPE  SYMSG_TAB
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
    DATA ls_message LIKE LINE OF et_messages.

    CLEAR es_class.
    CLEAR et_messages.

* Check on buffers first
    IF iv_use_buffer = 'X'.
      "search in create buffer
      READ TABLE gt_create_buffer INTO es_class WITH TABLE KEY class_id = iv_class_id.
      "search in update buffer
      IF sy-subrc <> 0.
        READ TABLE gt_update_buffer INTO es_class WITH TABLE KEY class_id = iv_class_id.
      ENDIF.
    ENDIF.

    IF es_class IS INITIAL.   "not found in buffers
      "search on DB
      SELECT SINGLE *
               FROM (gv_tabname_text)
               WHERE class = @iv_class_id
                 AND language = @sy-langu
               INTO CORRESPONDING FIELDS OF @es_class.
      SELECT SINGLE *
               FROM (gv_tabname_class)
               WHERE class = @iv_class_id
               INTO CORRESPONDING FIELDS OF @es_class.

      IF sy-subrc <> 0.
        ls_message-msgid = 'DEVS4D437'.
        ls_message-msgno = '500'.
        ls_message-msgty = 'E'.
        ls_message-msgv1 = iv_class_id.
        APPEND ls_message TO et_messages.

        RAISE not_found.
      ENDIF.

    ENDIF.

ENDFUNCTION.
