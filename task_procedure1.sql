CREATE DATABASE MoviesApp

CREATE TABLE Directors(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
 Surname NVARCHAR(50) NOT NULL
)

CREATE TABLE Movies(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
 Description NVARCHAR(200),
 CoverPhoto NVARCHAR(50),
 DirectorID INT FOREIGN KEY REFERENCES Directors(Id),
 LanguangeID INT FOREIGN KEY REFERENCES Languanges(Id)
)

CREATE TABLE Languanges(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
)

CREATE TABLE Actors(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
 Surname NVARCHAR(50) NOT NULL
)

CREATE TABLE Genres(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
)

CREATE TABLE MoviesActors(
Id INT PRIMARY KEY IDENTITY,
MovieID INT FOREIGN KEY REFERENCES Movies(Id),
ActorID INT FOREIGN KEY REFERENCES Actors(Id)
)

CREATE TABLE MoviesGenres(
Id INT PRIMARY KEY IDENTITY,
MovieID INT FOREIGN KEY REFERENCES Movies(Id),
GenreID INT FOREIGN KEY REFERENCES Genres(Id)
)


INSERT INTO Languanges
VALUES('Azerbaijan'),
('Turkish'),
('English'),
('Russian')

INSERT INTO Genres
VALUES('Comedy'),
('Action'),
('Romance'),
('Drama')

INSERT INTO Directors
VALUES('Salam', 'Salamzade'),
('Filankes','Filankesov'),
('Hello', 'Helloyev')

INSERT INTO Movies
VALUES(' The Shawshank Redemption', 'Over the course of several years, two convicts form a friendship, seeking consolation and, eventually, redemption through basic compassion.', 'URL1', 1, 1),
('Megan', 'Occupying world by Artisificial Intelligence', 'URL2', 2, 3),
('Fresh', 'A man eating humans', 'URL3', 3, 2)

INSERT INTO Actors 
VALUES 
('Leonardo', 'DiCaprio'),
('Scarlett', 'Johansson'),
('Tom', 'Hanks'),
('Natalie', 'Portman');

SELECT * FROM Movies
SELECT * FROM Actors
SELECT * FROM Genres

INSERT INTO MoviesGenres
VALUES(1,1),
(1,2),
(2,3),
(3,4)

INSERT INTO MoviesActors
VALUES(1,1),
(1,2),
(1,3),
(2,4),
(3,3),
(3,4)


CREATE OR ALTER PROCEDURE GetDirectorMovies @directorId INT
AS
BEGIN
    SELECT 
        Movies.name AS 'MovieName',
        Languanges.name AS Language
    FROM 
        Movies
    JOIN 
        Languanges ON Movies.languangeID = Languanges.id
    WHERE 
        Movies.directorId = @directorId;
END;

EXEC GetDirectorMovies 2


CREATE OR ALTER FUNCTION GetMoviesCountByLanguage (@languangeId INT)
RETURNS INT
AS
BEGIN
    DECLARE @movieCount INT;

    SELECT @movieCount = COUNT(*)
    FROM Movies
    WHERE languangeId = @languangeId;

    RETURN @movieCount;
END;

SELECT dbo.GetMoviesCountByLanguage(1);

CREATE OR ALTER PROCEDURE GetGenreMovies
    @genreId INT
AS
BEGIN
    SELECT m.Id, m.Name AS MovieName, d.Name AS DirectorName
    FROM Movies m
    JOIN MoviesGenres mg ON m.Id = mg.MovieID
    JOIN Directors d ON m.DirectorID = d.Id
    WHERE mg.GenreID = @genreId;
END;


CREATE OR ALTER FUNCTION HasActorParticipatedInMoreThanThreeMovies (@actorId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT;

    IF (SELECT COUNT(*) FROM MoviesActors WHERE ActorID = @actorId) > 3
    BEGIN
        SET @result = 1;
    END
    ELSE
    BEGIN
        SET @result = 0; 
    END

    RETURN @result;
END;


CREATE TRIGGER trg_AfterInsertMovie
ON Movies
AFTER INSERT
AS
BEGIN
    SELECT m.Id, m.Name AS MovieName, d.Name AS DirectorName, l.Name AS Language
    FROM Movies m
    JOIN Directors d ON m.DirectorID = d.Id
    JOIN Languanges l ON m.LanguangeID = l.Id;
END;




