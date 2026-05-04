--Register user
CREATE OR REPLACE FUNCTION register_user(input_username TEXT, input_password TEXT)
RETURNS TEXT
AS $$
DECLARE 
    exist_user INT = 0;
    hash_pass TEXT;
BEGIN
    IF input_username IS NULL OR TRIM(input_username) = '' THEN
        RETURN 'Username is invalid';
    END IF;

    IF input_password IS NULL OR TRIM(input_password) = '' THEN
        RETURN 'Password is invalid';
    END IF;

    hash_pass := crypt(input_password, gen_salt('bf'));
    INSERT INTO users(username, password) VALUES(input_username, hash_pass);
    RETURN 'Register successfully';
EXCEPTION
    WHEN unique_violation THEN
        RETURN 'User is existed';
END;
$$ LANGUAGE plpgsql;


--login
CREATE OR REPLACE FUNCTION login_user(input_username TEXT, input_password TEXT)
RETURNS TEXT
AS $$
DECLARE
    stored_hash TEXT;
    new_session TEXT;
BEGIN
    IF input_username IS NULL OR TRIM(input_username) = '' THEN
        RETURN 'USERNAME IS INVALID';
    END IF;

    IF input_password IS NULL OR TRIM(input_password) = '' THEN
        RETURN 'PASSWORD IS INVALID';
    END IF;

    select u.password into stored_hash from users u where u.username = input_username;
    if stored_hash IS NULL THEN
        RETURN 'USER NOT FOUND';
    END IF;

    IF stored_hash = crypt(input_password, stored_hash) THEN
        new_session := gen_random_uuid()::TEXT;
        INSERT INTO user_sessions(session_id, username, expires_at) VALUES (new_session, input_username, now()+interval '1 hour');
        RETURN new_session;
    ELSE
        RETURN 'Login Failure';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
        RETURN SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- check session for every single request
CREATE OR REPLACE FUNCTION check_session(input_session TEXT)
RETURNS TEXT
AS $$
DECLARE
    v_username TEXT;
BEGIN
    SELECT username INTO v_username FROM user_sessions WHERE session_id = input_session AND expires_at > now();

    IF NOT FOUND THEN
        RETURN 'SESSION INVALID';
    END IF;

    UPDATE user_sessions SET last_seen_at = now() , expires_at = now() + interval '1 hour' WHERE session_id = input_session;
    RETURN v_username;
END;
$$ LANGUAGE plpgsql;