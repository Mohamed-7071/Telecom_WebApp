CREATE DATABASE Telecom_Team_105;
use telecom_team_105;
go
CREATE FUNCTION dbo.Calculate_Remaining_Balance () 
RETURNS DECIMAL(10, 1)
AS
BEGIN
    RETURN (
        SELECT CASE 
            WHEN Payment.amount < Service_Plan.price 
            THEN Service_Plan.price - Payment.amount
            ELSE 0
        END
        FROM Payment 
        JOIN Service_Plan ON Service_Plan.planID = planID
        WHERE Payment.paymentID = paymentID
          AND Service_Plan.planID = planID
    );
END;

GO

 CREATE FUNCTION dbo.Calculate_Extra_Amount ()
RETURNS DECIMAL(10, 1)
AS
BEGIN
    
    RETURN (
        SELECT CASE 
            WHEN Payment.amount > Service_Plan.price 
            THEN Payment.amount - Service_Plan.price
            ELSE 0
        END
        FROM Payment 
        JOIN Service_Plan ON Service_Plan.planID = planID
        WHERE Payment.paymentID = paymentID
          AND Service_Plan.planID = planID
    );
END;
go 
--2.1b
CREATE PROCEDURE createAllTables
AS
BEGIN

    CREATE TABLE customer_profile (
        nationalid INT PRIMARY KEY,
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        email VARCHAR(50),
        address VARCHAR(50),
        date_of_birth DATE
    );


    CREATE TABLE customer_account (
        mobileno CHAR(11) PRIMARY KEY,
        pass VARCHAR(50),
        balance DECIMAL(10,1),
        account_type VARCHAR(50) CHECK (account_type IN ('Post Paid', 'Prepaid', 'Pay_as_you_go')),
        start_date DATE,
        status VARCHAR(50) CHECK (status IN ('active', 'onhold')),
        point INT DEFAULT 0,
        nationalid INT,
        FOREIGN KEY (nationalid) REFERENCES customer_profile(nationalid)
    );

    CREATE TABLE service_plan (
        planid INT IDENTITY(1,1) PRIMARY KEY,
        sms_offered INT,
        minutes_offered INT,
        data_offered INT,
        name VARCHAR(50),
        price INT,
        description VARCHAR(50)
    );


    CREATE TABLE subscription (
        mobileno CHAR(11),
        planid INT,
        subscription_date DATE,
        status VARCHAR(50) CHECK (status IN ('active', 'onhold')),
        FOREIGN KEY (mobileno) REFERENCES customer_account(mobileno),
        FOREIGN KEY (planid) REFERENCES service_plan(planid),
        PRIMARY KEY (mobileno, planid)
    );

    CREATE TABLE plan_usage (
        usageid INT IDENTITY(1,1) PRIMARY KEY,
        start_date DATE,
        end_date DATE,
        data_consumption INT,
        minutes_used INT,
        sms_sent INT,
        mobileno CHAR(11),
        planid INT,
        FOREIGN KEY (mobileno) REFERENCES customer_account(mobileno),
        FOREIGN KEY (planid) REFERENCES service_plan(planid)
    );


    CREATE TABLE payment (
        paymentid INT IDENTITY(1,1) PRIMARY KEY,
        amount DECIMAL(10,1),
        date_of_payment DATE,
        payment_method VARCHAR(50) CHECK (payment_method IN ('cash', 'credit')),
        status VARCHAR(50) CHECK (status IN ('successful', 'pending', 'rejected')),
        mobileno CHAR(11),
        FOREIGN KEY (mobileno) REFERENCES customer_account(mobileno)
    );


    CREATE TABLE Process_Payment (
        paymentID INT,
        planID INT,
        remaining_balance AS dbo.Calculate_Remaining_Balance(),
        extra_amount AS dbo.Calculate_Extra_Amount(),
        PRIMARY KEY (paymentID, planID),
        FOREIGN KEY (paymentID) REFERENCES Payment(paymentID) ON UPDATE CASCADE,
        FOREIGN KEY (planID) REFERENCES Service_Plan(planID) ON UPDATE CASCADE
    );


    CREATE TABLE wallet (
        walletid INT IDENTITY(1,1) PRIMARY KEY,
        current_balance DECIMAL(10,2),
        currency VARCHAR(50),
        last_modified_date DATE,
        nationalid INT,
        mobileno CHAR(11),
        FOREIGN KEY (nationalid) REFERENCES customer_profile(nationalid)
    );


    CREATE TABLE transfer_money (
        walletid1 INT,
        walletid2 INT,
        transfer_id INT IDENTITY(1,1) PRIMARY KEY,
        amount DECIMAL(10,2),
        transfer_date DATE,
        FOREIGN KEY (walletid1) REFERENCES wallet(walletid),
        FOREIGN KEY (walletid2) REFERENCES wallet(walletid)
    );


    CREATE TABLE benefits (
        benefitid INT IDENTITY(1,1) PRIMARY KEY,
        description VARCHAR(50),
        validity_date DATE,
        status VARCHAR(50) CHECK (status IN ('active', 'expired')),
        mobileno CHAR(11),
        FOREIGN KEY (mobileno) REFERENCES customer_account(mobileno)
    );

 
    CREATE TABLE points_group (
        pointid INT IDENTITY(1,1) PRIMARY KEY,
        benefitid INT,
        pointsamount INT,
        paymentid INT,
        FOREIGN KEY (benefitid) REFERENCES benefits(benefitid),
        FOREIGN KEY (paymentid) REFERENCES payment(paymentid)
    );


    CREATE TABLE exclusive_offer (
        offerid INT IDENTITY(1,1) PRIMARY KEY,
        benefitid INT,
        internet_offered INT,
        sms_offered INT,
        minutes_offered INT,
        FOREIGN KEY (benefitid) REFERENCES benefits(benefitid)
    );


    CREATE TABLE cashback (
        cashbackid INT IDENTITY(1,1) PRIMARY KEY,
        benefitid INT,
        walletid INT,
        amount INT,
        credit_date DATE,
        FOREIGN KEY (benefitid) REFERENCES benefits(benefitid),
        FOREIGN KEY (walletid) REFERENCES wallet(walletid)
    );

    CREATE TABLE plan_provides_benefits (
        benefitid INT,
        planid INT,
        FOREIGN KEY (benefitid) REFERENCES benefits(benefitid),
        FOREIGN KEY (planid) REFERENCES service_plan(planid),
        PRIMARY KEY (benefitid, planid)
    );


    CREATE TABLE shop (
        shopid INT IDENTITY(1,1) PRIMARY KEY,
        name VARCHAR(50),
        category VARCHAR(50)
    );


    CREATE TABLE physical_shop (
        shopid INT PRIMARY KEY,
        address VARCHAR(50),
        working_hours VARCHAR(50),
        FOREIGN KEY (shopid) REFERENCES shop(shopid)
    );


    CREATE TABLE e_shop (
        shopid INT PRIMARY KEY,
        url VARCHAR(50),
        rating INT,
        FOREIGN KEY (shopid) REFERENCES shop(shopid)
    );


    CREATE TABLE voucher (
        voucherid INT IDENTITY(1,1) PRIMARY KEY,
        value INT,
        expiry_date DATE,
        points INT,
        mobileno CHAR(11),
        shopid INT,
        redeem_date DATE,
        FOREIGN KEY (mobileno) REFERENCES customer_account(mobileno),
        FOREIGN KEY (shopid) REFERENCES shop(shopid)
    );


    CREATE TABLE technical_support_ticket (
        ticketid INT IDENTITY(1,1) PRIMARY KEY,
        mobileno CHAR(11),
        issue_description VARCHAR(50),
        priority_level INT,
        status VARCHAR(50) CHECK (status IN ('Open', 'In Progress', 'Resolved')),
        FOREIGN KEY (mobileno) REFERENCES customer_account(mobileno)
    );
