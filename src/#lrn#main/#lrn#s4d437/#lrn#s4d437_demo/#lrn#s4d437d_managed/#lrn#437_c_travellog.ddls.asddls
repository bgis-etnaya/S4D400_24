@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for /LRN/437_R_TRAVELLOG'
@ObjectModel.semanticKey: [ 'UUID' ]
define root view entity /LRN/437_C_TRAVELLOG
  provider contract transactional_query
  as projection on /LRN/437_R_TRAVELLOG
  {
    key UUID,
        AgencyID,
        TravelID,
        Origin,
        LocChangedAt

  }
