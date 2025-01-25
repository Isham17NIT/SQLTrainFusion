                -- Train Scheduling and Operation Related Queries

-- Make Train_No as foreign key in train_schedule table
ALTER TABLE train_schedule
ADD FOREIGN KEY(Train_No) REFERENCES train_info(Train_No) ON UPDATE CASCADE ON DELETE CASCADE;


-- Trains that don't operate on weekends
SELECT Train_No,Train_Name
FROM train_info
WHERE days NOT LIKE '%Saturday%' AND days NOT LIKE '%Sunday%';


-- Train with the maximum no. of stops
SELECT a.Train_No,b.Train_Name, COUNT(a.SN)-1 as Num_of_stops
FROM train_schedule AS a
INNER JOIN train_info AS b
ON a.Train_No=b.Train_No
GROUP BY Train_No,Train_Name
ORDER BY Num_of_stops DESC
LIMIT 1;


-- Trains that cover maximum distance in a single journey
SELECT a.Train_No,b.Train_Name,Distance
FROM train_schedule AS a
INNER JOIN train_info AS b
ON a.Train_No=b.Train_No
WHERE Distance=(
SELECT MAX(Distance) AS total_distance
FROM train_schedule
GROUP BY Train_No
ORDER BY total_distance DESC
LIMIT 1);


-- Trains that have the shortest travel time between 2 specific stations('KRMI' TO 'THVM')
SELECT a.Train_No,c.Train_Name,ROUND(TIME_TO_SEC(TIMEDIFF(b.Arrival_Time,a.Departure_Time)) / 60,0) AS time_taken
FROM train_schedule AS a
JOIN train_schedule AS b
ON a.Train_No=b.Train_No AND a.Station_Code='KRMI' AND b.Station_Code='THVM' AND a.Distance < b.Distance
INNER JOIN train_info AS c
ON a.Train_No=c.Train_No
ORDER BY time_taken ASC
LIMIT 1;


-- Average travel time b/w 2 specific stations('KRMI' TO 'THVM') for each train
SELECT ROUND(AVG(TIME_TO_SEC(TIMEDIFF(b.Arrival_Time,a.Departure_Time)) / 60),2) AS avg_time_in_minutes
FROM train_schedule AS a
JOIN train_schedule AS b
ON a.Train_No=b.Train_No 
WHERE a.Station_Code='KRMI' AND b.Station_Code='THVM' AND a.Distance < b.Distance;


-- Trains that have a layover time of more than 30 min at any station 
SELECT a.Train_No,b.Train_Name,a.Station_Code,ROUND(time_to_sec(TIMEDIFF(a.Departure_Time,a.Arrival_Time))/60,0) AS layover_time_in_min 
FROM train_schedule AS a
INNER JOIN train_info AS b
ON a.Train_NO=b.Train_NO 
WHERE time_to_sec(TIMEDIFF(a.Departure_Time,a.Arrival_Time))/60 > 30;


-- Find next station for each train from a given station('CHI')
SELECT a.Train_No,b.Station_Code AS next_station
FROM train_schedule AS a
JOIN train_schedule AS b
ON a.Train_No=b.Train_No AND b.SN=a.SN+1
WHERE a.Station_Code='CHI' AND a.SN!=(SELECT MAX(b.SN) FROM train_schedule AS b WHERE b.Train_No=a.Train_No);


-- List trains that stop at every station in a given list of stations('KRMI','THVM','MAO','KHED')
SELECT a.Train_No,b.Train_Name
FROM train_schedule AS a
INNER JOIN train_info AS b
ON a.Train_No=b.Train_No
GROUP BY Train_No,Train_Name
HAVING SUM(IF(Station_Code IN ('KRMI','THVM','MAO','KHED'),1,0))=4;






