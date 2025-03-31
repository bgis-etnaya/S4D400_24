FUNCTION-POOL /LRN/437FLCLASS.              "MESSAGE-ID ..

* INCLUDE /LRN/L437FLCLASSD...               " Local class definition

DATA:
      gv_tabname_class TYPE tabname  VALUE '/LRN/FLCLASS',
      gv_tabname_text  TYPE tabname  VALUE '/LRN/FLCLASST',

      gt_create_buffer TYPE TABLE OF /lrn/437_s_class
                       WITH NON-UNIQUE KEY class_id,

      gt_update_buffer TYPE TABLE OF /lrn/437_s_class
                       WITH NON-UNIQUE KEY class_id,


      gt_delete_buffer TYPE TABLE OF /lrn/437_s_class
                       WITH NON-UNIQUE KEY class_id.
