@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text By User - Projection, Child of Composition Child'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity /LRN/C_Word
  as projection on /LRN/R_Word
  {
    key WordUuid,
        WordNumber,
        Text,
        LineUuid,
        TextUuid,
        /* Associations */
        _Line : redirected to parent /LRN/C_Line,
        _Text : redirected to /LRN/C_Text
  }
