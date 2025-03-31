@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]   //equals the default and is optional

@AbapCatalog.extensibility: {
  extensible: true,
  allowNewDatasources: false,
  dataSources: ['_Extension'],
  elementSuffix: 'ZIT'
}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Travel Item'
define view entity /LRN/437h_R_TravelItem
  as select from /lrn/437h_tritem
  association to parent /LRN/437h_R_Travel as _Travel
    on  $projection.AgencyId = _Travel.AgencyId
    and $projection.TravelId = _Travel.TravelId

  association to /LRN/437h_E_TravelItem    as _Extension
    on $projection.ItemUuid = _Extension.ItemUuid
  {
    key item_uuid            as ItemUuid,
        agency_id            as AgencyId,
        travel_id            as TravelId,
        carrier_id           as CarrierId,
        connection_id        as ConnectionId,
        flight_date          as FlightDate,
        booking_id           as BookingId,
        passenger_first_name as PassengerFirstName,
        passenger_last_name  as PassengerLastName,
        @Semantics.systemDateTime.lastChangedAt: true
        changed_at           as ChangedAt,
        @Semantics.user.lastChangedBy: true
        changed_by           as ChangedBy,
        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        loc_changed_at       as LocChangedAt,

        _Travel,
        _Extension

  }
