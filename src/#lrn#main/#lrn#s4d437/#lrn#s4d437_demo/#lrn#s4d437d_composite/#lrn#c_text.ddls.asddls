@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text By User - Projection Root'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity /LRN/C_Text
  provider contract transactional_query
  as projection on /LRN/R_Text
  {
    key TextUuid,
        TextOwner,
        LinesCount,
        /* Associations */
        _Line : redirected to composition child /LRN/C_Line
  }
