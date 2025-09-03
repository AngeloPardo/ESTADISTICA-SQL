USE AgroD365FO;
GO

SELECT DISTINCT
    SLB.SalesId AS ORDE_VENTA,
	ISNULL(SOL.SalesOrderNumber,'-') AS ORDEN_NC,
	CONVERT(VARCHAR(8), CAST(DATEADD(HOUR, -5, slb.CreatedOn) AS DATE), 112) AS FECHA_ORDEN,
	COALESCE (BIP.InvoiceNumber,IDF.InvoiceId,'-') AS FACTURA,
	COALESCE (ISNULL(CONVERT(VARCHAR(8), CAST(DATEADD(HOUR, -5, IDF.InvoiceDate) AS DATE), 112),
	CONVERT(VARCHAR(8), CAST(DATEADD(HOUR, -5, BIP.InvoiceDate) AS DATE), 112) ),'-') AS FECHA_FACTURA,
	SLB.InventTransId,
	SLB.SalesStatus,
	LEFT(SLB.ItemId, 3) AS GRUPO,
    SLB.ItemId,
    SLB.LineNum,
    SLB.Name,
	SLB.BundleLineType,
    SLB.LineHeader,
	COALESCE(BIP.InvoicedQuantity,IDF.QTY,BOP.ConfirmedSalesQuantity,SLB.SalesQty,0) AS CANTIDAD,
	SLB.SalesUnit ,
	SLB.CustAccount,
	COALESCE(UPPER(SOH3.SalesOrderName),UPPER(SOH2.SalesOrderName),'-') AS NOMBRE_CLIENTE,
    COALESCE(SOH3.OrderTakerPersonnelNumber,SOH2.OrderTakerPersonnelNumber,'-') AS SECRETARIO,
	COALESCE(UPPER(EMP.NAME),UPPER(WKS_.NAME),'-') AS NOMBRE_SECRETARIO,
	COALESCE(UPPER(WKS.TitleId),UPPER(WKS_.TitleId),'-') AS CARGO_SECRETARIO,
    COALESCE(UPPER(SOH3.OrderResponsiblePersonnelNumber),UPPER(SOH2.OrderResponsiblePersonnelNumber),'-') AS RESPONSABLE,
	COALESCE(UPPER(EMP2.NAME),UPPER(WKS2_.NAME),'-') AS NOMBRE_RESPONSABLE,
	COALESCE(UPPER(EMP2.TitleId),UPPER(WKS2_.TitleId),'-') AS CARGO_RESPONSABLE,
	SLB.TaxItemGroup,
	SLB.LinePercent,
	CAST(ROUND(
  COALESCE(
    TRY_CONVERT(decimal(19,6), REPLACE(SLB.LineDisc, ',', '')),
    -- Si viene como 161.984,67: quita puntos de miles y cambia coma por punto
    TRY_CONVERT(decimal(19,6), REPLACE(REPLACE(SLB.LineDisc, '.', ''), ',', '.'))), 0) AS int) as DESCUENTO,
	--COALESCE(NULLIF(BIP.LineAmount, 0),NULLIF(IDF.LineAmount, 0),NULLIF(SLB.LineAmount, 0), BOP.LineAmount, 0)  AS VALOR_INC_IVA,
	CASE  WHEN SLB.BundleLineType = 'BundleComponent' THEN 0 ELSE COALESCE(NULLIF(BIP.LineAmount, 0),NULLIF(IDF.LineAmount, 0),NULLIF(SLB.LineAmount, 0), BOP.LineAmount, 0) END  AS VLR_EXC_IVA,
	CAST(CASE  WHEN SLB.BundleLineType = 'BundleComponent' THEN 0 ELSE CASE WHEN SLB.TaxItemGroup = 'Vta_Mci5%'  THEN CAST(COALESCE(NULLIF(BIP.LineAmount,0), NULLIF(IDF.LineAmount,0), NULLIF(SLB.LineAmount,0), BOP.LineAmount, 0) AS DECIMAL(18,4)) * CAST(1.05 AS DECIMAL(18,4))
    WHEN SLB.TaxItemGroup = 'Vta_Mci19%' THEN CAST(COALESCE(NULLIF(BIP.LineAmount,0), NULLIF(IDF.LineAmount,0), NULLIF(SLB.LineAmount,0), BOP.LineAmount, 0) AS DECIMAL(18,4)) * CAST(1.19 AS DECIMAL(18,4))
    ELSE CAST(COALESCE(NULLIF(BIP.LineAmount,0), NULLIF(IDF.LineAmount,0), NULLIF(SLB.LineAmount,0), BOP.LineAmount, 0) AS DECIMAL(18,4)) END END AS DECIMAL(18,0)) AS VLR_INC_IVA , 
	SLB.SysCreatedBy,
	SLB.SysModifiedBy,
	SOH.SalesOrderOriginCode,
	SLB.SalesGroup,
	slb.SalesGroup AS  CODIGO_VENDEDOR,
	SLB.DlvMode,
CASE WHEN  SLB.CustAccount = '900423563' THEN 'PESTAR' ELSE '-' END AS SECTOR
 

FROM SalesLineBiEntities SLB WITH (NOLOCK)
LEFT JOIN BundleSalesOrderConfirmationBundleParentLines BOP WITH (NOLOCK) ON SLB.InventTransId = BOP.SalesOrderLineInventoryLotId
LEFT JOIN BundleSalesInvoiceBundleParentLines BIP WITH (NOLOCK) ON SLB.InventTransId = BIP.InventoryLotId
LEFT JOIN InvoiceDetailFreights IDF WITH (NOLOCK) ON SLB.InventTransId = idf.InventTransId
LEFT JOIN SalesOrderLinesV3 SOL WITH (NOLOCK) ON SLB.InventTransIdReturn = SOL.InventoryLotId 
LEFT JOIN D365SalesOrderHeaders SOH3  WITH (NOLOCK) ON  SLB.SalesId = SOH3.SalesOrderNumber
LEFT JOIN D365SalesOrderHeaders SOH2  WITH (NOLOCK) ON  SOL.SalesOrderNumber = SOH2.SalesOrderNumber  ---- Trae el nombre en las notas credito
LEFT JOIN SalesOrderHeadersV4 SOH WITH (NOLOCK) ON SLB.SalesId = SOH.SalesOrderNumber
LEFT JOIN EmployeesV2 EMP WITH (NOLOCK) ON  COALESCE(SOH3.OrderTakerPersonnelNumber,SOH2.OrderTakerPersonnelNumber,'-') = EMP.PersonnelNumber
LEFT JOIN Workers WKS WITH (NOLOCK) ON SOH3.OrderTakerPersonnelNumber = WKS.PersonnelNumber
LEFT JOIN Workers WKS_ WITH (NOLOCK) ON SOH2.OrderTakerPersonnelNumber = WKS_.PersonnelNumber
LEFT JOIN EmployeesV2 EMP2 WITH (NOLOCK) ON COALESCE(UPPER(SOH3.OrderResponsiblePersonnelNumber),UPPER(SOH2.OrderResponsiblePersonnelNumber),'-') = EMP2.PersonnelNumber
LEFT JOIN Workers WKS2_ WITH (NOLOCK) ON SOH2.OrderResponsiblePersonnelNumber = WKS2_.PersonnelNumber
 
where CONVERT(VARCHAR(8), CAST(DATEADD(HOUR, -5, ISNULL(IDF.InvoiceDate, BIP.InvoiceDate)) AS DATE), 112) BETWEEN '20250601' AND '20250915'	