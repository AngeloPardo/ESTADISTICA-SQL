USE AgroD365FO
SELECT p.ProductNumber,
p.ProductName, 
w.InventoryWarehouseId, 
w.OnHandQuantity, 
w.ReservedOnHandQuantity, 
w.AvailableOnHandQuantity, 
w.OrderedQuantity, 
w.TotalAvailableQuantity, 
t.TaxItemGroupId, t.Price, 
(SELECT TOP 1 b.BatchNumber 
FROM ItemBatches b 
WHERE b.ItemNumber = p.ProductNumber
ORDER BY b.BatchExpirationDate DESC) AS BatchNumber, 
(SELECT TOP 1 b.BatchExpirationDate 
FROM ItemBatches b WHERE b.ItemNumber = p.ProductNumber 
ORDER BY b.BatchExpirationDate DESC) AS BatchExpirationDate 
FROM AllProducts p INNER JOIN WarehousesOnHandV2 w ON p.ProductNumber = w.ItemNumber 
INNER JOIN InventTableModuleBiEntities t ON t.ItemId = w.ItemNumber 
WHERE w.InventoryWarehouseId IN ('005', '008') AND t.ModuleType = 'Sales' 
--and p.ProductNumber ='911000003'
ORDER BY p.ProductNumber