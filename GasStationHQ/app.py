from flask import Flask, render_template, request, redirect, url_for
from db import get_connection

app = Flask(__name__)

# Home page
@app.route('/')
def index():
    return render_template('index.html')

# =====================
# STORES
# =====================
@app.route('/stores')
def stores():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Store")
    stores = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('stores.html', stores=stores)

@app.route('/stores/add', methods=['POST'])
def add_store():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO Store (storeID, storeCity, staffID, pumpNo) VALUES (%s, %s, %s, %s)",
        (request.form['storeID'], request.form['storeCity'], request.form['staffID'], request.form['pumpNo']))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('stores'))

@app.route('/stores/edit/<int:storeID>', methods=['POST'])
def edit_store(storeID):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE Store SET storeCity=%s, staffID=%s, pumpNo=%s WHERE storeID=%s",
        (request.form['storeCity'], request.form['staffID'], request.form['pumpNo'], storeID))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('stores'))

@app.route('/stores/delete/<int:storeID>')
def delete_store(storeID):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Store WHERE storeID=%s", (storeID,))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('stores'))

# =====================
# ORDERS
# =====================
@app.route('/orders')
def orders():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Orders")
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('orders.html', orders=orders)

@app.route('/orders/add', methods=['POST'])
def add_order():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Orders (orderDate, orderStatus, deliveryStatus, storeID, HQID, loadingBayNo, managerID)
        VALUES (%s, %s, %s, %s, %s, %s, %s)""",
        (request.form['orderDate'], False, 'Unassigned',
         request.form['storeID'], 1, request.form['loadingBayNo'], request.form['managerID']))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('orders'))

@app.route('/orders/edit/<int:orderNo>', methods=['POST'])
def edit_order(orderNo):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE Orders SET deliveryStatus=%s WHERE orderNo=%s""",
        (request.form['deliveryStatus'], orderNo))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('orders'))

@app.route('/orders/delete/<int:orderNo>')
def delete_order(orderNo):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Orders WHERE orderNo=%s", (orderNo,))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('orders'))

# =====================
# FLEET
# =====================
@app.route('/fleet')
def fleet():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Fleet")
    fleet = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('fleet.html', fleet=fleet)

@app.route('/fleet/add', methods=['POST'])
def add_fleet():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO Fleet (truckType, available, HQID, loadingBayNo) VALUES (%s, %s, %s, %s)",
        (request.form['truckType'], True, 1, request.form['loadingBayNo']))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('fleet'))

@app.route('/fleet/edit/<int:vehicleID>', methods=['POST'])
def edit_fleet(vehicleID):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE Fleet SET available=%s WHERE vehicleID=%s",
        (request.form['available'], vehicleID))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('fleet'))

@app.route('/fleet/delete/<int:vehicleID>')
def delete_fleet(vehicleID):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Fleet WHERE vehicleID=%s", (vehicleID,))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('fleet'))

# =====================
# STAFF
# =====================
@app.route('/staff')
def staff():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Staff")
    staff = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('staff.html', staff=staff)

@app.route('/staff/add', methods=['POST'])
def add_staff():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO Staff (staffID, staffFirstName, staffLastName, staffRole) VALUES (%s, %s, %s, %s)",
        (request.form['staffID'], request.form['staffFirstName'], request.form['staffLastName'], request.form['staffRole']))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('staff'))

@app.route('/staff/edit/<int:staffID>', methods=['POST'])
def edit_staff(staffID):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE Staff SET staffRole=%s WHERE staffID=%s",
        (request.form['staffRole'], staffID))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('staff'))

@app.route('/staff/delete/<int:staffID>')
def delete_staff(staffID):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Staff WHERE staffID=%s", (staffID,))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('staff'))

# =====================
# QUERIES
# =====================
@app.route('/queries')
def queries():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    # Query 1
    cursor.execute("""
        SELECT o.orderNo, o.orderDate, s.storeCity, s.storeID, o.deliveryStatus
        FROM Orders o JOIN Store s ON o.storeID = s.storeID""")
    q1 = cursor.fetchall()

    # Query 2
    cursor.execute("""
        SELECT SUM(galDiesel) AS totalDiesel, SUM(galRegular) AS totalRegular, SUM(galPremium) AS totalPremium
        FROM gasOrders""")
    q2 = cursor.fetchall()

    # Query 3
    cursor.execute("""
        SELECT st.staffFirstName, st.staffLastName, st.staffRole, suo.orderNo, suo.orderStatus, suo.deliveryStatus
        FROM Staff st JOIN staffUpdatesOrder suo ON st.staffID = suo.staffID""")
    q3 = cursor.fetchall()

    # Query 4
    cursor.execute("""
        SELECT storeID, storeCity FROM Store
        WHERE storeID IN (
            SELECT storeID FROM Orders GROUP BY storeID HAVING COUNT(orderNo) > 1)""")
    q4 = cursor.fetchall()

    # Query 5
    cursor.execute("SELECT orderNo, orderDate, deliveryStatus, truckType, storeCity FROM OrderTruckStore")
    q5 = cursor.fetchall()

    # Query 6
    cursor.execute("SELECT AVG(hotdogs) AS avgHotdogs, AVG(cigarettes) AS avgCigarettes FROM backstockOrders")
    q6 = cursor.fetchall()

    # Query 7
    cursor.execute("""
        SELECT f.vehicleID, f.truckType, d.orderNo, o.deliveryStatus, o.orderDate
        FROM Fleet f
        JOIN Deliveries d ON f.vehicleID = d.vehicleID
        JOIN Orders o ON d.orderNo = o.orderNo
        WHERE f.available = FALSE AND o.deliveryStatus = 'IP'""")
    q7 = cursor.fetchall()

    # Query 8
    cursor.execute("""
        SELECT storeID, storeCity FROM Store
        WHERE storeID IN (
            SELECT storeID FROM Orders WHERE orderNo IN (SELECT orderNo FROM gasOrders))
        AND storeID NOT IN (
            SELECT storeID FROM Orders WHERE orderNo IN (SELECT orderNo FROM backstockOrders))""")
    q8 = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template('queries.html', q1=q1, q2=q2, q3=q3, q4=q4, q5=q5, q6=q6, q7=q7, q8=q8)

if __name__ == '__main__':
    app.run(debug=True)