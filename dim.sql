-- channel
CREATE OR REPLACE TABLE Dim_Channel(
  DimChannelID INT IDENTITY(1,1) CONSTRAINT PK_DimChannelID PRIMARY KEY NOT NULL,
  SourceChannelID INT NOT NULL,
  SourceChannelCategoryID INT NOT NULL,
  ChannelName varchar(255) NOT NULL,
  ChannelCategory varchar(255) NOT NULL
);

insert into Dim_Channel (
  DimChannelID, SourceChannelID, SourceChannelCategoryID, ChannelName, ChannelCategory
)
values (
  -1, -1, -1, 'Unknown','Unknown'
)

select * from Dim_Channel


INSERT INTO Dim_Channel (
  SourceChannelID, SourceChannelCategoryID, ChannelName, ChannelCategory
)
    Select c.CHANNELID, c.CHANNELCATEGORYID, c.CHANNEL, cc.CHANNELCATEGORY  from STAGE_CHANNEL as c
inner join STAGE_CHANNEL_CATEGORY as cc
on c.CHANNELCATEGORYID = cc.CHANNELCATEGORYID;


-- dim location
CREATE OR REPLACE TABLE Dim_Location(
  DimLocationID INT IDENTITY(1,1) CONSTRAINT PK_DimLocationID PRIMARY KEY NOT NULL,
  Address varchar(255) NOT NULL,
  City varchar(255) NOT NULL,
  PostalCode INT NOT NULL,
  StateProvince varchar(255) NOT NULL,
  Country varchar(255) NOT NULL
);

insert into Dim_Location (
  DimLocationID, Address, City, PostalCode, StateProvince, Country
)
values (
  -1, 'Unknown', 'Unknown', -1,'Unknown', 'Unknown'
)

INSERT INTO Dim_Location (
  Address, City, PostalCode, StateProvince, Country
)
   Select ADDRESS, CITY, POSTALCODE, STATE, COUNTRY  from STAGE_STORE UNION
Select ADDRESS, CITY, POSTALCODE, STATE, COUNTRY  from STAGE_CUSTOMER UNION
Select ADDRESS, CITY, POSTALCODE, STATE, COUNTRY  from STAGE_RESELLER;

select * from Dim_Location

-- STORE 
CREATE OR REPLACE TABLE Dim_Store (
  DimStoreID INT IDENTITY(1,1) CONSTRAINT PK_DimStoreID PRIMARY KEY NOT NULL,
  DimLocationID INTEGER CONSTRAINT FK_DimLocationIDCustomer FOREIGN KEY REFERENCES Dim_Location (DimLocationID) NOT NULL,
  StoreSourceID INT NOT NULL,
  StoreName VARCHAR(255) NOT NULL,
  StoreNumber INT NOT NULL,
  StoreManager VARCHAR(255) NOT NULL
);

insert into Dim_Store (
  DimStoreID, DimLocationID, StoreSourceID, StoreName, StoreNumber, StoreManager
)
values (
  -1, -1, -1, 'Unknown', -1,'Unknown'
)


insert into Dim_Store (
  DimLocationID, StoreSourceID, StoreName, StoreNumber, StoreManager
)
   Select  DL.DimLocationID, 
    SS.STOREID, CONCAT('Store Number ', SS.STORENUMBER) as STORENAME,  SS.STORENUMBER, SS.STOREMANAGER 
    FROM Dim_Location AS DL,  STAGE_STORE AS SS 
    WHERE DL.ADDRESS=SS.ADDRESS;

Select * from Dim_Store

-- CUSTOMER
CREATE OR REPLACE TABLE Dim_Customer (
  DimCustomerID INT IDENTITY(1,1) CONSTRAINT PK_DimCustomerID PRIMARY KEY NOT NULL,
  DimLocationID INTEGER CONSTRAINT FK_DimLocationIDCustomer FOREIGN KEY REFERENCES Dim_Location (DimLocationID) NOT NULL,
  CustomerID VARCHAR(255) NOT NULL,
  CustomerFullName VARCHAR(255) NOT NULL,
  CustomerFirstName VARCHAR(255) NOT NULL,
  CustomerLastName VARCHAR(255) NOT NULL,
  CustomerGender VARCHAR(255) NOT NULL
);


insert into Dim_Customer (
  DimCustomerID, DimLocationID, CustomerID, CustomerFullName, CustomerFirstName, CustomerLastName, CustomerGender
)
values (
  -1, -1, 'Unknown', 'Unknown', 'Unknown','Unknown', 'Unknown'
)


