@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text By User - Projection Composition Child'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity /LRN/C_Line
  as projection on /LRN/R_Line
  {
    key LineUuid,
        LineNumber,
        WordsCount,
        TextUuid,
        /* Associations */
        _Text : redirected to parent /LRN/C_Text,
        _Word : redirected to composition child /LRN/C_Word
  }
