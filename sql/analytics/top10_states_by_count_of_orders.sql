CREATE VIEW top10_states_by_count_of_orders AS
SELECT s.state_name, COUNT(*) FROM orders o
JOIN order_statuses os ON o.order_status_id = os.order_status_id
JOIN (SELECT customer_id, state_id FROM customers) c ON o.customer_id = c.customer_id
JOIN states s ON s.state_id = c.state_id
WHERE o.order_status_id <> 1 AND o.order_status_id <> 7
GROUP BY s.state_name
ORDER BY COUNT(*) DESC
LIMIT 10;