@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text By User - Composition Child of composition child'

define view entity /LRN/R_Word
  as select from /lrn/word
  association        to parent /LRN/R_Line as _Line
    on $projection.LineUuid = _Line.LineUuid

  association [1..1] to /LRN/R_Text        as _Text
    on $projection.TextUuid = _Text.TextUuid


  {
    key word_uuid   as WordUuid,
        word_number as WordNumber,
        text        as Text,
        line_uuid   as LineUuid,
        text_uuid   as TextUuid,

        // to parent association
        _Line,

        // standard association to root entity - needed for Lock dependend
        _Text


  }
