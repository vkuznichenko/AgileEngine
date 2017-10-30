select * from [dbo].[ProductType]
select * from [dbo].[Products]
select * from [dbo].[Stores]
select * from [dbo].[Prices]

select * from [dbo].[Request]
select * from [dbo].[RequestType]

select * from [dbo].[ProcessStore]
select * from [dbo].[ProcessProducts]


----------------------Stores
go
exec dbo.SearchStores --show active stores

declare @RequestId int
exec dbo.ManageStore   @RequestId = @RequestId output,@StoreId = null,@StoreName = N'Ashan3',@Country = N'Ukraine',@City = N'Kiev',@Region = N'kie',@Address = N'33 street',@Action = 'Insert' 
select @RequestId 
/*
declare @RequestId int
exec dbo.ManageStore   @RequestId = @RequestId output,@StoreId = 5,@StoreName = N'Ashan16',@Action = 'Update' 
select @RequestId 
*/
/*
declare @RequestId int
exec dbo.ManageStore   @RequestId = @RequestId output,@StoreId = 5,@Action = 'Delete' 
select @RequestId 
*/

exec dbo.SearchManagedStores

exec dbo.approvestores @RequestId, 'Success'

----------------------Products
go
exec [dbo].[SearchProducts]  --show active products

declare @RequestId int
exec dbo.ManageProducts    @RequestId = @RequestId output,@ProductId = null,@ProductTypeId = NULL,@ProductName = 'Product3',@ProductTypeName = 'Meat' ,@Action = 'Insert' 
select @RequestId 
/*
declare @RequestId int
exec dbo.ManageProducts    @RequestId = @RequestId output,@ProductId = 8,@ProductTypeId = 1,@ProductName = 'Product4',@ProductTypeName = 'Seafood2' ,@Action = 'Update' 
select @RequestId 
*/
/*
declare @RequestId int
exec dbo.ManageProducts    @RequestId = @RequestId output,@ProductId = 8,@ProductTypeId = 1,@ProductName = 'Product4',@ProductTypeName = 'Seafood2' ,@Action = 'Delete' 
select @RequestId 
*/
exec dbo.SearchManagedProducts

exec dbo.ApproveProducts @RequestId, 'Success'

----------------------Prices
go

exec dbo.SearchPrices  --show active prices
----------------------UpdatePrices
declare @Xml xml
set @Xml = 
'<root>
	<row><ProductId>5</ProductId><StoreId>2</StoreId><Price>19.22</Price><PriceComment>PriceComment</PriceComment></row>
	<row><ProductId>2</ProductId><StoreId>1</StoreId><Price>9.99</Price><PriceComment>PriceComment2</PriceComment></row>
	<row><ProductId>1</ProductId><StoreId>1</StoreId><Price>1.99</Price><PriceComment>PriceComment3</PriceComment></row>
</root>'
--For update use only existing ProductId and PriceId in dbo.Prices

declare @RequestId int
exec dbo.ManagePrice    @RequestId = @RequestId output,@PriceXML = @Xml ,@Action = 'Update'
select @RequestId 

	
exec dbo.SearchManagedPrices

exec dbo.ApprovePrices @RequestId,'Success'
go
----------------------InsertPrices
GO
declare @Xml xml
set @Xml = 
'<root>
	<row><ProductId>5</ProductId><StoreId>1</StoreId><Price>999.22</Price><PriceComment>PriceComment</PriceComment></row>
	<row><ProductId>6</ProductId><StoreId>1</StoreId><Price>1099.99</Price><PriceComment>PriceComment2</PriceComment></row>
	<row><ProductId>6</ProductId><StoreId>2</StoreId><Price>999.99</Price><PriceComment>PriceComment3</PriceComment></row>
</root>'
--For insert use only existing ProductId and PriceId from dbo.Products and dbo.Stores. 

declare @RequestId int
exec dbo.ManagePrice    @RequestId = @RequestId output,@PriceXML = @Xml ,@Action = 'Insert'
select @RequestId 

	
exec dbo.SearchManagedPrices

exec dbo.ApprovePrices @RequestId,'Success'

----------------------DeletePrices
GO
declare @Xml xml
set @Xml = 
'<root>
	<row><ProductId>5</ProductId><StoreId>1</StoreId><Price>999.22</Price><PriceComment>PriceComment</PriceComment></row>
	<row><ProductId>6</ProductId><StoreId>1</StoreId><Price>1099.99</Price><PriceComment>PriceComment2</PriceComment></row>
	<row><ProductId>6</ProductId><StoreId>2</StoreId><Price>999.99</Price><PriceComment>PriceComment3</PriceComment></row>
</root>'
--For delete use only existing ProductId and PriceId from dbo.Prices. Price and PriceComment is not mondatory

declare @RequestId int
exec dbo.ManagePrice    @RequestId = @RequestId output,@PriceXML = @Xml ,@Action = 'Delete'
select @RequestId 

	
exec dbo.SearchManagedPrices

exec dbo.ApprovePrices @RequestId,'Success'
