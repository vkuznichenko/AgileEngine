
GO
IF OBJECT_ID('dbo.Prices') IS NOT NULL
    DROP TABLE dbo.Prices
GO
IF OBJECT_ID('dbo.Products') IS NOT NULL
    DROP TABLE dbo.Products
GO
IF OBJECT_ID('dbo.ProductType') IS NOT NULL
    DROP TABLE dbo.ProductType
GO
IF OBJECT_ID('dbo.Stores') IS NOT NULL
    DROP TABLE dbo.Stores
GO
GO
IF OBJECT_ID('dbo.Request') IS NOT NULL
    DROP TABLE dbo.Request
GO
IF OBJECT_ID('dbo.RequestType') IS NOT NULL
    DROP TABLE dbo.RequestType
GO


CREATE TABLE dbo.ProductType
    (
      ProductTypeID INT IDENTITY PRIMARY KEY ,
      ProductTypeName varchar(100) NOT NULL,
	  IsActive BIT DEFAULT (1),
 CONSTRAINT [UK_ProductType] UNIQUE (ProductTypeName,IsActive)
    );
GO
CREATE TABLE dbo.Products
    (
      ProductID INT IDENTITY PRIMARY KEY ,
	  ProductTypeID INT NOT NULL,
      ProductName varchar(100) NOT NULL ,
	  IsActive BIT DEFAULT (1),
	  CONSTRAINT [FK_Products_ProductType] FOREIGN KEY(ProductTypeID) REFERENCES [dbo].[ProductType] (ProductTypeID),
 CONSTRAINT [UK_Product] UNIQUE (ProductName,IsActive)
    );
GO


CREATE TABLE dbo.Stores
    (
      StoreID INT IDENTITY PRIMARY KEY,
      StoreName varchar(100) NOT NULL,
	  Country varchar(20) NOT NULL,
	  City varchar(20) NOT NULL,
	  Region varchar(20) NOT NULL,
	  Address varchar(100) NOT NULL,
	  IsActive BIT DEFAULT (1),
 CONSTRAINT [UK_Store] UNIQUE (StoreName,Country,City,Region,Address,IsActive)
    );

GO

CREATE TABLE dbo.Prices
	(
	[ProductID] [int] NOT NULL,
	[StoreID] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[PriceComment] [varchar](500) NULL,
	IsActive BIT DEFAULT (1),
 CONSTRAINT [PK_Prices] PRIMARY KEY CLUSTERED ([ProductID] ASC,[StoreID] ASC),
 CONSTRAINT [FK_Prices_Products] FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID]),
 CONSTRAINT [FK_Prices_Stores] FOREIGN KEY([StoreID]) REFERENCES [dbo].[Stores] ([StoreID]),
 CONSTRAINT [CHK_Prices_Price] CHECK(Price > 0)
	);
	
GO

CREATE TABLE [dbo].[RequestType]
(
	[RequestTypeId] [int] IDENTITY(1,1) NOT NULL,
	[RequestTypeName] [varchar](15) NOT NULL,
 CONSTRAINT [PK_RequestType] PRIMARY KEY CLUSTERED ([RequestTypeId] ASC)
)
GO

CREATE TABLE [dbo].[Request]
	(
	[RequestId] [int] IDENTITY(1,1) NOT NULL,
	[RequestTypeId] [int] NOT NULL,
	[RequestStatus] [varchar](15) NOT NULL,
	[UserName] [varchar](50) NOT NULL,
	[Action] [varchar](10) NOT NULL,
	[CreationTime] [datetime] NOT NULL,
	[UpdateTime] [datetime] NULL,
	-- [ValidateStatus] [bit] DEFAULT (0),
	-- [ValidateMessage] [varchar](500) NULL,
 CONSTRAINT [PK_Requests] PRIMARY KEY CLUSTERED ([RequestId] ASC),
 CONSTRAINT [FK_Request_RequestType] FOREIGN KEY([RequestTypeId]) REFERENCES [dbo].[RequestType] ([RequestTypeId]),
 CONSTRAINT [CK_Request_Action] CHECK  (([Action]='Insert' OR [Action]='Update' OR [Action]='Delete')),
 CONSTRAINT [CK_Request_Status] CHECK  (([RequestStatus]='Creating' OR [RequestStatus]='Success' OR [RequestStatus]='Failed'))
	)
