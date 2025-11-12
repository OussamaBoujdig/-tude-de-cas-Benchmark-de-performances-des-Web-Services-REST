-- Generate 2000 categories and 100,000 items for performance testing
-- This script can be executed directly in PostgreSQL

-- Generate 2000 categories in batches for better performance
INSERT INTO category (name, description)
SELECT 
    'Category ' || i,
    'Description for category ' || i
FROM generate_series(1, 2000) AS i;

SELECT 'Categories created: ' || COUNT(*) FROM category;

-- Generate 100,000 items in optimized batches
-- Using UNLOGGED table temporarily for faster inserts, then convert back
DO $$
BEGIN
    -- Disable triggers temporarily for faster inserts
    ALTER TABLE item DISABLE TRIGGER ALL;
    
    -- Insert in one go with optimized query
    INSERT INTO item (name, description, price, quantity, category_id)
    SELECT 
        'Item ' || i,
        'Description for item ' || i,
        ROUND((random() * 1000)::numeric, 2),
        (random() * 100)::integer + 1,
        (random() * 1999)::integer + 1
    FROM generate_series(1, 100000) AS i;
    
    -- Re-enable triggers
    ALTER TABLE item ENABLE TRIGGER ALL;
END $$;

SELECT 'Items created: ' || COUNT(*) FROM item;

-- Verify data generation
SELECT 
    'Data generation complete' AS status,
    (SELECT COUNT(*) FROM category) AS categories_count,
    (SELECT COUNT(*) FROM item) AS items_count;

-- Show distribution
SELECT 
    'Distribution stats' AS info,
    MIN(item_count) AS min_items_per_category,
    MAX(item_count) AS max_items_per_category,
    ROUND(AVG(item_count), 2) AS avg_items_per_category
FROM (
    SELECT category_id, COUNT(*) AS item_count
    FROM item
    GROUP BY category_id
) AS category_stats;
