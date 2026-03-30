CREATE OR REPLACE PROCEDURE upsert_contact(p_name VARCHAR, p_phone VARCHAR)
AS $$
BEGIN
    INSERT INTO phonebook (contact_name, phone_number)
    VALUES (p_name, p_phone)
    ON CONFLICT (contact_name) DO UPDATE 
    SET phone_number = EXCLUDED.phone_number;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delete_contact_v2(p_identifier VARCHAR)
AS $$
BEGIN
    DELETE FROM phonebook 
    WHERE contact_name = p_identifier OR phone_number = p_identifier;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION bulk_insert_contacts(names TEXT[], phones TEXT[])
RETURNS TABLE(rejected_name TEXT, rejected_phone TEXT, reason TEXT) AS $$
DECLARE
    i INT;
BEGIN
    -- Цикл по длине массива имен
    FOR i IN 1..array_length(names, 1) LOOP
        -- Простая валидация: номер должен быть не короче 10 символов
        IF length(phones[i]) < 10 THEN
            rejected_name := names[i];
            rejected_phone := phones[i];
            reason := 'Phone too short';
            RETURN NEXT;
        ELSE
            -- Сама вставка. Если имя уже есть — обновляем телефон (Upsert)
            INSERT INTO phonebook (contact_name, phone_number)
            VALUES (names[i], phones[i])
            ON CONFLICT (contact_name) DO UPDATE 
            SET phone_number = EXCLUDED.phone_number;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 1. Процедура для удаления по имени ИЛИ телефону
CREATE OR REPLACE PROCEDURE delete_contact_v8(p_val TEXT)
AS $$
BEGIN
    DELETE FROM phonebook WHERE contact_name = p_val OR phone_number = p_val;
END;
$$ LANGUAGE plpgsql;

-- 2. Функция для пагинации (вывод частями)
CREATE OR REPLACE FUNCTION get_phonebook_paged(p_limit INT, p_offset INT)
RETURNS TABLE(id INT, name VARCHAR, phone VARCHAR) AS $$
BEGIN
    RETURN QUERY 
    SELECT * FROM phonebook 
    ORDER BY contact_name 
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;