@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for Booking Class'
@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]

define view entity /LRN/437_I_ClassStdVH
  as select from /LRN/437_R_Class
  {
        @UI.lineItem: [{ position: 10, importance: #HIGH }]
    key ClassID,
        @UI.lineItem: [{ position: 20, importance: #HIGH }]
        Description
  }
