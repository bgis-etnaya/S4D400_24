CLASS /lrn/cl_setup_s4d437 DEFINITION
  PUBLIC
  INHERITING FROM /lrn/cl_setup_root
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS run REDEFINITION.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS generate_s4d437_mapping.

ENDCLASS.



CLASS /LRN/CL_SETUP_S4D437 IMPLEMENTATION.


  METHOD generate_s4d437_mapping.

    CONSTANTS max_agencyid TYPE /dmo/agency_id VALUE '070040'.

    DATA mapping TYPE TABLE OF /lrn/437_users.

    SELECT
      FROM /lrn/437_users
    FIELDS COUNT( * )
     WHERE user_id IS NOT INITIAL
     INTO @DATA(db_count).

    IF db_count >= lines( users ).
      APPEND `User/Agency assignment already exists for all users` TO log.
    ELSE.

      SELECT
        FROM /dmo/i_agency
      FIELDS agencyid
         WHERE agencyid <= @max_agencyid
        INTO TABLE @DATA(agencies).

      DATA(agency_count) = lines( agencies ).

      LOOP AT me->users ASSIGNING FIELD-SYMBOL(<user>).

        mapping = VALUE #(   BASE  mapping
                            (
                              user_id       = <user>
                              agency_id     = agencies[ ( ( sy-tabix - 1 ) MOD agency_count ) + 1 ]-agencyid
                            )
                              ).
      ENDLOOP.

      MODIFY /lrn/437_users FROM TABLE @mapping.

      APPEND `Successfully generated User/Agency-assignments` TO log.

    ENDIF.
  ENDMETHOD.


  METHOD run.

* general setup tasks:
    super->run( ).

* additional setup tasks:
    generate_s4d437_data( ).
    generate_s4d437_mapping( ).

  ENDMETHOD.
ENDCLASS.
