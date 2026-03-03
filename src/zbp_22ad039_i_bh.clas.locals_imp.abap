CLASS lhc_Z22AD039_I_BH DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
   CLASS-DATA: gt_bh TYPE STANDARD TABLE OF z22ad039bh WITH EMPTY KEY,
          gt_bi TYPE STANDARD TABLE OF z22ad039bi WITH EMPTY KEY.

  PRIVATE SECTION.


    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR z22ad039_i_bh RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR z22ad039_i_bh RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE z22ad039_i_bh.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE z22ad039_i_bh.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE z22ad039_i_bh.

    METHODS read FOR READ
      IMPORTING keys FOR READ z22ad039_i_bh RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK z22ad039_i_bh.

    METHODS rba_Item FOR READ
      IMPORTING keys_rba FOR READ z22ad039_i_bh\_Item FULL result_requested RESULT result LINK association_links.

    METHODS cba_Item FOR MODIFY
      IMPORTING entities_cba FOR CREATE z22ad039_i_bh\_Item.

ENDCLASS.



CLASS lhc_Z22AD039_I_BH IMPLEMENTATION.

  METHOD get_instance_authorizations.
  LOOP AT keys INTO DATA(ls_key).
    APPEND VALUE #( %tky = ls_key-%tky
                    %update = if_abap_behv=>auth-allowed
                    %delete = if_abap_behv=>auth-allowed
                  ) TO result.
  ENDLOOP.
ENDMETHOD.

  METHOD get_global_authorizations.
  IF requested_authorizations-%create = if_abap_behv=>mk-on.
    result-%create = if_abap_behv=>auth-allowed.
  ENDIF.
ENDMETHOD.

METHOD create.

  DATA: lv_uuid TYPE sysuuid_x16,
        lv_date TYPE d,
        lv_time TYPE t.

  LOOP AT entities INTO DATA(ls_entity).

    TRY.
        lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

    lv_date = cl_abap_context_info=>get_system_date( ).
    lv_time = cl_abap_context_info=>get_system_time( ).

    APPEND VALUE z22ad070bh(
      mandt      = sy-mandt
      bill_uuid  = lv_uuid
      bill_no    = |INV-{ lv_time }|
      cust_name  = ls_entity-cust_name
      bill_date  = lv_date
      pay_status = 'Draft'
      currency   = ls_entity-currency
    ) TO gt_bh.

  ENDLOOP.

ENDMETHOD.



  METHOD update.
  ENDMETHOD.



METHOD delete.

  LOOP AT keys INTO DATA(ls_key).

    DELETE FROM z22ad039bh
      WHERE bill_uuid = @ls_key-bill_uuid.

  ENDLOOP.

ENDMETHOD.



METHOD read.

  DATA lt_db TYPE STANDARD TABLE OF z22ad039bh.

  IF keys IS NOT INITIAL.

    SELECT *
      FROM z22ad039bh
      FOR ALL ENTRIES IN @keys
      WHERE bill_uuid = @keys-bill_uuid
      INTO TABLE @lt_db.

  ENDIF.

  LOOP AT lt_db INTO DATA(ls_db).

    APPEND VALUE #(
      bill_uuid = ls_db-bill_uuid
      bill_no   = ls_db-bill_no
      cust_name = ls_db-cust_name
      bill_date = ls_db-bill_date
      total_amt = ls_db-total_amt
      currency  = ls_db-currency
      pay_status = ls_db-pay_status
    ) TO result.

  ENDLOOP.

ENDMETHOD.



  METHOD lock.
  ENDMETHOD.



METHOD rba_Item.

  DATA lt_db TYPE STANDARD TABLE OF z22ad039bi.

  IF keys_rba IS NOT INITIAL.

    SELECT *
      FROM z22ad039bi
      FOR ALL ENTRIES IN @keys_rba
      WHERE bill_uuid = @keys_rba-bill_uuid
      INTO TABLE @lt_db.

  ENDIF.

  LOOP AT lt_db INTO DATA(ls_db).

    APPEND VALUE #(
      item_uuid  = ls_db-item_uuid
      bill_uuid  = ls_db-bill_uuid
      item_pos   = ls_db-item_pos
      product_id = ls_db-product_id
      qty        = ls_db-qty
      unit_price = ls_db-unit_price
      subtotal   = ls_db-subtotal
      currency   = ls_db-currency
    ) TO result.

  ENDLOOP.

ENDMETHOD.



