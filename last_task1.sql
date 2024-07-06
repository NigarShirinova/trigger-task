CREATE DATABASE Groups
CREATE TABLE Groups(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Limit INT NOT NULL,
    BeginDate DATE NOT NULL,
    EndDate DATE NOT NULL
);

CREATE TABLE Students (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Surname NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    GPA FLOAT NOT NULL,
    GroupId INT,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TRIGGER CheckGroupLimit
ON Students
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @GroupId INT
    SELECT @GroupId = GroupId FROM inserted

    IF (SELECT COUNT(*) FROM Students WHERE GroupId = @GroupId) >= (SELECT Limit FROM Groups WHERE Id = @GroupId)
    BEGIN
        RAISERROR ('Group limit reached', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO Students (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId)
        SELECT Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId
        FROM inserted
    END
END

CREATE TRIGGER CheckStudentAge
ON Students
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @BirthDate DATE
    SELECT @BirthDate = BirthDate FROM inserted

    IF DATEDIFF(YEAR, @BirthDate, GETDATE()) < 16
    BEGIN
        RAISERROR ('Student age must be greater than 16', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO Students (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId)
        SELECT Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId
        FROM inserted
    END
END

CREATE FUNCTION GetGroupAverageGPA (@GroupId INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @AvgGPA FLOAT
    SELECT @AvgGPA = AVG(GPA) FROM Students WHERE GroupId = @GroupId
    RETURN @AvgGPA
END
