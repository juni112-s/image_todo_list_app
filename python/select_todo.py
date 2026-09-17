from fastapi import APIRouter, UploadFile, Form, File
from fastapi.responses import Response
import pymysql

def connect():
    return pymysql.connect(
        host = '192.168.10.46',
        user = 'root',
        password = 'qwer1234',
        database = 'python',
        charset = 'utf8'
    )

router = APIRouter()

@router.get("/select_todo")
async def select_todo():
    conn = connect()
    curs = conn.cursor()
    curs.execute('SELECT * FROM todo_list')
    data = curs.fetchall()
    conn.close()
    result = [
        {
            'seq' : row[0],
            'title' : row[1],
            'added_date' : row[2],
        }
        for row in data
    ]
    return {'results' : result}

@router.get("/select_image/{seq}")
async def select_image(seq : int):
    try:
        conn = connect()
        curs = conn.cursor()
        sql =   """
                SELECT ti.image_data FROM relation_bet_todo_image as rti
                INNER JOIN todo_image as ti ON rti.image_key = ti.seq
                WHERE rti.todo_key = %s;
                """
        curs.execute(sql, (seq, ))
        row = curs.fetchone()
        conn.close()
        if row and row[0]:#row는 정상적으로 생겼지만 데이터는 없을수도 있음
            return Response(
                content = row[0],
                media_type = 'image/jpeg',
                headers = {"Cache-Control" : "no-cache, no-store, must-revaliate"}
            )
        else:
            return{'result' : 'No image found'}
    except Exception as e:
        print('Error :',e)
        return{'result':'Error'}

@router.post("/upload_image")
async def upload_image(
    file : UploadFile = File(...)
    ):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        curs.execute('INSERT INTO todo_image (image_data) VALUES (%s)', (image_data, ))
        conn.commit()
        conn.close()
        return {"result" : "OK"}
    except Exception as e:
        print('Error : ', e)
        return {"result" : "Error"}