import requests
import random

userID = "bG5PHmGC2Scd55rhuT3WGBazSc43"
deviceID = "nig-22-01"
path = "https://fluvius2-7f7a0-default-rtdb.firebaseio.com/" + userID + "/"+ deviceID +"/report/"

def sendSingle(date, hour, temp, chlorine):
    newPath = path + date + "/" + str(hour).rjust(2, '0') + ".json"
    values = {
        "chlorine": str(chlorine),
        "temp": str(temp),
        "conductivity": "1100",
        "ionizer": "OFF",
        "pump": "OFF", 
        "turbidity": "0.0"
    }
    r = requests.patch(newPath, json=values)
    print(str(r.content))


def sendOneMonth(year, month):
    i = 1
    for day in range(1, 31):
        for hour in range(0, 5):  # hour range
            date = str(year) + "-" + str(month).rjust(2, '0') + "-" + str(day).rjust(2, '0')
            tmp = random.randrange(200, 300, 50) / 10 # min, max, step
            ch = random.randrange(10, 50, 5) / 10
            sendSingle(date, hour, tmp, ch)
            i += 1

# call for push 1 month data for 24H
sendOneMonth(2022, 1) # year, month

# call for only a single data push
#sendSingle("2022-01-01", 1, 27, 5) # date, hour, tmp, ch