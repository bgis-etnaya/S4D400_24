*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_handler DEFINITION
      INHERITING FROM cl_abap_behavior_event_handler.

*  public section.
*  protected section.
  PRIVATE SECTION.

    METHODS on_travel_created FOR ENTITY EVENT
      IMPORTING new_travels
                  FOR travel~travelcreated.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_travel_created.

* Without parameter
*    DATA log TYPE TABLE FOR CREATE /lrn/437_i_travellog.
*
*    LOOP AT new_travels ASSIGNING FIELD-SYMBOL(<travel>).
*      APPEND VALUE #(
*                      agencyid = <travel>-agencyid
*                      travelid = <travel>-travelid
*                      origin   = '/LRN/437G_R_TRAVEL'
*                    )
*         TO log.
*
*    ENDLOOP.
*
*    MODIFY ENTITIES OF /lrn/437_i_travellog
*       ENTITY travellog
*         CREATE AUTO FILL CID
*         FIELDS ( agencyid travelid origin )
*         WITH log.

* With parameter
    MODIFY ENTITIES OF /lrn/437_i_travellog
       ENTITY travellog
         CREATE AUTO FILL CID
         FIELDS ( agencyid travelid origin )
         WITH CORRESPONDING #( new_travels ).

  ENDMETHOD.

ENDCLASS.
