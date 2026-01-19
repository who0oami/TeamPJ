from fastapi import APIRouter
import config
import pymysql
import base64 # [추가] 이미지 인코딩을 위해 필요

router = APIRouter()

def connect():
    conn = pymysql.connect(
        host=config.hostip,
        port=config.hostPort,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )
    return conn

@router.get("/student/{student_id}")
async def get_student(student_id: int):
    db = connect()
    cursor = db.cursor()
    sql = "SELECT * FROM student WHERE student_id = %s"
    cursor.execute(sql, (student_id,))
    result = cursor.fetchone()
    db.close()
    
    if result:
        # [수정] 이미지 데이터(bytes)가 있다면 JSON 전송이 가능하도록 Base64 문자열로 변환
        if result.get('student_image'):
            result['student_image'] = base64.b64encode(result['student_image']).decode('utf-8')
        return result
    return {"error": "Student not found"}