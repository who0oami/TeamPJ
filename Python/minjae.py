from fastapi import APIRouter
from pydantic import BaseModel
import config
import pymysql

router = APIRouter()


def connect():
    conn = pymysql.connect(
        host=config.hostip,
        port=config.hostport,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )
    return conn

@router.get("/select")
async def select(guardian_id: int):
    conn = connect()
    curs = conn.cursor()

    sql = "SELECT * FROM guardian WHERE guardian_id=%s"
    curs.execute(sql,(guardian_id))
    rows = curs.fetchall()
    conn.close()

    result = [{
        'guardian_id': row['guardian_id'],
        'student_id': row['student_id'],
        'guardian_name': row['guardian_name'],
        'guardian_email': row['guardian_email'],
        'guardian_phone': row['guardian_phone'],
        'guardian_password': row['guardian_password'],
        'sub_guardian_name': row['sub_guardian_name'],
        'sub_guardian_phone': "" if row['sub_guardian_phone'] is None else row['sub_guardian_phone']
    } for row in rows]

    return {'results': result}

