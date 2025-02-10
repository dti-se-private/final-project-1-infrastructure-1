-- Active: 1732281362598@@127.0.0.1@5432@db
-- extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ddl
-- Create the account table
DROP TABLE IF EXISTS account CASCADE;
CREATE TABLE account (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT,
    email TEXT UNIQUE,
    password TEXT NULL,
    phone TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    image BYTEA
);

-- Create the provider table
DROP TABLE IF EXISTS provider CASCADE;
CREATE TABLE provider (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    name TEXT
);

-- Create the session table
DROP TABLE IF EXISTS session CASCADE;
CREATE TABLE session (
    id UUID PRIMARY KEY,
    account_id UUID REFERENCES account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    access_token TEXT UNIQUE,
    refresh_token TEXT UNIQUE,
    access_token_expired_at TIMESTAMPTZ,
    refresh_token_expired_at TIMESTAMPTZ
);

-- Create the account address table
DROP TABLE IF EXISTS account_address CASCADE;
CREATE TABLE account_address (  
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    account_id UUID REFERENCES account(id) ON DELETE CASCADE ON UPDATE CASCADE,   
    name TEXT,  
    address TEXT,  
    location geography,
    is_primary BOOLEAN DEFAULT FALSE
);

-- Create the warehouse table
DROP TABLE IF EXISTS warehouse CASCADE;
CREATE TABLE warehouse (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), 
    name TEXT,
    description TEXT, 
    location GEOGRAPHY 
);

-- Create the warehouse admin
DROP TABLE IF EXISTS warehouse_admin CASCADE;
CREATE TABLE warehouse_admin (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), 
    account_id UUID REFERENCES account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    warehouse_id UUID REFERENCES warehouse(id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (account_id, warehouse_id)
);

-- Create the category table
DROP TABLE IF EXISTS category CASCADE;
CREATE TABLE category (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT,
    description TEXT                              
);

-- Create the product table
DROP TABLE IF EXISTS product CASCADE;
CREATE TABLE product (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES category(id) ON DELETE SET NULL,
    name TEXT,
    description TEXT,
    price NUMERIC(15, 2) NOT NULL CHECK (price >= 0),
    image BYTEA
);

-- Create the warehouse_product table
DROP TABLE IF EXISTS warehouse_product CASCADE;
CREATE TABLE warehouse_product (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), 
    warehouse_id UUID NOT NULL REFERENCES warehouse(id) ON DELETE CASCADE ON UPDATE CASCADE, 
    product_id UUID NOT NULL REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE,
    quantity NUMERIC NOT NULL CHECK (quantity >= 0)
);

-- Create the warehouse_ledger table
DROP TABLE IF EXISTS warehouse_ledger CASCADE;
CREATE TABLE warehouse_ledger (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), 
    product_id UUID NOT NULL REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE,
    origin_warehouse_id UUID NOT NULL REFERENCES warehouse(id) ON DELETE CASCADE ON UPDATE CASCADE,
    destination_warehouse_id UUID NOT NULL REFERENCES warehouse(id) ON DELETE CASCADE ON UPDATE CASCADE,
    origin_pre_quantity NUMERIC NOT NULL CHECK (origin_pre_quantity >= 0),
    origin_post_quantity NUMERIC NOT NULL CHECK (origin_post_quantity >= 0),
    destination_pre_quantity NUMERIC NOT NULL CHECK (destination_pre_quantity >= 0),
    destination_post_quantity NUMERIC NOT NULL CHECK (destination_post_quantity >= 0),
    time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'WAITING_FOR_APPROVAL' CHECK (status IN ('APPROVED', 'REJECTED', 'WAITING_FOR_APPROVAL'))
);

-- Create the order table
DROP TABLE IF EXISTS "order" CASCADE;
CREATE TABLE "order" (  
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    account_id UUID NOT NULL REFERENCES account(id) ON DELETE CASCADE ON UPDATE CASCADE ,  
    total_price NUMERIC NOT NULL,  
    shipment_origin GEOGRAPHY NOT NULL,
    shipment_destination GEOGRAPHY NOT NULL,
    shipment_price NUMERIC NOT NULL,  
    item_price NUMERIC NOT NULL,
    origin_warehouse_id UUID NOT NULL REFERENCES warehouse(id) ON DELETE CASCADE ON UPDATE CASCADE
); 

-- Create the order item table
DROP TABLE IF EXISTS order_item CASCADE;
CREATE TABLE order_item (  
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    order_id UUID NOT NULL REFERENCES "order"(id) ON DELETE CASCADE ON UPDATE CASCADE,  
    product_id UUID NOT NULL REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE,  
    quantity NUMERIC NOT NULL,
    warehouse_ledger_id UUID NULL REFERENCES warehouse_ledger(id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (order_id, product_id)  
);  

-- Create the order status table 
DROP TABLE IF EXISTS order_status CASCADE;
CREATE TABLE order_status (  
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    order_id UUID NOT NULL REFERENCES "order"(id) ON DELETE CASCADE ON UPDATE CASCADE  ,  
    status TEXT NOT NULL DEFAULT 'WAITING_FOR_PAYMENT' CHECK (status IN ('WAITING_FOR_PAYMENT', 'WAITING_FOR_PAYMENT_CONFIRMATION', 'PROCESSING', 'SHIPPING', 'ORDER_CONFIRMED', 'CANCELED')),
    time TIMESTAMPTZ NOT NULL
);  

-- Create the account permission table
DROP TABLE IF EXISTS account_permission CASCADE;
CREATE TABLE account_permission (  
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    account_id UUID NOT NULL REFERENCES account(id) ON DELETE CASCADE ON UPDATE CASCADE,  
    permission TEXT NOT NULL 
);

-- Create the verification table
DROP TABLE IF EXISTS verification CASCADE;
CREATE TABLE verification (  
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    email TEXT NOT NULL,  
    type TEXT NOT NULL,  
    code TEXT NOT NULL,  
    init_time TIMESTAMPTZ NOT NULL,  
    end_time TIMESTAMPTZ NOT NULL
);

-- Create the cart item table
DROP TABLE IF EXISTS cart_item CASCADE;
CREATE TABLE cart_item (  
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    account_id UUID REFERENCES account(id) ON DELETE CASCADE ON UPDATE CASCADE,  
    product_id UUID REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE,  
    quantity NUMERIC,
    unique (account_id, product_id)
);

-- Create the payment proof table
DROP TABLE IF EXISTS payment_proof CASCADE;
CREATE TABLE payment_proof (  
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    order_id UUID REFERENCES "order" (id) ON DELETE CASCADE ON UPDATE CASCADE,  
    file BYTEA,  
    extension TEXT,  
    time TIMESTAMPTZ
);