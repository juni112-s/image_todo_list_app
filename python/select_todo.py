from fastapi import APIRouter

router = APIRouter()

@router.get("/select")
async def select_todo():
    return {"todos": []}
