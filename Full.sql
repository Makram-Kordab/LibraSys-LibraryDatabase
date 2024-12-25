-- SQL Schema for Library Database
drop database c5;
CREATE DATABASE c5;
USE c5;

-- Author Table
CREATE TABLE Author (
    AuthorID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    BirthDate DATE,
    Nationality VARCHAR(50)
);

-- Publisher Table
CREATE TABLE Publisher (
    PublisherID INT PRIMARY KEY,
    PublisherName VARCHAR(100) NOT NULL,
    Address_Street VARCHAR(100),
    Address_City VARCHAR(50),
    Address_State VARCHAR(50),
    Address_ZipCode VARCHAR(10),
    Phone VARCHAR(15),
    Email VARCHAR(100)
);

-- Book Table
CREATE TABLE Book (
    BookID INT PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    ISBN VARCHAR(20) UNIQUE NOT NULL,
    Genre VARCHAR(50),
    PublicationYear INT,
    CopiesAvailable INT DEFAULT 0,
    AuthorID INT NOT NULL,
    PublisherID INT NOT NULL,
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID),
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID)
);

-- Member Table
CREATE TABLE Member (
    MemberID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    MembershipDate DATE NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(15),
    Address_Street VARCHAR(100),
    Address_City VARCHAR(50),
    Address_State VARCHAR(50),
    Address_ZipCode VARCHAR(10)
);

-- Employee Table (Parent Table for ISA Hierarchy)
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    EmploymentDate DATE NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(15),
    Salary DECIMAL(10, 2) NOT NULL
);

