@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED Log for Created Travels'
define root view entity /LRN/437_R_TRAVELLOG
  as select from /lrn/437_trlog as TravelLog
  {
    key uuid           as UUID,
        agency_id      as AgencyID,
        travel_id      as TravelID,
        origin         as Origin,
        @Semantics.systemDateTime.lastChangedAt: true
        changed_at     as ChangedAt,
        @Semantics.user.lastChangedBy: true
        changed_by     as ChangedBy,
        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        loc_changed_at as LocChangedAt

  }