-----------------------ProcessingTables
IF OBJECT_ID('dbo.ProcessStore') IS NOT NULL
    DROP TABLE dbo.ProcessStore
GO

CREATE TABLE [dbo].[ProcessStore]
	(
	[RequestId]	[int] NOT NULL,
	StoreID		[int] NULL,
	StoreName varchar(100) NULL,
	Country varchar(20) NULL,
	City varchar(20) NULL,
	Region varchar(20) NULL,
	Address varchar(100) NULL
	)
GO
	
IF OBJECT_ID('dbo.ProcessProducts') IS NOT NULL
    DROP TABLE dbo.ProcessProducts
GO
CREATE TABLE dbo.ProcessProducts
    (
	  [RequestId]	[int] NOT NULL,
      ProductID INT NULL,
	  ProductTypeID INT NULL,
      ProductName varchar(100)  NULL ,
      ProductTypeName varchar(100) NULL 
    );
GO

IF OBJECT_ID('dbo.ProcessPrices') IS NOT NULL
    DROP TABLE dbo.ProcessPrices
GO
CREATE TABLE dbo.ProcessPrices
	(
	[RequestId]	[int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[StoreID] [int] NULL,
	[Price] [money] NULL,
	[PriceComment] [varchar](500) NULL
	);
	
GO

-------------------Search
-------------------SearchStores
GO
IF OBJECT_ID('dbo.SearchStores') IS NOT NULL
    DROP PROCEDURE dbo.SearchStores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.SearchStores
	@IsActive BIT = 1
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;

	SELECT 
		StoreID,
		StoreName,
		Country,
		City,
		Region,
		Address 
	FROM 
		dbo.Stores
	WHERE IsActive = @IsActive
	
END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
GO
-------------------SearchStores
-------------------SearchProducts
GO
IF OBJECT_ID('dbo.SearchProducts') IS NOT NULL
    DROP PROCEDURE dbo.SearchProducts
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.SearchProducts
	@IsActive bit = 1
AS
BEGIN
	SET NOCOUNT ON;

	select 
		pd.ProductID,
		pt.ProductTypeID,
		pd.ProductName,
		pt.ProductTypeName
	from dbo.Products pd 
		INNER JOIN dbo.ProductType pt on pd.ProductTypeId = pt.ProductTypeId
	WHERE 
		pd.IsActive = @IsActive
		AND pt.IsActive = @IsActive
	
END
GO
-------------------SearchProducts
-------------------SearchPrices
GO
IF OBJECT_ID('dbo.SearchPrices') IS NOT NULL
    DROP PROCEDURE dbo.SearchPrices
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.SearchPrices
	@IsActive bit = 1
AS
BEGIN
	SET NOCOUNT ON;

	
SELECT 
	pd.ProductID,
	pd.ProductName,
	st.StoreID, 
	st.StoreName,
	pt.ProductTypeName,
	pc.Price, 
	pc.PriceComment
FROM dbo.Prices pc 
join dbo.Products pd on pc.ProductId = pd.ProductId
join dbo.ProductType pt on pd.ProductTypeID = pt.ProductTypeID
join dbo.Stores st on pc.StoreID = st.StoreID
WHERE pc.IsActive = @IsActive
END
GO
-------------------SearchPrices
-------------------Search


-------------------Request
GO
IF OBJECT_ID('dbo.CreateRequest') is not null
DROP PROCEDURE dbo.CreateRequest
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.CreateRequest
				@RequestId INT OUTPUT,
				@RequestTypeId INT,
				@UserName varchar(50) = NULL,
				@Action varchar(10)


AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;

    INSERT INTO dbo.Request
	(
	RequestTypeId,
	RequestStatus,
	UserName,
	[Action],
	[CreationTime]
	)
	VALUES
	(
	@RequestTypeId,
	'Creating',
	CASE 
		WHEN isnull(@UserName,'') = '' THEN USER_NAME()
		ELSE @UserName 
		END,
	@Action,
	GETDATE()
	)

	SET @RequestId = SCOPE_IDENTITY()
END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
-----------------------------------------------
GO
IF OBJECT_ID('dbo.UpdateRequest') is not null
DROP PROCEDURE dbo.UpdateRequest
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.UpdateRequest
				@RequestId INT ,
				@RequestStatus varchar(15)


AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;

    UPDATE 
		dbo.Request 
	SET 
		RequestStatus = @RequestStatus , 
		UpdateTime = GETDATE()
	WHERE
		Requestid = @RequestId

		IF @@ROWCOUNT != 1 RAISERROR('Unable to update RequestId',16,1)
END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH

END

GO
-------------------Request



-------------------Manage
-------------------ManageStore
GO
IF OBJECT_ID('dbo.ManageStore') is not null
DROP PROCEDURE dbo.ManageStore
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.ManageStore
				@RequestId INT OUTPUT,
				@StoreID		int = NULL,
				@StoreName varchar(100) = NULL,
				@Country varchar(20) = NULL,
				@City varchar(20) = NULL,
				@Region varchar(20) = NULL,
				@Address varchar(100) = NULL,
				@Action varchar(20) = NULL


AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;

	EXEC dbo.CreateRequest @requestId = @RequestId output, @RequestTypeId = 2,@UserName = DEFAULT, @Action = @Action  

	INSERT [dbo].[ProcessStore] 
	(RequestId, [StoreID], [StoreName], [Country], [City], [Region], [Address] ) 
	VALUES 
	(
	@RequestId,
	@StoreID, 
	@StoreName, 
	@Country, 
	@City, 
	@Region, 
	@Address
	)
	
	
END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
-------------------ManageStore
-------------------ManageProducts

GO
IF OBJECT_ID('dbo.ManageProducts') is not null
DROP PROCEDURE dbo.ManageProducts
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.ManageProducts
				@RequestId INT OUTPUT,
				@ProductID		int = NULL,
				@ProductTypeID int = NULL,
				@ProductName varchar(100) = NULL,
				@ProductTypeName varchar(100) = NULL,
				@Action varchar(20) = NULL


AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	EXEC dbo.CreateRequest @requestId = @RequestId output, @RequestTypeId = 1,@UserName = DEFAULT, @Action = @Action  
	
	INSERT [dbo].[ProcessProducts] 
	(RequestId, ProductID, ProductTypeID, ProductName, ProductTypeName ) 
	VALUES 
	(
	@RequestId,
	@ProductID, 
	@ProductTypeID, 
	@ProductName, 
	@ProductTypeName
	)
	
END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
GO
-------------------ManageProducts
-------------------ManagePrice
GO
IF OBJECT_ID('dbo.ManagePrice') is not null
DROP PROCEDURE dbo.ManagePrice
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.ManagePrice
				@RequestId INT OUTPUT,
				@PriceXML xml,
				@Action varchar(20) = NULL


AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;

	EXEC dbo.CreateRequest @requestId = @RequestId output, @RequestTypeId = 3,@UserName = DEFAULT, @Action = @Action  

	INSERT [dbo].[ProcessPrices] 
	([RequestId], [ProductId], [StoreID], [Price], [PriceComment] ) 
	SELECT 
		@RequestId,
		ProductId = x.v.value('ProductId[1]','INT'),
		StoreId = x.v.value('StoreId[1]','INT'),
		Price = x.v.value('Price[1]','money'),
		PriceComment = x.v.value('PriceComment[1]','varchar(500)')
	FROM @PriceXML.nodes('root/row') x(v)
	
	
END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
GO
-------------------ManagePrice
-------------------Manage



-------------------SearchManaged
-------------------SearchManagedStores
GO
IF OBJECT_ID('dbo.SearchManagedStores') IS NOT NULL
    DROP PROCEDURE dbo.SearchManagedStores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.SearchManagedStores

AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;

	SELECT 
		ps.StoreID
		,StoreName = ISNULL(ps.StoreName,s.StoreName)
		,Country = ISNULL(ps.Country,s.Country)
		,City = ISNULL(ps.City,s.City)
		,Region = ISNULL(ps.Region,s.Region)
		,Address = ISNULL(ps.Address,s.Address)
		,r.Action
		,r.RequestId	
	FROM dbo.ProcessStore ps 
		LEFT JOIN dbo.Stores s ON s.StoreID = ps.StoreID AND s.IsActive = 1
		INNER JOIN dbo.Request r ON r.RequestId = ps.RequestId and r.RequestStatus = 'Creating' 
		INNER JOIN [dbo].[RequestType] rt on rt.RequestTypeId = r.RequestTypeId and rt.RequestTypeName = 'Manage Store'
	
END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
GO
-------------------SearchManagedStores
-------------------SearchManagedProducts
GO
IF OBJECT_ID('dbo.SearchManagedProducts') IS NOT NULL
    DROP PROCEDURE dbo.SearchManagedProducts
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.SearchManagedProducts

AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;

	select 
		pp.ProductID,
		pp.ProductTypeID,
		ProductName = isnull(pp.ProductName,p.ProductName),
		ProductTypeName = isnull(pp.ProductTypeName,pt.ProductTypeName),
		r.Action,
		r.RequestId
	from dbo.ProcessProducts pp
		Left JOIN dbo.Products p on pp.ProductId = p.ProductId AND p.IsActive = 1
		Left JOIN dbo.ProductType pt on pp.ProductTypeId = pt.ProductTypeId AND pt.IsActive = 1
		INNER JOIN dbo.Request r ON r.RequestId = pp.RequestId and r.RequestStatus = 'Creating' 
		INNER JOIN [dbo].[RequestType] rt on rt.RequestTypeId = r.RequestTypeId and rt.RequestTypeName = 'Manage Product'

	
END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
GO
-------------------SearchManagedProducts
-------------------SearchManagedPrice
GO
IF OBJECT_ID('dbo.SearchManagedPrices') IS NOT NULL
    DROP PROCEDURE dbo.SearchManagedPrices
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.SearchManagedPrices

AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;

	SELECT 
		pp.ProductID
		,pp.StoreID
		,Price = ISNULL(pp.Price,p.Price)
		,Country = ISNULL(pp.PriceComment,p.PriceComment)
		,r.Action
		,r.RequestId	
	FROM dbo.ProcessPrices pp 
		LEFT JOIN dbo.Prices p ON p.ProductID = pp.ProductID AND p.StoreID = pp.StoreID AND p.IsActive = 1
		INNER JOIN dbo.Request r ON r.RequestId = pp.RequestId AND r.RequestStatus = 'Creating' 
		INNER JOIN [dbo].[RequestType] rt on rt.RequestTypeId = r.RequestTypeId AND rt.RequestTypeName = 'Manage Price'
	
END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
GO
-------------------SearchManagedPrice
-------------------SearchManaged








-------------------Approve
-------------------ApproveStores

GO
IF OBJECT_ID('dbo.ApproveStores') IS NOT NULL
    DROP PROCEDURE dbo.ApproveStores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.ApproveStores
					@RequestId INT,
					@Status varchar(15) --'Success' OR 'Failed'

AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	
	IF (@Status<>'Success')
	BEGIN
		EXEC dbo.UpdateRequest @RequestId=@RequestId, @RequestStatus='Failed'
		return;
	END

	DECLARE
	@Action VARCHAR(10),
	@RowNumber INT = 0

	SELECT @Action = Action FROM Request
	WHERE RequestId = @RequestId

	IF (@Action = 'Insert')
	BEGIN
		INSERT dbo.Stores
		(
			StoreName
			,Country
			,City
			,Region
			,Address
		)
		SELECT 
			StoreName = ps.StoreName
			,Country = ps.Country
			,City = ps.City
			,Region = ps.Region
			,Address = ps.Address	
		FROM dbo.ProcessStore ps 
			inner join dbo.Request r on r.RequestId = ps.RequestId
		WHERE ps.RequestId = @RequestId
			AND r.Action = 'Insert'
			and r.RequestStatus = 'Creating'
			--AND r.ValidateStatus = '1'
	END
	ELSE IF(@Action = 'Update')
	BEGIN
		UPDATE s SET
			StoreName = ISNULL(ps.StoreName,s.StoreName)
			,Country = ISNULL(ps.Country,s.Country)
			,City = ISNULL(ps.City,s.City)
			,Region = ISNULL(ps.Region,s.Region)
			,Address = ISNULL(ps.Address,s.Address)	
		FROM dbo.ProcessStore ps 
			INNER JOIN dbo.Stores s on s.StoreID = ps.StoreID AND s.IsActive = 1
			INNER JOIN dbo.Request r on r.RequestId = ps.RequestId
		WHERE ps.RequestId = @RequestId
			AND r.Action = 'Update'
			and r.RequestStatus = 'Creating'
			
	END
	ELSE IF(@Action = 'Delete')
	BEGIN
		UPDATE s SET
			IsActive=0
		FROM dbo.ProcessStore ps 
			INNER JOIN dbo.Stores s on s.StoreID = ps.StoreID AND s.IsActive = 1
			INNER JOIN dbo.Request r on r.RequestId = ps.RequestId
		WHERE ps.RequestId = @RequestId
			AND r.Action = 'Delete'
			and r.RequestStatus = 'Creating'
			
	END

	SET @RowNumber=@@ROWCOUNT

	IF @RowNumber=0
	BEGIN
		RAISERROR('There is no record for %s',16,1,@Action)
		EXEC dbo.UpdateRequest @RequestId=@RequestId, @RequestStatus='Failed'
	END

	EXEC dbo.UpdateRequest @RequestId, @Status
	PRINT('Row submitted, action:'+@Action)

END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;
		
		EXEC dbo.UpdateRequest @RequestId=@RequestId, @RequestStatus='Failed'
		
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
GO
-------------------ApproveStores
-------------------ApproveProducts
GO
IF OBJECT_ID('dbo.ApproveProducts') IS NOT NULL
    DROP PROCEDURE dbo.ApproveProducts
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.ApproveProducts
					@RequestId INT,
					@Status varchar(15) --'Success' OR 'Failed'

AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	
	IF (@Status<>'Success')
	BEGIN
		EXEC dbo.UpdateRequest @RequestId=@RequestId, @RequestStatus='Failed'
		return;
	END

	DECLARE
	@Action VARCHAR(10),
	@RowNumber INT = 0,
	@ProductTypeId INT

	SELECT @Action = Action FROM Request
	WHERE RequestId = @RequestId

	IF (@Action = 'Insert')
	BEGIN

		INSERT dbo.ProductType
		(
			ProductTypeName
		)
		SELECT 
			ProductTypeName = pp.ProductTypeName
		FROM dbo.ProcessProducts pp 
			inner join dbo.Request r on r.RequestId = pp.RequestId
			left join dbo.ProductType pt on pt.ProductTypeName = pp.ProductTypeName and pt.IsActive = 1
		WHERE pp.RequestId = @RequestId
			AND r.Action = 'Insert'
			and r.RequestStatus = 'Creating'
			and pt.ProductTypeName IS NULL
			and pp.ProductTypeName IS NOT NULL
		
		SET @RowNumber+=@@ROWCOUNT

		SELECT 
			@ProductTypeId = pt.ProductTypeID
		FROM dbo.ProcessProducts pp 
			INNER join dbo.ProductType pt on pp.ProductTypeName = pt.ProductTypeName and pt.IsActive = 1

		INSERT dbo.Products
		(
			ProductName
			,ProductTypeId
		)
		SELECT 
			ProductName = pp.ProductName
			,ProductTypeId = isnull(pp.ProductTypeId,@ProductTypeId)	
		FROM dbo.ProcessProducts pp 
			inner join dbo.Request r on r.RequestId = pp.RequestId
		WHERE pp.RequestId = @RequestId
			AND r.Action = 'Insert'
			and r.RequestStatus = 'Creating'
			and pp.ProductName IS NOT NULL
		
		SET @RowNumber+=@@ROWCOUNT
	END
	ELSE IF(@Action = 'Update')
	BEGIN

		UPDATE pt SET
			ProductTypeName = ISNULL(pp.ProductTypeName,pt.ProductTypeName)
		FROM dbo.ProcessProducts pp 
			INNER JOIN dbo.ProductType pt on pt.ProductTypeID = pp.ProductTypeID AND pt.IsActive = 1
			INNER JOIN dbo.Request r on r.RequestId = pp.RequestId
		WHERE pp.RequestId = @RequestId
			AND r.Action = 'Update'
			and r.RequestStatus = 'Creating'
		
		SET @RowNumber+=@@ROWCOUNT
		
		UPDATE p SET
			ProductName = ISNULL(pp.ProductName,p.ProductName)
		FROM dbo.ProcessProducts pp 
			INNER JOIN dbo.Products p on pp.ProductID = p.ProductID AND p.IsActive = 1
			INNER JOIN dbo.Request r on r.RequestId = pp.RequestId
		WHERE pp.RequestId = @RequestId
			AND r.Action = 'Update'
			and r.RequestStatus = 'Creating'
		
		SET @RowNumber+=@@ROWCOUNT
		
	END
	ELSE IF(@Action = 'Delete')
	BEGIN
		UPDATE p SET
			IsActive=0
		FROM dbo.ProcessProducts pp 
			INNER JOIN dbo.Products p on pp.ProductID = p.ProductID AND IsActive = 1
			INNER JOIN dbo.Request r on r.RequestId = pp.RequestId
		WHERE pp.RequestId = @RequestId
			AND r.Action = 'Delete'
			and r.RequestStatus = 'Creating'
		
		SET @RowNumber+=@@ROWCOUNT
		
		UPDATE pt SET
			IsActive=0
		FROM dbo.ProcessProducts pp 
			INNER JOIN dbo.ProductType pt on pp.ProductTypeID = pt.ProductTypeID AND IsActive = 1
			INNER JOIN dbo.Request r on r.RequestId = pp.RequestId
		WHERE pp.RequestId = @RequestId
			AND r.Action = 'Delete'
			and r.RequestStatus = 'Creating'
		
		SET @RowNumber+=@@ROWCOUNT
	END

	IF @RowNumber=0
	BEGIN
		RAISERROR('There is no record for %s',16,1,@Action)
		EXEC dbo.UpdateRequest @RequestId=@RequestId, @RequestStatus='Failed'
	END

	EXEC dbo.UpdateRequest @RequestId, @Status
	PRINT('Row submitted, action:'+@Action)

END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;
		
		EXEC dbo.UpdateRequest @RequestId=@RequestId, @RequestStatus='Failed'
		
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
GO
-------------------ApproveProducts
-------------------ApprovePrices

GO
IF OBJECT_ID('dbo.ApprovePrices') IS NOT NULL
    DROP PROCEDURE dbo.ApprovePrices
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.ApprovePrices
					@RequestId INT,
					@Status varchar(15) --'Success' OR 'Failed'

AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	
	IF (@Status<>'Success')
	BEGIN
		EXEC dbo.UpdateRequest @RequestId=@RequestId, @RequestStatus='Failed'
		return;
	END

	DECLARE
	@Action VARCHAR(10),
	@RowNumber INT = 0

	SELECT @Action = Action FROM Request
	WHERE RequestId = @RequestId

	IF (@Action = 'Insert')
	BEGIN
		INSERT dbo.Prices
		(
			ProductID
			,StoreID
			,Price
			,PriceComment
		)
		SELECT 
			ProductId = pp.ProductId
			,StoreId = pp.StoreID
			,Price = pp.Price
			,PriceComment = pp.PriceComment
		FROM dbo.ProcessPrices pp 
			inner join dbo.Request r on r.RequestId = pp.RequestId
		WHERE pp.RequestId = @RequestId
			AND r.Action = 'Insert'
			AND r.RequestStatus = 'Creating'
	END
	ELSE IF(@Action = 'Update')
	BEGIN
		UPDATE p SET
			Price = ISNULL(pp.Price,p.Price)
			,PriceComment = ISNULL(pp.PriceComment,p.PriceComment)
		FROM dbo.ProcessPrices pp 
			INNER JOIN dbo.Prices p on p.ProductID = pp.ProductID AND p.StoreID = pp.StoreID AND p.IsActive = 1
			INNER JOIN dbo.Request r on r.RequestId = pp.RequestId
		WHERE pp.RequestId = @RequestId
			AND r.Action = 'Update'
			and r.RequestStatus = 'Creating'
	END
	ELSE IF(@Action = 'Delete')
	BEGIN
		UPDATE p SET
			IsActive=0
		FROM dbo.ProcessPrices pp 
			INNER JOIN dbo.Prices p on p.ProductID = pp.ProductID AND p.StoreID = pp.StoreID AND p.IsActive = 1
			INNER JOIN dbo.Request r on r.RequestId = pp.RequestId
		WHERE pp.RequestId = @RequestId
			AND r.Action = 'Delete'
			and r.RequestStatus = 'Creating'
	END

	SET @RowNumber=@@ROWCOUNT

	IF @RowNumber=0
	BEGIN
		RAISERROR('There is no record for %s',16,1,@Action)
		EXEC dbo.UpdateRequest @RequestId=@RequestId, @RequestStatus='Failed'
	END

	EXEC dbo.UpdateRequest @RequestId, @Status
	PRINT('Row submitted, action:'+@Action)

END TRY
BEGIN CATCH
	DECLARE
		@ErrorSeverity INT = ERROR_SEVERITY(),
		@ErrorState INT = ERROR_STATE(),
		@ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE(),
		@ErrorLine INT = ERROR_LINE(),
		@ErrorMessage NVARCHAR(2048) = OBJECT_NAME(@@procid) + ': ' +ERROR_MESSAGE();

	IF(XACT_STATE() = -1)
		ROLLBACK;
		
		EXEC dbo.UpdateRequest @RequestId=@RequestId, @RequestStatus='Failed'
		
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorProcedure,@ErrorLine)
		
	
END CATCH
END
GO
-------------------ApprovePrices
-------------------InsertData
SET IDENTITY_INSERT [dbo].[ProductType] ON 