END;
EXEC  createAllTables
GO

--2.1c
CREATE PROCEDURE dropAllTables
AS

DROP TABLE IF EXISTS technical_support_ticket;
    DROP TABLE IF EXISTS voucher;
    DROP TABLE IF EXISTS e_shop;
    DROP TABLE IF EXISTS physical_shop;
    DROP TABLE IF EXISTS shop;
    DROP TABLE IF EXISTS plan_provides_benefits;
    DROP TABLE IF EXISTS cashback;
    DROP TABLE IF EXISTS exclusive_offer;
    DROP TABLE IF EXISTS points_group;
    DROP TABLE IF EXISTS benefits;
    DROP TABLE IF EXISTS transfer_money;
    DROP TABLE IF EXISTS wallet;
    DROP TABLE IF EXISTS process_payment;
    DROP TABLE IF EXISTS payment;
    DROP TABLE IF EXISTS plan_usage;
    DROP TABLE IF EXISTS subscription;
    DROP TABLE IF EXISTS service_plan;
    DROP TABLE IF EXISTS customer_account;
    DROP TABLE IF EXISTS customer_profile;
GO
EXEC dropAllTables
GO

--2.1 c


CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN

    DROP VIEW allCustomerAccounts;
    DROP VIEW allServicePlans;
    DROP VIEW allBenefits;
    DROP VIEW AccountPayments;
    DROP VIEW allShops;
    DROP VIEW allResolvedTickets;
    DROP VIEW CustomerWallet;
    DROP VIEW E_shopVouchers;
    DROP VIEW PhysicalStoreVouchers;
    DROP VIEW Num_of_cashback;

    DROP FUNCTION Account_Plan_date;
    DROP FUNCTION Account_Usage_Plan;
    DROP FUNCTION Account_SMS_Offers;
    DROP FUNCTION Wallet_Cashback_Amount;
    DROP FUNCTION Wallet_Transfer_Amount;
    DROP FUNCTION Wallet_MobileNo;
    DROP FUNCTION Consumption;
    DROP FUNCTION Usage_Plan_CurrentMonth;
    DROP FUNCTION Cashback_Wallet_Customer;
    DROP FUNCTION Remaining_plan_amount;
    DROP FUNCTION Extra_plan_amount;
    DROP FUNCTION Subscribed_plans_5_Months;

    DROP PROCEDURE createAllTables;
    DROP PROCEDURE dropAllTables;
    DROP PROCEDURE clearAllTables;
    DROP PROCEDURE Account_Plan;
    DROP PROCEDURE Benefits_Account;
    DROP PROCEDURE Account_Payment_Points;
    DROP PROCEDURE Total_Points_Account;
    DROP PROCEDURE Unsubscribed_Plans;
    DROP PROCEDURE Ticket_Account_Customer;
    DROP PROCEDURE Account_Highest_Voucher;
    DROP PROCEDURE Initiate_plan_payment;
    DROP PROCEDURE Payment_wallet_cashback;
    DROP PROCEDURE Initiate_balance_payment;
    DROP PROCEDURE Redeem_voucher_points;
    DROP PROCEDURE Top_Successful_Payments;
    PRINT 'All procedures, functions, and views (except this one) have been dropped.';
