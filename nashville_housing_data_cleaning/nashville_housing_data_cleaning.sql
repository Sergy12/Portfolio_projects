					----- Tables creation -----
CREATE TABLE nashville_housing (
    UniqueID  INTEGER,
    ParcelID VARCHAR,
    LandUse VARCHAR,
    PropertyAddress VARCHAR,    
    SaleDate TEXT,
    SalePrice INTEGER,
    LegalReference VARCHAR,     
    SoldAsVacant VARCHAR,       
    OwnerName VARCHAR,
    OwnerAddress VARCHAR,       
    Acreage FLOAT,
    TaxDistrict VARCHAR,        
    LandValue FLOAT,
    BuildingValue FLOAT,        
    TotalValue FLOAT,
    YearBuilt FLOAT,
    Bedrooms FLOAT,
    FullBath FLOAT,
    HalfBath FLOAT
);

					----- Data load -----
ALTER TABLE nashville_housing ALTER COLUMN salePrice SET DATA TYPE TEXT;

-- PSQL Tool
-- \copy nashville_housing FROM 'C:\Users\Usuario\Downloads\Nashville_Housing_Data.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
					
					----- Data cleaning -----

-- Transform incorrect format numbers type to integer type
SELECT salePrice from nashville_housing LIMIT 10;

SELECT salePrice
FROM nashville_housing
WHERE salePrice !~ '^[0-9]+$';

UPDATE nashville_housing
SET salePrice = REGEXP_REPLACE(salePrice, '[^0-9]', '', 'g')
WHERE salePrice !~ '^[0-9]+$';

ALTER TABLE nashville_housing
ALTER COLUMN salePrice TYPE INTEGER USING salePrice::INTEGER;

-- Transform varchar date to DATE type
SELECT saledate
FROM nashville_housing
WHERE saledate !~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$';

ALTER TABLE nashville_housing
ALTER COLUMN saledate TYPE DATE USING TO_DATE(saledate, 'Month DD, YYYY');

-- Populate missing property address
SELECT * from nashville_housing WHERE propertyaddress IS NULL;

SELECT parcelid, propertyaddress
FROM nashville_housing
WHERE parcelid IN (
       SELECT parcelid
       FROM nashville_housing
       WHERE propertyaddress IS NULL
	)
ORDER BY parcelid, propertyaddress;

UPDATE nashville_housing n1
SET propertyaddress = (
    SELECT propertyaddress
    FROM nashville_housing n2
    WHERE n2.parcelid = n1.parcelid AND n2.propertyaddress IS NOT NULL
    LIMIT 1
)
WHERE n1.propertyaddress IS NULL;

-- Spliting property and owner address
SELECT DISTINCT(owneraddress) FROM nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN propertyaddress_dir VARCHAR,
ADD COLUMN propertyaddress_city VARCHAR,
ADD COLUMN owneraddress_dir VARCHAR,
ADD COLUMN owneraddress_city VARCHAR,
ADD COLUMN owneraddress_state VARCHAR;

SELECT
    TRIM(SPLIT_PART(owneraddress, ',', 1)) AS column1,
    TRIM(SPLIT_PART(owneraddress, ',', 2)) AS column2,
    TRIM(SPLIT_PART(owneraddress, ',', 3)) AS column3
FROM nashville_housing LIMIT 10;

UPDATE nashville_housing
SET propertyaddress_dir = TRIM(SPLIT_PART(propertyaddress, ',', 1)),
    propertyaddress_city = TRIM(SPLIT_PART(propertyaddress, ',', 2)),
	owneraddress_dir = TRIM(SPLIT_PART(owneraddress, ',', 1)),
	owneraddress_city = TRIM(SPLIT_PART(owneraddress, ',', 2)),
    owneraddress_state = TRIM(SPLIT_PART(owneraddress, ',', 3));

ALTER TABLE nashville_housing
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress;

-- Standarize soldasvacant yes/no format
SELECT soldasvacant, COUNT(soldasvacant) FROM nashville_housing GROUP BY soldasvacant;

UPDATE nashville_housing
SET soldasvacant = CASE 
					WHEN soldasvacant = 'Y' THEN 'Yes'
					WHEN soldasvacant = 'N' THEN 'No'
					ELSE soldasvacant
				   END;

SELECT * FROM nashville_housing LIMIT 10;

