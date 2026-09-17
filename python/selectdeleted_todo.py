from fastapi import APIRouter

router = APIRouter()

@router.get("/selectdeleted")
async def select_deleted_todo():
    return {"deleted_todos": []}
