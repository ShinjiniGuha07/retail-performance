-- pass through views
-- channel
CREATE SECURE VIEW dim_channel_v as
select DIMCHANNELID,SOURCECHANNELID,SOURCECHANNELCATEGORYID,CHANNELNAME,CHANNELCATEGORY
from Dim_Channel;


-- location
CREATE SECURE VIEW dim_location_v as
select DimLocationID, Address, City, PostalCode, StateProvince, Country
from Dim_Location;

-- store
CREATE SECURE VIEW dim_store_v as
select DimStoreID, DimLocationID, StoreSourceID, StoreName, StoreNumber, StoreManager
from Dim_Store


-- customer
CREATE SECURE VIEW dim_customer_v as
select DimCustomerID, DimLocationID, CustomerID, CustomerFullName, CustomerFirstName, CustomerLastName, CustomerGender
from Dim_Customer 
  
-- reseller
CREATE SECURE VIEW dim_reseller_v as
select DimResellerID, DimLocationID, ResellerID, ResellerName, ContactName, PhoneNumber, Email
from Dim_Reseller
  
-- product
CREATE SECURE VIEW dim_product_v as
select DimProductID, ProductID, ProductTypeID, ProductCategoryID, ProductName, ProductType, ProductCategory, ProductRetailPrice, ProductWholesalePrice, ProductCost,
  ProductRetailProfit, ProductWholesaleUnitProfit, ProductProfitMarginUnitPercent
from Dim_Product

select * from Dim_Product 

-- date
CREATE SECURE VIEW dim_date_v as
select DATE_PKEY,DATE,FULL_DATE_DESC,DAY_NUM_IN_WEEK,DAY_NUM_IN_MONTH,DAY_NUM_IN_YEAR,DAY_NAME,DAY_ABBREV,
		WEEKDAY_IND,US_HOLIDAY_IND, _HOLIDAY_IND,MONTH_END_IND,
		WEEK_BEGIN_DATE_NKEY,WEEK_BEGIN_DATE,WEEK_END_DATE_NKEY,WEEK_END_DATE,WEEK_NUM_IN_YEAR,
		MONTH_NAME,MONTH_ABBREV,MONTH_NUM_IN_YEAR,YEARMONTH,QUARTER,YEARQUARTER,YEAR,
		FISCAL_WEEK_NUM,FISCAL_MONTH_NUM,FISCAL_YEARMONTH,FISCAL_QUARTER,FISCAL_YEARQUARTER,FISCAL_HALFYEAR,FISCAL_YEAR,
        SQL_TIMESTAMP,CURRENT_ROW_IND,EFFECTIVE_DATE,EXPIRATION_DATE
from Dim_Date

-- Fact_SRCSalesTarget
CREATE SECURE VIEW fact_SRCSalesTarget_v as
select DIMSTOREID, DIMRESELERID, DIMCHANNELID, DIMTARGETDATEID, SALESTARGETAMOUNT
from Fact_SRCSalesTarget

-- Fact_ProductSalesTaget
CREATE SECURE VIEW fact_ProductSalesTaget_v as
select DimProductID,DimTargetDateID,ProductTargetSalesQty
from Fact_ProductSalesTaget

-- Fact_SalesActual
CREATE or replace SECURE VIEW fact_SalesActual_v as
select DimProductID, DimStoreID,DimResellerID,DimCustomerID, DimChannelID,DimTargetDateID,DimLocationID,
SalesHeaderID,SalesDetailID,SaleAmount,SaleQty,SaleUnitPrice,SaleExtendedCost,SaleTotalProfit
from Fact_SalesActual


select * from fact_SalesActual_v

select * from fact_SRCSalesTarget_v

-- modified views
-- notes:
-- month of nov-dec missing for 2014

-- view1: daily sales target
CREATE SECURE VIEW daily_sales_target_v as
with sales_amt as (
  SELECT dc.DimChannelID, dc.CHANNELNAME, 
      ds.DimStoreID, ds.StoreName, ds.StoreNumber, 
      sum(fsa.SaleAmount) as DailySaleAmount, fsa.DimTargetDateID as dateId
  FROM Fact_SalesActual AS fsa
  LEFT JOIN Dim_Channel AS dc ON dc.DimChannelID = fsa.DimChannelID
  LEFT JOIN Dim_Store AS ds ON ds.DimStoreID = fsa.DimStoreID
  WHERE ds.StoreNumber IN (5, 8)
  GROUP BY fsa.DimTargetDateID, dc.DimChannelID, dc.CHANNELNAME, 
      ds.DimStoreID, ds.StoreName, ds.StoreNumber
)
select sa.DimChannelID, sa.CHANNELNAME, 
      sa.DimStoreID, sa.StoreName, sa.StoreNumber, 
      dd.year as year, MONTH(dd.date) as month, day(dd.date) as day,
      sa.DailySaleAmount, fst.SALESTARGETAMOUNT,
       CASE
          WHEN fst.SALESTARGETAMOUNT - sa.DailySaleAmount < 0 THEN 1
          else 0
      END AS TargetMet   