END;



    


--2.1 d
go
CREATE PROCEDURE clearAllTables
AS
Delete from technical_support_ticket;
    Delete from voucher;
    Delete from e_shop;
    Delete from physical_shop;
    Delete from shop;
    Delete from plan_provides_benefits;
    Delete from cashback;
    Delete from exclusive_offer;
    Delete from points_group;
    Delete from benefits;
    Delete from  transfer_money;
    Delete from wallet;
    Delete from process_payment;
    Delete from payment;
    Delete from plan_usage;
    Delete from subscription;
    Delete from service_plan;
    Delete from customer_account;
    Delete from customer_profile;

exec clearAllTables


--2.2 a

go
CREATE VIEW allCustomerAccounts
AS
SELECT C.*
FROM customer_account C
WHERE c.status='Active'

--2.2 b
GO
CREATE VIEW allServicePlans
AS 
SELECT S.*
FROM service_plan S ;

--2.2 c
GO
CREATE VIEW allBenefits
AS
SELECT *
FROM benefits 
WHERE status='Active'

--2.2 d
GO
CREATE VIEW AccountPayments
AS
SELECT c.mobileNo AS Cmobileno, c.pass,c.balance, c.account_type, c.start_date, c.status AS Cstatus, c.point, c.nationalID ,
p.paymentID, p.amount, p.date_of_payment, p.payment_method , p.status AS Pstatus, p.mobileNo AS Pmobileno
FROM customer_account c join payment p
on c.mobileno=p.mobileno

--2.2 e
GO
CREATE VIEW allShops
AS 
SELECT ss.*
FROM shop ss ;
GO
--2.2 f
CREATE VIEW allResolvedTickets 
AS 
SELECT t.*
FROM technical_support_ticket t
WHERE t.status ='resolved'

