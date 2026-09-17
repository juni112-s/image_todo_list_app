from fastapi import APIRouter

router = APIRouter()

@router.post("/insert")
async def insert_todo():
    return {"message": "todo inserted"}
