-- Data Cleansing

--1. Add a New Column to Hold a Newly Formatted SaleDate.

ALTER TABLE dbo.NashvilleHousingData
ADD SaleDateFormatted DATE;

UPDATE dbo.NashvilleHousingData
SET SaleDateFormatted = CONVERT(DATE, SaleDate)


-- 2. Populate Property Address data

select PropertyAddress
from dbo.NashvilleHousingData
where PropertyAddress Is Null

select ParcelID, PropertyAddress, Count(ParcelID)
from dbo.NashvilleHousingData
group by ParcelID, PropertyAddress
having Count(ParcelID) >1
order by ParcelId

-- We found duplicated ParcelIDs, where one row has the PropertyAddress populated and another row is missing an address.
-- Our task is to populate the addresses for these duplicated ParcelId rows, where one of the rows is missing an address, 
-- with the address from another row of the same ParcelId that has an address

select a.ParcelID
,a.PropertyAddress
,b.ParcelID
,b.PropertyAddress
,PopulatedPropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousingData a
INNER JOIN dbo.NashvilleHousingData b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
where a.PropertyAddress Is Null

-- update missing PropertyAddress 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousingData a
INNER JOIN dbo.NashvilleHousingData b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
where a.PropertyAddress Is Null

select * from dbo.NashvilleHousingData
where  PropertyAddress Is Null

-- Braking out Address into Individual columns (Address, City)

select 
UniqueID
,PropertyAddress
,Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',  PropertyAddress) -1) 
,City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))
from dbo.NashvilleHousingData


--Adding two new columns to store Address and City values, and subsequently updating them

ALTER TABLE dbo.NashvilleHousingData
ADD PropertySplitAddress Nvarchar(250),
PropertySplitCity Nvarchar(255);

UPDATE dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',  PropertyAddress) -1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))


-- Braking out Owner Address into Individual columns (Address, City, State) (using different method)

select 
OwnerAddress
,State = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
,City = PARSENAME(replace(OwnerAddress, ',', '.'), 2)
,Address = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
from dbo.NashvilleHousingData 

-- --Adding two new columns to store Owner Address, City & State values, and subsequently updating them

ALTER TABLE dbo.NashvilleHousingData 
ADD OwnerSplitState NVARCHAR(255),
OwnerSplitCity NVARCHAR(255),
OwnerSplitAddress NVARCHAR(255)

UPDATE dbo.NashvilleHousingData 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1),
OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2),
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


-- Change Y and N to Yes and No in Sold as Vacant field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from dbo.NashvilleHousingData 
Group by SoldAsVacant
order by 2

UPDATE dbo.NashvilleHousingData
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN  SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Finding & Remove Duplicates

SELECT *
FROM (
SELECT 
UniqueID
,ParcelID
,PropertyAddress
,Row_Count = ROW_NUMBER() OVER(
							PARTITION BY ParcelID
							,PropertyAddress
							,SalePrice
							,SaleDate
							,LegalReference ORDER BY ParcelId) 
FROM dbo.NashvilleHousingData 
) x

WHERE Row_Count >1

-- REMOVING DUPLICATES

WITH DuplicatedRecords AS
(
SELECT 
UniqueID
,ParcelID
,PropertyAddress
,Row_Count = ROW_NUMBER() OVER(
							PARTITION BY ParcelID
							,PropertyAddress
							,SalePrice
							,SaleDate
							,LegalReference ORDER BY ParcelId) 
FROM dbo.NashvilleHousingData 
)
DELETE
FROM DuplicatedRecords
WHERE Row_Count >1

-- Delete Unused Columns

ALTER TABLE dbo.NashvilleHousingData 
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress

SELECT * FROM dbo.NashvilleHousingData 