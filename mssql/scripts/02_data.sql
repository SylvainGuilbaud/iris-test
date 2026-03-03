USE MyAppDb;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE Email = 'alice@example.com')
  INSERT INTO dbo.Customers (Name, Email) VALUES ('Alice', 'alice@example.com');

IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE Email = 'bob@example.com')
  INSERT INTO dbo.Customers (Name, Email) VALUES ('Bob', 'bob@example.com');
GO