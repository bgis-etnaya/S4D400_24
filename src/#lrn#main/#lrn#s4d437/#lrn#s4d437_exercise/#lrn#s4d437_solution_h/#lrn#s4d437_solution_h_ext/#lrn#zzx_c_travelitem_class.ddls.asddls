extend view entity /LRN/437h_C_TravelItem with
  {
    @Consumption.valueHelpDefinition:
        [
         { entity: { name:    '/LRN/437_I_ClassStdVH',
                     element: 'ClassID'
                   }
         }
       ]
    Item./LRN/classZIT
  }