INSERT [dbo].[ProductType] ([ProductTypeID], [ProductTypeName]) VALUES (1, N'Meat')
INSERT [dbo].[ProductType] ([ProductTypeID], [ProductTypeName]) VALUES (2, N'Seafood')
INSERT [dbo].[ProductType] ([ProductTypeID], [ProductTypeName]) VALUES (3, N'Electronics')
SET IDENTITY_INSERT [dbo].[ProductType] OFF
SET IDENTITY_INSERT [dbo].[Products] ON 

INSERT [dbo].[Products] ([ProductID], [ProductTypeID], [ProductName] ) VALUES (1, 1, N'Product 1' )
INSERT [dbo].[Products] ([ProductID], [ProductTypeID], [ProductName] ) VALUES (2, 1, N'Product 2' )
INSERT [dbo].[Products] ([ProductID], [ProductTypeID], [ProductName] ) VALUES (3, 2, N'StarFish' )
INSERT [dbo].[Products] ([ProductID], [ProductTypeID], [ProductName] ) VALUES (4, 2, N'SeaHorse' )
INSERT [dbo].[Products] ([ProductID], [ProductTypeID], [ProductName] ) VALUES (5, 3, N'IPhone 7' )
INSERT [dbo].[Products] ([ProductID], [ProductTypeID], [ProductName] ) VALUES (6, 3, N'Mac book' )
SET IDENTITY_INSERT [dbo].[Products] OFF
SET IDENTITY_INSERT [dbo].[Stores] ON 

