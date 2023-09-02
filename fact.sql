-- Fact_SRCSalesTarget
create or replace table Fact_SRCSalesTarget(
  DimStoreID INTEGER CONSTRAINT FK_DimStoreID foreign key references Dim_Store(DimStoreID),
  DimReselerID INTEGER CONSTRAINT FK_DimReselerID foreign key references Dim_Reseller(DimResellerID),
  DimChannelID INTEGER CONSTRAINT FK_DimChannelID foreign key references Dim_Channel(DimChannelID),
  DimTargetDateID number(9) CONSTRAINT FK_DimTargetDateID foreign key references DIM_DATE(DATE_PKEY),
  SalesTargetAmount INT not null
);

insert into Fact_SRCSalesTarget (
DimStoreID, DimReselerID, DimChannelID, DimTargetDateID, SalesTargetAmount) 
with temp as (
 select NVL(s.DimStoreID, -1) AS DimStoreID ,NVL(r.DimResellerID, -1) AS DimResellerID
 ,c.DimChannelID, srct.YEAR, srct.TARGELSALESAMOUNT/365 as SalesTargetAmount
  from STAGE_TARGET_CHANNEL_RESELLER_STORE as srct left join Dim_Channel as c
  on REPLACE(c.ChannelName, '-', '') = srct.CHANNELNAME 
  LEFT OUTER JOIN Dim_Store as s  ON srct.TARGETNAME = s.StoreName
  LEFT OUTER JOIN Dim_Reseller as r ON srct.TARGETNAME = r.ResellerName
)
select temp.DimStoreID, temp.DimResellerID, temp.DimChannelID, d.DATE_PKEY, temp.SalesTargetAmount 
from DIM_DATE as d Full Outer Join temp
on d.year = temp.year

select * from Fact_SRCSalesTarget 


-- Fact_ProductSalesTaget
create or replace table Fact_ProductSalesTaget(
  DimProductID INTEGER CONSTRAINT FK_DimProductID foreign key references Dim_Product(DimProductID),
  DimTargetDateID number(9) CONSTRAINT FK_DimTargetDateID foreign key references DIM_DATE(DATE_PKEY),
  ProductTargetSalesQty INT not null
);

insert into Fact_ProductSalesTaget(DimProductID,DimTargetDateID,ProductTargetSalesQty)
with temp as (
    select p.DimProductID, stp.year, stp.salesqtytarget/365  as ProductTargetSalesQty from STAGE_TARGET_PRODUCT as stp left join Dim_Product p
    on p.ProductID =stp.ProductID
)
select temp.DimProductID, d.DATE_PKEY, temp.ProductTargetSalesQty 
from DIM_DATE as d Full Outer Join temp
on d.year = temp.year

select * from Fact_ProductSalesTaget



-- main fact table
create or replace table Fact_SalesActual(
  DimProductID INTEGER CONSTRAINT FK_DimProductID foreign key references Dim_Product(DimProductID),
  DimStoreID INTEGER CONSTRAINT FK_DimStoreID foreign key references Dim_Store(DimStoreID),
  DimResellerID INTEGER CONSTRAINT FK_DimReselerID foreign key references Dim_Reseller(DimResellerID),
  DimCustomerID INTEGER CONSTRAINT FK_DimCusomerID foreign key references Dim_Customer(DimCustomerID), 
  DimChannelID INTEGER CONSTRAINT FK_DimChannelID foreign key references Dim_Channel(DimChannelID),
  DimTargetDateID number(9) CONSTRAINT FK_DimTargetDateID foreign key references DIM_DATE(DATE_PKEY),
  DimLocationID INTEGER CONSTRAINT FK_DimLocationID foreign key references Dim_Location(DimLocationID),
  SalesHeaderID INT not null,
  SalesDetailID INT not null,
  SaleAmount float not null , 
  SaleQty INT not null,
  SaleUnitPrice float not null,
  SaleExtendedCost float not null,
  SaleTotalProfit float not null
);

insert into Fact_SalesActual(
  DimProductID,DimStoreID,DimResellerID,DimCustomerID,DimChannelID,DimTargetDateID,
  DimLocationID,SalesHeaderID,SalesDetailID, SaleAmount, SaleQty,
  SaleUnitPrice, SaleExtendedCost, SaleTotalProfit
  
)
with temp as (
  select NVL(pro.DimProductID, -1) as DimProductID , NVL(cust.DimCustomerID, -1) as DimCustomerID,
  c.DimChannelID, NVL(s.DimStoreID, -1) AS DimStoreID ,NVL(r.DimResellerID, -1) AS DimResellerID,
  NVL( r.DimLocationID , s.DimLocationID) as DimLocationID_temp,
  NVL(ssd.SALESAMOUNT,-1) as SaleAmount, NVL(ssd.SALESQUANTITY, -1) as SaleQty, 
  ssh.DATE, SaleAmount/SaleQty as SaleUnitPrice, SaleAmount as SaleExtendedCost, 
  CASE when (ssd.SalesAmount / ssd.SalesQuantity) = pro.ProductRetailPrice 
    then (pro.ProductRetailProfit * ssd.SalesQuantity) 
    else (pro.ProductWholesaleUnitProfit * ssd.SalesQuantity) 
    end as SaleTotalProfit,
  CASE
          WHEN year(ssh.date)=13 THEN 2013
          WHEN year(ssh.date)=14 THEN 2014
      END AS year,
  ssh.SalesHeaderID, ssd.SalesDetailID
  from STAGE_SALES_HEADER as ssh left join STAGE_SALES_DETAIL as ssd
  on ssd.SALESHEADERID = ssh.SALESHEADERID
  left join Dim_Product as pro on ssd.PRODUCTID = pro.ProductID
  left join Dim_Customer as cust on cust.CustomerID = ssh.CUSTOMERID
  left join Dim_Channel as c on c.SourceChannelID = ssh.CHANNELID
  left join Dim_Reseller as r on r.ResellerID = ssh.RESELLERID
  left join Dim_Store as s on s.StoreSourceID = ssh.STOREID
) 
select temp.DimProductID, temp.DimStoreID, temp.DimResellerID, temp.DimCustomerID, temp.DimChannelID,
d.DATE_PKEY, NVL(temp.DimLocationID_temp, -1) as DimLocationID, temp.SalesHeaderID, temp.SalesDetailID,
temp.SaleAmount, temp.SaleQty,  temp.SaleUnitPrice, temp.SaleExtendedCost, temp.SaleTotalProfit
from temp left Join DIM_DATE as d
on d.year = temp.year and month(d.date)=month(temp.date) and day(d.date)= day(temp.date)


