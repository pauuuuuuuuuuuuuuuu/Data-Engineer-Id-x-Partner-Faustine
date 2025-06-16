CREATE TABLE DimCustomer (
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    CityName VARCHAR(100) NOT NULL,
    StateName VARCHAR(100) NOT NULL,
    Age INT NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    CONSTRAINT PK_CustomerID PRIMARY KEY (CustomerID)
);

CREATE TABLE DimAccount (
    AccountID INT NOT NULL,
    CustomerID INT NOT NULL,
    AccountType VARCHAR(50) NOT NULL,
    Balance FLOAT NOT NULL,
    DateOpened DATE NOT NULL,
    Status VARCHAR(50) NOT NULL,
    CONSTRAINT PK_AccountID PRIMARY KEY (AccountID),
    CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID)
);

CREATE TABLE DimBranch (
    BranchID INT NOT NULL,
    BranchName VARCHAR(100) NOT NULL,
    BranchLocation VARCHAR(255) NOT NULL,
    CONSTRAINT PK_BranchID PRIMARY KEY (BranchID)
);

CREATE TABLE FactTransaction (
    TransactionID INT NOT NULL,
    AccountID INT NOT NULL,
    TransactionDate DATE NOT NULL,
    Amount FLOAT NOT NULL,
    TransactionType VARCHAR(50) NOT NULL,
    BranchID INT NOT NULL,
    CONSTRAINT PK_TransactionID PRIMARY KEY (TransactionID),
    CONSTRAINT FK_AccountID FOREIGN KEY (AccountID) REFERENCES DimAccount(AccountID),
    CONSTRAINT FK_BranchID FOREIGN KEY (BranchID) REFERENCES DimBranch(BranchID)
);
