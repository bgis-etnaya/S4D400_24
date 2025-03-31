CLASS /lrn/cl_deep_create DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS /LRN/CL_DEEP_CREATE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*Deep Create for Composite BO /lrn/r_text

    DATA texts TYPE TABLE FOR CREATE /lrn/r_text.
    DATA lines TYPE TABLE FOR CREATE /lrn/r_text\_line.
    DATA words TYPE TABLE FOR CREATE /lrn/r_line\_word.

* Root entity instance with %cid value
    texts = VALUE #( ( %cid = 'Hugo' linescount = 3 ) ).

* child entity instances with %cid_ref for parent instance reference
    lines = VALUE #( ( %cid_ref = 'Hugo' %target = VALUE #( ( %cid = 'Hugo1' linenumber = 1 wordscount = 3 )
                                                            ( %cid = 'Hugo2' linenumber = 2 wordscount = 7 )
                                                            ( %cid = 'Hugo3' linenumber = 3 wordscount = 5 )
                                                          )
                     ) ).
* second child level instances with %cid_ref for parent instance reference

    words = VALUE #(  (  %cid_ref = 'Hugo1' %target = VALUE #( ( %cid = 'Hugo1_1' wordnumber = 1 text = 'Hello' )
                                                               ( %cid = 'Hugo1_2' wordnumber = 2 text = 'World' )
                                                               ( %cid = 'Hugo1_3' wordnumber = 2 text = '?' )
                                                             )
                      )
                      (  %cid_ref = 'Hugo2' %target = VALUE #( ( %cid = 'Hugo2_1' wordnumber = 1 text = 'What' )
                                                               ( %cid = 'Hugo2_2' wordnumber = 2 text = 'do' )
                                                               ( %cid = 'Hugo2_3' wordnumber = 3 text = 'you' )
                                                               ( %cid = 'Hugo2_4' wordnumber = 4 text = 'think' )
                                                               ( %cid = 'Hugo2_5' wordnumber = 5 text = 'of' )
                                                               ( %cid = 'Hugo2_6' wordnumber = 6 text = 'RAP' )
                                                               ( %cid = 'Hugo2_7' wordnumber = 6 text = '?' )
                                                             )
                        )
                      (  %cid_ref = 'Hugo3' %target = VALUE #( ( %cid = 'Hugo3_1' wordnumber = 1 text = 'I' )
                                                               ( %cid = 'Hugo3_2' wordnumber = 2 text = 'think' )
                                                               ( %cid = 'Hugo3_3' wordnumber = 3 text = 'it''s' )
                                                               ( %cid = 'Hugo3_4' wordnumber = 4 text = 'great' )
                                                               ( %cid = 'Hugo3_5' wordnumber = 5 text = '!' )
                                                             )
                      )
                    ).

* Deep create for all three levels in one go
*
* %cid and %cid_ref are needed because of the internal assignment of values for the uuid fields

    MODIFY ENTITIES OF /lrn/r_text
         ENTITY text CREATE FIELDS ( linescount ) WITH texts
         ENTITY text CREATE BY \_line FIELDS ( linenumber wordscount ) WITH lines
         ENTITY line CREATE BY \_word FIELDS ( wordnumber text ) WITH words
        FAILED DATA(failed)
        REPORTED DATA(reported)
        MAPPED DATA(mapped).

* Mapped returns the relation between %cid values and uuid keys.
    IF failed IS INITIAL.

      COMMIT ENTITIES.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
