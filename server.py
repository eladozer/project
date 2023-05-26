import asyncio
import json
import websockets
import db
import datetime
import handle_csv as cs
import socket
import hashlib
import threading as th

key = "Key1986"
db.build_db()


def md5_encrypt(message):
    md5_hash = hashlib.md5()
    md5_hash.update(message.encode('utf-8'))
    encrypted = md5_hash.hexdigest()
    return encrypted


def check_months(dat1, dat2):
    return dat1.month > dat2.month


def xor_encrypt_decrypt(encrypted_text):
    decrypted = []
    for i in range(len(encrypted_text)):
        char_code = ord(encrypted_text[i]) ^ ord(key[i % len(key)])
        decrypted.append(char_code)
    return ''.join(chr(char) for char in decrypted)


def find(start, st, action):
    i = start
    while st[i] != action:
        i += 1
    return i


def handle_reg(dat):
    data = db.register(dat[1], md5_encrypt(dat[2]), dat[3], dat[4], dat[5], dat[6])
    return data


def check_dates(dat1, dat2):
    bigger_day = dat1.day > dat2.day
    bigger_month = dat1.month > dat2.month
    bigger_year = dat1.year > dat2.year
    if bigger_year is True:
        return True
    elif bigger_year is False and bigger_month is True:
        return True
    elif bigger_year is False and bigger_month is False and bigger_day is True:
        return True
    return False


def handle_food(prompt):
    import requests
    api_url = prompt
    response = requests.get(api_url, headers={'X-Api-Key': 'ulcnhWMn7eJJTSTot6w0uZhQGfuI0uG0iQjN6NCN'})
    if response.status_code == requests.codes.ok:
        return response.text
    else:
        return "Error:", response.status_code, response.text


async def handle_client_thread(websocket):
    t1 = th.Thread(target=handle_client, args=websocket)
    t1.start()
    t1.join()


async def handle_client(websocket):
    print("--------------------")
    print("Client Connected")
    try:
        async for message1 in websocket:
            message = xor_encrypt_decrypt(message1)
            print(f"Message received: {message}")
            data = message.split(",")
            date = datetime.datetime.today().date()
            if data[0].lower() == "in user":
                answer = str(db.in_user(xor_encrypt_decrypt(data[1])))
                await websocket.send(str(xor_encrypt_decrypt(answer)))
            elif data[0].lower() == "register":
                dat = handle_reg(data)
                await websocket.send(xor_encrypt_decrypt(dat))
            elif data[0].lower() == "login":
                answer = db.has_login(data[1], md5_encrypt(data[2]))
                if answer is True:
                    last = db.get_last(data[1])
                    date_object = datetime.datetime.strptime(last, "%Y-%m-%d")
                    if check_dates(date, date_object):
                        db.update_food_data(data[1])
                        db.reset_meals(data[1])
                        db.reset_activity(data[1])
                        dat = db.get_params(data[1], True, check_months(date, date_object))
                    else:
                        dat = db.get_params(data[1], False, False)
                    await websocket.send(xor_encrypt_decrypt(dat))
                else:
                    await websocket.send(xor_encrypt_decrypt(json.dumps(answer)))
            elif data[0].lower() == "food":
                prompt = data[2]
                body = handle_food(prompt)
                nameStart = body.index("name")
                nameEnd = nameStart + 4
                calStart = body.index("calories")
                calEnd = calStart + 8
                protStart = body.index("protein_g")
                protEnd = protStart + 9
                nameStr = body[nameEnd + 4:find(nameEnd + 4, body, '"')]
                calStr = body[calEnd + 3:find(calEnd + 3, body, ',')]
                protStr = body[protEnd + 3:find(protEnd + 3, body, ',')]
                updated = str(datetime.datetime.now().time()) + "-" + nameStr + "-" + calStr + "-" + protStr
                db.update_meals(data[1], updated)
                await websocket.send(xor_encrypt_decrypt(body))
            elif data[0].lower() == "update food":
                name = data[1]
                new_cal = data[2]
                new_prot = data[3]
                db.update_current_cal(name, new_cal)
                db.update_current_prot(name, new_prot)
                await websocket.send(xor_encrypt_decrypt("Food Updated"))
            elif data[0].lower() == "update weight":
                name = data[1]
                new_weight = data[2]
                db.update_weight(name, new_weight)
                db.update_weight_data(name, new_weight)
                db.update_change(name)
                await websocket.send(xor_encrypt_decrypt("Weight Updated"))
            elif data[0].lower() == "update name":
                name = data[1]
                new_name = data[2]
                data = db.update_name(name, new_name)
                await websocket.send(xor_encrypt_decrypt(data))
            elif data[0].lower() == "update pas":
                name = data[1]
                new_pas = data[2]
                db.update_pas(name, md5_encrypt(new_pas))
                await websocket.send(xor_encrypt_decrypt("Password Updated"))
            elif data[0].lower() == "update weight data":
                name = data[1]
                new_data = data[2]
                db.update_weight(name, new_data)
                db.update_weight_data(name, new_data)
                db.update_change(name)
                await websocket.send(xor_encrypt_decrypt("Weight Updated"))
            elif data[0].lower() == "update cal goal":
                name = data[1]
                new_data = data[2]
                db.update_cal(name, new_data)
                await websocket.send(xor_encrypt_decrypt("Cal Goal Updated"))
            elif data[0].lower() == "update prot goal":
                name = data[1]
                new_data = data[2]
                db.update_prot(name, new_data)
                await websocket.send(xor_encrypt_decrypt("Protein Goal Updated"))
            elif data[0].lower() == "update burned goal":
                db.update_burned(data[1], data[2])
                await websocket.send(xor_encrypt_decrypt("Burned Goal Updated"))
            elif data[0].lower() == "running":
                name = data[1]
                cal = data[2]
                distance = data[3]
                db.update_current_burned(name, cal)
                db.update_running(name, distance)
                data = "running-" + str(cal)
                db.update_activ_dat(name, data)
                await websocket.send(xor_encrypt_decrypt("Updated Successfully"))
            elif data[0].lower() == "cycling":
                name = data[1]
                cal = data[2]
                distance = data[3]
                db.update_current_burned(name, cal)
                db.update_cycling(name, distance)
                data = "cycling-" + str(cal)
                db.update_activ_dat(name, data)
                await websocket.send(xor_encrypt_decrypt("Updated Successfully"))
            elif data[0].lower() == "random activity":
                activity_name = data[1]
                name = data[2]
                cal = data[3]
                db.update_current_burned(name, cal)
                data = activity_name + "-" + str(cal)
                db.update_activ_dat(name, data)
                await websocket.send(xor_encrypt_decrypt("Updated Successfully"))
            elif data[0].lower() == "update chal":
                name = data[1]
                challenge = data[2]
                state = data[3]
                if challenge == "1":
                    db.update_one(name, state)
                if challenge == "2":
                    db.update_two(name, state)
            else:
                await websocket.send(xor_encrypt_decrypt(message))
    except:
        print("Client Disconnected Prematurely")
        print("--------------------")


async def main():
    print("Server Start")
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    async with websockets.serve(handle_client_thread, ip_address, 8820):
        await asyncio.Future()  # Run forever


if __name__ == "__main__":
    asyncio.run(main())
