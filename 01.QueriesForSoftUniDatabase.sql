--01. Employees with Salary Above 35000
GO
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS 
BEGIN
	SELECT FirstName, LastName
		FROM Employees
	WHERE Salary > 35000
END
GO;

EXEC usp_GetEmployeesSalaryAbove35000


--02. Employees with Salary Above Number
GO
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber(@minSalary DECIMAL(18,4))
AS 
BEGIN
	SELECT FirstName, LastName
		FROM Employees
	WHERE Salary >= @minSalary
END
GO;

EXEC usp_GetEmployeesSalaryAboveNumber 38000.50


--03. Town Names Starting With
GO
CREATE PROCEDURE usp_GetTownsStartingWith(@inputString VARCHAR(50))
AS 
BEGIN
	SELECT [Name]
		FROM Towns
	WHERE [Name] LIKE @inputString + '%'
END
GO;


--04. Employees from Town
GO
CREATE PROCEDURE usp_GetEmployeesFromTown (@townname VARCHAR(50))
AS 
BEGIN
	SELECT e.FirstName, e.LastName
		FROM Employees AS e
		LEFT JOIN Addresses AS a
		ON e.AddressID = a.AddressID
		LEFT JOIN Towns AS t
		ON a.TownID = t.TownID
		WHERE t.Name = @townname
END
GO;


--05. Salary Level Function
GO
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
RETURNS VARCHAR(7)
AS 
BEGIN
		DECLARE @salaryLevel VARCHAR(7)

	IF	@salary < 30000
	BEGIN
		SET @salaryLevel = 'Low'
	END
	ELSE IF @salary BETWEEN 30000 AND 50000
	BEGIN
		SET @salaryLevel = 'Average'
	END
	ELSE
	BEGIN 
		SET @salaryLevel = 'High'
	END

	RETURN @salaryLevel
END
GO;

--call function
SELECT Salary,
	dbo.ufn_GetSalaryLevel([Salary]) AS SalaryLevel
	FROM Employees


--06. Employees by Salary Level
GO
CREATE PROCEDURE usp_EmployeesBySalaryLevel  (@levelOfSalary VARCHAR(7))
AS 
BEGIN
	SELECT FirstName, LastName
	FROM Employees
	WHERE dbo.ufn_GetSalaryLevel([Salary]) = @levelOfSalary
END
GO;
exec usp_EmployeesBySalaryLevel 'High'


--07. Define Function
GO
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS 
BEGIN
	DECLARE @result BIT = 1
		DECLARE @COUNT INT = 1
		DECLARE @currentChar NVARCHAR(1) = NULL

		WHILE @COUNT <= LEN(@word)
		BEGIN
			SET @currentChar = SUBSTRING(@word, @COUNT, 1)

			IF (@setOfLetters LIKE '%' + @currentChar + '%')
				BEGIN
					SET @COUNT +=1;
				END
			ELSE
				BEGIN
					SET @result = 0;
				BREAK
				END
		END
		RETURN @result
END
GO;

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'halves') --0
						

--08. Delete Employees and Departments
GO
CREATE PROCEDURE usp_DeleteEmployeesFromDepartment(@departmentId INT) 
AS
BEGIN
	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (
						  SELECT EmployeeID FROM Employees
						  WHERE DepartmentID = @departmentId
	                    )

	UPDATE Employees
	SET ManagerID = NULL
	WHERE ManagerID IN 
						(
						  SELECT EmployeeID FROM Employees
						  WHERE DepartmentID = @departmentId
	                    )

	ALTER TABLE Departments ALTER COLUMN ManagerID INT 

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN 
						(
						  SELECT EmployeeID FROM Employees
						  WHERE DepartmentID = @departmentId
	                    )

	DELETE FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE FROM Departments
	WHERE DepartmentID = @departmentId

	SELECT COUNT(*) AS [Count]
	FROM Employees
	WHERE DepartmentID = @departmentId
END
GO;