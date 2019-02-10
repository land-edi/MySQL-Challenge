from flask import Flask, jsonify
import numpy as np
import pandas as pd
import datetime as dt
# Python SQL toolkit and Object Relational Mapper
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session, aliased
from sqlalchemy import create_engine, func, inspect, and_
engine = create_engine("sqlite:///Resources/hawaii.sqlite")
# reflect an existing database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(engine, reflect=True)

# We can view all of the classes that automap found
Base.classes.keys()
# Save references to each table
Measurement = Base.classes.measurement
Station = Base.classes.station
inspector = inspect(engine)
# Use Inspector to print the column names and types
for tbl in Base.classes.keys():
    columns = inspector.get_columns(tbl)
    print (f'Columns for Table:{tbl}')
    for c in columns:
        print(c['name'], c["type"])
    print (f'********************')
# Create our session (link) from Python to the DB
session = Session(engine)
query_date_now = dt.datetime.now().replace(dt.datetime.now().year-1)
query_date = dt.datetime(2017,8,23).replace(dt.datetime(2017,8,23).year-1)
print("Query Date: ", query_date_now)
print("Query Date: ", query_date)
# Design a query to retrieve the last 12 months of precipitation data and plot the results

print(session.query(Measurement.id,Measurement.station,Measurement.date,Measurement.prcp ,Measurement.tobs ).\
      filter(Measurement.date > query_date_now).all())
# Calculate the date 1 year ago from the last data point in the database
last_date = session.query(Measurement.date).order_by(Measurement.date.desc()).first()
# print(last_date[0])
last_date_dt = dt.datetime.strptime(last_date[0], '%Y-%m-%d').date()
# print(last_date_dt)
year_ago_from_last_date = last_date_dt.replace(last_date_dt.year-1)

print(f'date 1 year ago from the last data point in the database: {year_ago_from_last_date}')
# Latest Date
print(f'Latest Date: {last_date_dt}')

# Perform a query to retrieve the data and precipitation scores
result= session.query(Measurement.id,Measurement.station,Measurement.date,Measurement.prcp ,Measurement.tobs ).filter(Measurement.date >= year_ago_from_last_date).all()
# print(result)
result_dict = {}
for i in result:
      result_dict[i[2]]=i[3]

station = session.query(Station.id,Station.name).all()
station_dict ={}
for i in station:
      station_dict[i[0]]=i[1]

mainq = session.query(Measurement.id,Measurement.station,Measurement.date,  Measurement.prcp, Measurement.tobs).\
            filter(Measurement.date >= year_ago_from_last_date, Measurement.station=='USC00519281').all()
tob_dict = {}
for i in mainq:
      tob_dict[i[2]]=i[4]

#################################################
# Flask Setup
#################################################
app = Flask(__name__)

@app.route("/")
def home():

    return (
        f"Welcome to the Hawaii!<br/>"
        f"Available Routes:<br/>"
        f"/api/v1.0/precipitation<br/>"
        f"/api/v1.0/stations<br/>"
        f"/api/v1.0/tobs<br/>"
        f"/api/v1.0/start<br/>"
        f"/api/v1.0/start/end")

@app.route("/api/v1.0/precipitation")
def precipitation():

      """Return the precipitation data as json"""

      return jsonify(result_dict)

@app.route("/api/v1.0/stations")
def stations():

      """Return the precipitation data as json"""

      return jsonify(station_dict)

@app.route("/api/v1.0/tobs")
def tobs():

      """Return the precipitation data as json"""

      return jsonify(tob_dict)

@app.route("/api/v1.0/<start>")
def dailrangetob(start):
      engine = create_engine("sqlite:///Resources/hawaii.sqlite")
      # reflect an existing database into a new model
      Base = automap_base()
      # reflect the tables
      Base.prepare(engine, reflect=True)

      # We can view all of the classes that automap found
      Base.classes.keys()
      # Save references to each table
      Measurement = Base.classes.measurement
      Station = Base.classes.station
      inspector = inspect(engine)
      # Create our session (link) from Python to the DB
      session = Session(engine)
      try:
            start_tob = session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
            filter(Measurement.date >= dt.datetime.strptime(start, '%Y-%m-%d')).all()

            start_tob_dict = {}
            start_tob_dict['Minimum Temp']=start_tob[0][0]
            start_tob_dict['Average Temp']=start_tob[0][1]
            start_tob_dict['Maximum Temp']=start_tob[0][2]
            return jsonify(start_tob_dict)
      except:
            return jsonify({"error": f'Invalid Date {start} Date is expected in 2017-02-01 format.'}), 404

@app.route("/api/v1.0/<start>/<end>")
def dailrangetobend(start,end):
      engine = create_engine("sqlite:///Resources/hawaii.sqlite")
      # reflect an existing database into a new model
      Base = automap_base()
      # reflect the tables
      Base.prepare(engine, reflect=True)

      # We can view all of the classes that automap found
      Base.classes.keys()
      # Save references to each table
      Measurement = Base.classes.measurement
      Station = Base.classes.station
      inspector = inspect(engine)
      # Create our session (link) from Python to the DB
      session = Session(engine)
      try:
            start_tob = session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
            filter(Measurement.date >= dt.datetime.strptime(start, '%Y-%m-%d')).filter(Measurement.date <= dt.datetime.strptime(end, '%Y-%m-%d')).all()

            start_tob_dict = {}
            start_tob_dict['Minimum Temp']=start_tob[0][0]
            start_tob_dict['Average Temp']=start_tob[0][1]
            start_tob_dict['Maximum Temp']=start_tob[0][2]
            return jsonify(start_tob_dict)
      except:
            return jsonify({"error": f'Invalid Date : Date is expected in 2017-02-01 format.'}), 404

if __name__ == "__main__":
    app.run(debug=True)