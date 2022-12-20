/*
asg4.sql, Assignment 4, December 8 2021
Jameson Watson 
Comp 2521
*/
\! rm -f asg4.log

tee asg4.log

USE jwats569;

DROP TABLE IF EXISTS readbook;
DROP TABLE IF EXISTS bookauthor;
DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS user;
/*
user table - a limit of 25 is used on the varchar for simplicity 
when testing the domains. nickName and profile can be null.
*/
CREATE TABLE IF NOT EXISTS user (
       email VARCHAR(25) PRIMARY KEY CHECK(email like '%_@__%.__%'),
       dateAdded DATE NOT NULL DEFAULT (NOW()),
       nickName VARCHAR(25),
       profile VARCHAR(25))
       ENGINE=InnoDB;

/*
book table - all values have a low limit for testing purposes. 
numraters is set to default 0 because there are 0 ratings to begin with.
bookID is auto incremented as books are added.
*/

CREATE TABLE IF NOT EXISTS book (
       bookID INT PRIMARY KEY AUTO_INCREMENT,
       title VARCHAR(25) UNIQUE NOT NULL,
       year INT NOT NULL,
       numRaters INT DEFAULT 0,
       rating decimal(3,1) DEFAULT NULL)
       ENGINE=InnoDB;
/*
readbook table - bookid and email are the primary keys. dateread is not null
because when someone reads a book the dateread will be set. rating is an
integer between 1 and 10 - 10 being good 1 being bad. 
*/
CREATE TABLE IF NOT EXISTS readbook (
       bookID INT NOT NULL,
       email VARCHAR(25) NOT NULL,
       dateRead DATE NOT NULL DEFAULT (NOW()),
       rating INT check(rating between 1 and 10),
       CONSTRAINT readbook_pk PRIMARY KEY (email, bookID),      
       CONSTRAINT email_fk FOREIGN KEY (email)
       REFERENCES user(email),
       CONSTRAINT book_pk FOREIGN KEY (bookID)
       REFERENCES book(bookID)
       )ENGINE=InnoDB;
/*
author table - author ID is the primary key, lastname and middlename
are optional fields, firstname is not optional. firstName was set to
unique for testing purposes though in reality an author could have
the same name.
*/
CREATE TABLE IF NOT EXISTS author (
       authorID INT PRIMARY KEY AUTO_INCREMENT,
       lastName VARCHAR(25),
       firstName VARCHAR(25) UNIQUE NOT NULL,
       middleName VARCHAR(25),
       DOB DATE)
       ENGINE=InnoDB;

/*
bookauthor table - Author id and book id are the primary keys. Both 
keys are foreign keys to the book and user table.
*/
CREATE TABLE IF NOT EXISTS bookauthor (
       authorID INT,
       bookID INT,
       CONSTRAINT bookauthor_pk PRIMARY KEY(authorID, bookID),
       CONSTRAINT author_fk FOREIGN KEY (authorID)
       REFERENCES author(authorID),
       CONSTRAINT bookauth_pk FOREIGN KEY (bookID)
       REFERENCES book(bookID))
       ENGINE=InnoDB;

/*
deleteUser trigger - Drops the readbook values associated with the user
email that is deleted from the user table. 
*/
DROP TRIGGER IF EXISTS deleteUser_ADR;

DELIMITER $$
CREATE TRIGGER deleteUser_ADR
AFTER DELETE
ON user
FOR EACH ROW
BEGIN
	DELETE FROM readbook WHERE email = old.email;
END$$
DELIMITER ;

/*After delete on readbook remove all of the associated data */
DROP TRIGGER IF EXISTS deleteReadbookRaters_ADR;

DELIMITER $$
CREATE TRIGGER deleteReadbookRaters_ADR
AFTER DELETE
ON readbook
FOR EACH ROW
BEGIN
	UPDATE book SET numRaters = (SELECT COUNT(*)
	FROM readbook WHERE bookID = old.bookID)
	WHERE bookID = old.bookID;
END$$
DELIMITER ;

/*After delete on readbook remove all of the associated data */
DROP TRIGGER IF EXISTS deleteReadbookRatings_ADR;

DELIMITER $$
CREATE TRIGGER deleteReadbookRatings_ADR
AFTER DELETE
ON readbook
FOR EACH ROW
BEGIN
	UPDATE book SET rating = (SELECT AVG(rating)
	FROM readbook WHERE bookID = old.bookID)
	WHERE bookID = old.bookID;
END$$
DELIMITER ;



/*
numRating trigger - updating the number of raters as users add their ratings to 
the book that they have read.
*/
DROP TRIGGER IF EXISTS numRating_AIR;

DELIMITER $$
CREATE TRIGGER numRating_AIR
AFTER INSERT
ON readbook
FOR EACH ROW
BEGIN
	UPDATE book SET book.numRaters = (SELECT COUNT(*)
	FROM readbook WHERE bookID = new.bookID)
	WHERE bookID = new.bookID;
END$$
DELIMITER ;

/*
avgRating trigger - When a user adds a book to bookread, the book rating is
updated by selecting for the avg rating in readbook. There are three triggers 
for the average rating, one to update after insert, delete, and after a row is
updated.
*/

DROP TRIGGER IF EXISTS avgRatingInsert_AIR;

DELIMITER $$
CREATE TRIGGER avgRatingInsert_AIR
AFTER INSERT
ON readbook
FOR EACH ROW
BEGIN
	UPDATE book SET rating = (SELECT AVG(rating)
	FROM readbook WHERE bookID = new.bookID)
	WHERE bookID = new.bookID;
END$$
DELIMITER ;

/*num raters after an update */
DROP TRIGGER IF EXISTS numRatingUpdate_AUR;

DELIMITER $$
CREATE TRIGGER numRatingUpdate_AUR
AFTER UPDATE
ON readbook
FOR EACH ROW
BEGIN
	UPDATE book SET rating = (SELECT COUNT(*)
	FROM readbook WHERE bookID = new.bookID)
	WHERE bookID = new.bookID;
END$$
DELIMITER ;


/*average rating after an update */
DROP TRIGGER IF EXISTS avgRatingUpdate_AUR;

DELIMITER $$
CREATE TRIGGER avgRatingUpdate_AUR
AFTER UPDATE
ON readbook
FOR EACH ROW
BEGIN
	UPDATE book SET rating = (SELECT AVG(rating)
	FROM readbook WHERE bookID = new.bookID)
	WHERE bookID = new.bookID;
END$$
DELIMITER ;

/*
Throw an error message if the user tries to change the email or date
added.
*/
DROP TRIGGER IF EXISTS BeforeUpdateUser_BUR;

DELIMITER $$
CREATE TRIGGER BeforeUpdateUser_BUR
BEFORE UPDATE
ON user
FOR EACH ROW
BEGIN
	IF(old.email <> new.email) OR (old.dateAdded <> new.dateAdded)
	THEN SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Unable to update email or date added';
	END IF;
END$$
DELIMITER ;

/*
Before delete on user remove all of the data for the foreign key
constraints to not fail.
*/
DROP TRIGGER IF EXISTS BeforeDeleteUser_ADR;

DELIMITER $$
CREATE TRIGGER BeforeDeleteUser_ADR
AFTER DELETE
ON user
FOR EACH ROW
BEGIN
	DELETE FROM readbook WHERE email = old.email;
END$$
DELIMITER ;
