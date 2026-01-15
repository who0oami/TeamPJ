from datetime import datetime, timedelta
from fastapi import FastAPI, HTTPException
import requests

#   Weather python

#   Created in: 15/01/2026 14:13
#   Author: Chansol, Park
#   Description: Weather python for get weather in designated time
#   Update log: 
#     DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
#   Version: 1.0
#   Dependency: (FastAPI, HTTPException, requests) from fastapi, datetime

app = FastAPI()

weather_URL = "https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtNcst"
AUTH_KEY = "Hj5f4F14Rtq-X-BdeKbaHw"

@app.get("/forecast")
def get_forecast(
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
        "nx": 55, # Position x
        "ny": 127, # Position y
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

    # category별로 정리
    result = {}
    for item in items:
        result[item["category"]] = item["obsrValue"]

    return {
        "weather": result,
    }