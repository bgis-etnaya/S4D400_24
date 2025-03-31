@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Class (Projection)'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity /LRN/437_C_CLASS
  provider contract transactional_query
  as projection on /LRN/437_R_Class
  {
    key ClassID,
        Priority,
        Description,
        AllElements
  }
