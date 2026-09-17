from fastapi import FastAPI
from insert_todo import router as insert_router
from delete_todo import router as delete_router
from select_todo import router as select_router

app = FastAPI(title="Todo API")

app.include_router(insert_router, prefix="/todo", tags=["todo"])
app.include_router(delete_router, prefix="/todo", tags=["todo"])
app.include_router(select_router, prefix="/todo", tags=["todo"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("todolist:app", host='192.168.10.46', port=8000, reload=True)