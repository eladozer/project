import csv

activities = []
cond = []


def extract_activ():
    with open('exercise_dataset.csv', newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        data = ""
        for row in reader:
            if "," in row[0]:
                data = row[0].split(",")[0]
            else:
                data = row[0]
            if data in activities:
                pass
            else:
                activities.append(data)

    return activities


def cs2(dat):
    with open('exercise_dataset.csv', newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        name = ""
        data = ""
        for row in reader:
            if "," in row[0]:
                name = row[0].split(",")[0]
            else:
                name = row[0]
            if name == dat:
                if "," in row[0]:
                    data = row[0].split(",")[1]
                else:
                    if row[1].isdigit():
                        data = ""
                    else:
                        data = row[1]
                if data not in cond:
                    cond.append(data)
    return cond


