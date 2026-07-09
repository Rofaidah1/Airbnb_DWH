USE AirbnbProject;
GO


CREATE SCHEMA GOLD ;
GO
----------------------------------------------------
SELECT
    IDENTITY(INT,1,1) AS city_key,
    city
INTO GOLD.DimCity
FROM
(
    SELECT DISTINCT city
    FROM SILVER.DATA
) t;

ALTER TABLE GOLD.DimCity
ADD CONSTRAINT PK_DimCity
PRIMARY KEY(city_key);

SELECT *
FROM GOLD.DimCity;

--------------------
SELECT
    IDENTITY(INT,1,1) AS room_key,
    room_type
    
INTO GOLD.DimRoom
FROM
(
    SELECT DISTINCT
        room_type

    FROM SILVER.DATA
) t;
ALTER TABLE GOLD.DimRoom
ADD CONSTRAINT PK_DimRoom
PRIMARY KEY(room_key);

SELECT *
FROM GOLD.DimRoom;
------------------------
SELECT
    IDENTITY(INT,1,1) AS host_key,
    host_is_superhost,
    multi,
    biz
INTO GOLD.DimHost
FROM
(
    SELECT DISTINCT
        host_is_superhost,
        multi,
        biz
    FROM SILVER.DATA
) t;

ALTER TABLE GOLD.DimHost
ADD CONSTRAINT PK_DimHost
PRIMARY KEY(host_key);

SELECT *
FROM GOLD.DimHost;
-------------------------
SELECT
    IDENTITY(INT,1,1) AS day_key,
    day_type
INTO GOLD.DimDay
FROM
(
    SELECT DISTINCT day_type
    FROM SILVER.DATA
) t;

ALTER TABLE GOLD.DimDay
ADD CONSTRAINT PK_DimDay
PRIMARY KEY(day_key);

SELECT *
FROM GOLD.DimDay;
-------------------------------------------
SELECT

    ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS listing_key,

    c.city_key,
    r.room_key,
    h.host_key,
    d.day_key,

    s.realSum,
    s.cleanliness_rating,
    s.guest_satisfaction_overall,
    s.bedrooms,

    s.dist,
    s.metro_dist,

    s.attr_index,
    s.attr_index_norm,

    s.rest_index,
    s.rest_index_norm,

    s.lng,
    s.lat

INTO GOLD.FactListing

FROM SILVER.DATA s

INNER JOIN GOLD.DimCity c
ON s.city = c.city

INNER JOIN GOLD.DimRoom r
ON s.room_type = r.room_type


INNER JOIN GOLD.DimHost h
ON s.host_is_superhost = h.host_is_superhost
AND s.multi = h.multi
AND s.biz = h.biz

INNER JOIN GOLD.DimDay d
ON s.day_type = d.day_type;
----------------------------------------
ALTER TABLE GOLD.FactListing
ALTER COLUMN listing_key INT NOT NULL;

ALTER TABLE GOLD.FactListing
ADD CONSTRAINT PK_FactListing
PRIMARY KEY(listing_key);

ALTER TABLE GOLD.DimRoom
ADD CONSTRAINT PK_DimRoom
PRIMARY KEY (room_key);
-----------------------------------------------
ALTER TABLE GOLD.FactListing
ADD CONSTRAINT FK_Fact_City
FOREIGN KEY(city_key)
REFERENCES GOLD.DimCity(city_key);


ALTER TABLE GOLD.FactListing
ADD CONSTRAINT FK_Fact_Room
FOREIGN KEY(room_key)
REFERENCES GOLD.DimRoom(room_key);


ALTER TABLE GOLD.FactListing
ADD CONSTRAINT FK_Fact_Host
FOREIGN KEY(host_key)
REFERENCES GOLD.DimHost(host_key);

ALTER TABLE GOLD.FactListing
ADD CONSTRAINT FK_Fact_Day
FOREIGN KEY(day_key)
REFERENCES GOLD.DimDay(day_key);

----------------------------
CREATE INDEX IX_Fact_City
ON GOLD.FactListing(city_key);

CREATE INDEX IX_Fact_Room
ON GOLD.FactListing(room_key);

CREATE INDEX IX_Fact_Host
ON GOLD.FactListing(host_key);

CREATE INDEX IX_Fact_Day
ON GOLD.FactListing(day_key);