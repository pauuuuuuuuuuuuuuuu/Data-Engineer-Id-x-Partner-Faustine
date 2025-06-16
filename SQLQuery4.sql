DROP TABLE StagingTransaction;

CREATE TABLE StagingTransaction (
    TransactionID INT,
    AccountID INT,
    TransactionDate DATETIME,
    Amount INT,
    TransactionType NVARCHAR(50),
    BranchID INT
);

CREATE TABLE StagingTransactionUpload (
    TransactionID INT,
    AccountID INT,
    TransactionDate DATETIME,
    Amount INT,
    TransactionType NVARCHAR(50),
    BranchID INT
);

USE DWH_Project;
GO

BULK INSERT StagingTransaction
FROM 'C:\DataFiles\transaction_upload.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

SELECT * FROM StagingTransaction;

SELECT TOP 10 * FROM FactTransaction;

SELECT TransactionID, COUNT(*)
FROM FactTransaction
GROUP BY TransactionID
HAVING COUNT(*) > 1;

USE DWH_Project;
GO

CREATE PROCEDURE DailyTransaction
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SELECT 
        CAST(TransactionDate AS DATE) AS [Date],
        COUNT(*) AS TotalTransactions,
        SUM(Amount) AS TotalAmount
    FROM FactTransaction
    WHERE TransactionDate BETWEEN @start_date AND @end_date
    GROUP BY CAST(TransactionDate AS DATE)
    ORDER BY [Date];
END;
GO

EXEC DailyTransaction 
    @start_date = '2024-01-18', 
    @end_date = '2024-01-21';

CREATE TABLE FactTransaction (
    TransactionID INT PRIMARY KEY,
    AccountID INT,
    TransactionDate DATETIME,
    Amount INT,
    TransactionType NVARCHAR(50),
    BranchID INT
);

INSERT INTO FactTransaction (TransactionID, AccountID, TransactionDate, Amount, TransactionType, BranchID)
SELECT
    TransactionID,
    AccountID,
    TransactionDate,
    Amount,
    TransactionType,
    BranchID
FROM StagingTransaction;

SELECT * FROM FactTransaction;


USE DWH_Project;
GO

CREATE PROCEDURE BalancePerCustomer
    @CustomerName NVARCHAR(100)
AS
BEGIN
    SELECT 
        c.CustomerName,
        a.AccountType,
        a.Balance AS InitialBalance,
        a.Balance + 
            SUM(
                CASE 
                    WHEN ft.TransactionType = 'Deposit' THEN ft.Amount
                    ELSE -ft.Amount
                END
            ) AS CurrentBalance
    FROM DimCustomer c
    JOIN DimAccount a ON c.CustomerID = a.CustomerID
    LEFT JOIN FactTransaction ft ON a.AccountID = ft.AccountID
    WHERE 
        a.Status = 'Active' AND
        c.CustomerName = @CustomerName
    GROUP BY 
        c.CustomerName,
        a.AccountType,
        a.Balance;
END;
GO

EXEC BalancePerCustomer 
    @name = 'Shelly';


CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(100),
    Address NVARCHAR(255),
    CityName NVARCHAR(100),
    StateName NVARCHAR(100),
    Age INT,
    Gender NVARCHAR(10),
    Email NVARCHAR(100)
);

INSERT INTO DimCustomer (CustomerID, CustomerName, Address, CityName, StateName, Age, Gender, Email)
SELECT 
    c.customer_id,
    UPPER(c.customer_name),
    c.address,
    UPPER(ci.city_name),
    UPPER(s.state_name),
    c.age,
    UPPER(c.gender),
    c.email
FROM customer c
JOIN city ci ON c.city_id = ci.city_id
JOIN state s ON ci.state_id = s.state_id;

CREATE TABLE DimAccount (
    AccountID INT PRIMARY KEY,
    CustomerID INT,
    AccountType NVARCHAR(50),
    Balance INT,
    DateOpened DATE,
    Status NVARCHAR(50)
);

INSERT INTO DimAccount (AccountID, CustomerID, AccountType, Balance, DateOpened, Status)
SELECT 
    account_id,
    customer_id,
    account_type,
    balance,
    date_opened,
    status
FROM account;

-- Drop if exists: DimCustomer
DROP TABLE IF EXISTS DimCustomer;
GO

-- Buat tabel DimCustomer
CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(100),
    Address NVARCHAR(255),
    CityName NVARCHAR(100),
    StateName NVARCHAR(100),
    Age INT,
    Gender NVARCHAR(10),
    Email NVARCHAR(100)
);
GO

-- Isi data DimCustomer
INSERT INTO DimCustomer (CustomerID, CustomerName, Address, CityName, StateName, Age, Gender, Email)
SELECT 
    c.customer_id,
    UPPER(c.customer_name),
    c.address,
    UPPER(ci.city_name),
    UPPER(s.state_name),
    c.age,
    UPPER(c.gender),
    c.email
FROM customer c
JOIN city ci ON c.city_id = ci.city_id
JOIN state s ON ci.state_id = s.state_id;
GO


-- Drop if exists: DimAccount
DROP TABLE IF EXISTS DimAccount;
GO

-- Buat tabel DimAccount
CREATE TABLE DimAccount (
    AccountID INT PRIMARY KEY,
    CustomerID INT,
    AccountType NVARCHAR(50),
    Balance INT,
    DateOpened DATE,
    Status NVARCHAR(50)
);
GO

-- Isi data DimAccount
INSERT INTO DimAccount (AccountID, CustomerID, AccountType, Balance, DateOpened, Status)
SELECT 
    account_id,
    customer_id,
    account_type,
    balance,
    date_opened,
    status
FROM account;
GO

DROP TABLE IF EXISTS DimBranch;
GO

CREATE TABLE DimBranch (
    BranchID INT PRIMARY KEY,
    BranchName NVARCHAR(100),
    BranchAddress NVARCHAR(255)
);

INSERT INTO DimBranch (BranchID, BranchName, BranchAddress)
SELECT 
    branch_id,
    UPPER(branch_name),
    branch_address
FROM branch;

SELECT TOP 5 * FROM DimBranch;

SELECT * FROM DimBranch
WHERE BranchID IN (1, 3, 4, 5);



