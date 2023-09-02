Create or replace database IMT577_DW_SGUHA_STAGE
Create or replace WAREHOUSE "DW_SGUHA_STAGE" with WAREHOUSE_SIZE='XSMALL' AUTO_SUSPEND=600 AUTO_RESUME=TRUE comment='';

create or replace STAGE "DW_SGUHA_STAGE"."PUBLIC"."STAGE_PROJECT"

-- file formatting to skip headers etc
Create or replace FILE FORMAT CSV_SKIP_HEADER
type = 'CSV'
field_delimiter = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
skip_header = 1;

-- stage tables
create or replace table STAGE_CHANNEL(
  CHANNELID NUMBER(38,0),
  CHANNELCATEGORYID NUMBER(38,0),
  CHANNEL VARCHAR(255),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255)
);

create or replace table STAGE_CHANNEL_CATEGORY(
  CHANNELCATEGORYID NUMBER(38,0),
  CHANNELCATEGORY VARCHAR(255),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255)
);



CREATE OR REPLACE TABLE STAGE_CUSTOMER(
  CUSTOMERID VARCHAR(255),
  SUBSEGMENTID NUMBER(38,0),
  FIRSTNAME VARCHAR(255),
  LASTNAME VARCHAR(255),
  GENDER VARCHAR(255),
  EMAILADDRESS VARCHAR(255),
  ADDRESS VARCHAR(255),
  CITY VARCHAR(255),
  STATE VARCHAR(255),
  COUNTRY VARCHAR(255),
  POSTALCODE NUMBER(38,0),
  PHONENUMBER VARCHAR(255),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_PRODUCT(
  PRODUCTID NUMBER(38,0),
  PRODUCTTYPEID NUMBER(38,0),
  PRODUCT VARCHAR(255),
  COLOR VARCHAR(255),
  STYLE VARCHAR(255),
  UNITOFMEASUREID NUMBER(38,0),
  WEIGHT NUMBER(38,2),
  PRICE NUMBER(38,2),
  COST NUMBER(38,2),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255),
  WHOLESALEPRICE NUMBER(38,2)  
);

CREATE OR REPLACE TABLE STAGE_PRODUCT_CATEGORY(
  PRODUCTCATEGORYID NUMBER(38,0),
  PRODUCTCATEGORY VARCHAR(255),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_PRODUCT_TYPE(
  PRODUCTTYPEID NUMBER(38,0),
  PRODUCTCATEGORYID NUMBER(38,0),
  PRODUCTTYPE VARCHAR(255),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_RESELLER(
  RESELLERID VARCHAR(255),
  CONTACT VARCHAR(255),
  EMAILADDRESS VARCHAR(255),
  ADDRESS VARCHAR(255),
  CITY VARCHAR(255),
  STATE VARCHAR(255),
  COUNTRY VARCHAR(255),
  POSTALCODE NUMBER(38,0),
  PHONENUMBER VARCHAR(255),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255),
  RESELLERNAME VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_SALES_DETAIL(
  SALESDETAILID NUMBER(38,0),
  SALESHEADERID NUMBER(38,0),
  PRODUCTID NUMBER(38,0),
  SALESQUANTITY NUMBER(38,0),
  SALESAMOUNT NUMBER(38,2),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_SALES_HEADER(
  SALESHEADERID NUMBER(38,0),
  DATE DATE,
  CHANNELID NUMBER(38,0),
  STOREID NUMBER(38,0),
  CUSTOMERID VARCHAR(255),
  RESELLERID VARCHAR(255),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_SEGMENT(
  SEGMENTID NUMBER(38,0),
  SEGMENT VARCHAR(255),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_STORE(
  STOREID NUMBER(38,0),
  SUBSEGEMENTID NUMBER(38,0),
  STORENUMBER NUMBER(38,0),
  STOREMANAGER VARCHAR(255),
  ADDRESS VARCHAR(255),
  CITY VARCHAR(255),
  STATE VARCHAR(255),
  COUNTRY VARCHAR(255),
  POSTALCODE NUMBER(38,0),
  PHONENUMBER VARCHAR(255),
  CREATEDDATE DATETIME,
  CREATEDBY VARCHAR(255),
  MODIFIEDDATE DATETIME,
  MODIFIEDBY VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_TARGET_CHANNEL_RESELLER_STORE(
  YEAR NUMBER(38,0),
  CHANNELNAME VARCHAR(255),
  TARGETNAME VARCHAR(255),
  TARGELSALESAMOUNT NUMBER(38,0)
);

CREATE OR REPLACE TABLE STAGE_TARGET_PRODUCT(
  PRODUCTID NUMBER(38,0),
  PRODUCT VARCHAR(255),
  YEAR NUMBER(38,0),
  SALESQTYTARGET NUMBER(38,0)
);


SELECT * from STAGE_TARGET_CHANNEL_RESELLER_STORE 
Where TARGETNAME in ('Store Number 5', 'Store Number 8');

Select sd.PRODUCTID, sd.SALESQUANTITY, sd.SALESAMOUNT, sh.DATE, sh.STOREID  
from STAGE_SALES_DETAIL as sd, STAGE_SALES_HEADER as sh 
where sd.SALESHEADERID = sh.SALESHEADERID
and STOREID in (5,8)
limit 10; 

Select count(p.PRODUCT) as NUM , pt.PRODUCTTYPE, pc.PRODUCTCATEGORY 
from  STAGE_PRODUCT as p, STAGE_PRODUCT_TYPE as pt, STAGE_PRODUCT_CATEGORY as pc 
where p.PRODUCTTYPEID = pt.PRODUCTTYPEID and pc.PRODUCTCATEGORYID = pt.PRODUCTCATEGORYID
group by pc.PRODUCTCATEGORY, pt.PRODUCTTYPE;


Select c.CHANNELID, c.CHANNELCATEGORYID, c.CHANNEL, cc.CHANNELCATEGORY  from STAGE_CHANNEL as c
inner join STAGE_CHANNEL_CATEGORY as cc
on c.CHANNELCATEGORYID = cc.CHANNELCATEGORYID;