METHOD cba_Item.

  LOOP AT entities_cba INTO DATA(ls_cba).

    LOOP AT ls_cba-%target INTO DATA(ls_item).

      DATA lv_item_uuid TYPE sysuuid_x16.
      DATA lv_subtotal  TYPE z22ad039bi-subtotal.
      DATA ls_db        TYPE z22ad039bi.

      TRY.
          lv_item_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          CONTINUE.
      ENDTRY.

      lv_subtotal = ls_item-qty * ls_item-unit_price.

      ls_db-mandt      = sy-mandt.
      ls_db-item_uuid  = lv_item_uuid.
      ls_db-bill_uuid  = ls_cba-bill_uuid.
      ls_db-item_pos   = ls_item-item_pos.
      ls_db-product_id = ls_item-product_id.
      ls_db-qty        = ls_item-qty.
      ls_db-unit_price = ls_item-unit_price.
      ls_db-subtotal   = lv_subtotal.
      ls_db-currency   = ls_item-currency.

      INSERT z22ad039bi FROM @ls_db.

    ENDLOOP.

  ENDLOOP.

ENDMETHOD.

ENDCLASS.



CLASS lhc_Z22AD039_I_BI DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE z22ad039_i_bi.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE z22ad039_i_bi.

    METHODS read FOR READ
      IMPORTING keys FOR READ z22ad039_i_bi RESULT result.

    METHODS rba_Header FOR READ
      IMPORTING keys_rba FOR READ z22ad039_i_bi\_Header FULL result_requested RESULT result LINK association_links.

ENDCLASS.



CLASS lhc_Z22AD039_I_BI IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

METHOD delete.

  LOOP AT keys INTO DATA(ls_key).

    DELETE FROM z22ad039bi
      WHERE item_uuid = @ls_key-item_uuid.

  ENDLOOP.

ENDMETHOD.

METHOD read.

  DATA lt_db TYPE STANDARD TABLE OF z22ad039bi.

  IF keys IS NOT INITIAL.

    SELECT *
      FROM z22ad039bi
      FOR ALL ENTRIES IN @keys
      WHERE item_uuid = @keys-item_uuid
      INTO TABLE @lt_db.

  ENDIF.

  LOOP AT lt_db INTO DATA(ls_db).

    APPEND VALUE #(
      item_uuid  = ls_db-item_uuid
      bill_uuid  = ls_db-bill_uuid
      item_pos   = ls_db-item_pos
      product_id = ls_db-product_id
      qty        = ls_db-qty
      unit_price = ls_db-unit_price
      subtotal   = ls_db-subtotal
      currency   = ls_db-currency
    ) TO result.

  ENDLOOP.

ENDMETHOD.

METHOD rba_Header.

  LOOP AT keys_rba INTO DATA(ls_key).

    "First get bill_uuid from item table
    SELECT SINGLE bill_uuid
      FROM z22ad039bi
      WHERE item_uuid = @ls_key-%key-item_uuid
      INTO @DATA(lv_bill_uuid).

    IF sy-subrc = 0.

      "Now fetch header
      SELECT SINGLE *
        FROM z22ad039bh
        WHERE bill_uuid = @lv_bill_uuid
        INTO @DATA(ls_db).

      IF sy-subrc = 0.

        APPEND VALUE #(
          bill_uuid  = ls_db-bill_uuid
          bill_no    = ls_db-bill_no
          cust_name  = ls_db-cust_name
          bill_date  = ls_db-bill_date
          total_amt  = ls_db-total_amt
          currency   = ls_db-currency
          pay_status = ls_db-pay_status
        ) TO result.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDMETHOD.

ENDCLASS.



CLASS lsc_Z22AD039_I_BH DEFINITION
  INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.


ENDCLASS.



CLASS lsc_Z22AD039_I_BH IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.


METHOD save.
    " Save Header data [cite: 90, 1048]
    IF lhc_Z22AD039_I_BH=>gt_bh IS NOT INITIAL.
      INSERT z22ad039bh FROM TABLE @lhc_Z22AD039_I_BH=>gt_bh.
      CLEAR lhc_Z22AD039_I_BH=>gt_bh. " Clear buffer after save [cite: 37]
    ENDIF.

    " Save Item data [cite: 1048]
    IF lhc_Z22AD039_I_BH=>gt_bi IS NOT INITIAL.
      INSERT z22ad039bi FROM TABLE @lhc_Z22AD039_I_BH=>gt_bi.
      CLEAR lhc_Z22AD039_I_BH=>gt_bi. " Clear buffer after save [cite: 37]
    ENDIF.
ENDMETHOD.



  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