insert into Dim_Customer (
  DimLocationID, CustomerID, CustomerFullName, CustomerFirstName, CustomerLastName, CustomerGender
)
   Select  DL.DimLocationID, SC.CUSTOMERID, CONCAT(SC.FIRSTNAME, ' ',SC.LASTNAME) AS FULLNAME, SC.FIRSTNAME, SC.LASTNAME, SC.GENDER
  FROM Dim_Location AS DL, STAGE_CUSTOMER AS SC WHERE DL.ADDRESS=SC.ADDRESS;

Select * from Dim_Customer


-- RESELLER
  
  CREATE OR REPLACE TABLE Dim_Reseller (
  DimResellerID INT IDENTITY(1,1) CONSTRAINT PK_DimResellerID PRIMARY KEY NOT NULL,
  DimLocationID INTEGER CONSTRAINT FK_DimLocationIDCustomer FOREIGN KEY REFERENCES Dim_Location (DimLocationID) NOT NULL,
  ResellerID VARCHAR(255) NOT NULL,
  ResellerName VARCHAR(255) NOT NULL,
  ContactName VARCHAR(255) NOT NULL,
  PhoneNumber VARCHAR(255) NOT NULL,
  Email VARCHAR(255) NOT NULL
);


insert into Dim_Reseller (
  DimResellerID, DimLocationID, ResellerID, ResellerName, ContactName, PhoneNumber, Email
)
values (
  -1, -1, 'Unknown', 'Unknown', 'Unknown','Unknown', 'Unknown'
)


insert into Dim_Reseller (
  DimLocationID, ResellerID, ResellerName, ContactName, PhoneNumber, Email
)
  Select DL.DimLocationID, SR.RESELLERID, SR.RESELLERNAME, SR.CONTACT, SR.PHONENUMBER, SR.EMAILADDRESS
  from STAGE_RESELLER as SR, Dim_Location AS DL WHERE DL.ADDRESS=SR.ADDRESS;

Select * from Dim_Reseller


-- PRODUCT
CREATE OR REPLACE TABLE Dim_Product(
  DimProductID INT IDENTITY(1,1) CONSTRAINT PK_DimProductID PRIMARY KEY NOT NULL,
  ProductID INTEGER NOT NULL,
  ProductTypeID INTEGER NOT NULL,
  ProductCategoryID INTEGER NOT NULL,
  ProductName VARCHAR(255) NOT NULL,
  ProductType VARCHAR(255) NOT NULL,
  ProductCategory VARCHAR(255) NOT NULL,
  ProductRetailPrice FLOAT (10) NOT NULL,
  ProductWholesalePrice FLOAT (10) NOT NULL,
  ProductCost FLOAT (10) NOT NULL,
  ProductRetailProfit FLOAT (10) NOT NULL,
  ProductWholesaleUnitProfit FLOAT (10) NOT NULL,
  ProductProfitMarginUnitPercent FLOAT (10) NOT NULL
);


insert into Dim_Product (
  DimProductID, ProductID, ProductTypeID, ProductCategoryID, ProductName, ProductType, ProductCategory, ProductRetailPrice, ProductWholesalePrice, ProductCost,
  ProductRetailProfit, ProductWholesaleUnitProfit, ProductProfitMarginUnitPercent
)
values (
  -1, -1, -1, -1, 'Unknown', 'Unknown', 'Unknown', -1.0, -1.0, -1.0, -1.0, -1.0, -1.0
)

insert into Dim_Product (
  ProductID, ProductTypeID, ProductCategoryID, ProductName, ProductType, ProductCategory, 
  ProductRetailPrice, ProductWholesalePrice, ProductCost,
  ProductRetailProfit, ProductWholesaleUnitProfit, ProductProfitMarginUnitPercent
)
Select SP.PRODUCTID, SPT.PRODUCTTYPEID, SPC.PRODUCTCATEGORYID, SP.PRODUCT, SPT.PRODUCTTYPE, SPC.PRODUCTCATEGORY,
    SP.PRICE, SP.WHOLESALEPRICE, SP.COST, 
    (SP.PRICE) - (SP.COST) As ProductRetailProfit,
    (SP.COST) As ProductWholesaleUnitProfit,
    (SP.PRICE - SP.COST) / (SP.PRICE) As ProductProfitMarginUnitPercent
from STAGE_PRODUCT as SP 
Left join STAGE_PRODUCT_TYPE as SPT ON SP.PRODUCTTYPEID=SPT.PRODUCTTYPEID
left join STAGE_PRODUCT_CATEGORY as SPC ON SPC.PRODUCTCATEGORYID = SPT.PRODUCTCATEGORYID
