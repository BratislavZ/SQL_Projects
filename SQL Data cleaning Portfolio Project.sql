/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID
------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format (Eliminate time from date)

SELECT SaleDate, cast(SaleDate AS DATE) AS Datum
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

-- OR

ALTER TABLE NashvilleHousing
ADD SaleDate2 DATE;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate2 = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

sp_rename 'NashvilleHousing.SaleDate2', 'SaleDate', 'COLUMN';
-------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data, filling NULL value with PropertyAddress 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON  a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON  a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) || LEFT, RIGHT, SUBSTRING, PARSENAME


SELECT PropertyAddress, LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS adress,
						RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) AS city
FROM PortfolioProject.dbo.NashvilleHousing


--OR

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS adress,
						SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS city
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD adress varchar(255)

ALTER TABLE NashvilleHousing
ADD city varchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET adress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS O_adress,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS O_city,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS O_state
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD O_adress varchar(255)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD O_city varchar(255)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD O_state varchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET O_adress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET O_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET O_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)




--------------------------------------------------------------------------------------------------------------------------


-- Changing Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)       -- Checking if there are more 'Yes' and 'No' fields than 'Y' and 'N' fields
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

                -- checking if there are any duplicates
SELECT COUNT([UniqueID ]), ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference	
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference		 
ORDER BY 1


DELETE
FROM PortfolioProject.dbo.NashvilleHousing
WHERE [UniqueID ] NOT IN 
	(
	SELECT MAX([UniqueID ])	
	FROM PortfolioProject.dbo.NashvilleHousing
	GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference		 
	--ORDER BY 1
	)

	
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress