create table dbo.commande (
    id int identity(1,1) primary key,
    customer_id int not null,
    order_date datetime not null,
    total_amount decimal(18, 2) not null,
    status nvarchar(50) not null,
    foreign key (customer_id) references dbo.customers(id)
);

insert into dbo.commande (customer_id, order_date, total_amount, status) values (1, '2024-01-01', 100.00, 'Pending');
insert into dbo.commande (customer_id, order_date, total_amount, status) values (2, '2024-01-02', 150.00, 'Completed'); 
insert into dbo.commande (customer_id, order_date, total_amount, status) values (1, '2024-01-03', 200.00, 'Shipped');
insert into dbo.commande (customer_id, order_date, total_amount, status) values (2, '2024-01-04', 250.00, 'Cancelled');
insert into dbo.commande (customer_id, order_date, total_amount, status) values (1, '2024-01-05', 300.00, 'Pending');
insert into dbo.commande (customer_id, order_date, total_amount, status) values (2, '2024-01-06', 350.00, 'Completed');
insert into dbo.commande (customer_id, order_date, total_amount, status) values (1, '2024-01-07', 400.00, 'Shipped');
insert into dbo.commande (customer_id, order_date, total_amount, status) values (2, '2024-01-08', 450.00, 'Cancelled');
insert into dbo.commande (customer_id, order_date, total_amount, status) values (1, '2024-01-09', 500.00, 'Pending');
insert into dbo.commande (customer_id, order_date, total_amount, status) values (2, '2024-01-10', 550.00, 'Completed');         
