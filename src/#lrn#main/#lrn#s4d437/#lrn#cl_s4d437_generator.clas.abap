CLASS /lrn/cl_s4d437_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /LRN/CL_S4D437_GENERATOR IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.

        NEW lcl_generator_class(  )->generate(  ).
        NEW lcl_generator_classt( )->generate(  ).

        NEW lcl_generator_agency( )->generate(  ).

        NEW lcl_generator_travel_a(  )->generate(  ).
        NEW lcl_generator_travel_b(  )->generate(  ).
        NEW lcl_generator_travel_c(  )->generate(  ).
        NEW lcl_generator_travel_d(  )->generate(  ).
        NEW lcl_generator_travel_e(  )->generate(  ).
        NEW lcl_generator_travel_f(  )->generate(  ).
        NEW lcl_generator_travel_g(  )->generate(  ).
        NEW lcl_generator_travel_h(  )->generate(  ).

        lcl_generator=>save( ).

        out->write( name = `Log of S4D437 data generator`
                    data = lcl_generator=>log ).

      CATCH cx_abap_not_a_table INTO DATA(not_a_table).
        out->write(  not_a_table->get_text(  ) ).

    ENDTRY.


  ENDMETHOD.
ENDCLASS.
