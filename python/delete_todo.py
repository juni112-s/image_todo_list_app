from fastapi import APIRouter

router = APIRouter()

@router.delete("/delete/{todo_id}")
async def delete_todo(todo_id: int):
    return {"message": "todo deleted", "todo_id": todo_id}
