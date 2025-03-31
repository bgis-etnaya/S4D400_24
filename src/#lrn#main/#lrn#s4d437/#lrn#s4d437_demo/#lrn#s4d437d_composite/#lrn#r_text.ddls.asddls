@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text By User - Data Model Root'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /LRN/R_Text
  as select from /lrn/text
  composition [0..*] of /LRN/R_Line as _Line
  {
    key text_uuid   as TextUuid,
        text_owner  as TextOwner,
        lines_count as LinesCount,

        _Line

  }
