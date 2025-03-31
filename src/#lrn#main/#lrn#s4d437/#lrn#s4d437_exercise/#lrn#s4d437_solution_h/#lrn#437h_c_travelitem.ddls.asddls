@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]   //equals the default and is optional

@AbapCatalog.extensibility: {
  extensible: true,
  allowNewDatasources: false,
  dataSources: ['Item'],
  elementSuffix: 'ZIT'
}

@EndUserText.label: 'Flight Travel Item (Projection)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /LRN/437h_C_TravelItem
  //  provider contract transactional_query
  as projection on /LRN/437h_R_TravelItem as Item
  {
    key ItemUuid,
        AgencyId,
        TravelId,

        @Consumption.valueHelpDefinition:
                [ { entity: { name:    '/DMO/I_Carrier_StdVH',
                              element: 'AirlineID'
                            }
                  }
                ]
        CarrierId,

        @Consumption.valueHelpDefinition:
                 [ { entity: { name:    '/DMO/I_Connection_StdVH',
                               element: 'ConnectionID'
                             },
                     additionalBinding:
                          [ { localElement: 'CarrierId',
                                   element: 'AirlineID',
                                     usage: #FILTER_AND_RESULT
                            }
                          ],
                     label: 'Value Help by Connection'
                   },
                   { entity: { name:    '/DMO/I_Flight_StdVH',
                               element: 'ConnectionID'
                             },
                     additionalBinding:
                          [ { localElement: 'CarrierId',
                              element:      'AirlineID',
                              usage:        #FILTER_AND_RESULT
                            },
                            { localElement: 'FlightDate',
                              element:      'FlightDate',
                              usage:         #RESULT
                           }
                         ],
                     label: 'Value Help by Flight',
                     qualifier: 'Secondary Value help'
                   }
                 ]
        ConnectionId,

        @Consumption.valueHelpDefinition:
             [ { entity: { name:    '/DMO/I_Flight_StdVH',
                           element: 'FlightDate'
                         },
                 additionalBinding:
                      [ { localElement: 'CarrierId',
                          element:      'AirlineID',
                          usage:         #FILTER_AND_RESULT
                        },
                        { localElement: 'ConnectionId',
                          element:      'ConnectionID',
                          usage:        #RESULT
                        }
                      ]
               }
             ]
        FlightDate,
        BookingId,
        PassengerFirstName,
        PassengerLastName,
        ChangedAt,
        ChangedBy,
        LocChangedAt,

        _Travel : redirected to parent /LRN/437h_C_Travel,

        _Extension
  }
