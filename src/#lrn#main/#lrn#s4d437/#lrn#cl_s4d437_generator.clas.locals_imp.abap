*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

**"* use this source file for the definition and implementation of
**"* local helper classes, interface definitions and type
**"* declarations
*

CLASS lcl_generator DEFINITION ABSTRACT.

  PUBLIC SECTION.

    TYPES tt_log TYPE STANDARD TABLE OF string
                 WITH NON-UNIQUE DEFAULT KEY.

    CLASS-DATA log TYPE tt_log READ-ONLY.

    METHODS
      constructor
        IMPORTING
          i_table_name TYPE tabname
          ir_data      TYPE REF TO data
        RAISING
          cx_abap_not_a_table.

    METHODS generate ABSTRACT.

    CLASS-METHODS
      save.


  PROTECTED SECTION.
    CONSTANTS random_min TYPE i VALUE 0.
    CONSTANTS random_max TYPE i VALUE 1000000.

    CLASS-DATA instances TYPE TABLE OF REF TO lcl_generator.
    DATA random TYPE REF TO cl_abap_random_int.

  PRIVATE SECTION.

    DATA table_name  TYPE tabname.
    DATA r_data      TYPE REF TO data.

    METHODS table_exists
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS is_empty_db
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS delete_db.

    METHODS insert_db.


ENDCLASS.

CLASS lcl_generator IMPLEMENTATION.

  METHOD constructor.

    table_name = i_table_name.

    IF table_exists( ) <> abap_true.
      RAISE EXCEPTION TYPE cx_abap_not_a_table
        EXPORTING
          value = CONV #( table_name ).
    ENDIF.

    r_data = ir_data.
    APPEND me TO instances.

    DATA(seed) = CONV i( cl_abap_context_info=>get_system_date(   ) ).
    me->random = cl_abap_random_int=>create( seed = seed
                                              min = me->random_min
                                              max = me->random_max ).

  ENDMETHOD.

  METHOD save.

    LOOP AT instances INTO DATA(instance).

      IF instance->is_empty_db( ) <> abap_false.
        instance->delete_db(  ).
      ENDIF.

      instance->insert_db(  ).

    ENDLOOP.

    COMMIT WORK.

  ENDMETHOD.

  METHOD table_exists.
    cl_abap_typedescr=>describe_by_name(
       EXPORTING
         p_name = table_name
      EXCEPTIONS
        type_not_found = 1
    ).
    IF sy-subrc = 0.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD is_empty_db.

    CLEAR result.

    SELECT SINGLE
      FROM (table_name)
    FIELDS @abap_true
     INTO @result.

  ENDMETHOD.

  METHOD delete_db.
    DELETE FROM (table_name).
    APPEND |Deleted content from table { table_name }| TO log.
  ENDMETHOD.

  METHOD insert_db.

    DATA r_itab TYPE REF TO data.

    CREATE DATA r_itab TYPE TABLE OF (table_name).

    r_itab->* = CORRESPONDING #( r_data->* ).

    INSERT (table_name) FROM TABLE @r_itab->*.

    APPEND |Filled table { table_name } with { lines( r_itab->* ) } rows | TO log.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_generator_class DEFINITION INHERITING FROM lcl_generator.

  PUBLIC SECTION.
    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/FLCLASS'.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

    DATA classes TYPE SORTED TABLE OF /lrn/flclass
                 WITH UNIQUE KEY class_id READ-ONLY.

ENDCLASS.
CLASS lcl_generator_class IMPLEMENTATION.


  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->classes ) ).

  ENDMETHOD.

  METHOD generate.

    classes = VALUE #(
                 (
                   class_id = 'Y'
                   priority = ' '
                 )
                 (
                   class_id = 'C'
                   priority = 'X'
                 )
                 (
                   class_id = 'F'
                   priority = 'X'
                 )
              )   .

  ENDMETHOD.

