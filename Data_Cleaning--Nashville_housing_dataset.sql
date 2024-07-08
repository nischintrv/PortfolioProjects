--CLEANING DATA IN SQL

SELECT *
FROM NashvilleHousing

-- ***Standardize the Date Format

SELECT CAST(SaleDate As date), CONVERT(date, saledate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, saledate)

-- checking if updated
SELECT SaleDate
FROM NashvilleHousing
-- did not update

--using ALTER TABLE
ALTER TABLE NashvilleHousing
ADD saledate_converted date

UPDATE NashvilleHousing
SET saledate_converted = CONVERT(date, saledate)

--checking
SELECT saledate_converted
FROM NashvilleHousing



-- ***Populate property address Data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

--using self join to check the rows that are null and populate
SELECT a.ParcelID,
		a.PropertyAddress,
		b.ParcelID,
		b.PropertyAddress,
		ISNULL(a.PropertyAddress, b.PropertyAddress) --check if null and add from alt col.
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--***Breaking out PropertyAddress into induvidual Columns (Address, City, state)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT PropertyAddress,
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

--using ALTER TABLE
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255),
	PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	 PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--checking
SELECT *
FROM NashvilleHousing



--***Breaking out OwnerAddress into induvidual Columns (Address, City, state)

SELECT OwnerAddress,
		PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--checking
SELECT *
FROM NashvilleHousing;



--*** Change Y and N to Yes and No in 'SoldAsVacant' field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant LIKE 'Y%' THEN 'Yes'
		WHEN SoldAsVacant LIKE 'N%' THEN 'No'
		END 
FROM NashvilleHousing
WHERE SoldAsVacant IN ('Y', 'N'

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant LIKE 'Y%' THEN 'Yes'
		WHEN SoldAsVacant LIKE 'N%' THEN 'No'
		ELSE SoldAsVacant END

-- Checking if updated

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant



--***Remove Duplicates

WITH row_num AS (
SELECT *,
		ROW_NUMBER() OVER( PARTITION BY ParcelID,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
							ORDER BY UniqueID ) AS row_num
FROM NashvilleHousing
---ORDER BY ParcelID
)

SELECT *
FROM row_num
WHERE row_num > 1


-- Delete selection

WITH row_num AS (
SELECT *,
		ROW_NUMBER() OVER( PARTITION BY ParcelID,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
							ORDER BY UniqueID ) AS row_num
FROM NashvilleHousing
---ORDER BY ParcelID
)

DELETE
FROM row_num
WHERE row_num > 1



--***Delete unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
			TaxDistrict,
			PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

--check
SELECT *
FROM NashvilleHousing
