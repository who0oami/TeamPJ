from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta
import requests
import pymysql
import config

#   Weather python

#   Created in: 15/01/2026 14:13
#   Author: Chansol, Park
#   Description: Weather python for get weather in designated time
#   Update log: 
#     DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
#           18/01/2026 12:27, 'Point 1, Transfer .py into restitutor.dart', Creator: Chansol, Park
#           18/01/2026 14:03, 'Point 2, Forecast added', Creator: Chansol, Park
#   Version: 1.0
#   Dependency: (FastAPI, HTTPException, requests) from fastapi, datetime

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


router = APIRouter(
    tags=["weather"]
)

weather_URL = "https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtNcst"
forecast_URL = "https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtFcst"
AUTH_KEY = "Hj5f4F14Rtq-X-BdeKbaHw"

@router.get("/currentweather")
def get_current(
):
    now = datetime.now()
    if now.minute < 40:
        base_dt = now - timedelta(hours=1)
    else:
        base_dt = now

    base_date = base_dt.strftime("%Y%m%d")
    base_time = base_dt.strftime("%H00")
    
    params = {
        "authKey": AUTH_KEY,
        "base_date": base_date, # Current date
        "base_time": base_time, # Current Time
        "nx": 61, # Position x
        "ny": 126, # Position y
        "dataType": "JSON",
        "numOfRows": 1000,
        "pageNo": 1,
    }
    
    try:
        res = requests.get(weather_URL, params=params, timeout=10)
        res.raise_for_status()
    except requests.RequestException as e:
        raise HTTPException(status_code=502, detail=str(e))

    data = res.json()

    items = data["response"]["body"]["items"]["item"]

    result = {}
    for item in items:
        result[item["category"]] = item["obsrValue"]

    return result

@router.get("/forecast")
def get_forecast(
):
    now = datetime.now()
    if now.minute < 40:
        base_dt = now - timedelta(hours=1)
    else:
        base_dt = now

    base_date = base_dt.strftime("%Y%m%d")
    base_time = base_dt.strftime("%H00")

    target_times = [now + timedelta(hours = hr) for hr in range(1,6+1)]
    target_date = [target.strftime("%Y%m%d") for target in target_times]
    target_time = [target.strftime("%H00") for target in target_times]

    length = len(target_times);
    
    params = {
        "authKey": AUTH_KEY,
        "base_date": base_date, # Current date
        "base_time": base_time, # Current Time
        "nx": 61, # Position x
        "ny": 126, # Position y
        "dataType": "JSON",
        "numOfRows": 1000,
        "pageNo": 1,
    }
    
    try:
        res = requests.get(forecast_URL, params=params, timeout=10)
        res.raise_for_status()
    except requests.RequestException as e:
        raise HTTPException(status_code=502, detail=str(e))

    data = res.json()

    items = data["response"]["body"]["items"]["item"]

    result = {}
    for item in items:
        for index in range(length):
            if (item.get("category") == "PTY" and item.get("fcstDate") == target_date[index] and item.get("fcstTime") == target_time[index]): 
                result[index] = {"PTY": item.get("fcstValue")}
    if not result:
        raise HTTPException(status_code=404, detail="Forecast Error")

    return result