ENDCLASS.
CLASS lcl_generator_classt DEFINITION INHERITING FROM lcl_generator.

  PUBLIC SECTION.
    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/FLCLASST'.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

    DATA classes TYPE SORTED TABLE OF /lrn/flclasst
                 WITH UNIQUE KEY class_id READ-ONLY.

ENDCLASS.
CLASS lcl_generator_classt IMPLEMENTATION.


  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->classes ) ).

  ENDMETHOD.

  METHOD generate.

    classes = VALUE #(
                 (
                   class_id = 'Y'
                   language = 'E'
                   description = 'Economy'
                 )
                 (
                   class_id = 'C'
                   language = 'E'
                   description = 'Business'
                 )
                 (
                   class_id = 'F'
                   language = 'E'
                   description = 'First'
                 )
              )   .

  ENDMETHOD.

ENDCLASS.

CLASS lcl_generator_agency DEFINITION INHERITING FROM lcl_generator.

  PUBLIC SECTION.
    CONSTANTS c_tabname TYPE tabname VALUE '/DMO/AGENCY'.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

    DATA agencies TYPE SORTED TABLE OF /dmo/agency
                 WITH UNIQUE KEY agency_id READ-ONLY.

ENDCLASS.

CLASS lcl_generator_agency IMPLEMENTATION.


  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->agencies ) ).

  ENDMETHOD.

  METHOD generate.

    CONSTANTS new_agency_id TYPE /dmo/agency_id VALUE '070000'.

    SELECT
      FROM /dmo/agency
      FIELDS *
      INTO TABLE @me->agencies.

    IF NOT line_exists( agencies[ agency_id = new_agency_id ] ).

      agencies = VALUE #(  BASE agencies
                           (
                           agency_id     = new_agency_id
                           name          = 'Wide World Travel'
                           street        = 'Dietmar-Hopp-Allee 20'
                           postal_code   = '69190'
                           city          = 'Walldorf'
                           country_code  = 'DE'
                           phone_number  = '+49 6227-7-0'
                           email_address = 'info@wide-world.de'
                           web_address   = 'http://www.wide-world.de'
                           )
                        ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.
CLASS lcl_generator_travel DEFINITION
   INHERITING FROM lcl_generator
   ABSTRACT.

  PUBLIC SECTION.

    CLASS-METHODS class_constructor.

  PROTECTED SECTION.

    CLASS-DATA travels_template TYPE TABLE OF /lrn/437h_travel.

ENDCLASS.

CLASS lcl_generator_travel IMPLEMENTATION.

  METHOD class_constructor.

    CONSTANTS changed_by TYPE syuname VALUE 'GENERATOR'.

    CONSTANTS agencyid TYPE /dmo/agency_id VALUE '070000'.
    DATA(today) = cl_abap_context_info=>get_system_date(  ).
    GET TIME STAMP FIELD DATA(timestamp).

    travels_template =
   VALUE #(
            status          = ' '
            changed_by      = changed_by
             changed_at     = timestamp
             loc_changed_at = timestamp
            (
              agency_id   = agencyid
              travel_id   = /lrn/cl_s4d437_model=>get_next_travelid( )
              description = 'Travel in the past'
              customer_id = '00000001'
              begin_date  = today - 28
              end_date    = today - 14
            )
            (
              agency_id   = agencyid
              travel_id   = /lrn/cl_s4d437_model=>get_next_travelid( )
              description = 'Travel ongoing'
              customer_id = '00000002'
              begin_date  = today - 14
              end_date    = today + 14
            )
            (
              agency_id   = agencyid
              travel_id   = /lrn/cl_s4d437_model=>get_next_travelid( )
              description = 'Travel in the future'
              customer_id = '00000003'
              begin_date  = today + 14
              end_date    = today + 28
            )
            (
              agency_id   = '070041'
              travel_id   = /lrn/cl_s4d437_model=>get_next_travelid( )
              description = 'Travel of travel agency 070041'
              customer_id = '00000004'
              begin_date  = today  + 10
               end_date    = today + 40
             )
            (
              agency_id   = '070050'
              travel_id   = /lrn/cl_s4d437_model=>get_next_travelid( )
              description = 'Travel of travel agency 070050'
              customer_id = '00000005'
              begin_date  = today  + 20
               end_date    = today + 27
             )
          ).

  ENDMETHOD.


