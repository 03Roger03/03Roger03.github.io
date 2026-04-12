create database RepairShopDB;
go

use RepairShopDB;
go

if object_id('dbo.RepairItemPart', 'U') is not null drop table dbo.RepairItemPart;
if object_id('dbo.RepairItem', 'U') is not null drop table dbo.RepairItem;
if object_id('dbo.RepairOrder', 'U') is not null drop table dbo.RepairOrder;
if object_id('dbo.Vehicle', 'U') is not null drop table dbo.Vehicle;
if object_id('dbo.Part', 'U') is not null drop table dbo.Part;
if object_id('dbo.Employee', 'U') is not null drop table dbo.Employee;
if object_id('dbo.Customer', 'U') is not null drop table dbo.Customer;
if object_id('dbo.Brand', 'U') is not null drop table dbo.Brand;
go

create table Brand (
    brandID int not null identity(1,1) unique,
    brandName nvarchar(100) not null,
    companyName nvarchar(200),
    phone varchar(20),
    primary key (brandID)
);
go

create table Customer (
    cID int not null identity(1,1) unique,
    cName nvarchar(50) not null,
    phone varchar(20) unique,
    address nvarchar(255),
    primary key (cID)
);
go

create table Employee (
    eID int not null identity(1,1) unique,
    eName nvarchar(50) not null,
    [role] nvarchar(50),
    specialty nvarchar(100),
    supervisorID int,
    primary key (eID),
    foreign key (supervisorID) references Employee(eID)
);
go

create table Vehicle (
    vID int not null identity(1,1) unique,
    licensePlate varchar(20) not null unique,
    model nvarchar(100),
    [year] int,
    cID int not null,
    brandID int not null,
    primary key (vID),
    foreign key (cID) references Customer(cID),
    foreign key (brandID) references Brand(brandID)
);
go

create table Part (
    pID int not null identity(1,1) unique,
    pName nvarchar(150) not null,
    unitPrice decimal(10, 2) not null,
    stockQty int not null default 0,
    brandID int,
    primary key (pID),
    foreign key (brandID) references Brand(brandID)
);
go

create table RepairOrder (
    oID int not null identity(1,1) unique,
    [date] date not null,
    [status] nvarchar(50),
    vID int not null,
    eID int not null,
    primary key (oID),
    foreign key (vID) references Vehicle(vID),
    foreign key (eID) references Employee(eID)
);
go

create table RepairItem (
    iID int not null identity(1,1) unique,
    iName nvarchar(200) not null,
    laborCost decimal(10, 2) not null,
    partsCost decimal(10, 2) not null,
    oID int not null,
    primary key (iID),
    foreign key (oID) references RepairOrder(oID)
);
go

create table RepairItemPart (
    iID int not null,
    pID int not null,
    qty int not null,
    primary key (iID, pID),
    foreign key (iID) references RepairItem(iID),
    foreign key (pID) references Part(pID)
);
go

insert into Customer (cName, phone, address) values (N'陳一明', '0910-123-456', N'台北市信義區市府路1號');
insert into Customer (cName, phone, address) values (N'林美惠', '0928-765-432', N'新北市板橋區文化路一段100號');
insert into Customer (cName, phone, address) values (N'張偉雄', '0933-111-222', N'桃園市中壢區中央路200號');
insert into Customer (cName, phone, address) values (N'李淑芬', '0955-888-999', N'台中市西屯區台灣大道三段99號');
insert into Customer (cName, phone, address) values (N'王志豪', '0912-345-678', N'高雄市苓雅區四維三路2號');
insert into Customer (cName, phone, address) values (N'黃秀玲', '0988-222-333', N'台南市安平區永華路二段6號');
insert into Customer (cName, phone, address) values (N'劉建宏', '0921-555-666', N'新竹市東區光復路二段101號');
insert into Customer (cName, phone, address) values (N'吳雅婷', '0975-999-000', N'宜蘭縣羅東鎮公正路50號');
insert into Customer (cName, phone, address) values (N'蔡明輝', '0919-444-777', N'花蓮縣花蓮市中山路300號');
insert into Customer (cName, phone, address) values (N'鄭佳穎', '0966-789-123', N'屏東縣屏東市自由路500號');
go

select * from Customer;
go

insert into Brand (brandName, companyName, phone) values (N'Toyota', N'豐田汽車', '0800-221-345');
insert into Brand (brandName, companyName, phone) values (N'Honda', N'本田技研工業', '0800-666-788');
insert into Brand (brandName, companyName, phone) values (N'Ford', N'福特六和', '0800-032-101');
insert into Brand (brandName, companyName, phone) values (N'Mercedes-Benz', N'台灣賓士', '0800-036-524');
insert into Brand (brandName, companyName, phone) values (N'BMW', N'汎德股份有限公司', '0800-291-101');
insert into Brand (brandName, companyName, phone) values (N'Nissan', N'裕隆日產', '0800-088-888');
insert into Brand (brandName, companyName, phone) values (N'Mazda', N'台灣馬自達', '0800-280-123');
insert into Brand (brandName, companyName, phone) values (N'Volkswagen', N'台灣福斯', '0800-828-818');
insert into Brand (brandName, companyName, phone) values (N'Audi', N'台灣奧迪', '0809-092-834');
insert into Brand (brandName, companyName, phone) values (N'Lexus', N'和泰汽車 (Lexus)', '0800-036-036');
go

