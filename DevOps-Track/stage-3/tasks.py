from celery import Celery
import smtplib
import logging
from datetime import datetime

app = Celery('tasks', broker='pyamqp://guest@localhost//')

@app.task
def send_email_task(recipient):
    sender = 'your_email@example.com'
    message = 'Subject: Test Email\n\nThis is a test email.'
    try:
        with smtplib.SMTP('localhost') as server:
            server.sendmail(sender, recipient, message)
        print(f"Email sent to {recipient}")
    except Exception as e:
        print(f"Failed to send email: {e}")

@app.task
def log_current_time():
    logging.basicConfig(filename='/var/log/messaging_system.log', level=logging.INFO)
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    logging.info(f"Current time logged: {current_time}")
