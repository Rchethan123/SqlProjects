CREATE DATABASE LibraryManagement;
USE libraryManagement;

CREATE TABLE publishers (
		PublisherName varchar(100) primary key NOT NULL,
	    PublisherAddress varchar(200) NOT NULL,
		PublisherPhone varchar(50)NOT NULL
);

CREATE TABLE books (
		BookID varchar(10) primary key NOT NULL,
		Title varchar(100) NOT NULL,
        AuthorName varchar(100) NOT NULL,
		PublisherName varchar(100) NULL, CONSTRAINT FOREIGN KEY(PublisherName) REFERENCES publishers(PublisherName)
);

CREATE TABLE library_branch (
		BranchID INT primary key NOT NULL auto_increment,
		BranchName varchar(100) NOT NULL,
		BranchAddress varchar(200) NOT NULL,
        Phone varchar(100)
);

CREATE TABLE borrower (
		CardNo varchar(10) PRIMARY KEY NOT NULL,
		BorrowerName varchar(100) NOT NULL,
		BorrowerAddress varchar(200) NOT NULL,
		BorrowerPhone varchar(50) NOT NULL
);

CREATE TABLE book_loans (
		LoansID INT primary key NOT NULL auto_increment,
		BookID varchar(10) NOT NULL , CONSTRAINT FOREIGN KEY (BookID) REFERENCES books(BookID) ,
		BranchID INT , CONSTRAINT FOREIGN KEY (BranchID) REFERENCES library_branch(BranchID),
		CardNo varchar(10) NOT NULL , CONSTRAINT FOREIGN KEY (CardNo) REFERENCES borrower(CardNo),
		DateOut varchar(50) NOT NULL,
		DueDate varchar(50) NULL
);
      
CREATE TABLE book_copies (
		CopiesID INT primary key NOT NULL auto_increment,
		BookID varchar(10) NOT NULL, CONSTRAINT  FOREIGN KEY (BookID) REFERENCES books(BookID) ,
		BranchID INT NOT NULL , CONSTRAINT  FOREIGN KEY (BranchID) REFERENCES library_branch(BranchID) ,
		No_Of_Copies INT Null
);

INSERT INTO library_branch
		(BranchName,BranchAddress,Phone)
		VALUES
		('Sharpstown','32 Corner Road, New York, NY 10012',6312387560),
		('Central','491 3rd Street, New York, NY 10014',8332253423),
		('Saline','40 State Street, Los Angeles, California  48176',6131235543),
		('Anna Arbor','101 South University, San Antonia, Texas 48143',8544345323),
        ('East City','101 South University,Jacksonville, Florida 48233',9231334565),
        ('Street 12th','101 South University, Fersno, California 48344',6867653443),
        ('Seaside','101 South University, Seattle, Washington 48654',7776875643),
        ('Cityville','101 South University, Columbus, Georgia 48564',865345664),
        ('Riverdale','101 South University, Morristown,New Jersey 42345',9675443345);

SELECT * FROM book_copies;
SELECT * FROM book_loans;
SELECT * FROM books;
SELECT * FROM borrower;
SELECT * FROM library_branch;
SELECT * FROM publishers;

-- 1.find the authors and the total number of books borrowed --
SELECT b.authorname,COUNT(bl.bookid)AS totalbooksbowored FROM books b 
JOIN book_loans bl ON b.bookid = bl.bookid 
GROUP BY b.authorname ORDER BY totalbooksbowored DESC;

-- 2.list all books titles ans their corresponding publishers --
SELECT b.title,p.publishername FROM books b 
LEFT JOIN publishers p ON b.PublisherName = p.PublisherName 
ORDER BY p.publishername ASC;

-- 3.how many books has each author written --
SELECT AuthorName,COUNT(BookID)AS totalbooks FROM books 
GROUP BY AuthorName;

-- 4.Find the book that has been borrowed the most times --
SELECT b.Title FROM book_loans bl
JOIN books b ON bl.BookID = b.BookID
GROUP BY b.Title ORDER BY COUNT(*) DESC LIMIT 1;

-- 5.how many books were boorowed in the month of march 2024 --
SELECT count(*)as totalbooks FROM book_loans 
WHERE dateout BETWEEN '2024-03-01' AND '2024-03-31';

