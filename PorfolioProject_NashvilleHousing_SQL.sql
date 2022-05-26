
select * from NashvilleHousing
--there are 56,477 records

-----------
--Start cleaning data now
--1. SaleDate converted from Datetime to Date, 
--by first Adding another column SaleDateAltered, 
--populating it with converted Saledate, then deleting column original SaleDate, 
--then renaming SaleDateAltered back to SaleDate (which will now have Date only)
select SaleDate, Convert(date, SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDateAltered = Convert(date, SaleDate)

Alter table NashvilleHousing
Rename column  SaleDateAltered ; -- renaming with sql didn't work, so renamed in the object browser

Alter table NashvilleHousing
Drop column SaleDate;


--2. Updating Property Address
--There are 29 records with null prpertyAddress

Select * from NashvilleHousing
where PropertyAddress is null

--Since Property's ParcelIds are unique, will match on ParcelId and update the propertyAddresses

Select ParcelId, PropertyAddress from NashvilleHousing
where ParcelId in (Select ParcelId  from NashvilleHousing where PropertyAddress is null)
and PropertyAddress is not null
order by ParcelId

select a.ParcelId, b.ParcelId, a.PropertyAddress, b.PropertyAddress, isnull(b.PropertyAddress, a.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelId = b.ParcelId
and a.UniqueID <> b.uniqueId
and b.PropertyAddress is null

---populated all the 29 records who had Null propertyaddress with valid PropertyAddress with same ParcelId
update b
set PropertyAddress = isnull(b.PropertyAddress, a.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelId = b.ParcelId
and a.uniqueId <> b.uniqueId
and b.PropertyAddress is null


--3. Breaking Address into Address, City and State

Select substring(a.PropertyAddress, 1, CHARINDEX(',', a.PropertyAddress, 1)-1) as Address,
substring(a.PropertyAddress, CHARINDEX(',', a.PropertyAddress, 1)+1, Len(a.PropertyAddress)) as City
--right(a.PropertyAddress, CHARINDEX(',', a.PropertyAddress, 1)+1) as City,  a.PropertyAddress
from NashvilleHousing a

Alter Table NashvilleHousing
Add PropertyCity nvarchar(50)

Select 
substring(a.PropertyAddress, CHARINDEX(',', a.PropertyAddress, 1)+1, Len(a.PropertyAddress)) as City
--right(a.PropertyAddress, CHARINDEX(',', a.PropertyAddress, 1)+1) as City,  a.PropertyAddress
from NashvilleHousing a

--now update newly created City field with City Data we extracted from PropertyAddress
update NashvilleHousing
set PropertyCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress, 1)+1, Len(PropertyAddress)) 


--now update PropertyAdress field with Address Data we extracted from PropertyAddress, 
--original PropertyAddress will be gone
select substring(a.PropertyAddress, 1, CHARINDEX(',', a.PropertyAddress, 1)-1) as Address 
from PortfolioProject.dbo.NashvilleHousing a
inner join NashvilleHousing b
on a.uniqueid = b.uniqueId


update NashvilleHousing
set PropertyAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1)-1) 

--Now lets look at OwnerAddess

select OwnerAddress,
Parsename(Replace(OwnerAddress, ',', '.'), 1) as OwnerAddressSplitState,
Parsename(Replace(OwnerAddress, ',', '.'), 2) as OwnerAddressSplitCity,
Parsename(Replace(OwnerAddress, ',', '.'), 3) as OwnerAddressSplitStreet
from NashvilleHousing
where OwnerAddress is not null

--lets add three Owner fields to accomodate split ownerAddress 
Alter table NashvilleHousing
add OwnerAddressSplitState nvarchar(10),
 OwnerAddressSplitCity nvarchar(50),
OwnerAddressSplitStreet nvarchar(100)


--now populate the new owner fields with split data
update NashvilleHousing
set OwnerAddressSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1),
 OwnerAddressSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2),
OwnerAddressSplitStreet = Parsename(Replace(OwnerAddress, ',', '.'), 3)

select OwnerAddress, OwnerAddressSplitStreet, OwnerAddressSplitCity, OwnerAddressSplitState
from NashvilleHousing
where OwnerAddress is not null



----4  Lets look at SoldasVacant field

select SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N'then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing

--now lets update SoldAsVacant field with Yes and No for Y and N data where ever necessary
update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N'then 'No'
	 else SoldAsVacant
	 end

--5 lets find duplicate records  
--found there are 104 duplicate records

--create a RowNumCTE
with RowNumCTE
As(
select 
ROW_NUMBER() over (
		partition by parcelId,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		order by uniqueId
) row_num, *
from NashvilleHousing
--where row_num > 1
--order by parcelid
)

select * from rowNumCTE
where row_num >1

delete  from rowNumCTE
where row_num >1

--now after deleting 104 records, there r now 56,373 records instead of 57,477 records before with duplicates
select * from NashvilleHousing


