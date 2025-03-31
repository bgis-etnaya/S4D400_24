@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text By User - Composition Child'

define view entity /LRN/R_Line
  as select from /lrn/line

  composition [0..*] of /LRN/R_Word as _Word

  association to parent /LRN/R_Text as _Text
    on $projection.TextUuid = _Text.TextUuid
  {
    key line_uuid   as LineUuid,
        line_number as LineNumber,
        words_count as WordsCount,
        text_uuid   as TextUuid,

        // Association to Parent
        _Text,
        // Association to composition child
        _Word

  }
