from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2

app = Flask(__name__)
CORS(app)

conn = psycopg2.connect(
 host="127.0.0.1", 
 database="sketchy",
 user="",
 password=""
)
cur = conn.cursor()


@app.route("/")
def hello_world():
    return "Hello Sketchy!"


@app.route("/api/subs-over-time", methods=["GET"])
def subs_over_time():
    where = []
    for k, v in request.args.items():
        if k == "start":
            where.append(f"month::DATE >= '{v}'")
        elif k == "end":
            where.append(f"month::DATE <= '{v}'")
        elif k == "university_id":
            where.append(f"university_id = {v}")
        elif k == "program_year":
            where.append(f"program_year = '{v}'")
    if len(where) > 0:
        where = "WHERE " + " AND ".join(where)
    else:
        where = ""
    sql = f"""
    SELECT
        MONTH::date::text AS date, 
        SUM(subs)::int AS total
    FROM subscription_by_month
    {where}
    GROUP BY month
    ORDER BY month ASC
    """
    cur = conn.cursor()
    cur.execute(sql)
    colnames = [desc[0] for desc in cur.description]
    rows = cur.fetchall()
    rows = [dict(zip(colnames, row)) for row in rows]
    cur.close()
    return jsonify(rows)


@app.route("/api/total-subs", methods=["GET"])
def total_subs():
    where = []
    for k, v in request.args.items():
        if k == "start":
            where.append(f"term_start::DATE >= '{v}'")
        elif k == "end":
            where.append(f"term_end::DATE <= '{v}'")
        elif k == "university_id":
            where.append(f"university_id = {v}")
        elif k == "program_year":
            where.append(f"program_year = '{v}'")
    if len(where) > 0:
        where = "WHERE " + " AND ".join(where)
    else:
        where = ""
    sql = f"""
    SELECT COUNT(*)::int AS total
    FROM subscriptions s
    INNER JOIN users u ON s.user_id = u.id
    INNER JOIN university uv ON u.university_id = uv.id
    {where}
    """
    cur = conn.cursor()
    cur.execute(sql)
    rows = cur.fetchone()
    cur.close()
    print(rows)
    return jsonify({
        "total": rows[0]
    })


@app.route("/api/universities", methods=["GET"])
def get_universities():
    q = request.args.get('q', "")
    if not q:
        return jsonify([])

    where = ""
    if len(q) > 0:
        where = f"WHERE name ILIKE '%{q}%'"
    sql = f"""
    SELECT id AS value, name AS label
    FROM university 
    {where}
    ORDER BY name ASC
    """
    cur = conn.cursor()
    cur.execute(sql)
    colnames = [desc[0] for desc in cur.description]
    rows = cur.fetchall()
    rows = [dict(zip(colnames, row)) for row in rows]
    cur.close()
    return jsonify(rows)

app.run(debug=True)