--2.2 g
GO
CREATE VIEW CustomerWallet
AS 
SELECT c.nationalID AS Cnationalid, c.first_name, c.last_name, c.email, c.address, c.date_of_birth ,
w.walletID, w.current_balance, w.currency, w.last_modified_date, w.nationalID AS Wnationalid, w.mobileNo 
FROM wallet w join customer_profile c
on w.nationalid=c.nationalid

--2.2 h
GO
CREATE VIEW E_shopVouchers
AS 
SELECT e.* , v.voucherid , v.value 
FROM e_shop  e join voucher v
on e.shopid=v.shopid

--2.2 i 
GO
CREATE VIEW PhysicalStoreVouchers 
AS 
SELECT p.* , v.voucherid , v.value 
FROM   physical_shop p join voucher v
on p.shopid=v.shopid

--2.2 j
GO
CREATE VIEW Num_of_cashback
AS 
SELECT w.walletid ,COUNT(*) AS NumberOfCashbacks
FROM wallet w join cashback c
on w.walletid=c.walletid
GROUP BY w.walletid;
 


--2.3 a
go
CREATE PROCEDURE Account_Plan
AS
SELECT c.* 
FROM (customer_account c join subscription ss 
on c.mobileno=ss.mobileno) 
join  service_plan s
on s.planid=ss.planid



--2.3b
go
CREATE PROCEDURE Account_Plan_date
@Subscription_Date date ,
@Plan_id int
AS
SELECT c.*  
FROM (customer_account c join subscription ss 
on c.mobileno=ss.mobileno) 
join  service_plan s
on s.planid=ss.planid
WHERE @subscription_date=ss.subscription_date and @Plan_id=s.planid

--2.3c
GO
CREATE PROCEDURE Account_Usage_Plan 
@MobileNo char(11), 
@from_date date
AS
SELECT s.planid , SUM ( p.data_consumption),
SUM ( p.minutes_used) ,
SUM (p.sms_sent)
FROM (Plan_usage p join subscription ss 
on p.mobileno=ss.mobileno) 
join  service_plan s
on s.planid=ss.planid
WHERE p.mobileno=ss.mobileno and @from_date <= start_date
GROUP BY s.planid

--2.3d
go
CREATE PROCEDURE Benefits_Account
@MobileNo char(11),
@planID int
AS
if exists ( 
SELECT b.*
        FROM Benefits b
        inner JOIN Customer_Account c ON b.mobileNo = c.mobileNo inner JOIN Subscription s ON c.mobileNo = s.mobileNo
        WHERE b.mobileNo = @mobileno  and s.planID = @planID
    )
DELETE b
        FROM Benefits b
       inner JOIN Customer_Account c ON b.mobileNo = c.mobileNo inner JOIN Subscription s ON c.mobileNo = s.mobileNo
        WHERE b.mobileNo = @mobileno and s.planID = @planID;
else
print 'benefits not found';



--2.3e
go
CREATE FUNCTION Account_SMS_Offers
(@MobileNo char(11))
returns table 
AS
return (
SELECT e.*
FROM(exclusive_offer e inner join benefits b on e.benefitid=b.benefitid) 
WHERE @MobileNo=b.mobileno and e.sms_offered>0)

--2.3f
go
CREATE PROCEDURE Account_Payment_Points
(@MobileNo CHAR(11))
AS
BEGIN
    SELECT COUNT(pr.paymentid) AS Total_Transactions, SUM(p.pointsAmount) AS Total_Points
    FROM points_group p
    inner JOIN Process_Payment pr ON p.paymentid = pr.paymentid inner JOIN payment pa ON pr.paymentid = pa.paymentid
    WHERE pa.mobileno = @MobileNo  and pa.date_of_payment >= DATEADD(YEAR, -1, GETDATE())  and pa.status = 'Accepted';
END;




--2.3g 
go
create function Wallet_Cashback_Amount
(@WalletId int, @planId int)
returns int
as
begin

declare @result int

select @result=sum(c.amount)  from cashback c , plan_provides_benefits p
where  c.benefitid = p .benefitid and p.benefitid = @planId and c.walletid = @WalletId

return @result
end


