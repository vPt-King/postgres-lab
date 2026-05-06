-- add product
CREATE OR REPLACE FUNCTION add_product(input_name TEXT, input_price INT, input_quantity INT, input_descrption TEXT)
RETURNS TEXT
AS $$
BEGIN
    IF input_name IS NULL OR TRIM(input_name) = '' THEN
        RETURN 'NAME IS INVALID';
    END IF;

    IF input_price IS NULL OR input_price < 0 THEN
        RETURN 'PRICE IS INVALID';
    END IF;

    IF input_quantity IS NULL OR input_quantity < 0 THEN
        RETURN 'QUANTITY IS INVALID';
    END IF;

    INSERT INTO products(name, price, quantity, description) VALUES(input_name, input_price, input_quantity, input_descrption);
    RETURN 'Add product successfully';
END;
$$ LANGUAGE plpgsql;