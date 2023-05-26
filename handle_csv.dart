List active = [];

List activities(var data2) {
  var data = "";
  for (var row in data2) {
    if (row[0].contains(",")) {
      data = row[0].split(",")[0];
    } else {
      data = row[0];
    }
    if (!active.contains(data)) {
      active.add(data);
    }
  }
  return active;
}

List getDur(var dat, var csv) {
  List cond = [];
  var name;
  var data;
  for (var row in csv) {
    if (row[0].contains(",")) {
      name = row[0].split(",")[0];
    } else {
      name = row[0];
    }
    if (name == dat) {
      if (row[0].contains(",")) {
        data = row[0].split(",")[1];
      } else {
        if (num.tryParse(row[1].toString()) != null) {
          data = "";
        } else {
          data = row[1];
        }
      }
      if (!cond.contains(data)) {
        cond.add(data);
      }
    }
  }
  return cond;
}

double burned(var activity, var state, var csv) {
  var name;
  var data;
  var burned;
  for (var row in csv) {
    if (row[0].contains(",")) {
      name = row[0].split(",")[0];
    } else {
      name = row[0];
    }
    if (name == activity) {
      if (row[0].contains(",")) {
        data = row[0].split(",")[1];
      } else {
        if (num.tryParse(row[1].toString()) != null) {
          data = "";
        } else {
          data = row[1];
        }
      }
      if (data == state) {
        return row[row.length - 1];
      }
    }
  }
  return burned;
}
