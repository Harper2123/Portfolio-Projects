/* In this project, we are using SQL to clean our dataset and make it usable */

-- Retrieving Data

SELECT *
FROM NashvilleHousing;

------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing;

------------------------------------------------------------------------------

-- Populate Property Address Data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------

-- Breaking Out Address into Individual Columns (Address, City, State)

Select
substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1) as Address,
substring(PropertyAddress, charindex(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, charindex(',',PropertyAddress) +1,LEN(PropertyAddress))

select PropertySplitAddress, PropertySplitCity
from NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing;

-----------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end

select distinct(SoldAsVacant)
from NashvilleHousing

--------------------------------------------------------------------------------------

-- Remove Duplicates

WITH cte_row_num AS
(
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM NashvilleHousing
)
DELETE
from cte_row_num
where row_num > 1;

---------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

select * from NashvilleHousing;

------------------------------------------------------------------------------------------