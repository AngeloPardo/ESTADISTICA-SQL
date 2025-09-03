USE AGROD365FO;
SELECT DISTINCT 
    POL.Itemnumber AS CODIGO,
    POL.LineDescription AS DESCRIPCION,
    LEFT(POL.Itemnumber, 3) AS GRUPO,
    POL.PurchaseOrderNumber AS ORDEN,
    POH.ReasonCode AS TIPO,
    POL.ReceivingWarehouseId AS ALMACEN,
    CONVERT(VARCHAR(8), CAST(POH.AccountingDate AS DATE), 112) AS FECHAORDEN,
    TRY_CAST(POL.OrderedPurchaseQuantity AS FLOAT) AS CANT_ORDEN,
    ISNULL(CONVERT(VARCHAR(8), CAST(PRL.ProductReceiptDate AS DATE), 112), '-') AS FECHA_INGRESO,
    ISNULL(PRL.ReceivedPurchaseQuantity, '-') AS CANT_RECIBO,
    TRY_CAST(POL.PurchasePrice AS FLOAT) AS PRECIO_COMPRA,
    ISNULL(TRY_CAST(PRL.ReceivedPurchaseQuantity AS FLOAT), 0) * TRY_CAST(POL.PurchasePrice AS FLOAT) AS PRECIO_COMPRA_TOTAL,
    ISNULL(PRL.RemainingPurchaseQuantity, '-') AS CANT_PEND,
    CASE 
        WHEN ISNULL(Disp.TotalAvailableOnHand, 0) < 0 THEN 0 
        ELSE ISNULL(Disp.TotalAvailableOnHand, 0) 
    END AS DISPONIBLE,
    RP.BuyerGroupId AS COMPRADOR
FROM PurchaseOrderLinesV2 POL
LEFT JOIN PurchaseOrderHeaders POH ON POL.PurchaseOrderNumber = POH.PurchaseOrderNumber
LEFT JOIN ProductReceiptLines PRL ON POL.PurchaseOrderNumber = PRL.PurchaseOrderNumber
AND POL.LineNumber = PRL.PurchaseOrderLineNumber
LEFT JOIN Workers W ON POH.OrdererPersonnelNumber = W.PersonnelNumber
LEFT JOIN ReleasedProductsV2 RP ON RP.ItemNumber = POL.Itemnumber
LEFT JOIN (
    SELECT 
        ItemNumber,
        SUM(CAST(ISNULL(AvailableOnHandQuantity, 0) AS FLOAT)) AS TotalAvailableOnHand
    FROM WarehousesOnHandV2 WITH (NOLOCK)
    WHERE InventoryWarehouseId IN ('005', '008')
    GROUP BY ItemNumber
) Disp ON Disp.ItemNumber = POL.Itemnumber
WHERE RP.BuyerGroupId = 'MASC & VAR' --'MASC & VAR''MEDICA GEN'--
ORDER BY 
    POL.Itemnumber ASC,
    POL.PurchaseOrderNumber DESC;


