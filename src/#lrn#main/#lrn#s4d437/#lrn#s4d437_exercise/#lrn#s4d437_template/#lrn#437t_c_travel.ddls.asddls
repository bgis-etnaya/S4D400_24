@EndUserText.label: 'Flight Travel (Projection)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity /LRN/437t_C_Travel
  provider contract transactional_query
  as projection on /LRN/437t_R_Travel
  {
    key AgencyId,
    key TravelId,
        Description,
        CustomerId,
        BeginDate,
        EndDate,
        Status,
        ChangedAt,
        ChangedBy
  }
