@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Class (Data Model)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity /LRN/437_R_Class
  as select from    /lrn/flclass  as c
    left outer join /lrn/flclasst as t
      on  c.class_id = t.class_id
      and t.language = $session.system_language
  {
    key c.class_id    as ClassID,
        c.priority    as Priority,
        t.description as Description,
        concat( c.priority,
                t.description
               )      as AllElements
  }
