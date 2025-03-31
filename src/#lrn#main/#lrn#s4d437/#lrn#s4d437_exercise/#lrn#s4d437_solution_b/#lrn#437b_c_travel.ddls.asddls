@EndUserText.label: 'Flight Travel (Projection)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity /LRN/437b_C_Travel
  provider contract transactional_query
  as projection on /LRN/437b_R_Travel
  {
    key AgencyId,
    key TravelId,
        @Search.defaultSearchElement: true
        Description,
        @Search.defaultSearchElement: true
        CustomerId,
        BeginDate,
        EndDate,
        Status,
        ChangedAt,
        ChangedBy
  }
