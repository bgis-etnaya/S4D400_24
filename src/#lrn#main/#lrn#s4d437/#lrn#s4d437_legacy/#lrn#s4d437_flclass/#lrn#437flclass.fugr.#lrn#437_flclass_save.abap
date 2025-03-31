FUNCTION /lrn/437_flclass_save.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXCEPTIONS
*"      ERROR_IN_CREATE
*"      ERROR_IN_UPDATE
*"      ERROR_IN_DELETE
*"----------------------------------------------------------------------
  DATA ls_class LIKE LINE OF gt_create_buffer.

  DATA lt_class_db TYPE TABLE OF /lrn/flclass.
  DATA ls_class_db TYPE /lrn/flclass.
  DATA lt_classt_db TYPE TABLE OF /lrn/flclasst.
  DATA ls_classt_db TYPE /lrn/flclasst.

* Evaluate create buffer

  LOOP AT gt_create_buffer INTO ls_class.

    CLEAR ls_class_db.
    CLEAR ls_classt_db.
    MOVE-CORRESPONDING ls_class TO ls_class_db.
    MOVE-CORRESPONDING ls_class TO ls_classt_db.

    APPEND ls_class_db TO lt_class_db.
    APPEND ls_classt_db TO lt_classt_db.

  ENDLOOP.

  INSERT (gv_tabname_class) FROM TABLE @lt_class_db.

  IF sy-subrc <> 0.
    RAISE error_in_create.
  ENDIF.

  INSERT (gv_tabname_text) FROM TABLE @lt_classt_db.
  IF sy-subrc <> 0.
    RAISE error_in_create.
  ENDIF.

  CLEAR: gt_create_buffer,
         lt_class_db,
         lt_classt_db.

* Evaluate Update buffer

  LOOP AT gt_update_buffer INTO ls_class.

    CLEAR ls_class_db.
    CLEAR ls_classt_db.
    MOVE-CORRESPONDING ls_class TO ls_class_db.
    MOVE-CORRESPONDING ls_class TO ls_classt_db.

    APPEND ls_class_db TO lt_class_db.
    APPEND ls_classt_db TO lt_classt_db.

  ENDLOOP.

  UPDATE (gv_tabname_class) FROM TABLE @lt_class_db.
  IF sy-subrc <> 0.
    RAISE error_in_update.
  ENDIF.

  UPDATE (gv_tabname_text) FROM TABLE @lt_classt_db.
  IF sy-subrc <> 0.
    RAISE error_in_update.
  ENDIF.

  CLEAR: gt_update_buffer,
         lt_class_db,
         lt_classt_db.

* Evaluate Delete buffer

  LOOP AT gt_delete_buffer INTO ls_class.

    CLEAR ls_class_db.
    CLEAR ls_classt_db.
    MOVE-CORRESPONDING ls_class TO ls_class_db.
    MOVE-CORRESPONDING ls_class TO ls_classt_db.

    APPEND ls_class_db  TO lt_class_db.
    APPEND ls_classt_db TO lt_classt_db.

  ENDLOOP.

  SORT lt_class_db BY class_id.
  DELETE ADJACENT DUPLICATES FROM lt_class_db COMPARING class_id.

  DELETE (gv_tabname_class) FROM TABLE @lt_class_db.
  IF sy-subrc <> 0.
    RAISE error_in_delete.
  ENDIF.

  DELETE (gv_tabname_text) FROM TABLE @lt_classt_db.
  IF sy-subrc <> 0.
    RAISE error_in_delete.
  ENDIF.

  CLEAR: gt_delete_buffer,
         lt_class_db,
         lt_classt_db.






ENDFUNCTION.
