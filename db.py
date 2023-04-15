import sqlite3 as sq
import datetime
conn = sq.connect('user.db')


def build_db():
    conn.execute('''CREATE TABLE IF NOT EXISTS user
    (
    username    TEXT PRIMARY KEY    NOT NULL,
    password    TEXT                NOT NULL,
    weight      REAL                NOT NULL,
    calories    INTEGER             NOT NULL,
    proteins    INTEGER             NOT NULL,
    current_cal INTEGER             NOT NULL,
    current_prot INTEGER            NOT NULL,
    weight_data TEXT                NOT NULL,
    td_of_change TEXT               NOT NULL,
    last_login TEXT                 NOT NULL,
    food_data TEXT                  NOT NULL,
    meals_data TEXT                 NOT NULL
    );''')


def update_name(name, new_name):
    conn.execute('UPDATE user SET username = ?', (new_name,) + "WHERE username = ?", (name,))


def get_weight(name):
    cur = conn.execute('SELECT * FROM user')
    cu = cur.fetchall()
    for row in cu:
        if row[0] == name:
            return row[2]


def get_cal(name):
    cur = conn.execute('SELECT * FROM user')
    cu = cur.fetchall()
    for row in cu:
        if row[0] == name:
            return row[3]


def get_prot(name):
    cur = conn.execute('SELECT * FROM user')
    cu = cur.fetchall()
    for row in cu:
        if row[0] == name:
            return row[4]


def get_current_cal(name):
    cur = conn.execute('SELECT * FROM user')
    cu = cur.fetchall()
    for row in cu:
        if row[0] == name:
            return row[5]


def get_current_prot(name):
    cur = conn.execute('SELECT * FROM user')
    cu = cur.fetchall()
    for row in cu:
        if row[0] == name:
            return row[6]


def get_params(name, bigger):
    cur = conn.execute('SELECT * FROM user')
    cu = cur.fetchall()
    now = str(datetime.datetime.today().date())
    data = get_weight_data(name)
    for row in cu:
        if row[0] == name:
            if bigger is True:
                update_last(name)
                params = name + "," + str(row[2]) + "," + str(int(row[3])) + "," + str(int(row[4])) + "," + \
                         str(0) + "," + str(0) + "," + str(data) + "," + str(row[8]) + "," + \
                         now + "," + str(row[10]) + "," + ""
                return params
            else:
                current_cal = get_current_cal(name)
                current_prot = get_current_prot(name)
                params = name + "," + str(row[2]) + "," + str(int(row[3])) + "," + str(int(row[4])) + "," + \
                         str(int(current_cal)) + "," + str(int(current_prot)) + "," + str(data) \
                         + "," + str(row[8]) + "," + now + "," + str(row[10]) + "," + get_meals(name)
                return params


def in_user(name):
    cur = conn.execute('SELECT * FROM user')
    cu = cur.fetchall()
    for row in cu:
        if row[0] == name:
            return True
    return False


def register(name, pas, weit, cal, prot):
    params = (name, pas, weit, cal, prot, 0, 0, str(weit), str(datetime.datetime.now()), str(datetime.datetime.today().date()), "", "")
    if in_user(name):
        return "NO"
    conn.execute("INSERT INTO user \
        (username, password, weight, calories, proteins, current_cal, current_prot, weight_data, td_of_change, last_login, food_data, meals_data) \
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", params)
    conn.commit()
    return "User Registered"


def has_login(name, pas):
    if not in_user(name):
        return "GOOFY ALERT"
    else:
        cur = conn.execute('SELECT * FROM user')
        rows = cur.fetchall()
        for row in rows:
            if name == row[0]:
                if pas == row[1]:
                    return True
        return False


def update_pas(name, new_pas):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        conn.execute('UPDATE user SET password = ? WHERE username = ?', (new_pas, name))
        conn.commit()


def update_cal(name, new_cal_goal):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        conn.execute('UPDATE user SET calories = ? WHERE username = ?', (new_cal_goal, name))
        conn.commit()


def update_prot(name, new_prot_goal):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        conn.execute('UPDATE user SET proteins = ? WHERE username = ?', (new_prot_goal, name))
        conn.commit()


def update_current_cal(name, new_cal):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        conn.execute('UPDATE user SET current_cal = ? WHERE username = ?', (new_cal, name))
        conn.commit()


def update_current_prot(name, new_prot):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        conn.execute('UPDATE user SET current_prot = ? WHERE username = ?', (new_prot, name))
        conn.commit()


def get_weight_data(name):
    cur = conn.execute('SELECT * FROM user')
    rows = cur.fetchall()
    for row in rows:
        if name == row[0]:
            return row[7]


def get_td_data(name):
    cur = conn.execute('SELECT * FROM user')
    rows = cur.fetchall()
    for row in rows:
        if name == row[0]:
            return row[8]


def update_weight_data(name, weit):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        data = row[7]
        new_data = data + "-" + str(weit)
        conn.execute('UPDATE user SET weight_data = ? WHERE username = ?', (new_data, name))
        conn.commit()


def update_change(name):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        data = row[8]
        new_data = data + "+" + str(datetime.datetime.now())
        conn.execute('UPDATE user SET td_of_change = ? WHERE username = ?', (new_data, name))
        conn.commit()


def update_weight(name, new_weit):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        conn.execute('UPDATE user SET weight = ? WHERE username = ?', (new_weit, name))
        conn.commit()


def update_last(name):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        dat = datetime.datetime.today().date()
        conn.execute('UPDATE user SET last_login = ? WHERE username = ?', (str(dat), name))
        conn.commit()


def update_food_data(name):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        last_log = get_last(name)
        last_data = get_food_data(name)
        cal = get_current_cal(name)/get_cal(name)
        pro = get_current_prot(name)/get_prot(name)
        if cal >= 1 and pro >= 1:
            data = str(last_data) + "/" + str(last_log) + "+" + "Reached" + "+" + "Reached"
        elif cal >= 1 > pro:
            data = str(last_data) + "/" + str(last_log) + "+" + "Reached" + "+" + "Hasn't Reached"
        elif pro >= 1 > cal:
            data = str(last_data) + "/" + str(last_log) + "+" + "Hasn't Reached" + "+" + "Reached"
        else:
            data = str(last_data) + "/" + str(last_log) + "+" + "Hasn't Reached" + "+" + "Hasn't Reached"
        update_current_cal(name, 0)
        update_current_prot(name, 0)
        conn.execute('UPDATE user SET food_data = ? WHERE username = ?', (data, name))
        conn.commit()


def get_food_data(name):
    cur = conn.execute('SELECT * FROM user')
    rows = cur.fetchall()
    for row in rows:
        if name == row[0]:
            return row[10]


def get_last(name):
    cur = conn.execute('SELECT * FROM user')
    rows = cur.fetchall()
    for row in rows:
        if name == row[0]:
            return row[9]


def update_meals(name, new_meal):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        current_meals = get_meals(name)
        if current_meals == "":
            dat = str(new_meal)
        else:
            dat = current_meals + "#" + str(new_meal)
        conn.execute('UPDATE user SET meals_data = ? WHERE username = ?', (str(dat), name))
        conn.commit()


def get_meals(name):
    cur = conn.execute('SELECT * FROM user')
    rows = cur.fetchall()
    for row in rows:
        if name == row[0]:
            return row[11]


def reset_meals(name):
    cur = conn.execute("SELECT * FROM user WHERE username = ?", (name,))
    row = cur.fetchone()  # fetch the first row from the result set
    if row:
        conn.execute('UPDATE user SET meals_data = ? WHERE username = ?', ("", name))
        conn.commit()