select * from Brand;
go

insert into Employee (eName, [role], specialty, supervisorID) values (N'王經理', N'廠長', N'管理', NULL);
insert into Employee (eName, [role], specialty, supervisorID) values (N'李組長', N'技師長', N'引擎診斷', 1);
insert into Employee (eName, [role], specialty, supervisorID) values (N'張師傅', N'資深技師', N'電機', 2);
insert into Employee (eName, [role], specialty, supervisorID) values (N'陳阿弟', N'技師', N'底盤', 2);
insert into Employee (eName, [role], specialty, supervisorID) values (N'林小妹', N'技師', N'保養', 2);
insert into Employee (eName, [role], specialty, supervisorID) values (N'黃大哥', N'資深技師', N'板金', 1);
insert into Employee (eName, [role], specialty, supervisorID) values (N'周師傅', N'技師', N'烤漆', 6);
insert into Employee (eName, [role], specialty, supervisorID) values (N'吳專員', N'服務專員', N'接待', 1);
insert into Employee (eName, [role], specialty, supervisorID) values (N'A-Ken', N'學徒', N'學習中', 4);
insert into Employee (eName, [role], specialty, supervisorID) values (N'Vicky', N'會計', N'行政', 1);
go

select * from Employee;
go

insert into Part (pName, unitPrice, stockQty, brandID) values (N'5W-30 全合成機油 1L', 450.00, 200, NULL);
insert into Part (pName, unitPrice, stockQty, brandID) values (N'Toyota 原廠機油濾清器', 300.00, 150, 1);
insert into Part (pName, unitPrice, stockQty, brandID) values (N'Honda HCF-2 變速箱油 4L', 1800.00, 80, 2);
insert into Part (pName, unitPrice, stockQty, brandID) values (N'Ford Motorcraft 空氣濾清器', 650.00, 120, 3);
insert into Part (pName, unitPrice, stockQty, brandID) values (N'Brembo 前來令片 (一組)', 3200.00, 50, NULL);
insert into Part (pName, unitPrice, stockQty, brandID) values (N'Michelin 輪胎 215/55/R17', 4500.00, 40, NULL);
insert into Part (pName, unitPrice, stockQty, brandID) values (N'Bosch 電瓶 80Ah', 3800.00, 60, NULL);
insert into Part (pName, unitPrice, stockQty, brandID) values (N'Nissan 原廠空氣濾清器', 580.00, 90, 6);
insert into Part (pName, unitPrice, stockQty, brandID) values (N'BMW 原廠火星塞 (單支)', 800.00, 100, 5);
insert into Part (pName, unitPrice, stockQty, brandID) values (N'VW DSG 變速箱油 1L', 1100.00, 70, 8);
go

select * from Part;
go

insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('ABC-1234', 'Camry', 2018, 1, 1);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('DEF-5678', 'Civic', 2020, 2, 2);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('GHI-9012', 'Focus', 2019, 3, 3);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('JKL-3456', 'C-Class C300', 2021, 4, 4);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('MNO-7890', '3 Series 320i', 2017, 5, 5);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('PQR-1122', 'X-Trail', 2022, 6, 6);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('STU-3344', 'Mazda3', 2018, 7, 7);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('VWX-5566', 'Golf', 2020, 8, 8);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('YZA-7788', 'A4', 2019, 9, 9);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('BCD-9900', 'ES 300h', 2021, 10, 10);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('EFG-1212', 'RAV4', 2019, 1, 1);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('HIJ-3434', 'CR-V', 2022, 2, 2);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('KLM-5656', 'Kuga', 2017, 3, 3);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('NOP-7878', 'E-Class E200', 2018, 4, 4);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('QRS-9090', '5 Series 530i', 2020, 5, 5);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('TUV-2121', 'Kicks', 2021, 6, 6);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('WXY-4343', 'CX-5', 2019, 7, 7);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('ZAB-6565', 'Tiguan', 2022, 8, 8);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('CDE-8787', 'Q5', 2017, 9, 9);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('FGH-0909', 'RX 300', 2020, 10, 10);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('IJK-1313', 'Altis', 2023, 1, 1);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('LMN-2424', 'HR-V', 2019, 2, 2);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('OPQ-3535', 'Ranger', 2020, 3, 3);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('RST-4646', 'GLC 300', 2021, 4, 4);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('UVW-5757', 'X3', 2018, 5, 5);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('XYZ-6868', 'Sentra', 2022, 6, 6);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('AAA-7979', 'CX-30', 2020, 7, 7);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('BBB-8080', 'Polo', 2019, 8, 8);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('CCC-9191', 'A1', 2021, 9, 9);
insert into Vehicle (licensePlate, model, [year], cID, brandID) values ('DDD-0202', 'UX 200', 2022, 10, 10);
go

