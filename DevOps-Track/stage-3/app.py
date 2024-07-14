from fastapi import FastAPI, Query
from tasks import send_email_task, log_current_time

app = FastAPI()

@app.get("/")
async def index(sendmail: str = Query(None), talktome: bool = Query(False)):
    if sendmail:
        send_email_task.delay(sendmail)
        return {"message": f"Email to {sendmail} has been queued."}
    if talktome:
        log_current_time.delay()
        return {"message": "Current time has been logged."}
    return {"message": "Please provide a valid parameter."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
