USE [WideWorldImporters]
GO
CREATE INDEX idx_Orders_By_PO on Sales.Orders ([CustomerPurchaseOrderNumber])
INCLUDE (CustomerID, OrderId, SalesPersonPersonID,ContactPersonID)
GO

SELECT CustomerID, OrderId, SalesPersonPersonID,ContactPersonID
FROM Sales.Orders
WHERE [CustomerPurchaseOrderNumber] = 10776

DROP INDEX idx_Orders_By_PO on Sales.Orders