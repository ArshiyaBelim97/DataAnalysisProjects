/*
Cleaning Data in SQL Queries
*/

Select *
From NashvilleHousing

-----------------------------------------
--Standarize Date Formate

Select SaleDateConverted, CONVERT(date,SaleDate)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted =CONVERT(Date,SaleDate)

-----------------------------------------
--Populate Property Address data 

Select *
From NashvilleHousing
--Where PropertyAddress is NULL
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b. [UniqueID ]
  Where a.PropertyAddress is NULL

  UPDATE a
  SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
  From NashvilleHousing a
  Join NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b. [UniqueID ]
  Where a.PropertyAddress is NULL

-----------------------------------------
--Breaking out Address into individual columns(Address, City, State)

Select PropertyAddress
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress =SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select * 
From NashvilleHousing


Select OwnerAddress
From NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-----------------------------------------
--Change Y and N to Yes and No  in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,CASE When SoldAsVacant='Y' THEN 'Yes'
      When SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant='Y' THEN 'Yes'
      When SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END


-----------------------------------------
--Remove Duplicate

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
)
DELETE 
--SELECT *
From RowNumCTE
Where row_num>1
--Order by PropertyAddress

-----------------------------------------
--Delete Unsued Columns

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

-----------------------------------------
-----------------------------------------
