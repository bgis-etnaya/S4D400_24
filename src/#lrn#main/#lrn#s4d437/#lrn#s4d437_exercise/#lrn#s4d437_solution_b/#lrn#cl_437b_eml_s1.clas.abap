CLASS /lrn/cl_437b_eml_s1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '0700##'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '000#####'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /LRN/CL_437B_EML_S1 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    READ ENTITIES OF /lrn/437b_r_travel
      ENTITY Travel " /lrn/437b_r_travel
        ALL FIELDS
        WITH   VALUE #( ( agencyid = c_agency_id
                          travelid = c_travel_id ) )
        RESULT DATA(travels)
        FAILED DATA(failed).

    IF failed IS NOT INITIAL.
      out->write( `Error retrieving the travel` ).
    ELSE.
      MODIFY ENTITIES OF /lrn/437b_r_travel
        ENTITY Travel " /lrn/437b_r_travel
        UPDATE
        FIELDS ( description )
        WITH   VALUE #( ( agencyid    = c_agency_id
                          travelid    = c_travel_id
                          description = `My new Description` ) )
        FAILED failed.

      IF failed IS INITIAL.
        COMMIT ENTITIES.
        out->write( `Description successfully updated` ).

      ELSE.
        ROLLBACK ENTITIES.
        out->write( `Error updating the description` ).
      ENDIF.
    ENDIF.



  ENDMETHOD.
ENDCLASS.
