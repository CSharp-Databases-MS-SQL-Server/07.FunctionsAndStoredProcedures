--09. Find Full Name
GO
CREATE PROCEDURE usp_GetHoldersFullName
AS
BEGIN
	SELECT FirstName + ' ' + LastName AS [Full Name]
		FROM AccountHolders
END
GO

--10. People with Balance Higher Than
GO
CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan (@money DECIMAL(18,4))
AS
BEGIN
	SELECT a.FirstName,
		   a.LastName
		FROM Accounts AS acc
		LEFT JOIN AccountHolders AS a
		ON acc.Id = a.Id
		GROUP BY a.FirstName, a.LastName
		HAVING SUM(acc.Balance) > @money
END
GO;


--11. Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(16, 2), @interest FLOAT, @years INT) 
RETURNS DECIMAL(20, 4) AS
BEGIN
	DECLARE @futureValue DECIMAL(20, 4) = @sum * POWER(1 + @interest, @years)
	RETURN @futureValue
END
GO

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)
GO


--12. Calculating Interest
CREATE PROC usp_CalculateFutureValueForAccount(@AccountID INT, @InterestRate FLOAT) AS
SELECT 
	a.Id AS [Account Id], 
	ah.FirstName AS [First Name],
	ah.LastName AS [Last Name],
	a.Balance AS [Current Balance],
	dbo.ufn_CalculateFutureValue(a.Balance, @InterestRate, 5) AS [Balance in 5 years] 
	FROM Accounts AS a
JOIN AccountHolders AS ah
ON a.AccountHolderId = ah.Id AND a.Id = @AccountID

EXEC usp_CalculateFutureValueForAccount 1, 0.1
GO;