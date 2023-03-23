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


