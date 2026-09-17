from fastapi import APIRouter
import pymysql
router = APIRouter()

@router.delete("/delete/{todo_id}")
async def delete_todo(todo_id: int):
    return {"message": "todo deleted", "todo_id": todo_id}


def connect_delete_todo():
    return pymysql.connect(
        host= '192.168.10.46',
        user= 'root',
        passwd= 'qwer1234',
        db='python',
        charset='utf8'
    )

@router.delete("/delete/{seq}")
async def delete(seq:int):
    try:
        conn = connect_delete_todo()
        curs = conn.cursor()
        curs.execute("DELETE FROM image WHERE seq = %s", (seq))
        conn.commit()
        conn.close()
        return {"result" : "OK"}
    except Exception as e:
        print("Error", e)
        return{"result" : "Error"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(router, host='192.168.10.46', port=8000)