# 🏠 Nashville Housing Cleaning Project

In this project, we have a data set about housing in Nashville. Let's clean it to make it more usable for data analysis.

***

First, let's take a look at all of our data.

```sql
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
```

IMAGE 1 HERE:

IMAGE 2 HERE:

***

## 1. SaleDate Column

The SaleDate column is in DATETIME format. 

```sql
SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing
```

IMAGE: 

Let's change it so we only get the date (yyyy-mm-dd).

```sql
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
```

IMAGE: 

***

## 2. Populate Property Address Data

There are null values in the PropertyAddress column. Since this column is referring to the address of property, we can be almost certain that the values will not change. So, let's find out a way to fill these null values.

If we run the following query (where we order by ParcelID), we notice that there are multiple records where ParcelID and PropertyAddress is the same.

```sql
SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID
```

IMAGE: image_3

So, we can say if the first ParcelID highlighted has a PropertyAddress, and the second ParcelID does not have an PropertyAddress, let's populate it with the first address that's already populated since we know they are going to be the same.

We can do this by using a self join.

Let's run this query:

```sql
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
```
Result:

IMAGE: image_4

In this query, we use a self join. The first join condition is "WHEN a.ParcelID = b.ParcelID" because in the original data, there are multiple records with the same ParcelID. For the second join condition, we want the results to be when a.UniqueID IS NOT EQUAL to b.UniqueID. Since UniqueIDs are unique, this makes sure that the records we are querying will be different (in terms of UniqueID).

The next important part of this query is using the ISNULL function, which returns a specified value if the expression is NULL. For the above query, we are checking if a.PropertyAddress IS NULL. If it is NULL, then we want to return b.PropertyAddress.

This whole query creates a column that we will use to UPDATE the PropertyAddress column.

```sql
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
```

The above UPDATE query will successfully populate the PropertyAddress column.

***