-- 6.list the borrower details who don't return the book yet --
SELECT * FROM borrower b JOIN book_loans bl
ON b.CardNo = bl.CardNo WHERE DueDate IS NULL;

-- 7.Find the number of books borrowed by each borrower --
   WITH BorrowerCount AS (
     SELECT CardNo, COUNT(*)AS BookCount
     FROM book_loans
	 GROUP BY CardNo HAVING Bookcount > 2
   )
   SELECT b.BorrowerName, bc.BookCount
   FROM BorrowerCount bc
   JOIN borrower b ON bc.CardNo = b.CardNo;

-- 8.Get the publisher who has published the most books and list the books -- 
SELECT PublisherName ,GROUP_CONCAT(title 
ORDER BY PublisherName SEPARATOR ', ') AS Bookslist
FROM books GROUP BY PublisherName
ORDER BY COUNT(*) DESC LIMIT 1;

-- 9.Find the borrowers who have borrowed books from more than 2 branches --
SELECT CardNo FROM book_loans GROUP BY CardNo HAVING Count(BranchID) > 2;

-- 10.Retrieve the borrower who has borrowed the most books --
   WITH borrowerBookCount AS (
     SELECT cardNo, COUNT(*) AS borrowedbooks
     FROM book_loans
     GROUP BY CardNo
   )
   SELECT b.borrowerName, bc.BorrowedBooks
   FROM borrowerbookcount bc
   JOIN borrower b ON bc.CardNo = b.CardNo
   ORDER BY  borrowedbooks DESC
   LIMIT 1;

-- 11.Find the library branch with the most number of books available --
SELECT BranchID, SUM(No_Of_Copies) AS totalCopies FROM book_copies
GROUP BY BranchID ORDER BY totalCopies DESC LIMIT 1;

-- 12.List all the publishers who have not published any books --
SELECT PublisherName FROM publishers 
WHERE PublisherName NOT IN (SELECT PublisherName FROM books );
   
-- 13.list the branches  that have loaned out more books than the average books loaned per branch --
WITH BranchLoanCounts AS (
    SELECT BranchID, count(LoansID)AS LoanCount
    FROM book_loans
    GROUP BY BranchID
),
AvgLoanCount as (
    SELECT AVG(LoanCount)AS avgLoans
    FROM BranchLoanCounts
)
SELECT lb.BranchName, bc.LoanCount
FROM BranchLoanCounts bc
JOIN library_branch lb ON bc.BranchID = lb.BranchID
JOIN AvgLoanCount alc ON bc.LoanCount > alc.avgLoans;


-- 14.Retrieve the book ID, title, and number of copies for all books located at branch ID 4 --
SELECT b.BookID, b.Title, bc.No_Of_Copies
FROM books b
JOIN book_copies bc ON b.BookID = bc.BookID
WHERE bc.BranchID = 5 ORDER BY No_Of_Copies DESC;

-- 15.List the names of all borrowers and the number of books they have currently borrowed --
SELECT b.BorrowerName,b.CardNo, COUNT(bl.BookID) AS NoofBookBorrower
FROM borrower b
LEFT JOIN book_loans bl ON b.CardNo = bl.CardNo
WHERE bl.DueDate IS NULL
GROUP BY b.BorrowerName,b.CardNo HAVING NoofBookBorrower >  1;


-- 16.Retrieve the names of all library branches and the total number of books available at each branch --
SELECT lb.BranchName, SUM(bc.No_Of_Copies) AS TotalBooks
FROM library_branch lb
LEFT JOIN book_copies bc ON lb.BranchID = bc.BranchID
GROUP BY lb.BranchName;

-- 17.Find all books that have no copies available at any branch --
SELECT b.Title,GROUP_CONCAT(bl.BranchName SEPARATOR '  -  ')AS total_branchs -- (branches dont have copies of bookes)
FROM books AS b
LEFT JOIN book_copies bc ON b.BookID = bc.BookID 
JOIN library_branch bl ON bl.BranchID = bc.BranchID
WHERE bc.No_Of_Copies IS NULL GROUP BY b.Title;

-- 18.Retrieve the names of borrowers who have borrowed a book published by "William Shakespeare" --
SELECT br.BorrowerName
FROM borrower AS br
JOIN book_loans bl ON br.CardNo = bl.CardNo
JOIN books b ON bl.BookID = b.BookID
WHERE b.AuthorName = "William Shakespeare";


