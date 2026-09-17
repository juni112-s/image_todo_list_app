from fastapi import APIRouter
import pymysql

router = APIRouter()

# @router.delete("/delete/{todo_id}")
# async def delete_todo(todo_id: int):
#     return {"message": "todo deleted", "todo_id": todo_id}

# SQL 등록
def connect_delete_todo():
    return pymysql.connect(
        host= '192.168.10.46',
        user= 'root',
        passwd= 'qwer1234',
        db='python',
        charset='utf8'
    )

# DB = 삭제 기능
@router.delete("/delete/{seq}")
async def delete(seq:int):
    conn = None
    try:
        conn = connect_delete_todo()
        curs = conn.cursor()
        curs.execute(
            "DELETE FROM relation_bet_todo_image WHERE todo_key = %s",
            (seq, )
        )
        curs.execute("DELETE FROM todo_list WHERE seq = %s", (seq))
        conn.commit()
        return {"result" : "OK"}
    except Exception as e:
        if conn:
            conn.rollback()
        print("Error", e)
        return{"result" : "Error"}
    finally:
        if conn:
            conn.close()
