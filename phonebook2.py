import psycopg2
from config import load_config

def call_bulk_insert(name_list, phone_list):
    config = load_config()
    try:
        with psycopg2.connect(**config) as conn:
            with conn.cursor() as cur:
                print("\n--- Запуск массовой вставки ---")
                
                for name, phone in zip(name_list, phone_list):
                    cur.execute("SELECT insert_single_contact(%s::text, %s::text)", (name, phone))
                    status = cur.fetchone()[0]
                    print(f"Контакт {name}: {status}")
                
                conn.commit()
                print("\n[УСПЕХ] Все операции завершены.")
    except Exception as e:
        print(f"Ошибка при выполнении: {e}")


def call_delete(identifier):
    config = load_config()
    try:
        with psycopg2.connect(**config) as conn:
            with conn.cursor() as cur:
                cur.execute("CALL delete_contact_v8(%s::text)", (identifier,))
                conn.commit()
                print(f"[Удаление] Запись '{identifier}' удалена.")
    except Exception as e:
        print(f"Ошибка удаления: {e}")

def call_pagination(limit, offset):
    config = load_config()
    try:
        with psycopg2.connect(**config) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT * FROM get_phonebook_paged(%s, %s)", (limit, offset))
                rows = cur.fetchall()
                print(f"\n--- Страница (Limit: {limit}, Offset: {offset}) ---")
                for row in rows:
                    print(f"{row[1]}: {row[2]}")
    except Exception as e:
        print(f"Ошибка пагинации: {e}")


if __name__ == '__main__':
    test_names = ['Alibek', 'Beka', 'Aidos', 'Temir']
    test_phones = ['87071112233', '87015554433', '87476665544', '12345']
    call_bulk_insert(test_names, test_phones)

    call_pagination(2, 0)

    call_delete('Temir')
