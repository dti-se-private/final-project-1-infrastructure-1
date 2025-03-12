
-- dql
SELECT * 
FROM account
INNER JOIN session ON session.account_id = account.id
WHERE account.id in (SELECT id FROM account LIMIT 1 OFFSET 0)
LIMIT 1 OFFSET 0;

select (now()-interval) - time, now() - interval, interval
from (values (now(), '1 day'::interval)) as t(time, interval)
where ((now()-interval-interval) - time) <= interval '-1 days';


SELECT
DATE_TRUNC('day', stock_ledger.time) as x,
SUM(stock_ledger.post_quantity - stock_ledger.pre_quantity) as y
FROM stock_ledger
INNER JOIN warehouse_product ON warehouse_product.id = stock_ledger.warehouse_product_id
WHERE (stock_ledger.post_quantity - stock_ledger.pre_quantity) > 0
AND warehouse_product.warehouse_id in (
    SELECT DISTINCT warehouse_admin.warehouse_id
    FROM warehouse_admin
)
GROUP BY x
ORDER BY x;

SELECT json_build_object(
    'id', warehouse_ledger.id,
    'origin_warehouse_product', json_build_object(
        'id', warehouse_product_origin.id,
        'quantity', warehouse_product_origin.quantity,
        'warehouse', json_build_object(
            'id', warehouse_origin.id,
            'name', warehouse_origin.name,
            'description', warehouse_origin.description,
            'location', warehouse_origin.location
        ),
        'product', json_build_object(
            'id', product_origin.id,
            'name', product_origin.name,
            'description', product_origin.description,
            'price', product_origin.price,
            'image', product_origin.image,
            'category', json_build_object(
                'id', category_origin.id,
                'name', category_origin.name,
                'description', category_origin.description
            )
        )
    ),
    'destination_warehouse_product', json_build_object(
        'id', warehouse_product_destination.id,
        'quantity', warehouse_product_destination.quantity,
        'warehouse', json_build_object(
            'id', warehouse_destination.id,
            'name', warehouse_destination.name,
            'description', warehouse_destination.description,
            'location', warehouse_destination.location
        ),
        'product', json_build_object(
            'id', product_destination.id,
            'name', product_destination.name,
            'description', product_destination.description,
            'price', product_destination.price,
            'image', product_destination.image,
            'category', json_build_object(
                'id', category_destination.id,
                'name', category_destination.name,
                'description', category_destination.description
            )
        )
    ),
    'origin_pre_quantity', warehouse_ledger.origin_pre_quantity,
    'origin_post_quantity', warehouse_ledger.origin_post_quantity,
    'destination_pre_quantity', warehouse_ledger.destination_pre_quantity,
    'destination_post_quantity', warehouse_ledger.destination_post_quantity,
    'time', warehouse_ledger.time,
    'status', warehouse_ledger.status
) as item
FROM warehouse_ledger
INNER JOIN warehouse_product AS warehouse_product_origin ON warehouse_ledger.origin_warehouse_product_id = warehouse_product_origin.id
INNER JOIN warehouse_product AS warehouse_product_destination ON warehouse_ledger.destination_warehouse_product_id = warehouse_product_destination.id
INNER JOIN product AS product_origin ON product_origin.id = warehouse_product_origin.product_id
INNER JOIN product AS product_destination ON product_destination.id = warehouse_product_destination.product_id
INNER JOIN category AS category_origin ON category_origin.id = product_origin.category_id
INNER JOIN category AS category_destination ON category_destination.id = product_destination.category_id
INNER JOIN warehouse AS warehouse_origin ON warehouse_origin.id = warehouse_product_origin.warehouse_id
INNER JOIN warehouse AS warehouse_destination ON warehouse_destination.id = warehouse_product_destination.warehouse_id;
                

SELECT json_build_object(
    'id', warehouse_ledger.id,
    'origin_warehouse_product', origin_warehouse_product.details,
    'destination_warehouse_product', destination_warehouse_product.details,
    'origin_pre_quantity', warehouse_ledger.origin_pre_quantity,
    'origin_post_quantity', warehouse_ledger.origin_post_quantity,
    'destination_pre_quantity', warehouse_ledger.destination_pre_quantity,
    'destination_post_quantity', warehouse_ledger.destination_post_quantity,
    'time', warehouse_ledger.time,
    'status', warehouse_ledger.status
) AS item
FROM warehouse_ledger,
LATERAL (
    SELECT json_build_object(
        'id', warehouse_product.id,
        'quantity', warehouse_product.quantity,
        'warehouse', json_build_object(
            'id', warehouse.id,
            'name', warehouse.name,
            'description', warehouse.description,
            'location', warehouse.location
        ),
        'product', json_build_object(
            'id', product.id,
            'name', product.name,
            'description', product.description,
            'price', product.price,
            'image', product.image,
            'category', json_build_object(
                'id', category.id,
                'name', category.name,
                'description', category.description
            )
        )
    ) AS details
    FROM warehouse_product
    INNER JOIN warehouse ON warehouse_product.warehouse_id = warehouse.id
    INNER JOIN product ON warehouse_product.product_id = product.id
    INNER JOIN category ON product.category_id = category.id
    WHERE warehouse_product.id = warehouse_ledger.origin_warehouse_product_id
) AS origin_warehouse_product,
LATERAL (
    SELECT json_build_object(
        'id', warehouse_product.id,
        'quantity', warehouse_product.quantity,
        'warehouse', json_build_object(
            'id', warehouse.id,
            'name', warehouse.name,
            'description', warehouse.description,
            'location', warehouse.location
        ),
        'product', json_build_object(
            'id', product.id,
            'name', product.name,
            'description', product.description,
            'price', product.price,
            'image', product.image,
            'category', json_build_object(
                'id', category.id,
                'name', category.name,
                'description', category.description
            )
        )
    ) AS details
    FROM warehouse_product
    INNER JOIN warehouse ON warehouse_product.warehouse_id = warehouse.id
    INNER JOIN product ON warehouse_product.product_id = product.id
    INNER JOIN category ON product.category_id = category.id
    WHERE warehouse_product.id = warehouse_ledger.destination_warehouse_product_id
) AS destination_warehouse_product;