select * from Vehicle;
go

insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-01', N'已完成', 1, 3);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-01', N'已完成', 2, 4);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-02', N'已完成', 3, 5);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-03', N'已完成', 4, 3);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-04', N'已完成', 5, 4);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-05', N'已完成', 6, 5);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-06', N'已完成', 7, 3);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-07', N'已完成', 8, 4);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-08', N'已完成', 9, 5);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-09', N'已完成', 10, 3);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-10', N'已完成', 11, 4);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-11', N'已完成', 12, 5);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-12', N'已完成', 13, 3);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-13', N'已完成', 14, 4);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-14', N'已完成', 15, 5);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-15', N'已完成', 16, 6);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-15', N'已完成', 17, 7);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-16', N'已完成', 18, 3);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-17', N'已完成', 19, 4);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-18', N'已完成', 20, 5);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-19', N'已完成', 21, 6);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-20', N'已完成', 22, 7);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-21', N'已完成', 23, 3);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-22', N'已完成', 24, 4);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-22', N'已完成', 25, 5);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-23', N'維修中', 26, 3);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-23', N'維修中', 27, 4);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-24', N'待維修', 28, 5);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-24', N'待維修', 29, 8);
insert into RepairOrder ([date], [status], vID, eID) values ('2024-10-24', N'待維修', 30, 8);
go

select * from RepairOrder;
go

insert into RepairItem (iName, laborCost, partsCost, oID) values (N'5000公里定期保養', 1200.00, 0, 1);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換機油', 0.00, 1800.00, 1);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'10000公里定期保養', 1500.00, 0, 2);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換機油與機油濾清器', 300.00, 2100.00, 2);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換空氣濾清器', 200.00, 650.00, 3);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'20000公里定期保養', 2000.00, 0, 4);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換火星塞 (4支)', 800.00, 3200.00, 5);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換電瓶', 500.00, 3800.00, 6);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換前輪來令片', 1200.00, 3200.00, 7);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'輪胎對調', 600.00, 0, 8);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換冷氣濾網', 300.00, 580.00, 9);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'變速箱油更換 (DSG)', 1500.00, 4400.00, 10);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'5000公里定期保養', 1200.00, 0, 11);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換機油', 0.00, 1800.00, 11);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'10000公里定期保養', 1500.00, 0, 12);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換機油與機油濾清器', 300.00, 2100.00, 12);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換空氣濾清器', 200.00, 650.00, 13);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'20000公里定期保養', 2000.00, 0, 14);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換火星塞 (4支)', 800.00, 3200.00, 15);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'板金：左前葉子板', 4000.00, 0, 16);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'烤漆：左前葉子板', 3500.00, 0, 17);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換電瓶', 500.00, 3800.00, 18);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換前輪來令片', 1200.00, 3200.00, 19);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'輪胎對調', 600.00, 0, 20);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'板金：後保險桿', 2500.00, 0, 21);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'烤漆：後保險桿', 3000.00, 0, 22);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換冷氣濾網', 300.00, 580.00, 23);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'變速箱油更換 (DSG)', 1500.00, 4400.00, 24);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'5000公里定期保養', 1200.00, 0, 25);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換機油', 0.00, 1800.00, 25);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'引擎抖動檢查', 800.00, 0, 26);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'冷氣不冷檢查', 800.00, 0, 27);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'事故估價', 0.00, 0, 28);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'新車首次保養', 1000.00, 0, 29);
insert into RepairItem (iName, laborCost, partsCost, oID) values (N'更換雨刷', 150.00, 800.00, 30);
go

select * from RepairItem;
go

insert into RepairItemPart (iID, pID, qty) values (2, 1, 4);
insert into RepairItemPart (iID, pID, qty) values (4, 1, 5);
insert into RepairItemPart (iID, pID, qty) values (4, 2, 1);
insert into RepairItemPart (iID, pID, qty) values (5, 4, 1);
insert into RepairItemPart (iID, pID, qty) values (7, 9, 4);
insert into RepairItemPart (iID, pID, qty) values (8, 7, 1);
insert into RepairItemPart (iID, pID, qty) values (9, 5, 1);
insert into RepairItemPart (iID, pID, qty) values (11, 8, 1);
insert into RepairItemPart (iID, pID, qty) values (12, 10, 4);
insert into RepairItemPart (iID, pID, qty) values (14, 1, 4);
insert into RepairItemPart (iID, pID, qty) values (16, 2, 1);
insert into RepairItemPart (iID, pID, qty) values (17, 4, 1);
insert into RepairItemPart (iID, pID, qty) values (19, 9, 4);
insert into RepairItemPart (iID, pID, qty) values (22, 7, 1);
insert into RepairItemPart (iID, pID, qty) values (23, 5, 1);
go

select * from RepairItemPart;
go
-------------------------------------------------------

use RepairShopDB;
go