-- Librarian Table (Specialized from Employee)
CREATE TABLE Librarian (
    EmployeeID INT PRIMARY KEY,
    Specialization VARCHAR(100),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Archivist Table (Specialized from Employee)
CREATE TABLE Archivist (
    EmployeeID INT PRIMARY KEY,
    ArchivalType VARCHAR(50),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Janitor Table (Specialized from Employee)
CREATE TABLE Janitor (
    EmployeeID INT PRIMARY KEY,
    EquipmentAssigned VARCHAR(100),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Loan Table
CREATE TABLE Loan (
    LoanID INT PRIMARY KEY,
    LoanDate DATE NOT NULL,
    ReturnDate DATE,
    LoanStatus VARCHAR(20) NOT NULL CHECK (LoanStatus IN ('Active', 'Returned', 'Overdue')),
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    FOREIGN KEY (BookID) REFERENCES Book(BookID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
);

-- Fine Table (Weak Entity)
CREATE TABLE Fine (
    LoanID INT PRIMARY KEY,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount >= 0),
    FOREIGN KEY (LoanID) REFERENCES Loan(LoanID)
);

-- Library Floor Table
CREATE TABLE LibraryFloor (
    FloorID INT PRIMARY KEY,
    FloorName VARCHAR(50),
    Location VARCHAR(100)
);

-- Book Copy Table (Weak Entity)
CREATE TABLE BookCopy (
    CopyID INT PRIMARY KEY,
    Barcode VARCHAR(50) UNIQUE NOT NULL,
    BookID INT NOT NULL,
    FOREIGN KEY (BookID) REFERENCES Book(BookID)
);

-- Private Study Room Table
CREATE TABLE PrivateStudyRoom (
    RoomID INT PRIMARY KEY,
    RoomNumber VARCHAR(10),
    Capacity INT CHECK (Capacity > 0),
    AvailabilityStatus VARCHAR(20) CHECK (AvailabilityStatus IN ('Available', 'Occupied', 'Reserved')),
    ReservationsCount INT DEFAULT 0
);

-- Reservation Table
CREATE TABLE Reservation (
    ReservationID INT PRIMARY KEY,
    ReservationDate DATE NOT NULL,
    ExpirationDate DATE NOT NULL,
    MemberID INT NOT NULL,
    BookID INT,
    CopyID INT,
    RoomID INT,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (BookID) REFERENCES Book(BookID),
    FOREIGN KEY (CopyID) REFERENCES BookCopy(CopyID),
    FOREIGN KEY (RoomID) REFERENCES PrivateStudyRoom(RoomID)
);

-- Review Table
CREATE TABLE Review (
    ReviewID INT PRIMARY KEY,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments TEXT,
    ReviewDate DATE NOT NULL,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    FOREIGN KEY (BookID) REFERENCES Book(BookID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
);

-- Supplier Table
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    Address_Street VARCHAR(100),
    Address_City VARCHAR(50),
    Address_State VARCHAR(50),
    Address_ZipCode VARCHAR(10)
);

-- libOrder Table
CREATE TABLE libOrder (
    libOrderID INT PRIMARY KEY,
    libOrderDate DATE NOT NULL,
    ExpectedDeliveryDate DATE,
    OrderStatus VARCHAR(20) NOT NULL CHECK (OrderStatus IN ('Pending', 'Delivered', 'Canceled')),
    TotalCost DECIMAL(10, 2) NOT NULL CHECK (TotalCost >= 0)
);

-- Recording Table
CREATE TABLE Recording (
    RecordingID INT PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    RecodingType VARCHAR(50) NOT NULL,
    ArchivalDate DATE NOT NULL
);

-- Cleans Relationship Table
CREATE TABLE Cleans (
    EmployeeID INT,
    FloorID INT,
    PRIMARY KEY (EmployeeID, FloorID),
    FOREIGN KEY (EmployeeID) REFERENCES Janitor(EmployeeID),
    FOREIGN KEY (FloorID) REFERENCES LibraryFloor(FloorID)
);

-- Works On Relationship Table (Librarian-Library Floor)
CREATE TABLE WorksOn (
    EmployeeID INT,
    FloorID INT,
    PRIMARY KEY (EmployeeID, FloorID),
    FOREIGN KEY (EmployeeID) REFERENCES Librarian(EmployeeID),
    FOREIGN KEY (FloorID) REFERENCES LibraryFloor(FloorID)
);

-- Contains Relationship Table (Library Floor - Book Copy)
CREATE TABLE Contain (
    FloorID INT,
    BookID INT,
    CopyID INT,
    PRIMARY KEY (FloorID, BookID, CopyID),
    FOREIGN KEY (FloorID) REFERENCES LibraryFloor(FloorID),
    FOREIGN KEY (BookID) REFERENCES Book(BookID),
    FOREIGN KEY (CopyID) REFERENCES BookCopy(CopyID)
);

-- Supplies Relationship Table (Supplier-libOrder-Book)
CREATE TABLE Supplies (
    SupplierID INT,
    libOrderID INT,
    BookID INT,
    PRIMARY KEY (SupplierID, libOrderID, BookID),
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    FOREIGN KEY (libOrderID) REFERENCES libOrder(libOrderID),
    FOREIGN KEY (BookID) REFERENCES Book(BookID)
);

-- Monitors Aggregation Relationship Table
CREATE TABLE Monitors (
    LoanID INT,
    MemberID INT,
    EmployeeID INT,
    MonitoringDate DATE NOT NULL,
    ActionTaken VARCHAR(100),
    Remarks TEXT,
    PRIMARY KEY (LoanID, MemberID, EmployeeID),
    FOREIGN KEY (LoanID) REFERENCES Loan(LoanID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (EmployeeID) REFERENCES Librarian(EmployeeID)
);


-- Author Table
INSERT INTO Author (AuthorID, FirstName, LastName, BirthDate, Nationality) 
VALUES 
(1, 'George', 'Orwell', '1903-06-25', 'British'),
(2, 'J.K.', 'Rowling', '1965-07-31', 'British'),
(3, 'Harper', 'Lee', '1926-04-28', 'American'),
(4, 'Jane', 'Austen', '1775-12-16', 'British'),
(5, 'Mark', 'Twain', '1835-11-30', 'American'),
(6, 'Ernest', 'Hemingway', '1899-07-21', 'American'),
(7, 'F. Scott', 'Fitzgerald', '1896-09-24', 'American'),
(8, 'Leo', 'Tolstoy', '1828-09-09', 'Russian'),
(9, 'Gabriel', 'Garcia Marquez', '1927-03-06', 'Colombian'),
(10, 'Toni', 'Morrison', '1931-02-18', 'American'),
(11, 'Charles', 'Dickens', '1812-02-07', 'British'),
(12, 'William', 'Shakespeare', '1564-04-23', 'English'),
(13, 'Friedrich', 'Nietzsche', '1844-10-15', 'German'),
(14, 'Virginia', 'Woolf', '1882-01-25', 'British'),
(15, 'Homer', 'Platz', '1875-05-28', 'Greek'),
(16, 'Franz', 'Kafka', '1883-07-03', 'Austrian'),
(17, 'Dostoevsky', 'Fyodor', '1821-11-11', 'Russian'),
(18, 'Albert', 'Camus', '1913-11-07', 'French'),
(19, 'Haruki', 'Murakami', '1949-01-12', 'Japanese'),
(20, 'Isaac', 'Asimov', '1920-01-02', 'Russian');

-- Publisher Table
INSERT INTO Publisher (PublisherID, PublisherName, Address_Street, Address_City, Address_State, Address_ZipCode, Email, Phone)
VALUES
(1, 'Penguin Books', '123 Main St', 'New York', 'NY', '10001', 'contact@penguin.com', '555-1234'),
(2, 'HarperCollins', '456 Park Ave', 'Chicago', 'IL', '60601', 'info@harpercollins.com', '555-5678'),
(3, 'Simon & Schuster', '789 Elm St', 'Boston', 'MA', '02110', 'support@simonandschuster.com', '555-9101'),
(4, 'Random House', '101 Maple Rd', 'San Francisco', 'CA', '94110', 'contact@randomhouse.com', '555-1122'),
(5, 'Macmillan', '202 Oak Blvd', 'Dallas', 'TX', '75201', 'info@macmillan.com', '555-3344'),
(6, 'Hachette', '303 Pine St', 'Los Angeles', 'CA', '90001', 'support@hachette.com', '555-5566'),
(7, 'Oxford University Press', '404 Cedar Ave', 'Oxford', 'UK', 'OX1 1DP', 'contact@oup.com', '555-7788'),
(8, 'Cambridge University Press', '505 Birch Rd', 'Cambridge', 'UK', 'CB2 1TN', 'info@cup.com', '555-9900'),
(9, 'Bloomsbury', '606 Chestnut St', 'London', 'UK', 'WC1B 3DP', 'support@bloomsbury.com', '555-2233'),
(10, 'Wiley', '707 Walnut Dr', 'Boston', 'MA', '02111', 'contact@wiley.com', '555-4455'),
(11, 'Pearson Education', '808 Pine Ln', 'New York', 'NY', '10002', 'info@pearson.com', '555-6677'),
(12, 'Scholastic', '909 Maple St', 'Chicago', 'IL', '60602', 'support@scholastic.com', '555-8899'),
(13, 'MIT Press', '1010 Birch Ave', 'Cambridge', 'MA', '02139', 'contact@mitpress.com', '555-2234'),
(14, 'Routledge', '1111 Oak St', 'London', 'UK', 'WC2E 7BT', 'info@routledge.com', '555-5567'),
(15, 'Kogan Page', '1212 Maple Dr', 'New York', 'NY', '10003', 'support@koganpage.com', '555-3345'),
(16, 'University of California Press', '1313 Chestnut Rd', 'Berkeley', 'CA', '94704', 'contact@ucpress.com', '555-7789'),
(17, 'Springer', '1414 Cedar Ave', 'Berlin', 'Germany', '10117', 'info@springer.com', '555-2235'),
(18, 'Taylor & Francis', '1515 Walnut Rd', 'London', 'UK', 'WC1X 8HB', 'support@taylorandfrancis.com', '555-4466'),
(19, 'St. Martin’s Press', '1616 Elm Blvd', 'New York', 'NY', '10004', 'contact@stmartins.com', '555-6678'),
(20, 'University of Chicago Press', '1717 Pine Blvd', 'Chicago', 'IL', '60603', 'info@uchicago.com', '555-8898');


-- book table
INSERT INTO Book (BookID, Title, ISBN, Genre, PublicationYear, CopiesAvailable, AuthorID, PublisherID) 
VALUES 
(1, '1984', '9780451524935', 'Dystopian', 1949, 10, 1, 1),
(2, 'Harry Potter and the Sorcerer\'s Stone', '9780747532699', 'Fantasy', 1997, 12, 2, 2),
(3, 'To Kill a Mockingbird', '9780061120084', 'Southern Gothic', 1960, 8, 3, 3),
(4, 'Pride and Prejudice', '9781503290563', 'Romantic Fiction', 1813, 5, 4, 4),
(5, 'The Adventures of Huckleberry Finn', '9780486280615', 'Adventure', 1884, 7, 5, 5),
(6, 'The Old Man and the Sea', '9780684830490', 'Literary Fiction', 1952, 6, 6, 6),
(7, 'The Great Gatsby', '9780743273565', 'Tragedy', 1925, 4, 7, 7),
(8, 'War and Peace', '9781400079988', 'Historical Fiction', 1869, 3, 8, 8),
(9, 'One Hundred Years of Solitude', '9780060883287', 'Magical Realism', 1967, 5, 9, 9),
(10, 'Beloved', '9781400033416', 'Historical Fiction', 1987, 6, 10, 10),
(11, 'A Tale of Two Cities', '9780141439600', 'Historical Fiction', 1859, 7, 11, 11),
(12, 'Hamlet', '9780140620840', 'Tragedy', 1600, 2, 12, 12),
(13, 'Thus Spoke Zarathustra', '9780140441185', 'Philosophy', 1883, 4, 13, 13),
(14, 'Mrs. Dalloway', '9780156628709', 'Modernist Fiction', 1925, 5, 14, 14),
(15, 'The Iliad', '9780140275360', 'Epic Poetry', 1850, 3, 15, 15),
(16, 'The Trial', '9780805209990', 'Absurdist Fiction', 1914, 4, 16, 16),
(17, 'Crime and Punishment', '9780143058144', 'Psychological Fiction', 1866, 9, 17, 17),
(18, 'The Stranger', '9780679720201', 'Existentialism', 1942, 6, 18, 18),
(19, 'Norwegian Wood', '9780099491751', 'Contemporary Fiction', 1987, 8, 19, 19),
(20, 'I, Robot', '9780553382563', 'Science Fiction', 1950, 10, 20, 20);


-- Member Table
INSERT INTO Member (MemberID, FirstName, LastName, MembershipDate, Email, Phone, Address_Street, Address_City, Address_State, Address_ZipCode) 
VALUES 
(1, 'Alice', 'Johnson', '2023-01-01', 'alice.johnson@example.com', '555-1234', '123 Oak St', 'Springfield', 'IL', '62701'),
(2, 'Bob', 'Smith', '2023-02-15', 'bob.smith@example.com', '555-2345', '456 Maple Ave', 'Greenwood', 'IN', '46142'),
(3, 'Charlie', 'Davis', '2023-03-10', 'charlie.davis@example.com', '555-3456', '789 Pine Rd', 'Riverside', 'CA', '92501'),
(4, 'David', 'Martinez', '2023-04-20', 'david.martinez@example.com', '555-4567', '101 Birch Blvd', 'Hometown', 'TX', '75001'),
(5, 'Eva', 'Taylor', '2023-05-15', 'eva.taylor@example.com', '555-5678', '202 Cedar Ln', 'Lakeside', 'FL', '33101'),
(6, 'Frank', 'Anderson', '2023-06-01', 'frank.anderson@example.com', '555-6789', '303 Elm Dr', 'Hilltop', 'OH', '44101'),
(7, 'Grace', 'Thomas', '2023-07-10', 'grace.thomas@example.com', '555-7890', '404 Maple Blvd', 'Clearwater', 'FL', '33755'),
(8, 'Helen', 'White', '2023-08-22', 'helen.white@example.com', '555-8901', '505 Birch Ave', 'Mountainview', 'CO', '80123'),
(9, 'Ian', 'Moore', '2023-09-01', 'ian.moore@example.com', '555-9012', '606 Oak Dr', 'Valleyview', 'CA', '94001'),
(10, 'Jack', 'Jackson', '2023-10-18', 'jack.jackson@example.com', '555-0123', '707 Pine St', 'Brooklyn', 'NY', '11201'),
(11, 'Kathy', 'Lee', '2023-11-25', 'kathy.lee@example.com', '555-1235', '808 Cedar Blvd', 'Sunnydale', 'CA', '90001'),
(12, 'Liam', 'Harris', '2023-12-05', 'liam.harris@example.com', '555-2346', '909 Oak Ln', 'Foxborough', 'MA', '02035'),
(13, 'Mona', 'Clark', '2023-01-15', 'mona.clark@example.com', '555-3457', '101 Pine Ave', 'Windsor', 'WI', '53598'),
(14, 'Nathan', 'Lewis', '2023-02-22', 'nathan.lewis@example.com', '555-4568', '202 Birch Rd', 'Harrisburg', 'PA', '17101'),
(15, 'Olivia', 'Walker', '2023-03-05', 'olivia.walker@example.com', '555-5679', '303 Maple Dr', 'Newton', 'MA', '02458'),
(16, 'Paul', 'Young', '2023-04-18', 'paul.young@example.com', '555-6780', '404 Oak Blvd', 'Chicago', 'IL', '60601'),
(17, 'Quincy', 'Scott', '2023-05-25', 'quincy.scott@example.com', '555-7891', '505 Elm St', 'Dayton', 'OH', '45402'),
(18, 'Rachel', 'King', '2023-06-10', 'rachel.king@example.com', '555-8902', '606 Cedar Dr', 'Austin', 'TX', '73301'),
(19, 'Sam', 'Adams', '2023-07-01', 'sam.adams@example.com', '555-9013', '707 Elm Ave', 'Detroit', 'MI', '48201'),
(20, 'Tina', 'Baker', '2023-08-05', 'tina.baker@example.com', '555-0124', '808 Oak Blvd', 'Seattle', 'WA', '98101');

-- Employee Table
INSERT INTO Employee (EmployeeID, FirstName, LastName, EmploymentDate, Email, Phone, Salary)
VALUES
(1, 'John', 'Doe', '2015-06-15', 'jdoe@company.com', '555-1010', 50000.00),
(2, 'Jane', 'Smith', '2018-09-20', 'jsmith@company.com', '555-1020', 60000.00),
(3, 'Michael', 'Johnson', '2020-01-10', 'mjohnson@company.com', '555-1030', 55000.00),
(4, 'Sarah', 'Brown', '2017-03-25', 'sbrown@company.com', '555-1040', 65000.00),
(5, 'David', 'Williams', '2016-11-30', 'dwilliams@company.com', '555-1050', 70000.00),
(6, 'Emily', 'Jones', '2019-07-14', 'ejones@company.com', '555-1060', 48000.00),
(7, 'Christopher', 'Miller', '2021-05-06', 'cmiller@company.com', '555-1070', 52000.00),
(8, 'Jessica', 'Davis', '2022-03-11', 'jdavis@company.com', '555-1080', 47000.00),
(9, 'James', 'Garcia', '2020-08-18', 'jgarcia@company.com', '555-1090', 56000.00),
(10, 'Karen', 'Martinez', '2014-12-05', 'kmartinez@company.com', '555-1100', 75000.00),
(11, 'Matthew', 'Rodriguez', '2021-02-14', 'mrodriguez@company.com', '555-1110', 48000.00),
(12, 'Laura', 'Wilson', '2018-10-25', 'lwilson@company.com', '555-1120', 53000.00),
(13, 'Robert', 'Moore', '2022-06-30', 'rmoore@company.com', '555-1130', 49000.00),
(14, 'Daniel', 'Taylor', '2017-04-22', 'dtaylor@company.com', '555-1140', 62000.00),
(15, 'Nancy', 'Hernandez', '2020-11-01', 'nhernandez@company.com', '555-1150', 55000.00),
(16, 'Joseph', 'Lee', '2016-02-14', 'jlee@company.com', '555-1160', 68000.00),
(17, 'Matthew', 'Walker', '2023-03-01', 'mwalker@company.com', '555-1170', 45000.00),
(18, 'Rachel', 'Allen', '2021-07-20', 'rallen@company.com', '555-1180', 54000.00),
(19, 'Sophia', 'Young', '2019-12-19', 'syoung@company.com', '555-1190', 51000.00),
(20, 'Ethan', 'King', '2022-04-10', 'eking@company.com', '555-1200', 53000.00),
(21, 'Olivia', 'Scott', '2015-06-09', 'oscott@company.com', '555-1210', 66000.00),
(22, 'Lucas', 'Adams', '2019-01-21', 'ladams@company.com', '555-1220', 55000.00),
(23, 'Megan', 'Carter', '2018-11-15', 'mcarter@company.com', '555-1230', 60000.00),
(24, 'James', 'Baker', '2022-08-25', 'jbaker@company.com', '555-1240', 52000.00),
(25, 'Lily', 'Gonzalez', '2021-01-10', 'lgonzalez@company.com', '555-1250', 54000.00),
(26, 'Ethan', 'Nelson', '2016-12-19', 'enelson@company.com', '555-1260', 62000.00),
(27, 'Samuel', 'Mitchell', '2020-10-30', 'smitchell@company.com', '555-1270', 48000.00),
(28, 'Ella', 'Perez', '2021-11-05', 'eperez@company.com', '555-1280', 46000.00),
(29, 'Harper', 'Roberts', '2015-04-13', 'hroberts@company.com', '555-1290', 70000.00),
(30, 'Jack', 'Harris', '2022-09-12', 'jharris@company.com', '555-1300', 48000.00),
(31, 'Ava', 'Davis', '2020-06-22', 'adavis@company.com', '555-1310', 51000.00),
(32, 'Mason', 'Martinez', '2017-01-14', 'mmartinez@company.com', '555-1320', 63000.00),
(33, 'Grace', 'Rodriguez', '2021-04-18', 'grodriguez@company.com', '555-1330', 46000.00),
(34, 'Leo', 'Gonzalez', '2023-02-22', 'lgonzalez@company.com', '555-1340', 52000.00),
(35, 'Charlotte', 'Taylor', '2022-07-10', 'ctaylor@company.com', '555-1350', 47000.00),
(36, 'Benjamin', 'Moore', '2021-06-17', 'bmoore@company.com', '555-1360', 54000.00),
(37, 'Amelia', 'Walker', '2018-02-02', 'awalker@company.com', '555-1370', 65000.00),
(38, 'Henry', 'Wilson', '2020-03-13', 'hwilson@company.com', '555-1380', 58000.00),
(39, 'Lucas', 'Johnson', '2023-01-18', 'ljohnson@company.com', '555-1390', 55000.00),
(40, 'Chloe', 'Allen', '2022-05-03', 'callen@company.com', '555-1400', 51000.00),
(41, 'Jack', 'Thompson', '2021-08-10', 'jthompson@company.com', '555-1410', 46000.00),
(42, 'Mason', 'Scott', '2020-02-22', 'mscott@company.com', '555-1420', 53000.00),
(43, 'Ava', 'Taylor', '2021-12-01', 'ataylor@company.com', '555-1430', 49000.00),
(44, 'David', 'Roberts', '2023-06-14', 'droberts@company.com', '555-1440', 52000.00),
(45, 'Harper', 'Davis', '2020-07-09', 'hdavis@company.com', '555-1450', 55000.00),
(46, 'Sophia', 'Harris', '2021-09-28', 'sharris@company.com', '555-1460', 50000.00),
(47, 'Isabella', 'Green', '2022-10-11', 'igreen@company.com', '555-1470', 47000.00),
(48, 'Daniel', 'Young', '2023-01-15', 'dyoung@company.com', '555-1480', 49000.00),
(49, 'Emily', 'Miller', '2020-04-06', 'emiller@company.com', '555-1490', 52000.00),
(50, 'Oliver', 'Adams', '2017-02-01', 'oadams@company.com', '555-1500', 63000.00),
(51, 'James', 'Baker', '2019-11-11', 'jbaker@company.com', '555-1510', 57000.00),
(52, 'Harper', 'Nelson', '2023-03-05', 'hnelson@company.com', '555-1520', 51000.00),
(53, 'Charlotte', 'King', '2022-12-20', 'cking@company.com', '555-1530', 48000.00),
(54, 'Benjamin', 'Harris', '2021-07-18', 'bharris@company.com', '555-1540', 50000.00),
(55, 'Amelia', 'Thompson', '2020-09-05', 'athompson@company.com', '555-1550', 55000.00),
(56, 'Ethan', 'Roberts', '2022-05-29', 'eroberts@company.com', '555-1560', 53000.00),
(57, 'Sophia', 'Adams', '2019-03-15', 'sadams@company.com', '555-1570', 59000.00),
(58, 'Lucas', 'Miller', '2021-10-13', 'lmiller@company.com', '555-1580', 52000.00),
(59, 'Isabella', 'Taylor', '2020-08-30', 'itaylor@company.com', '555-1590', 47000.00),
(60, 'Lily', 'Roberts', '2021-03-23', 'lroberts@company.com', '555-1600', 54000.00);

-- Librarian Table (20 Librarians)
INSERT INTO Librarian (EmployeeID, Specialization)
VALUES
(1, 'Public Library Management'),
(2, 'Children’s Literature'),
(3, 'Reference Services'),
(4, 'Digital Archives'),
(5, 'Library Technology'),
(6, 'Customer Services'),
(7, 'Cataloging and Classification'),
(8, 'Rare Books'),
(9, 'Library Outreach'),
(10, 'Academic Libraries'),
(11, 'Special Collections'),
(12, 'Public Relations'),
(13, 'Library Instruction'),
(14, 'Government Libraries'),
(15, 'Library Systems'),
(16, 'Information Literacy'),
(17, 'User Experience'),
(18, 'Information Technology'),
(19, 'Medical Libraries'),
(20, 'Librarian Development');

INSERT INTO Archivist (EmployeeID, ArchivalType)
VALUES
(21, 'Photographs'),
(22, 'Manuscripts'),
(23, 'Government Records'),
(24, 'Audio Archives'),
(25, 'Video Archives'),
(26, 'Museum Collections'),
(27, 'Cultural Heritage'),
(28, 'Corporate Records'),
(29, 'Historical Documents'),
(30, 'Legal Records'),
(31, 'Art Collections'),
(32, 'Newspaper Collections'),
(33, 'Digital Archives'),
(34, 'Medical Archives'),
(35, 'University Records'),
(36, 'Architectural Archives'),
(37, 'Genealogical Records'),
(38, 'Private Collections'),
(39, 'Print Media'),
(40, 'Personal Collections');


-- Janitor Table (20 Janitors)
INSERT INTO Janitor (EmployeeID, EquipmentAssigned)
VALUES
(41, 'Floor Scrubber'),
(42, 'Vacuum Cleaner'),
(43, 'Trash Compactor'),
(44, 'Cleaning Supplies'),
(45, 'Window Cleaning Equipment'),
(46, 'Carpet Shampooer'),
(47, 'Restroom Cleaning Kit'),
(48, 'Trash Bin Liners'),
(49, 'Floor Polisher'),
(50, 'Mop and Bucket'),
(51, 'Pressure Washer'),
(52, 'Sanitization Equipment'),
(53, 'Disinfectant Sprayers'),
(54, 'Waste Collection Trolley'),
(55, 'Chemical Cleaning Agents'),
(56, 'Gloves and Safety Gear'),
(57, 'Cleaning Cart'),
(58, 'Dusting Tools'),
(59, 'Broom and Dustpan'),
(60, 'Floor Mopping Tools');


-- Loan Table (20 Entries)
INSERT INTO Loan (LoanID, LoanDate, ReturnDate, LoanStatus, BookID, MemberID)
VALUES
(1, '2023-01-05', '2023-01-19', 'Returned', 1, 1),
(2, '2023-01-15', '2023-01-30', 'Returned', 2, 2),
(3, '2023-02-01', '2023-02-15', 'Overdue', 3, 3),
(4, '2023-02-10', '2023-02-24', 'Returned', 4, 4),
(5, '2023-03-05', NULL, 'Active', 5, 5),
(6, '2023-03-15', NULL, 'Active', 6, 6),
(7, '2023-04-01', '2023-04-15', 'Returned', 7, 7),
(8, '2023-04-10', '2023-04-24', 'Overdue', 8, 8),
(9, '2023-05-01', '2023-05-15', 'Returned', 9, 9),
(10, '2023-05-10', NULL, 'Active', 10, 10),
(11, '2023-05-12', '2023-05-26', 'Returned', 11, 11),
(12, '2023-06-01', NULL, 'Active', 12, 12),
(13, '2023-06-15', '2023-06-29', 'Returned', 13, 13),
(14, '2023-06-18', '2023-07-02', 'Returned', 14, 14),
(15, '2023-07-01', '2023-07-15', 'Returned', 15, 15),
(16, '2023-07-05', '2023-07-19', 'Returned', 16, 16),
(17, '2023-07-10', NULL, 'Active', 17, 17),
(18, '2023-08-01', '2023-08-15', 'Returned', 18, 18),
(19, '2023-08-05', NULL, 'Active', 19, 19),
(20, '2023-08-10', '2023-08-24', 'Returned', 20, 20);

-- Fine Table
INSERT INTO Fine (LoanID, Amount)
VALUES
(3, 15.00),
(8, 25.00),
(6, 10.00),
(5, 20.00),
(1, 0.00),
(2, 0.00),
(4, 0.00),
(7, 0.00),
(9, 0.00),
(10, 18.00),
(11, 0.00),
(12, 5.00),
(13, 0.00),
(14, 0.00),
(15, 0.00),
(16, 0.00),
(17, 22.00),
(18, 0.00),
(19, 20.00),
(20, 0.00);

-- Library Floor Table
INSERT INTO LibraryFloor (FloorID, FloorName, Location)
VALUES
(1, 'Ground Floor', 'Main Entrance'),
(2, 'First Floor', 'Children\'s Section'),
(3, 'Second Floor', 'Fiction Section'),
(4, 'Third Floor', 'Reference Section'),
(5, 'Fourth Floor', 'Rare Books'),
(6, 'Basement', 'Archives'),
(7, 'Fifth Floor', 'Study Rooms'),
(8, 'Sixth Floor', 'Technology Lab'),
(9, 'Rooftop', 'Garden Area'),
(10, 'Lobby', 'Cafe and Information Desk'),
(11, 'Seventh Floor', 'Meeting Rooms'),
(12, 'Eighth Floor', 'Staff Offices'),
(13, 'Ninth Floor', 'Conference Hall'),
(14, 'Tenth Floor', 'Event Space'),
(15, 'Eleventh Floor', 'Art Gallery'),
(16, 'Twelfth Floor', 'Audio-Visual Room'),
(17, 'Thirteenth Floor', 'Science and Technology Section'),
(18, 'Fourteenth Floor', 'Literature and Arts Section'),
(19, 'Fifteenth Floor', 'Business and Economics Section'),
(20, 'Sixteenth Floor', 'History and Politics Section');

-- BookCopy Table
INSERT INTO BookCopy (CopyID, Barcode, BookID)
VALUES
(1, 'BC123456', 1),
(2, 'BC123457', 1),
(3, 'BC123458', 2),
(4, 'BC123459', 2),
(5, 'BC123460', 3),
(6, 'BC123461', 4),
(7, 'BC123462', 5),
(8, 'BC123463', 6),
(9, 'BC123464', 7),
(10, 'BC123465', 8),
(11, 'BC123466', 9),
(12, 'BC123467', 9),
(13, 'BC123468', 10),
(14, 'BC123469', 10),
(15, 'BC123470', 11),
(16, 'BC123471', 12),
(17, 'BC123472', 13),
(18, 'BC123473', 14),
(19, 'BC123474', 15),
(20, 'BC123475', 16);

-- PrivateStudyRoom Table
INSERT INTO PrivateStudyRoom (RoomID, RoomNumber, Capacity, AvailabilityStatus, ReservationsCount)
VALUES
(1, 'A101', 4, 'Available', 0),
(2, 'A102', 2, 'Reserved', 3),
(3, 'A103', 6, 'Available', 1),
(4, 'B201', 8, 'Reserved', 5),
(5, 'B202', 3, 'Available', 0),
(6, 'B203', 5, 'Reserved', 2),
(7, 'C301', 4, 'Available', 1),
(8, 'C302', 7, 'Available', 0),
(9, 'C303', 10, 'Reserved', 4),
(10, 'D401', 12, 'Available', 0),
(11, 'D402', 5, 'Reserved', 3),
(12, 'E501', 6, 'Available', 0),
(13, 'E502', 4, 'Reserved', 2),
(14, 'F601', 3, 'Available', 1),
(15, 'F602', 8, 'Reserved', 4),
(16, 'G701', 7, 'Available', 0),
(17, 'G702', 10, 'Reserved', 6),
(18, 'H801', 2, 'Available', 0),
(19, 'H802', 5, 'Reserved', 3),
(20, 'I901', 12, 'Available', 1);

-- Reservation Table
INSERT INTO Reservation (ReservationID, ReservationDate, ExpirationDate, MemberID, BookID, CopyID, RoomID)
VALUES
-- Reservations for BookCopy (RoomID is NULL)
(1, '2023-06-01', '2023-06-15', 1, 1, 1, NULL),
(2, '2023-06-05', '2023-06-20', 2, 2, 3, NULL),
(3, '2023-06-10', '2023-06-25', 3, 3, 5, NULL),
(4, '2023-06-15', '2023-06-30', 4, 4, 6, NULL),
(5, '2023-06-20', '2023-07-05', 5, 5, 7, NULL),
-- Reservations for Private Study Room (BookID and CopyID are NULL)
(6, '2023-06-01', '2023-06-10', 6, NULL, NULL, 1),
(7, '2023-06-05', '2023-06-15', 7, NULL, NULL, 3),
(8, '2023-06-10', '2023-06-20', 8, NULL, NULL, 4),
(9, '2023-06-12', '2023-06-22', 9, NULL, NULL, 6),
(10, '2023-06-18', '2023-06-28', 10, NULL, NULL, 8),
-- More Reservations for BookCopy
(11, '2023-06-20', '2023-07-05', 11, 6, 8, NULL),
(12, '2023-06-25', '2023-07-10', 12, 7, 9, NULL),
(13, '2023-07-01', '2023-07-15', 13, 8, 10, NULL),
(14, '2023-07-05', '2023-07-20', 14, 9, 11, NULL),
(15, '2023-07-10', '2023-07-25', 15, 10, 12, NULL),
-- More Reservations for Private Study Room
(16, '2023-07-01', '2023-07-10', 16, NULL, NULL, 2),
(17, '2023-07-05', '2023-07-15', 17, NULL, NULL, 5),
(18, '2023-07-10', '2023-07-20', 18, NULL, NULL, 7),
(19, '2023-07-15', '2023-07-25', 19, NULL, NULL, 9),
(20, '2023-07-20', '2023-07-30', 20, NULL, NULL, 10),
(21, '2023-07-20', '2023-07-30', 1, NULL, NULL, 5);


-- Review Table
INSERT INTO Review (ReviewID, Rating, Comments, ReviewDate, BookID, MemberID)
VALUES
(1, 5, 'An excellent read!', '2023-08-01', 1, 1),
(2, 4, 'Very informative.', '2023-08-05', 2, 2),
(3, 3, 'Not as good as expected.', '2023-08-10', 3, 3),
(4, 4, 'Well-written and engaging.', '2023-08-15', 4, 4),
(5, 5, 'A masterpiece!', '2023-08-20', 5, 5),
(6, 2, 'Found it a bit boring.', '2023-08-25', 6, 6),
(7, 4, 'Great book for young adults.', '2023-08-30', 7, 7),
(8, 5, 'Highly recommended!', '2023-09-01', 8, 8),
(9, 1, 'Not worth reading.', '2023-09-05', 9, 9),
(10, 3, 'Good but not great.', '2023-09-10', 10, 10),
(11, 5, 'Loved every page!', '2023-09-12', 11, 11),
(12, 4, 'A bit slow at the start, but worth it.', '2023-09-14', 12, 12),
(13, 2, 'Didn\'t enjoy it much.', '2023-09-16', 13, 13),
(14, 5, 'One of the best books I\'ve read!', '2023-09-18', 14, 14),
(15, 3, 'It was okay, not very memorable.', '2023-09-20', 15, 15),
(16, 4, 'The plot was interesting, but the ending was weak.', '2023-09-22', 16, 16),
(17, 5, 'A truly amazing story!', '2023-09-24', 17, 17),
(18, 4, 'Well researched and insightful.', '2023-09-26', 18, 18),
(19, 2, 'Disappointing and predictable.', '2023-09-28', 19, 19),
(20, 3, 'It was decent but didn\'t stand out.', '2023-09-30', 20, 20);

-- Supplier Table
INSERT INTO Supplier (SupplierID, SupplierName, ContactPerson, Phone, Email, Address_Street, Address_City, Address_State, Address_ZipCode)
VALUES
(1, 'ABC Books Co.', 'Alice Green', '555-2001', 'contact@abcbooks.com', '123 Main St', 'New York', 'NY', '10001'),
(2, 'Global Publishers', 'Bob White', '555-2002', 'info@globalpublishers.com', '456 Elm St', 'Los Angeles', 'CA', '90001'),
(3, 'Pearson Distributors', 'Cathy Black', '555-2003', 'sales@pearson.com', '789 Maple St', 'Chicago', 'IL', '60601'),
(4, 'Oxford Supplies', 'David Gray', '555-2004', 'support@oxfordsupplies.com', '321 Oak St', 'Houston', 'TX', '77001'),
(5, 'McGraw-Hill Partners', 'Eva Brown', '555-2005', 'service@mcgrawhill.com', '654 Pine St', 'Phoenix', 'AZ', '85001'),
(6, 'Cambridge Distributors', 'Frank Red', '555-2006', 'info@cambridgedist.com', '987 Cedar St', 'Philadelphia', 'PA', '19101'),
(7, 'Random House Suppliers', 'Grace Blue', '555-2007', 'random@house.com', '135 Spruce St', 'San Antonio', 'TX', '78201'),
(8, 'Scholastic Source', 'Hank Yellow', '555-2008', 'support@scholastic.com', '246 Willow St', 'Dallas', 'TX', '75201'),
(9, 'HarperCollins Distributors', 'Ivy Purple', '555-2009', 'service@harpercollins.com', '369 Birch St', 'San Diego', 'CA', '92101'),
(10, 'Penguin Random House', 'Jack Orange', '555-2010', 'penguin@randomhouse.com', '975 Redwood St', 'San Francisco', 'CA', '94101'),
(11, 'Hachette Book Group', 'Kara Silver', '555-2011', 'contact@hachettebooks.com', '523 Maple St', 'Austin', 'TX', '73301'),
(12, 'Wiley Publishers', 'Liam Gray', '555-2012', 'info@wiley.com', '684 Oak St', 'Seattle', 'WA', '98101'),
(13, 'Routledge Publishers', 'Mia Red', '555-2013', 'sales@routledge.com', '192 Birch St', 'Portland', 'OR', '97201'),
(14, 'Springer Nature', 'Oliver Black', '555-2014', 'info@springernature.com', '370 Willow St', 'Boston', 'MA', '02101'),
(15, 'Elsevier', 'Peter Brown', '555-2015', 'contact@elsevier.com', '522 Cedar St', 'Chicago', 'IL', '60602'),
(16, 'Bloomsbury Publishing', 'Quincy Green', '555-2016', 'service@bloomsbury.com', '631 Oak St', 'Denver', 'CO', '80203'),
(17, 'Taylor & Francis', 'Rachel White', '555-2017', 'support@taylorandfrancis.com', '781 Pine St', 'Miami', 'FL', '33101'),
(18, 'SAGE Publications', 'Sam Blue', '555-2018', 'sales@sagepub.com', '891 Cedar St', 'San Francisco', 'CA', '94102'),
(19, 'John Wiley & Sons', 'Tina Yellow', '555-2019', 'contact@wiley.com', '345 Spruce St', 'Atlanta', 'GA', '30301'),
(20, 'MIT Press', 'Ursula Gray', '555-2020', 'info@mitpress.com', '987 Birch St', 'Cambridge', 'MA', '02139');

-- libOrder Table
INSERT INTO libOrder (libOrderID, libOrderDate, ExpectedDeliveryDate, OrderStatus, TotalCost)
VALUES
(1, '2023-01-10', '2023-01-20', 'Delivered', 500.00),
(2, '2023-02-15', '2023-02-25', 'Pending', 300.00),
(3, '2023-03-05', '2023-03-15', 'Delivered', 700.00),
(4, '2023-04-10', '2023-04-20', 'Canceled', 250.00),
(5, '2023-05-01', '2023-05-10', 'Delivered', 1000.00),
(6, '2023-06-15', '2023-06-25', 'Pending', 450.00),
(7, '2023-07-20', '2023-07-30', 'Delivered', 600.00),
(8, '2023-08-05', '2023-08-15', 'Pending', 350.00),
(9, '2023-09-10', '2023-09-20', 'Delivered', 900.00),
(10, '2023-10-01', '2023-10-10', 'Pending', 750.00),
(11, '2023-11-01', '2023-11-10', 'Delivered', 550.00),
(12, '2023-11-05', '2023-11-15', 'Pending', 600.00),
(13, '2023-12-10', '2023-12-20', 'Delivered', 800.00),
(14, '2023-12-01', '2023-12-10', 'Canceled', 400.00),
(15, '2023-12-15', '2023-12-25', 'Delivered', 650.00),
(16, '2024-01-01', '2024-01-10', 'Pending', 700.00),
(17, '2024-02-01', '2024-02-10', 'Delivered', 900.00),
(18, '2024-03-01', '2024-03-10', 'Pending', 850.00),
(19, '2024-04-01', '2024-04-10', 'Delivered', 950.00),
(20, '2024-05-01', '2024-05-10', 'Pending', 750.00);

-- Insert 20 records into Recording table
INSERT INTO Recording (RecordingID, Title, RecodingType, ArchivalDate)
VALUES
(1, 'The Great Concert', 'Audio', '2024-01-15'),
(2, 'Science Lecture 101', 'Video', '2024-02-20'),
(3, 'History Documentary', 'Video', '2024-03-05'),
(4, 'Jazz Night Live', 'Audio', '2024-04-10'),
(5, 'Art Exhibition Opening', 'Video', '2024-05-25'),
(6, 'Rock Festival Highlights', 'Audio', '2024-06-30'),
(7, 'Nature Documentary', 'Video', '2024-07-12'),
(8, 'Music of the 80s', 'Audio', '2024-08-02'),
(9, 'Shakespeare Play: Hamlet', 'Video', '2024-09-14'),
(10, 'Physics Lecture on Quantum Mechanics', 'Video', '2024-10-21'),
(11, 'Classic Movies Collection', 'Video', '2024-11-03'),
(12, 'Pop Hits of 2024', 'Audio', '2024-12-15'),
(13, 'Cultural Heritage of Egypt', 'Video', '2023-01-09'),
(14, 'Modern Art Explained', 'Video', '2023-02-13'),
(15, 'Rock Band Reunion Concert', 'Audio', '2023-03-17'),
(16, 'Classical Music Symphonies', 'Audio', '2023-04-22'),
(17, 'Wildlife Adventures', 'Video', '2023-05-30'),
(18, 'Jazz Legends of the Past', 'Audio', '2023-06-14'),
(19, 'The Story of Ancient Rome', 'Video', '2023-07-25'),
(20, 'Global Cuisine Cook-off', 'Video', '2023-08-19');

-- Insert 20 records into Cleans table (Janitors cleaning specific library floors)
INSERT INTO Cleans (EmployeeID, FloorID)
VALUES
(41, 1),   -- Janitor 41 cleans Floor 1
(42, 2),   -- Janitor 42 cleans Floor 2
(43, 3),   -- Janitor 43 cleans Floor 3
(44, 4),   -- Janitor 44 cleans Floor 4
(45, 5),   -- Janitor 45 cleans Floor 5
(46, 6),   -- Janitor 46 cleans Floor 6
(47, 7),   -- Janitor 47 cleans Floor 7
(48, 8),   -- Janitor 48 cleans Floor 8
(49, 9),   -- Janitor 49 cleans Floor 9
(50, 10),  -- Janitor 50 cleans Floor 10
(51, 1),   -- Janitor 51 cleans Floor 1
(52, 2),   -- Janitor 52 cleans Floor 2
(53, 3),   -- Janitor 53 cleans Floor 3
(54, 4),   -- Janitor 54 cleans Floor 4
(55, 5),   -- Janitor 55 cleans Floor 5
(56, 6),   -- Janitor 56 cleans Floor 6
(57, 7),   -- Janitor 57 cleans Floor 7
(58, 8),   -- Janitor 58 cleans Floor 8
(59, 9),   -- Janitor 59 cleans Floor 9
(60, 10);  -- Janitor 60 cleans Floor 10

-- Insert 20 records into WorksOn table (Librarians working on specific library floors)
INSERT INTO WorksOn (EmployeeID, FloorID)
VALUES
(1, 1),   -- Librarian 1 works on Floor 1
(2, 2),   -- Librarian 2 works on Floor 2
(3, 3),   -- Librarian 3 works on Floor 3
(4, 4),   -- Librarian 4 works on Floor 4
(5, 5),   -- Librarian 5 works on Floor 5
(6, 6),   -- Librarian 6 works on Floor 6
(7, 7),   -- Librarian 7 works on Floor 7
(8, 8),   -- Librarian 8 works on Floor 8
(9, 9),   -- Librarian 9 works on Floor 9
(10, 10), -- Librarian 10 works on Floor 10
(11, 1),  -- Librarian 11 works on Floor 1
(12, 2),  -- Librarian 12 works on Floor 2
(13, 3),  -- Librarian 13 works on Floor 3
(14, 4),  -- Librarian 14 works on Floor 4
(15, 5),  -- Librarian 15 works on Floor 5
(16, 6),  -- Librarian 16 works on Floor 6
(17, 7),  -- Librarian 17 works on Floor 7
(18, 8),  -- Librarian 18 works on Floor 8
(19, 9),  -- Librarian 19 works on Floor 9
(20, 10); -- Librarian 20 works on Floor 10

-- Insert 20 records into Contain table (FloorID, BookID, CopyID)
INSERT INTO Contain (FloorID, BookID, CopyID)
VALUES
(1, 1, 1),  -- Book '1984' (ID 1) Copy 1 on Floor 1
(1, 1, 2),  -- Book '1984' (ID 1) Copy 2 on Floor 1
(2, 2, 3),  -- Book 'Harry Potter and the Sorcerer's Stone' (ID 2) Copy 3 on Floor 2
(2, 2, 4),  -- Book 'Harry Potter and the Sorcerer's Stone' (ID 2) Copy 4 on Floor 2
(3, 3, 5),  -- Book 'To Kill a Mockingbird' (ID 3) Copy 5 on Floor 3
(3, 3, 6),  -- Book 'To Kill a Mockingbird' (ID 3) Copy 6 on Floor 3
(4, 4, 7),  -- Book 'Pride and Prejudice' (ID 4) Copy 7 on Floor 4
(4, 4, 8),  -- Book 'Pride and Prejudice' (ID 4) Copy 8 on Floor 4
(5, 5, 9),  -- Book 'The Adventures of Huckleberry Finn' (ID 5) Copy 9 on Floor 5
(5, 5, 10), -- Book 'The Adventures of Huckleberry Finn' (ID 5) Copy 10 on Floor 5
(6, 6, 11), -- Book 'The Old Man and the Sea' (ID 6) Copy 11 on Floor 6
(6, 6, 12), -- Book 'The Old Man and the Sea' (ID 6) Copy 12 on Floor 6
(7, 7, 13), -- Book 'The Great Gatsby' (ID 7) Copy 13 on Floor 7
(7, 7, 14), -- Book 'The Great Gatsby' (ID 7) Copy 14 on Floor 7
(8, 8, 15), -- Book 'War and Peace' (ID 8) Copy 15 on Floor 8
(8, 8, 16), -- Book 'War and Peace' (ID 8) Copy 16 on Floor 8
(9, 9, 17), -- Book 'One Hundred Years of Solitude' (ID 9) Copy 17 on Floor 9
(9, 9, 18), -- Book 'One Hundred Years of Solitude' (ID 9) Copy 18 on Floor 9
(10, 10, 19), -- Book 'Beloved' (ID 10) Copy 19 on Floor 10
(10, 10, 20); -- Book 'Beloved' (ID 10) Copy 20 on Floor 10

-- Insert 20 records into Supplies table (SupplierID, libOrderID, BookID)
INSERT INTO Supplies (SupplierID, libOrderID, BookID)
VALUES
(1, 1, 1),    -- Supplier 1 provides Book 1 in libOrder 1
(2, 2, 2),    -- Supplier 2 provides Book 2 in libOrder 2
(3, 3, 3),    -- Supplier 3 provides Book 3 in libOrder 3
(4, 4, 4),    -- Supplier 4 provides Book 4 in libOrder 4
(5, 5, 5),    -- Supplier 5 provides Book 5 in libOrder 5
(6, 6, 6),    -- Supplier 6 provides Book 6 in libOrder 6
(7, 7, 7),    -- Supplier 7 provides Book 7 in libOrder 7
(8, 8, 8),    -- Supplier 8 provides Book 8 in libOrder 8
(9, 9, 9),    -- Supplier 9 provides Book 9 in libOrder 9
(10, 10, 10),  -- Supplier 10 provides Book 10 in libOrder 10
(11, 11, 11),  -- Supplier 11 provides Book 11 in libOrder 11
(12, 12, 12),  -- Supplier 12 provides Book 12 in libOrder 12
(13, 13, 13),  -- Supplier 13 provides Book 13 in libOrder 13
(14, 14, 14),  -- Supplier 14 provides Book 14 in libOrder 14
(15, 15, 15),  -- Supplier 15 provides Book 15 in libOrder 15
(16, 16, 16),  -- Supplier 16 provides Book 16 in libOrder 16
(17, 17, 17),  -- Supplier 17 provides Book 17 in libOrder 17
(18, 18, 18),  -- Supplier 18 provides Book 18 in libOrder 18
(19, 19, 19),  -- Supplier 19 provides Book 19 in libOrder 19
(20, 20, 20);  -- Supplier 20 provides Book 20 in libOrder 20

-- Insert 20 records into Monitors table (LoanID, MemberID, EmployeeID, MonitoringDate, ActionTaken, Remarks)
INSERT INTO Monitors (LoanID, MemberID, EmployeeID, MonitoringDate, ActionTaken, Remarks)
VALUES
(1, 1, 1, '2024-11-01', 'Returned', 'Loan returned on time by Alice'),
(2, 2, 2, '2024-11-02', 'Active', 'Loan is still active, Bob has the book'),
(3, 3, 3, '2024-11-03', 'Overdue', 'Charlie has not returned the book, overdue for 2 days'),
(4, 4, 4, '2024-11-04', 'Returned', 'Loan returned by David, no issues'),
(5, 5, 5, '2024-11-05', 'Overdue', 'Eva has not returned the book, overdue for 1 day'),
(6, 6, 6, '2024-11-06', 'Active', 'Frank has the book, loan status active'),
(7, 7, 7, '2024-11-07', 'Returned', 'Grace returned the book, no damage'),
(8, 8, 8, '2024-11-08', 'Overdue', 'Helen has not returned the book, overdue for 2 days'),
(9, 9, 9, '2024-11-09', 'Active', 'Ian is still using the book, loan status active'),
(10, 10, 10, '2024-11-10', 'Returned', 'Jack returned the book on time'),
(11, 11, 11, '2024-11-11', 'Active', 'Loan active, Kathy has the book'),
(12, 12, 12, '2024-11-12', 'Returned', 'Liam returned the book, no issues'),
(13, 13, 13, '2024-11-13', 'Overdue', 'Mona is late by 3 days on returning the book'),
(14, 14, 14, '2024-11-14', 'Active', 'Nathan has the book, loan is still active'),
(15, 15, 15, '2024-11-15', 'Returned', 'Olivia returned the book on time'),
(16, 16, 16, '2024-11-16', 'Overdue', 'Paul is overdue by 1 day on returning the book'),
(17, 17, 17, '2024-11-17', 'Active', 'Quincy has the book, still on loan'),
(18, 18, 18, '2024-11-18', 'Returned', 'Rachel returned the book on time'),
(19, 19, 19, '2024-11-19', 'Overdue', 'Sam is 2 days overdue on returning the book'),
(20, 20, 20, '2024-11-20', 'Active', 'Tina has the book, loan status active');


-- SHOW TABLES;

-- Query 1
SELECT M.Email
FROM Reservation R, Member M
WHERE M.MemberID=R.MemberID AND R.CopyID=10;

-- Query 2
SELECT FirstName, LastName
FROM Reservation NATURAL JOIN Member
WHERE RoomID%2=0;

-- Query 3
SELECT M.FirstName, M.LastName
FROM Reservation R JOIN Member M USING (MemberID)
WHERE R.RoomID=6;

-- QUERY 4:
SELECT E.EmployeeID, E.Salary
FROM Cleans C JOIN Employee E ON (C.EmployeeID=E.EmployeeID);

-- Query 5:
SELECT E1.EmployeeID
FROM Employee E1, Employee E2
WHERE E1.Salary>E2.Salary AND E2.EmployeeID=1;

-- Query 6:
SELECT DISTINCT R.MemberID
FROM Review R
WHERE R.Rating=5;

-- Query 7:
SELECT R.RecordingID, R.Title
FROM Recording R
WHERE R.Title LIKE '%Quantum %';

-- Query 8:
SELECT R.RecordingID, R.Title
FROM Recording R
ORDER BY R.Title ASC;

-- Query 9:
SELECT C.EmployeeID
FROM Cleans C
WHERE FloorID=10
UNION
SELECT W.EmployeeID
FROM WorksOn W
WHERE FloorID=10
ORDER BY EmployeeID;

-- Query 10 (INTERSECT)
-- SELECT R.MemberID
-- FROM Reservation R
-- WHERE R.RoomID IS NULL
-- INTERSECT
-- SELECT R.MemberID
-- FROM Reservation R
-- WHERE R.BookID IS NULL AND R.CopyID IS NULL;

-- Query 11 (EXCEPT)
-- SELECT E.EmployeeID
-- FROM Employee E
-- EXCEPT 
-- SELECT E1.EmployeeID
-- FROM Employee E1, Employee E2
-- WHERE E1.EmployeeID < E2.EmployeeID;

-- Query 12:
SELECT COUNT(*)
FROM libOrder L
WHERE L.OrderStatus='Delivered' AND L.TotalCost>=700.0; 

-- Query 13:
SELECT R.Rating, COUNT(*)
FROM Review R
GROUP BY R.Rating; 

-- Query 14:
SELECT B.Genre, COUNT(B.BookID) AS BookCount
FROM Book B
GROUP BY B.Genre
HAVING COUNT(B.BookID) < 4;

-- ADVANCED QUERIES

-- Query 15:
SELECT M.MemberID, M.FirstName, M.LastName
FROM Member M
WHERE NOT EXISTS (
    SELECT B.BookID
    FROM Book B
    WHERE B.AuthorID = 1
    AND NOT EXISTS (
        SELECT L.BookID
        FROM Loan L
        WHERE L.BookID = B.BookID AND L.MemberID = M.MemberID
    )
);

SELECT COUNT(DISTINCT BookID) AS TotalBooksOnLoan
FROM Loan
WHERE LoanStatus = 'Active';


SELECT SupplierID, SupplierName
FROM Supplier
WHERE NOT EXISTS (
    SELECT BookID
    FROM Book
    WHERE BookID NOT IN (
        SELECT Supplies.BookID
        FROM Supplies
        WHERE Supplies.SupplierID = Supplier.SupplierID
    )
);


SELECT AVG(LateDays) AS AvgLateDays
FROM (
    SELECT LoanID, DATEDIFF(ReturnDate, LoanDate) AS LateDays
    FROM Loan
    WHERE LoanStatus = 'Returned'
) AS LoanDurations;


SELECT DISTINCT MemberID, FirstName, LastName
FROM Member
WHERE MemberID IN (
    SELECT Review.MemberID
    FROM Review
    WHERE BookID IN (
        SELECT Loan.BookID
        FROM Loan
        WHERE LoanStatus = 'Overdue'
	)
);


SELECT MemberID, FirstName, LastName, 
       (SELECT COUNT(LoanID) 
        FROM Loan 
        WHERE Loan.MemberID = Member.MemberID) AS TotalLoans
FROM Member;


SET SQL_SAFE_UPDATES = 0;
UPDATE Loan
SET LoanStatus = CASE 
                    WHEN ReturnDate IS NULL THEN 'Active'
                    WHEN ReturnDate <= CURDATE() THEN 'Returned'
                    WHEN ReturnDate > CURDATE() THEN 'Overdue'
                 END
WHERE LoanID IS NOT NULL;

SELECT Member.FirstName, Member.LastName, Loan.LoanID, Loan.LoanStatus
FROM Member
LEFT OUTER JOIN Loan
ON Member.MemberID = Loan.MemberID
WHERE Loan.LoanID IS NULL OR LoanStatus = 'Overdue';


CREATE VIEW OverdueLoansView AS
SELECT Loan.LoanID, Loan.LoanDate, Loan.ReturnDate, Member.FirstName, Member.LastName
FROM Loan
JOIN Member ON Loan.MemberID = Member.MemberID
WHERE Loan.LoanStatus = 'Overdue';

SELECT * 
FROM OverdueLoansView;


DELIMITER //

CREATE TRIGGER UpdateBookCopiesOnLoan
AFTER INSERT ON Loan
FOR EACH ROW
BEGIN
    UPDATE Book
    SET CopiesAvailable = CopiesAvailable - 1
    WHERE BookID = NEW.BookID;
END //

DELIMITER ;


SELECT BookID, CopiesAvailable 
FROM Book 
WHERE BookID = 10;
INSERT INTO Loan (LoanDate, ReturnDate, LoanStatus, BookID, MemberID)
VALUES ('2024-12-15', '2025-01-15', 'Active', 10, 1);
SELECT BookID, CopiesAvailable 
FROM Book 
WHERE BookID = 10;



DELIMITER //
CREATE PROCEDURE RecordLoanAndUpdateCopies(
    IN p_LoanDate DATE,
    IN p_ReturnDate DATE,
    IN p_LoanStatus VARCHAR(20),
    IN p_BookID INT,
    IN p_MemberID INT
)
BEGIN
    -- Insert a new loan record
    INSERT INTO Loan (LoanDate, ReturnDate, LoanStatus, BookID, MemberID)
    VALUES (p_LoanDate, p_ReturnDate, p_LoanStatus, p_BookID, p_MemberID);
    
    -- Decrement the available copies for the book
    UPDATE Book
    SET CopiesAvailable = CopiesAvailable - 1
    WHERE BookID = p_BookID;
END//
DELIMITER ;

SELECT * FROM Loan WHERE BookID = 10 AND MemberID = 1;
SELECT BookID, CopiesAvailable FROM Book WHERE BookID = 10;
SELECT L.LoanID, L.LoanDate, L.ReturnDate, L.LoanStatus, B.BookID, B.CopiesAvailable
FROM Loan L
JOIN Book B ON L.BookID = B.BookID
WHERE L.BookID = 10 AND L.MemberID = 1;



DELIMITER //
CREATE TRIGGER EnsureNoNegativeCopiesBeforeUpdate
BEFORE UPDATE ON Book
FOR EACH ROW
BEGIN
    IF NEW.CopiesAvailable < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CopiesAvailable cannot be negative';
    END IF;
END//
DELIMITER ;



CREATE VIEW ActiveLoansSummary AS
SELECT Member.FirstName, Member.LastName, COUNT(Loan.LoanID) AS TotalActiveLoans
FROM Member
LEFT JOIN Loan ON Member.MemberID = Loan.MemberID AND Loan.LoanStatus = 'Active'
GROUP BY Member.MemberID;

SELECT * FROM ActiveLoansSummary;



-- CREATE ASSERTION EnsureNoNegativeCopies
-- CHECK (
--     (SELECT MIN(CopiesAvailable) FROM Book) >= 0
-- );


