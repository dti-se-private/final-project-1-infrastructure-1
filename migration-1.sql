-- extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ddl
-- Create the warehouse table
CREATE TABLE warehouse (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), 
    name TEXT NOT NULL UNIQUE,
    description TEXT, 
    location GEOGRAPHY 
);

-- Create the warehouse_product table
CREATE TABLE warehouse_product (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), 
    warehouse_id UUID NOT NULL REFERENCES warehouse(id) ON DELETE CASCADE, 
    product_id UUID NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    quantity NUMERIC NOT NULL CHECK (quantity >= 0)
);

-- Create the warehouse_ledger table
CREATE TABLE warehouse_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), 
    warehouse_product_id UUID NOT NULL REFERENCES warehouse_product(id) ON DELETE CASCADE,
    pre_quantity NUMERIC NOT NULL CHECK (pre_quantity >= 0),
    post_quantity NUMERIC NOT NULL CHECK (post_quantity >= 0),
    time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_approved BOOLEAN DEFAULT FALSE 
);

-- Create the category table
CREATE TABLE category (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT                              
);

-- Create the product table
CREATE TABLE product (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES category(id) ON DELETE SET NULL,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    price NUMERIC(15, 2) NOT NULL CHECK (price >= 0),
    image BYTEA
);

DROP TABLE IF EXISTS account CASCADE;
CREATE TABLE account (
    id UUID PRIMARY KEY,
    name TEXT,
    email TEXT UNIQUE,
    password TEXT,
    phone TEXT,
    dob TIMESTAMPTZ,
    referral_code TEXT UNIQUE,
    profile_image_url TEXT
);

DROP TABLE IF EXISTS session CASCADE;
CREATE TABLE session (
    id UUID PRIMARY KEY,
    account_id UUID REFERENCES account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    access_token TEXT UNIQUE,
    refresh_token TEXT UNIQUE,
    access_token_expired_at TIMESTAMPTZ,
    refresh_token_expired_at TIMESTAMPTZ
);

-- Create the order table
DROP TABLE IF EXISTS "order" CASCADE;
CREATE TABLE "order" (  
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    account_id UUID NOT NULL,  
    total_price NUMERIC NOT NULL,  
    shipment_price NUMERIC NOT NULL,  
    item_price NUMERIC NOT NULL,  
    FOREIGN KEY (account_id) REFERENCES account(id)  
); 

-- Create the order item table
DROP TABLE IF EXISTS order_item CASCADE;
CREATE TABLE order_item (  
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    order_id UUID NOT NULL,  
    product_id UUID NOT NULL,  
    quantity NUMERIC NOT NULL,  
    FOREIGN KEY (order_id) REFERENCES order_table(id),  
    FOREIGN KEY (product_id) REFERENCES product(id)  
);  

-- Create the order status table 
DROP TABLE IF EXISTS order_status CASCADE;
CREATE TABLE order_status (  
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    order_id UUID NOT NULL,  
    status TEXT NOT NULL,  
    time TIMESTAMPTZ NOT NULL,  
    FOREIGN KEY (order_id) REFERENCES order_table(id)  
);  

-- Create the account permission table
DROP TABLE IF EXISTS account_permission CASCADE;
CREATE TABLE account_permission (  
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    account_id UUID NOT NULL,  
    permission TEXT NOT NULL,  
    FOREIGN KEY (account_id) REFERENCES account(id)  
);

-- Create the account address table
DROP TABLE IF EXISTS account_address CASCADE;
CREATE TABLE account_address (  
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    account_id UUID NOT NULL,  
    name TEXT NOT NULL,  
    address TEXT NOT NULL,  
    location GEOGRAPHY,  
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,  
    FOREIGN KEY (account_id) REFERENCES account(id)  
);