INSERT [dbo].[Stores] ([StoreID], [StoreName], [Country], [City], [Region], [Address] ) VALUES (1, N'Ashan', N'Ukraine', N'Kiev', N'kie', N'33 street')
INSERT [dbo].[Stores] ([StoreID], [StoreName], [Country], [City], [Region], [Address] ) VALUES (2, N'Novus', N'Ukraine', N'Kiev', N'kie', N'13 street')
SET IDENTITY_INSERT [dbo].[Stores] OFF
INSERT [dbo].[Prices] ([ProductID], [StoreID], [Price], [PriceComment]) VALUES (1, 1, 33.4600, NULL)
INSERT [dbo].[Prices] ([ProductID], [StoreID], [Price], [PriceComment]) VALUES (1, 2, 33.4600, NULL)
INSERT [dbo].[Prices] ([ProductID], [StoreID], [Price], [PriceComment]) VALUES (2, 1, 33.4600, NULL)
INSERT [dbo].[Prices] ([ProductID], [StoreID], [Price], [PriceComment]) VALUES (5, 2, 99.9900, NULL)

SET IDENTITY_INSERT [dbo].[RequestType] ON 

INSERT [dbo].[RequestType] ([RequestTypeId],[RequestTypeName]) VALUES (1, 'Manage Product')
INSERT [dbo].[RequestType] ([RequestTypeId],[RequestTypeName]) VALUES (2, 'Manage Store')
INSERT [dbo].[RequestType] ([RequestTypeId],[RequestTypeName]) VALUES (3, 'Manage Price')
SET IDENTITY_INSERT [dbo].[RequestType] OFF	