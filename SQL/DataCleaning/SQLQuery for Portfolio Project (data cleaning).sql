SELECT * FROM NashvilleHousing


-- 1 - Standartize date format
-- selecting columns
SELECT
	SaleDate,
	SaleDateConverted,
	convert(date, SaleDate)
FROM NashvilleHousing;

-- doesn't work
UPDATE NashvilleHousing
SET SaleDate = convert(date, SaleDate);

-- alternatively can add new column and set the converted values
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = convert(date, SaleDate)


-- 2 - Populating property address
-- selecting null address columns
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is NULL

-- selecting a column with Property address by other rows with the same ParcelID
SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- updating the table
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


-- 3 - Breaking address to 3 columns - Address, City, State
-- looking for 1st part before ',' and secod part after ',' in address value
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as City
FROM NashvilleHousing

-- adding new columns and setting values to them
ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

-- breaking OwnerAddress in 3 columns
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

-- adding new columns and setting values to them
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- 4 - Change 'SoldAsVacant' column's Y and N fields to Yes and No
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing


-- 5 - Removing duplicates
-- using CTE to find duplicate rows
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID) as row_num
FROM NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1

-- to delete duplicates jus replace 'select *' with 'delete'
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID) as row_num
FROM NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1


-- 6 - Deleting unused columns (unnecessary to use to DB)
-- deleting 'PropertyAddress', 'OwnerAddress', 'TaxDistrict' and 'SaleDate'
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
