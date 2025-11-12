-- REST API Performance Test Database Schema
-- PostgreSQL 15+

-- Drop existing tables
DROP TABLE IF EXISTS item CASCADE;
DROP TABLE IF EXISTS category CASCADE;

-- Create Category table
CREATE TABLE category (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Item table
CREATE TABLE item (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    category_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE
);

-- Create indexes for performance
CREATE INDEX idx_item_category_id ON item(category_id);
CREATE INDEX idx_category_name ON category(name);
CREATE INDEX idx_item_name ON item(name);
CREATE INDEX idx_item_price ON item(price);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER update_category_updated_at BEFORE UPDATE ON category
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_item_updated_at BEFORE UPDATE ON item
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Verify tables
SELECT 'Schema created successfully' AS status;
