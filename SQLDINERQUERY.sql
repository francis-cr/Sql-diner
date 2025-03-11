/** What is the total amount each customer spent at the restaurant?**/
select s.customer_id, sum(m.price) Toat_price from sales s
join menu m
on s.product_id = m.product_id
group by s.customer_id

--How many days has each customer visited the restaurant?--
select customer_id, count(order_date) from sales
group by customer_id

--What was the first item from the menu purchased by each customer?
with First as
(
select s.customer_id, m.product_name, 
row_number () over(partition by s.customer_id order by m.product_id) RN
from sales s
join menu m
on m.product_id = s.product_id
)
SELECT customer_id, product_name from first
where rn = 1

--What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 m.product_name, count(m.product_id)Most_purchase from menu m
join sales s
on m.product_id = s.product_id
group by m.product_name
order by count(m.product_id) desc

--Which item was the most popular for each customer?
with Most_populular as
(
select s.customer_id, m.product_name, count(m.product_id) T,
ROW_NUMBER () over ( partition by s.customer_id order by count(m.product_id)) as rn
from menu m
join sales s
on s.product_id=m.product_id
group by s.customer_id, m.product_name
)

select customer_id, product_name from Most_populular
where rn = 1

--Which item was purchased first by the customer after they became a member?
with first_purchase as
(
select s.customer_id, m.product_name,
row_number () over(partition by s.customer_id order by m.product_id) as R
from sales s 
join menu m
on m.product_id = s.product_id
join members w
on w.customer_id = s.customer_id
where s.order_date >= w.join_date
)
select customer_id, product_name from first_purchase
where r = 1

--Which item was purchased just before the customer became a member?
with first_purchase as
(
select s.customer_id, m.product_name,
row_number () over(partition by s.customer_id order by m.product_id) as R
from sales s 
join menu m
on m.product_id = s.product_id
join members w
on w.customer_id = s.customer_id
where s.order_date < w.join_date
)
select customer_id, product_name from first_purchase
where r = 1

--What is the total items and amount spent for each member before they became a member?
--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with second as
(
select s.customer_id, m.price,
case
when 
m.product_name = 'sushi' then m.price * 10 * 2
else price * 10
end as T_price
from sales s
join menu m
on s.product_id = m.product_id
)
select customer_id, sum(t_price) Point from second
group by customer_id


--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--not just sushi - how many points do customer A and B have at the end of January? **/
with first as
(
select s.customer_id, m.price,
case
when m.product_name = 'sushi'and s.order_date >= w.join_date then m.price * 2 * 2 *10
when m.product_name = 'sushi' and s.order_date <= w.join_date then m.price  * 2 * 10
 when m.product_name <> 'sushi'and s.order_date >= w.join_date then m.price * 2 *10
 else price * 10
 end as Point
from sales s
join menu m
on m.product_id = s.product_id
join members w
on w.customer_id = s.customer_id
)
Select customer_id, sum(point) as T_point from First





