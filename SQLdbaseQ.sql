
#Supplier Report
#distance from supplier to warehouse
DROP VIEW IF EXISTS supplier_distance;
CREATE VIEW supplier_distance AS
SELECT suppliermemberId,warehouseId,
	ST_Distance_Sphere(point(S.longitude,S.latitude),point(W.longitude,W.latitude)
    )/1000  AS distance_to_warehouse FROM suppliermembers S
CROSS JOIN warehouse W
WHERE W.clientId='c0001'
ORDER BY distance_to_warehouse;

#distance from warehouse to store
DROP VIEW IF EXISTS warehouse_distance;
CREATE VIEW warehouse_distance AS
SELECT warehouseId,storeId,
	ST_Distance_Sphere(point(S.longitude,S.latitude),point(W.longitude,W.latitude)
    )/1000  AS distance_to_store FROM stores S
CROSS JOIN warehouse W
WHERE W.clientId='c0001'
ORDER BY distance_to_store;

#distance travelled to get produce from supplier to store
DROP VIEW IF EXISTS produce_distance;
CREATE VIEW produce_distance AS
SELECT suppliermemberId,W.warehouseId,storeId,distance_to_store+distance_to_warehouse Produce_travel_distance FROM supplier_distance S
CROSS JOIN warehouse_distance W ON S.warehouseId=W.warehouseId
WHERE suppliermemberId NOT IN 
	(SELECT suppliermemberId FROM supplier WHERE supplier.clientId='c0001')
#AND W.warehouseId='w0001'
#AND W.storeId='z0001'
#AND suppliermemberId IN
#	(SELECT suppliermemberId FROM memberproduce WHERE produceTypeId IN
#		(SELECT producetypeId FROM produce WHERE produce.produceId='p0001' AND produce.clientId='c0001'))
ORDER BY Produce_travel_distance;

#minimal distance travelled
SELECT D1.* FROM produce_distance D1
LEFT JOIN produce_distance D2
ON D1.suppliermemberId=D2.suppliermemberId AND D1.Produce_travel_distance>D2.Produce_travel_distance
WHERE D2.Produce_travel_distance IS NULL
ORDER BY Produce_travel_distance;


#Available Cpacity Report
#Capacity of each warehouse already occupied
DROP VIEW IF EXISTS `Warehouse Used Capacity`;
CREATE VIEW `Warehouse Used Capacity` AS
SELECT B1.warehouseId,P2.storageCondition,sum(B2.batchvolume) 'used warehouse capacity (m^3)'
FROM batchlocation B1,batches B2,produce P1,produceType P2
WHERE B1.clientId=B2.clientId AND B1.batchNo=B2.batchNo AND B1.purchaseYear=B2.purchaseYear
AND B2.produceId=P1.produceId AND B2.clientId=P1.clientId
AND P1.produceTypeId=P2.produceTypeId
AND B2.clientId='c0001'
AND B1.warehouseId IS NOT NULL
GROUP BY B1.warehouseId,P2.storageCondition;

#capacity of each warehouse that is still available
SELECT W.warehouseId,W.storageCondition,W.maxCapacity-'used warehouse capacity (m^3)' AS 'Capacity Available (m^3)' 
FROM warehouseCapacity W
LEFT JOIN `Warehouse Used Capacity` C ON W.warehouseId=C.warehouseId AND W.storageCondition=C.storageCondition
WHERE W.clientId='c0001';


#Excess Volume Report
SELECT batchVolume 'Excess Volume (m^3)',useByDate,email,contactNumber,P2.produceName FROM batches B,client C,produce P1,produceType P2
WHERE C.clientId!='c0001'
AND B.clientId=C.clientId AND P1.clientId=C.clientId
AND P1.produceId=B.produceId
AND P2.produceTypeId=P1.produceTypeId
AND P2.produceTypeId IN
	(SELECT produceTypeId FROM produce WHERE produceId='p0004' AND clientId='c0001');
    
    
#Produce Disposal Report
SELECT produceId,sum(ifnull(price,0)) 'Price of produce disposed' FROM batchsales B1,batches B2
WHERE B1.clientId=B2.clientId AND B1.purchaseYear=B2.purchaseYear AND B1.batchNo=B2.batchNo
AND disposalDate IS NOT NULL
AND disposalDate BETWEEN '2023-09-01' and '2023-09-30'
AND B1.clientId='c0001'
GROUP BY produceId
ORDER BY produceId;


#Batch use-by-dates
SELECT B1.batchNo,produceId,locationStatus,IFNULL(warehouseId,IFNULL(storeId,'Produce In Transit')), useByDate FROM batchlocation B1,batches B2
WHERE B1.clientId=B2.clientId AND B1.purchaseYear=B2.purchaseYear AND B1.batchNo=B2.batchNo
AND (B1.clientId,B1.purchaseYear,B1.batchNo) NOT IN
	(SELECT clientId,purchaseYear,batchNo FROM batchSales)
#AND produceId='p0002'
ORDER BY useByDate Asc;