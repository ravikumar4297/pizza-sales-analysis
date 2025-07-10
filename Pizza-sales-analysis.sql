use pizzasales

--Retrieve the total number of orders placed.

select COUNT(order_id) as Total_orders
from orders;

--Calculate the total revenue generated from pizza sales.

select sum(order_details.quantity * pizzas.price) as Total_Sales
from order_details
    join pizzas
        on pizzas.pizza_id = order_details.pizza_id;


--Identify the highest-priced pizza.

select top 1
    pizza_types.name,
    pizzas.price
from pizza_types
    join pizzas
        on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc;

--Identify the most common pizza size ordered.

select pizzas.size,
       COUNT(order_details.order_details_id) as Order_count
from pizzas
    join order_details
        on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by count(order_details.order_details_id) desc;

--List the top 5 most ordered pizza types along with their quantities.

select top 5
    name as Name_of_the_Pizza,
    sum(quantity) as Total_quantity_sold
from pizza_types
    join pizzas
        on pizza_types.pizza_type_id = pizzas.pizza_type_id
    join order_details
        on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by Total_quantity_sold desc;

--Join the necessary tables to find the total quantity of each pizza category ordered.

select category,
       sum(quantity) as qty
from pizza_types
    join pizzas
        on pizza_types.pizza_type_id = pizzas.pizza_type_id
    join order_details
        on order_details.pizza_id = pizzas.pizza_id
group by category
order by qty desc;

--Determine the distribution of orders by hour of the day.

select DATEPART(hour, order_time) as Time,
       count(order_id) as Order_count
from orders
group by DATEPART(hour, order_time)
order by DATEPART(hour, order_time);

--Join relevant tables to find the category-wise distribution of pizzas.

select category,
       count(name) as Pizza_count
from pizza_types
group by category;

--Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(qty) as average_pizza_order_per_day
from
(
    select order_date,
           sum(quantity) as qty
    from orders
        join order_details
            on order_details.order_id = orders.order_id
    group by order_date
) as Order_qty;

--Determine the top 3 most ordered pizza types based on revenue.

select top 3
    pizza_types.name,
    sum(order_details.quantity * pizzas.price) as revenue
from pizza_types
    join pizzas
        on pizzas.pizza_type_id = pizza_types.pizza_type_id
    join order_details
        on order_details.pizza_id = pizzas.pizza_id
group by name
order by revenue desc;

--Advanced

--Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
       cast(round(   sum(order_details.quantity * pizzas.price) /
                     (
                         select SUM(quantity * price)
                         from order_details
                             join pizzas
                                 on pizzas.pizza_id = order_details.pizza_id
                     ) * 100,
                     2
                 ) as int) as revenue
from pizza_types
    join pizzas
        on pizzas.pizza_type_id = pizza_types.pizza_type_id
    join order_details
        on order_details.pizza_id = pizzas.pizza_id
group by category
order by revenue desc;

--Analyze the cumulative revenue generated over time.

select order_date,
       sum(revenue) over (order by order_date) as cumulative_revenue
from
(
    select orders.order_date as order_date,
           SUM(pizzas.price * order_details.quantity) as revenue
    from order_details
        join pizzas
            on order_details.pizza_id = pizzas.pizza_id
        join orders
            on order_details.order_id = orders.order_id
    group by order_date
) as sales;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,
       revenue,
       Rank
from
(
    select category,
           name,
           revenue,
           rank() over (partition by category order by revenue desc) as Rank
    from
    (
        select pizza_types.category as category,
               pizza_types.name as name,
               SUM(pizzas.price * order_details.quantity) as revenue
        from pizza_types
            join pizzas
                on pizza_types.pizza_type_id = pizzas.pizza_type_id
            join order_details
                on order_details.pizza_id = pizzas.pizza_id
        group by category,
                 name
    ) as a
) as b
where Rank <= 3;

