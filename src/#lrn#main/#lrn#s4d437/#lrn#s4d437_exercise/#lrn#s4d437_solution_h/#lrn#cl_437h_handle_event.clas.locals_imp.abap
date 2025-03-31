*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_handler DEFINITION
      INHERITING FROM cl_abap_behavior_event_handler.

  PRIVATE SECTION.

    METHODS on_travel_created FOR ENTITY EVENT
      IMPORTING new_travels
                  FOR travel~travelcreated.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_travel_created.

    MODIFY ENTITIES OF /lrn/437_i_travellog
       ENTITY travellog
         CREATE AUTO FILL CID
         FIELDS ( agencyid travelid origin )
         WITH CORRESPONDING #( new_travels ).

  ENDMETHOD.

ENDCLASS.