--2.3 h 
go
Create function Wallet_Transfer_Amount (@Wallet_id int, @start_date date, @end_date date)
returns DECIMAL
begin 

DECLARE @Average DECIMAL(10,1)= 0.0 ;

SELECT @Average = @Average + AVG(amount)
FROM Transfer_money
WHERE walletID1 = @Wallet_id   and  transfer_date BETWEEN @Start_date and @End_date;

RETURN @Average; 
end





--2.3 i

go
create function Wallet_MobileNo
(@MobileNo char(11))
returns bit

begin 
declare @result bit

if @MobileNo in(
select a.mobileno from wallet w , customer_account a
where w.mobileno = a.mobileno)
set @result = 1
else set @result = 0

return @result
end
go


 
---2.3j
    go
    create procedure Total_Points_Account
    @MobileNo char(11),
    @Total_Points int output
    AS
    BEGIN
    select @Total_Points = sum(P.pointsAmount)
    from Points_Group P inner join Payment P1 on P.PaymentID = P1.PaymentID inner join Customer_Account C on P1.MobileNo = C.MobileNo
    where P1.MobileNo = @MobileNo;
    UPDATE Customer_Account
    set point = @Total_Points
    where MobileNo = @MobileNo

    END;

--2.4 a
go 
CREATE FUNCTION AccountLoginValidation (
    @MobileNo CHAR(11),
    @Password VARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    declare @Success BIT;
 if exists (
        select * from Customer_Account
        Where mobileNo = @MobileNo AND pass = @Password
    )
        set @Success = 1;
    else
        set @Success = 0;  
    RETURN @Success;
END;


--2.4 b
go
CREATE FUNCTION Consumption (
    @Plan_name VARCHAR(50),
    @Start_date DATE,
    @End_date DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        SUM(data_consumption) AS [Data consumption],
        SUM(minutes_used) AS [Minutes used],
        SUM(SMS_sent) AS [SMS sent]
    FROM 
        Plan_Usage PU INNER JOIN Service_Plan SP ON PU.planID = SP.planID
    WHERE 
        SP.name = @Plan_name and PU.start_date >= @Start_date and PU.end_date <= @End_date
);


--2.4 c
go
CREATE PROCEDURE Unsubscribed_Plans
    @MobileNo CHAR(11)
AS
BEGIN
    SELECT sp.*
    FROM service_plan sp
    WHERE sp.planID NOT IN (
        SELECT s.planID
        FROM subscription s
        WHERE s.mobileNo = @MobileNo
    );
END;



--2.4 d
go 
create Function Usage_Plan_CurrentMonth
(@MobileNo char(11))

RETURNS TABLE
AS
RETURN
(
    SELECT  pu.data_consumption,pu.minutes_used, pu.sms_sent
    FROM plan_usage pu inner join customer_account c on pu.mobileno=c.mobileno inner join subscription s on pu.planid= s.planid
    where pu.mobileno= @MobileNo and s.status='active' and   MONTH(pu.start_date) = MONTH(GETDATE())  and YEAR(pu.end_date) = YEAR(GETDATE())

      )

--2.4 e
go
CREATE FUNCTION Cashback_Wallet_Customer
(@NationalID INT)
RETURNS TABLE
AS
RETURN
(
    select cb.*  from  cashback cb
    inner join  Wallet w ON cb.walletid = w.walletid inner join  Customer_Profile cp ON w.nationalid = cp.nationalid
    where  cp.nationalid = @NationalID
);

--2.4 f

go
CREATE PROCEDURE Ticket_Account_Customer
    @NationalID INT
AS
BEGIN
    DECLARE @UnresolvedTicketCount INT;

    SELECT @UnresolvedTicketCount = COUNT(*) FROM technical_support_ticket t
    inner JOIN customer_account a ON t.mobileno = a.mobileno inner JOIN customer_profile c ON a.nationalid = c.nationalid
    WHERE c.nationalid = @NationalID and t.Status <> 'Resolved';
    PRINT 'Number of unresolved tickets: ' +@UnresolvedTicketCount;
END;

--2.4 g
go
CREATE PROCEDURE Account_Highest_Voucher
    @MobileNo CHAR(11)
AS
BEGIN
    SELECT v.*
    FROM Voucher v
    WHERE v.Value = (
        SELECT MAX(v2.Value)
        FROM Voucher v2
        WHERE v2.MobileNo = @MobileNo
    );
END;
GO
--2.4 h

create function Remaining_plan_amount 
(@MobileNo char(11), @plan_name varchar(50)
)
returns int
as 
begin
declare @Remaining int
declare @amount int
declare @price int


select @amount=p.amount,@price=s.price from payment p, service_plan s,process_payment po
where p.paymentid = po.paymentid and s.planid=po.planid and p.mobileno=@MobileNo and s.name = @plan_name

set @Remaining =@amount-@price
return @Remaining;
end;
go


-----2.4 (i)
create function Extra_plan_amount
(@mobileno char(11), @plan_name varchar(50)) 

returns decimal(10,1)
as
begin
    declare @extra_amount decimal(10,1); 
    select @extra_amount=pp.extra_amount from process_payment pp
inner join payment p on pp.paymentid = p.paymentid inner join service_plan sp on pp.planid = sp.planid 
    where p.mobileno = @mobileno and sp.name = @plan_name;
     return @extra_amount; 
end;
go 

----2.4(j)
create procedure Top_Successful_Payments
(@mobileno char(11))
as
begin
    select top 10 p.*
    from payment p
    where mobileno= @mobileno and status = 'successful'
    order by amount desc;
end;
go

----2.4(k) 
create function Subscribed_plans_5_Months
(@mobileno char(11))
returns table
as
return (select sp.* from subscription s
 inner join service_plan sp on s.planid = sp.planid 
    where s.mobileno = @mobileno and s.subscription_date >= dateadd(month, -5, getdate())
);
go

----2.4(l)
create procedure Initiate_plan_payment
(@mobileno char(11), @amount decimal(10,1),@payment_method varchar(50),@plan_id int)
as
begin
    insert into payment ( amount, date_of_payment, payment_method, status, mobileno) 
    values ( @amount, getdate(), @payment_method, 'accepted', @mobileno);
    update subscription
    set status = 'renewed', subscription_date = getdate() where mobileno = @mobileno and planid = @plan_id;
end;

--2.4 m
go
CREATE PROCEDURE Payment_wallet_cashback
(
    @MobileNo CHAR(11),
    @PaymentID INT,
    @BenefitID INT
)
AS
BEGIN
    declare @CashbackAmount decimal(10,2);
    declare @WalletID int;
    select @CashbackAmount = amount * 0.1
    from Payment
    where paymentID = @PaymentID and mobileNo = @MobileNo;
    select @WalletID = walletID
    from Wallet
    where mobileNo = @MobileNo;
    update Wallet
    set current_balance = current_balance + @CashbackAmount
    where walletID = @WalletID;
    insert into Cashback (benefitID, walletID, amount, credit_date)
    values (@BenefitID, @WalletID, @CashbackAmount, getdate());
END;



--2.4 n 

go
CREATE PROCEDURE Initiate_balance_payment 
( @MobileNo CHAR(11), @amount DECIMAL(10,1),
@payment_method VARCHAR(50))
AS
BEGIN
if exists (select mobileno from Customer_Account where mobileno = @Mobileno)
begin
INSERT INTO Payment (amount, date_of_payment, payment_method, status, mobileNo)
values (@amount, GETDATE(), @payment_method, 'Accepted', @MobileNo);
UPDATE Customer_Account
set balance = balance + @amount
where mobileNo = @MobileNo;
END
ELSE
PRINT 'Mobile number not found.';
END;


--2.4 O
go
CREATE PROCEDURE Redeem_voucher_points
(
    @MobileNo CHAR(11),
    @VoucherID INT
)
AS
BEGIN
    IF EXISTS (
        SELECT v.* 
        FROM Voucher v
        WHERE v.voucherid = @VoucherID and v.mobileno = @MobileNo and v.expiry_date >= GETDATE() and v.redeem_date IS NULL
    )
BEGIN
        UPDATE Customer_Account 
        SET point = point + (SELECT points FROM Voucher WHERE voucherID = @VoucherID and mobileNo = @MobileNo)
        WHERE mobileNo = @MobileNo;

        UPDATE Voucher
        SET redeem_date = GETDATE()
        WHERE voucherID = @VoucherID and mobileNo = @MobileNo;
END
ELSE
        PRINT 'The voucher is either invalid, expired, or already redeemed.';
END;