ENDCLASS.

CLASS lcl_generator_travel_a DEFINITION INHERITING FROM lcl_generator_travel.

  PUBLIC SECTION.

    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/437A_TRAVEL'.

    DATA travels TYPE TABLE OF /lrn/437a_travel READ-ONLY.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_generator_travel_a IMPLEMENTATION.

  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->travels ) ).

  ENDMETHOD.

  METHOD generate.
    me->travels = CORRESPONDING #( travels_template ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_generator_travel_b DEFINITION INHERITING FROM lcl_generator_travel.

  PUBLIC SECTION.

    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/437B_TRAVEL'.

    DATA travels TYPE TABLE OF /lrn/437b_travel READ-ONLY.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_generator_travel_b IMPLEMENTATION.

  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->travels ) ).

  ENDMETHOD.

  METHOD generate.
    me->travels = CORRESPONDING #( travels_template ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_generator_travel_c DEFINITION INHERITING FROM lcl_generator_travel.

  PUBLIC SECTION.

    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/437C_TRAVEL'.

    DATA travels TYPE TABLE OF /lrn/437c_travel READ-ONLY.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_generator_travel_c IMPLEMENTATION.

  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->travels ) ).

  ENDMETHOD.

  METHOD generate.
    me->travels = CORRESPONDING #( travels_template ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_generator_travel_d DEFINITION INHERITING FROM lcl_generator_travel.

  PUBLIC SECTION.

    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/437D_TRAVEL'.

    DATA travels TYPE TABLE OF /lrn/437d_travel READ-ONLY.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_generator_travel_d IMPLEMENTATION.

  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->travels ) ).

  ENDMETHOD.

  METHOD generate.
    me->travels = CORRESPONDING #( travels_template ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_generator_travel_e DEFINITION INHERITING FROM lcl_generator_travel.

  PUBLIC SECTION.

    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/437E_TRAVEL'.

    DATA travels TYPE TABLE OF /lrn/437e_travel READ-ONLY.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_generator_travel_e IMPLEMENTATION.

  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->travels ) ).

  ENDMETHOD.

  METHOD generate.
    me->travels = CORRESPONDING #( travels_template ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_generator_travel_f DEFINITION INHERITING FROM lcl_generator_travel.

  PUBLIC SECTION.

    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/437F_TRAVEL'.

    DATA travels TYPE TABLE OF /lrn/437f_travel READ-ONLY.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_generator_travel_f IMPLEMENTATION.

  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->travels ) ).

  ENDMETHOD.

  METHOD generate.
    me->travels = CORRESPONDING #( travels_template ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_generator_travel_g DEFINITION INHERITING FROM lcl_generator_travel.

  PUBLIC SECTION.

    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/437G_TRAVEL'.

    DATA travels TYPE TABLE OF /lrn/437g_travel READ-ONLY.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_generator_travel_g IMPLEMENTATION.

  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->travels ) ).

  ENDMETHOD.

  METHOD generate.
    me->travels = CORRESPONDING #( travels_template ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_generator_travel_h DEFINITION INHERITING FROM lcl_generator_travel.

  PUBLIC SECTION.

    CONSTANTS c_tabname TYPE tabname VALUE '/LRN/437H_TRAVEL'.

    DATA travels TYPE TABLE OF /lrn/437h_travel READ-ONLY.

    METHODS constructor
      RAISING cx_abap_not_a_table.

    METHODS generate REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_generator_travel_h IMPLEMENTATION.

  METHOD constructor.

    super->constructor(  i_table_name = c_tabname
                         ir_data = REF #( me->travels ) ).

  ENDMETHOD.

  METHOD generate.
    me->travels = CORRESPONDING #( travels_template ).
  ENDMETHOD.

ENDCLASS.
