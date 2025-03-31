CLASS /lrn/cl_deep_read DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS /LRN/CL_DEEP_READ IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT
             FROM /lrn/r_text
           FIELDS textuuid
           INTO TABLE @DATA(text_uuids)
           UP TO 1 ROWS.

    IF sy-subrc <> 0.

      out->write(  `No data in table /LRN/TEXT` ).
      out->write(  `Execute Deep Create demo first` ).

    ELSE.
      DATA(text_uuid) = text_uuids[ 1 ]-textuuid.

      READ ENTITIES OF /lrn/r_text
            ENTITY text ALL FIELDS  WITH VALUE #( ( textuuid = text_uuid ) )
            RESULT DATA(texts)

            ENTITY text BY \_line ALL FIELDS WITH VALUE #( ( textuuid = text_uuid ) )
            RESULT DATA(lines)
            LINK DATA(text_line_links)

           FAILED DATA(failed)
           REPORTED DATA(reported).

      IF failed IS INITIAL.

* Currently, Deep read only supports one level. (Chaining of associations not supported)

        READ ENTITIES OF /lrn/r_text
             ENTITY line BY \_word ALL FIELDS WITH CORRESPONDING #( lines )
             RESULT DATA(words)
             LINK DATA(word_line_links)
            FAILED DATA(failed2)
            REPORTED DATA(reported2).


        IF failed2 IS INITIAL.

          out->write( name = `Text`
                      data = texts ).
          out->write( name = `Lines`
                      data = lines ).
          out->write( name = `Words`
                      data = words ).

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
