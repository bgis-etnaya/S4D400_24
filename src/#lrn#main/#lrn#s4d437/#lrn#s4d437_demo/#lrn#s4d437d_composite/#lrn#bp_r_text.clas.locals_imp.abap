CLASS lhc_text DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR text RESULT result.

    METHODS condense_text FOR MODIFY
      IMPORTING keys FOR ACTION text~condense_text RESULT result.

    METHODS set_owner FOR DETERMINE ON MODIFY
      IMPORTING keys FOR text~set_owner.

ENDCLASS.

CLASS lhc_text IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD condense_text.

  ENDMETHOD.

  METHOD set_owner.

      MODIFY ENTITIES of /LRN/R_Text IN LOCAL MODE
         ENTITY TEXT
           UPDATE
             FIELDS ( textowner )
               WITH VALUE #( FOR line IN keys
                              ( %key = line-%key
                                textowner = sy-uname
                              )
                            ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_line DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS set_number FOR DETERMINE ON MODIFY
      IMPORTING keys FOR line~set_number.

    METHODS update_count FOR DETERMINE ON MODIFY
      IMPORTING keys FOR line~update_count.

ENDCLASS.

CLASS lhc_line IMPLEMENTATION.

  METHOD set_number.
  ENDMETHOD.

  METHOD update_count.

      READ ENTITIES of /lrn/R_Text in local mode
        ENTITY Line
          FIELDS ( textuuid )
            WITH CORRESPONDING #( keys )
          RESULT DATA(lt_lines).

    LOOP AT lt_lines INTO DATA(ls_line).

      READ ENTITies of /LRN/R_Text in LOCAL MODE
        ENTITY Text BY \_line
          FIELDS ( lineuuid )
            WITH VALUE #( ( textuuid = ls_line-textuuid ) )
          RESULT DATA(lt_siblings).

      MODIFY ENTITIES OF /LRN/R_Text IN LOCAL MODE
        ENTITY Text
         UPDATE
           FIELDS ( linescount )
             WITH VALUE #( ( textuuid   = ls_line-textuuid
                             linescount = lines( lt_siblings ) ) ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_word DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS set_number FOR DETERMINE ON MODIFY
      IMPORTING keys FOR word~set_number.

    METHODS update_count FOR DETERMINE ON MODIFY
      IMPORTING keys FOR word~update_count.

    METHODS textnotempty FOR VALIDATE ON SAVE
      IMPORTING keys FOR word~textnotempty.

ENDCLASS.

CLASS lhc_word IMPLEMENTATION.

  METHOD set_number.
  ENDMETHOD.

  METHOD update_count.
  ENDMETHOD.

  METHOD textnotempty.
  ENDMETHOD.

ENDCLASS.
