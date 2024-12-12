create database library;
use library;
create table publisher(
publisher_name varchar(50) primary key ,
publisher_address varchar(255),
publisher_phone   varchar(50));


create table borrower(
borrower_cardno int primary key auto_increment,
borrower_name varchar(50),
borrower_address varchar(255),
borrower_phone varchar(50));

create table library_branch(
branch_id int primary key auto_increment,
branch_name varchar(100),
braanch_address varchar(255));

create table book(
book_id int primary key ,
book_title varchar(255),
book_publishername varchar(60),
foreign key(book_publishername) references publisher(publisher_name)
on delete cascade on update cascade);

create table book_authors(
book_authorid int primary key auto_increment,
author_bookid int,
author_authorname varchar(90),
foreign key(author_bookid) references book(book_id)
on delete cascade on update cascade);

create table book_copies(
copies_copiesid int primary key auto_increment,
copies_bookid int,
copies_branchid int,
copies_no_of_copies int,
foreign key(copies_bookid) references book(book_id)
on delete cascade on update cascade,
foreign key(copies_branchid) references library_branch(branch_id)
on delete cascade on update cascade);

create table book_loans(
loansid int primary key auto_increment,
loans_bookid int,
loans_branchid int,
loans_cardno int,
loans_dateout date,
loans_duedate date,
foreign key (loans_bookid) references book(book_id)
on delete cascade on update cascade,
foreign key(loans_branchid) references library_branch(branch_id)
on delete cascade on update cascade,
foreign key(loans_cardno) references borrower(borrower_cardno)
on delete cascade on update cascade);

-- How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

select sum(copies_no_of_copies) from book_copies as bc
join library_branch as lb
on lb.branch_id=bc.copies_branchid
join book as b
on b.book_id=bc.copies_bookid
where b.book_title="The Lost Tribe" and lb.branch_name="Sharpstown";

-- How many copies of the book titled "The Lost Tribe" are owned by each library branch?

SELECT lb.Branch_Name,SUM(bc.copies_No_Of_Copies) AS Total_Copies
from book_copies as bc
join library_branch as lb
on lb.branch_id=bc.copies_branchid
join book as b
on b.book_id=bc.copies_bookid
where b.book_title="The Lost Tribe"
group by lb.branch_name;

-- Retrieve the names of all borrowers who do not have any books checked out.

select bo.borrower_cardno,bo.borrower_name from borrower as bo
left join book_loans as bl
on bo.borrower_cardno=bl.loans_cardno
where bl.loans_dateout is null;

-- For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18,retrieve the book title, the borrower's name, and the borrower's address. 

select b.book_title,bo.borrower_name,bo.borrower_address from  book_loans as bl
join book as b 
on b.book_id=bl.loans_bookid
join borrower as bo
on bo.borrower_cardno=bl.loans_cardno
join library_branch as lb
on lb.branch_id=bl.loans_branchid
where lb.branch_name="Sharpstown" and bl.loans_duedate="2018-02-03";

-- For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

select lb.branch_name,count(loansid) as total_copies from library_branch as lb
join book_copies as bc
on bc.copies_branchid =lb.branch_id
join book_loans as bl
on bl.loans_branchid=lb.branch_id
group by lb.branch_name;

-- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
select bo.borrower_name , bo.borrower_address ,count(loansid) from borrower as bo
left join book_loans as bl
on bo.borrower_cardno =  bl.loans_cardno
group by bo.borrower_name , bo.borrower_address
having count(loansid)>5;

-- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
select b.book_title, count(copies_copiesid) from book_copies as bc
join library_branch as lb
on lb.branch_id=bc.copies_branchid
join book as b
on b.book_id=bc.copies_bookid
join book_authors as ba
on ba.author_bookid=b.book_id
where lb.branch_name="Central" and ba.author_authorname ="Stephen King"
group by b.book_title;

