import os
from flask import Flask, request, render_template, redirect, url_for
import pymysql

app = Flask(__name__)
DB_SETTINGS = {
    'user': os.environ['DB_USER'],
    'db': os.environ['DB_NAME'],
    'host': os.environ['DB_HOST'], 
    'password': os.environ['DB_PASSWORD'],
    'table_name': 'items'
}

#database connection
connection = pymysql.connect(
  host=DB_SETTINGS['host'], 
  user=DB_SETTINGS['user'], 
  passwd=DB_SETTINGS['password'], 
  database=DB_SETTINGS['db'])
cursor = connection.cursor()

# Create table
with app.app_context():
  cursor.execute("CREATE TABLE IF NOT EXISTS `{0}` (`id` INT PRIMARY KEY AUTO_INCREMENT, `item` VARCHAR(40));".format(DB_SETTINGS['table_name']))
  connection.commit()

def add_text(text_value):
    cursor.execute("INSERT INTO `{0}`(`id`, `item`) VALUES (DEFAULT, '{1}')".format(DB_SETTINGS['table_name'], text_value))
    connection.commit()
    return 1

def delete_text(text_value):
    cursor.execute("DELETE FROM `{0}` WHERE `item`='{1}'".format(DB_SETTINGS['table_name'], text_value))
    connection.commit()
    return 1

def get_data():
    cursor.execute('SELECT * FROM {0}'.format(DB_SETTINGS['table_name']))
    rows = cursor.fetchall()    
    return rows

@app.route("/")
def MainPage():
    hostname = "hostname: " + os.environ['HOSTNAME']
    all_text = get_data()
    return render_template('index.html', all_text = all_text, hostname = hostname)

@app.route("/add_text", methods=["POST", "GET"])
def AddText():
    if request.method == "POST":
        add_new = add_text(request.form["textv"])
        return redirect(url_for('MainPage'))
    return render_template('index.html')

@app.route("/delete_text", methods=["POST", "GET"])
def DeletteText():
    if request.method == "POST":
        delete_new = delete_text(request.form["textv"])
        return redirect(url_for('MainPage'))
    return render_template('index.html')

if __name__ == "__main__":
    app.run()


# import os
# from flask import Flask, request, render_template, redirect, url_for
# import pymysql

# app = Flask(__name__)
# DB_SETTINGS = {
#     'user': os.environ['DB_USER'],
#     'db': os.environ['DB_NAME'],
#     'host': os.environ['DB_HOST'], 
#     'password': os.environ['DB_PASSWORD'],
#     'table_name': 'items'
# }

# #database connection
# connection = pymysql.connect(
#   host=DB_SETTINGS['host'], 
#   user=DB_SETTINGS['user'], 
#   passwd=DB_SETTINGS['password'], 
#   database=DB_SETTINGS['db']
# )
# cursor = connection.cursor()

# # Create table
# with app.app_context():
#   cursor.execute("CREATE TABLE IF NOT EXISTS `{0}` (`id` INT     PRIMARY KEY AUTO_INCREMENT, `item` VARCHAR(40));".format(DB_SETTINGS['table_name']))
#   connection.commit()

# def add_text(text_value):
#     cursor.execute("INSERT INTO `{0}`(`id`, `item`) VALUES (DEFAULT, '{1}')".format(DB_SETTINGS['table_name'], text_value))
#     connection.commit()
#     return 1

# def delete_text(text_value):
#     cursor.execute("DELETE FROM `{0}` WHERE `item`='{1}'".format(DB_SETTINGS['table_name'], text_value))
#     connection.commit()
#     return 1

# def get_data():
#     cursor.execute('SELECT * FROM {0}'.format(DB_SETTINGS['table_name']))
#     rows = cursor.fetchall()    
#     return rows

# @app.route("/")
# def MainPage():
#     hostname = "hostname: " + os.environ['HOSTNAME']
#     all_text = get_data()
#     return render_template('index.html', all_text = all_text, hostname = hostname)

# @app.route("/add_text", methods=["POST", "GET"])
# def AddText():
#     if request.method == "POST":
#         text_value = request.form["textv"]
#         # Saving all the values to db
#         add_new = add_text(text_value)
#         return redirect(url_for('MainPage'))
#     else:
#         return render_template('index.html')

# @app.route("/delete_text", methods=["POST", "GET"])
# def DeletteText():
#     if request.method == "POST":
#         text_value = request.form["textv"]
#         delete_new = delete_text(text_value)
#         return redirect(url_for('MainPage'))
#     else:
#         return render_template('index.html')

# if __name__ == "__main__":
#     app.run()