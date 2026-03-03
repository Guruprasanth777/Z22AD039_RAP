@AbapCatalog.viewEnhancementCategory: [#NONE]
@EndUserText.label: 'Bill Item Child 22AD039'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity Z22AD039_I_BI
  as select from z22ad039bi
  association to parent Z22AD039_I_BH as _Header
    on $projection.bill_uuid = _Header.bill_uuid
{
  key item_uuid,
      bill_uuid,
      item_pos,
      product_id,
      qty,
      @Semantics.amount.currencyCode: 'currency'
      unit_price,
      @Semantics.amount.currencyCode: 'currency'
      subtotal,
      currency,
      _Header
}
