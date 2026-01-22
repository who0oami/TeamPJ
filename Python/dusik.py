# -*- coding: utf-8 -*-
"""
author      : 유지현
Description : SQL의 python Database와 CRUD on Web
"""

from fastapi import APIRouter, File, Form, UploadFile
from pydantic import BaseModel
import config
import pymysql

router = APIRouter()

class Student(BaseModel):
    student_name: str = Form(...)
    student_phone: str = Form(...)
    student_guardian_phone: str = Form(...)
    student_password: str = Form(...)
    student_address: str = Form(...)
    student_birthday: str = Form(...)
    student_image: UploadFile = File(...)

class StudentLogin(BaseModel):
    student_phone: str
    student_password: str

class TeacherLogin(BaseModel):
    teacher_email: str
    teacher_password: str

def connect():
    conn = pymysql.connect(
        host=config.hostip,
        port=config.hostport,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset='utf8',
    )
    return conn

@router.get("/select")
async def select():
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 결과값을 Dictionary로 변환
    result = [{'student_id' : row[0], 'student_name' : row[1], 'student_phone' : row[2], 'student_guardian_phone' : row[3], 'student_address' : row[4], 'student_birthday' :row[5] } for row in rows]
    return {'results' : result}
    # >>>>> student 테이블 , 전체 학생 조회_ 학생 관리용

@router.post("/insert")
async def insert(student: Student):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "insert into student( student_name, student_phone, student_guardian_phone, student_password, student_address,student_birthday,student_image) values (%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql, ( student.student_name, student.student_phone, student.student_guardian_phone,student.student_password, student.student_address, student.student_birthday, student.student_image))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}
        # >>>>> student 테이블 , 학생 추가_ 신규 학생 등록용

@router.post("/student_login")
async def login(student: StudentLogin):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
                SELECT count(student_id), student_id, student_name
                FROM student
                WHERE student_phone=%s AND student_password=%s
                """
        curs.execute(sql, ( student.student_phone, student.student_password ))
        conn.commit()
        result = curs.fetchone()
        conn.close()
        if result and result[0] == 1:
            return [{'student_id' : result[1], 'student_name' : result[2],}]
        else:
            return {'result' : 'Fail'}
    except Exception as e:
        print('Error:', e)
        return {'result' : 'Error'}
        # >>>>> student 테이블 , 학생 로그인 확인용

@router.post("/teacher_login")
async def login_teacher(teacher: TeacherLogin):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
                SELECT count(teacher_id), teacher_id, teacher_name
                FROM teacher
                WHERE teacher_email=%s AND teacher_password=%s
                """
        curs.execute(sql, ( teacher.teacher_email, teacher.teacher_password ))
        conn.commit()
        result = curs.fetchone()
        conn.close()
        if result and result[0] == 1:
            return [{'teacher_id' : result[1], 'teacher_name' : result[2],}]
        else:
            return {'result' : 'Fail'}
    except Exception as e:
        print('Error:', e)
        return {'result' : 'Error'}
        # >>>>> student 테이블 , 선생 로그인 확인용
