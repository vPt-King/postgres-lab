--Register user
CREATE OR REPLACE FUNCTION register_user(input_username TEXT, input_password TEXT)
RETURNS TEXT
AS $$
DECLARE 
    exist_user INT = 0;
    hash_pass TEXT;
BEGIN
    hash_pass := crypt(input_password, gen_salt('bf'));
    INSERT INTO users(username, password) VALUES(input_username, hash_pass);
    RETURN 'Register successfully';
EXCEPTION
    WHEN unique_violation THEN
        RETURN 'User is existed';
END;
$$ LANGUAGE plpgsql;