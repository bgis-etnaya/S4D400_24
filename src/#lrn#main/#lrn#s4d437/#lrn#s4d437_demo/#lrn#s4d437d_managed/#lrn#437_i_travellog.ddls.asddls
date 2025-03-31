@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Log for Created Travels'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /LRN/437_I_TravelLog
  provider contract transactional_interface
  as projection on /LRN/437_R_TRAVELLOG

  {
    key UUID,
        AgencyID,
        TravelID,
        Origin,
        ChangedAt,
        ChangedBy,
        LocChangedAt
  }