-- Create the verification table
DROP TABLE IF EXISTS verification CASCADE;
CREATE TABLE verification (  
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    account_id UUID NOT NULL,  
    type TEXT NOT NULL,  
    code TEXT NOT NULL,  
    init_time TIMESTAMPTZ NOT NULL,  
    end_time TIMESTAMPTZ NOT NULL,  
    FOREIGN KEY (account_id) REFERENCES account(id)  
);

-- Create the cart item table
DROP TABLE IF EXISTS cart_item CASCADE;
CREATE TABLE cart_item (  
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    account_id UUID NOT NULL,  
    product_id UUID NOT NULL,  
    quantity NUMERIC NOT NULL,  
    FOREIGN KEY (account_id) REFERENCES account(id),  
    FOREIGN KEY (product_id) REFERENCES product(id)  
);

-- Create the payment proof table
DROP TABLE IF EXISTS payment_proof CASCADE;
CREATE TABLE payment_proof (  
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    order_id UUID NOT NULL,  
    file BYTEA NOT NULL,  
    extension TEXT NOT NULL,  
    time TIMESTAMPTZ NOT NULL,  
    FOREIGN KEY (order_id) REFERENCES order_table(id)  
);

-- dml
INSERT INTO account (id, name, email, password, phone) VALUES
(uuid_generate_v4(), 'admin', 'admin@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456789'),
(uuid_generate_v4(), 'Beth', 'beth@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456780'),
(uuid_generate_v4(), 'Charles', 'charles@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456781'),
(uuid_generate_v4(), 'Diana', 'diana@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456782'),
(uuid_generate_v4(), 'Edward', 'edward@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456783'),
(uuid_generate_v4(), 'Fiona', 'fiona@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456784'),
(uuid_generate_v4(), 'George', 'george@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456785'),
(uuid_generate_v4(), 'Hannah', 'hannah@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456786'),
(uuid_generate_v4(), 'Isaac', 'isaac@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456787'),
(uuid_generate_v4(), 'Jasmine', 'jasmine@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456788'),
(uuid_generate_v4(), 'Kevin', 'kevin@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456789'),
(uuid_generate_v4(), 'Lila', 'lila@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456790'),
(uuid_generate_v4(), 'Mark', 'mark@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456791'),
(uuid_generate_v4(), 'Nina', 'nina@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456792'),
(uuid_generate_v4(), 'Owen', 'owen@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456793'),
(uuid_generate_v4(), 'Paula', 'paula@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456794'),
(uuid_generate_v4(), 'Quinn', 'quinn@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456795'),
(uuid_generate_v4(), 'Rita', 'rita@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456796'),
(uuid_generate_v4(), 'Sam', 'sam@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456797'),
(uuid_generate_v4(), 'Tina', 'tina@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456798'),
(uuid_generate_v4(), 'Ursula', 'ursula@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456799'),
(uuid_generate_v4(), 'Victor', 'victor@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456800'),
(uuid_generate_v4(), 'Wendy', 'wendy@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456801'),
(uuid_generate_v4(), 'Xander', 'xander@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456802'),
(uuid_generate_v4(), 'Yasmine', 'yasmine@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456803'),
(uuid_generate_v4(), 'Zack', 'zack@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456804'),
(uuid_generate_v4(), 'Alicia', 'alicia@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456805'),
(uuid_generate_v4(), 'Brian', 'brian@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456806'),
(uuid_generate_v4(), 'Cindy', 'cindy@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456807'),
(uuid_generate_v4(), 'David', 'david@mail.com', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86', '08123456808');

INSERT INTO session (id, account_id, access_token, refresh_token, access_token_expired_at, refresh_token_expired_at)
SELECT uuid_generate_v4(), id, uuid_generate_v4(), uuid_generate_v4(), now() + interval '1 hour', now() + interval '1 day' 
FROM account;

-- dql
SELECT * 
FROM account
INNER JOIN session ON session.account_id = account.id
WHERE account.id in (SELECT id FROM account LIMIT 1 OFFSET 0)
LIMIT 1 OFFSET 0;