from Fact_SRCSalesTarget as fst
LEFT JOIN Dim_Date AS dd ON dd.DATE_PKEY = fst.DimTargetDateID
left join sales_amt as sa on sa.dateId = fst.DIMTARGETDATEID
where fst.DIMSTOREID=sa.DimStoreID
ORDER BY dd.year, MONTH(dd.date), day(dd.date)

select * from daily_sales_target_v


-- view2: yearly sales per store
CREATE or replace SECURE VIEW yearly_contribution_per_store_v as
  SELECT ds.DimStoreID, ds.StoreName, ds.StoreNumber, dd.year AS year,
  dl.city, dl.STATEPROVINCE,dp.PRODUCTTYPE,
  SUM(fsa.SaleAmount) AS YearlySaleAmount, 
  (SUM(fsa.SaleAmount) / SUM(SUM(fsa.SaleAmount)) OVER (PARTITION BY dd.year)) * 100 AS SaleAmountPercentage,
  SUM(fsa.SaleQty) AS YearlySaleQty,
  (SUM(fsa.SaleQty) / SUM(SUM(fsa.SaleQty)) OVER (PARTITION BY dd.year)) * 100 AS SaleQtytPercentage
  FROM Fact_SalesActual AS fsa
  LEFT JOIN Dim_Date AS dd ON dd.DATE_PKEY = fsa.DimTargetDateID
  LEFT JOIN Dim_Product AS dp ON dp.DimProductID = fsa.DimProductID
  LEFT JOIN Dim_Store AS ds ON ds.DimStoreID = fsa.DimStoreID
  Left join Dim_Location as dl on ds.DIMLOCATIONID = dl.DIMLOCATIONID
  WHERE ds.StoreNumber > -1 AND dp.PRODUCTTYPE IN ('Men\'s Casual', 'Women\'s Casual')
  GROUP BY dd.year, ds.DimStoreID, ds.StoreName, ds.StoreNumber,ds.DIMLOCATIONID, dl.city, dl.STATEPROVINCE,dp.PRODUCTTYPE
  ORDER BY dd.year, ds.StoreNumber;

  
select * from yearly_contribution_per_store_v
  
-- view3: day of the week trends 
CREATE or replace SECURE VIEW day_week_trends_per_store_v as
  SELECT ds.StoreName, ds.StoreNumber, 
      dp.PRODUCTTYPE, dp.PRODUCTCATEGORY, dd.DAY_NAME as day,dd.YEARQUARTER, dd.year, dd.quarter,
      sum(fsa.SaleAmount) as TotalSaleAmount, avg(fsa.SaleAmount) as AvgSaleAmount,
      SUM(fsa.SaleQty) AS TotalSaleQty, avg(fsa.SaleQty) as AvgSaleQty   
  FROM Fact_SalesActual AS fsa
  LEFT JOIN Dim_Store AS ds ON ds.DimStoreID = fsa.DimStoreID
  LEFT JOIN Dim_Product AS dp ON dp.DimProductID = fsa.DimProductID
  LEFT JOIN Dim_Date AS dd ON dd.DATE_PKEY = fsa.DimTargetDateID
  WHERE ds.StoreNumber IN (5, 8)
  GROUP BY ds.StoreName, ds.StoreNumber, 
      dp.PRODUCTTYPE, dp.PRODUCTCATEGORY, dd.DAY_NAME, day,dd.YEARQUARTER, dd.year, dd.quarter
  ORDER BY CASE dd.DAY_NAME
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
END, ds.StoreNumber, PRODUCTCATEGORY

select * from dim_date



  
CREATE or replace SECURE VIEW qty_target_w_m_casual_v as  
with temp1 as (
  select dp.PRODUCTTYPE, sum(pst.PRODUCTTARGETSALESQTY) as Target_qty, dd.year AS year from Fact_ProductSalesTaget as pst
  left join dim_product as dp on dp.DIMPRODUCTID = pst.DIMPRODUCTID
  LEFT JOIN Dim_Date AS dd ON dd.DATE_PKEY = pst.DimTargetDateID
  WHERE dp.PRODUCTTYPE IN ('Men\'s Casual', 'Women\'s Casual')
  group by dd.year, dp.PRODUCTTYPE
)  
    select dp.PRODUCTTYPE, dd.year, sum(SALEQTY)as Actual_qty, temp1.Target_qty
  from fact_salesactual as fsa
  left join dim_product as dp on dp.dimproductid = fsa.dimproductid
  LEFT JOIN Dim_Date AS dd ON dd.DATE_PKEY = fsa.DimTargetDateID
  left join temp1 on temp1.year=dd.year and temp1.PRODUCTTYPE = dp.PRODUCTTYPE
  WHERE dp.PRODUCTTYPE IN ('Men\'s Casual', 'Women\'s Casual')
  group by dd.year, dp.PRODUCTTYPE, temp1.Target_qty 
  union 
  select 'Total' as PRODUCTTYPE, 2013 as year, (5352788+4299165) as ACTUAL_QTY,  (4724925+4328900) as TARGET_QTY
  union
  select 'Total' as PRODUCTTYPE, 2014 as year, (3813285+4747072) as ACTUAL_QTY,  (4466870+4799750) as TARGET_QTY

  select * from qty_target_w_m_casual_v
