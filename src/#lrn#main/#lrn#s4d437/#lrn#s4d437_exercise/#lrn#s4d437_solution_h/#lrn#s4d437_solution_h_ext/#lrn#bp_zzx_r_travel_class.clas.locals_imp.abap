CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS /lrn/validateclass FOR VALIDATE ON SAVE
      IMPORTING keys FOR item~/lrn/validateclass.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD /lrn/validateclass.

    CONSTANTS c_area TYPE string VALUE `CLASS`.

    READ ENTITIES OF /lrn/437h_r_travel IN LOCAL MODE
      ENTITY item
      FIELDS ( agencyid travelid /lrn/classzit )
      WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

      APPEND VALUE #( %tky = <item>-%tky
                      %state_area = c_area
                     )
          TO reported-item.

      IF <item>-/lrn/classzit IS INITIAL.

        APPEND VALUE #(  %tky = <item>-%tky )
            TO failed-item.

        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-/lrn/classzit = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> )
                       )
            TO reported-item.
      ELSE.

        SELECT SINGLE
          FROM /lrn/437_i_classstdvh
        FIELDS classid
         WHERE classid = @<item>-/lrn/classzit
          INTO @DATA(dummy).

        IF sy-subrc <> 0.

          APPEND VALUE #(  %tky = <item>-%tky )
              TO failed-item.

          APPEND VALUE #( %tky = <item>-%tky
                          %msg = NEW /lrn/cm_s4d437(
                                       textid   = /lrn/cm_s4d437=>class_not_exist
                                       classid  = <item>-/lrn/classzit
                                     )
                          %element-/lrn/classzit = if_abap_behv=>mk-on
                          %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> )
                         )
          TO reported-item.

        ENDIF.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_437h_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_437h_r_travel IMPLEMENTATION.

  METHOD save_modified.

* Handle items that require update of booking class field
    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item>)
      WHERE %control-/lrn/classzit = if_abap_behv=>mk-on.

      UPDATE /lrn/437h_tritem
         SET /lrn/classzit = @<item>-/lrn/classzit
       WHERE item_uuid     = @<item>-itemuuid.

    ENDLOOP.

* Update booking class field in items that were created
*    -> the new data sets are already on the DB
    LOOP AT create-item ASSIGNING <item>
      WHERE %control-/lrn/classzit = if_abap_behv=>mk-on.

      UPDATE /lrn/437h_tritem
         SET /lrn/classzit = @<item>-/lrn/classzit
       WHERE item_uuid = @<item>-itemuuid.

    ENDLOOP.

* Alternative: Combine Update and Create in one table

*    DATA(items) = update-item.
*    APPEND LINES OF create-item TO items.
*
*    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>)
*      WHERE %control-/lrn/classzit = if_abap_behv=>mk-on.
**
*      UPDATE /lrn/437h_tritem
*         SET /lrn/classzit = @<item>-/lrn/classzit
*       WHERE item_uuid = @<item>-itemuuid.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
