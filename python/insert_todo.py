from fastapi import APIRouter, UploadFile, File
import pymysql

router = APIRouter()

def connect():
    return pymysql.connect(
        host = '192.168.10.46',
        user = 'root',
        passwd = 'qwer1234',
        database = 'python',
        charset = 'utf8'
    )

@router.post("/insert")
async def insert_todo(
    title: str, 
    added_date: str,
    image: int,
    ):
    conn = connect()
    curs = conn.cursor()

    # Todo 추가
    sql = '''
            INSERT INTO todo_list(title, added_date)
            VALUES (%s, %s)
        '''

    curs.execute(sql, (title, added_date))
    todo_key = curs.lastrowid

    # Todo + 이미지
    sql = '''
            INSERT INTO relation_bet_todo_image(todo_key, image_key)
            VALUES (%s, %s)
        '''
    curs.execute(sql, (todo_key, image))

    conn.commit()

    curs.close()
    conn.close()

    return {
        'result': 'OK',
        'todo_key': todo_key
    }
