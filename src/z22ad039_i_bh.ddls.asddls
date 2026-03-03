@EndUserText.label: 'Bill Header Root 22AD039'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z22AD039_I_BH
  as select from z22ad039bh
  composition [0..*] of Z22AD039_I_BI as _Item
{
  key bill_uuid,
      bill_no,
      cust_name,
      bill_date,
      @Semantics.amount.currencyCode: 'currency'
      total_amt,
      currency,
      pay_status,
      _Item
}
