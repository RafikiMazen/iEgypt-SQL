USE project10
GO

INSERT INTO Category VALUES ('Educational','Educational Description'),
('Investment','Investment Description'),('Tourism','Tourism Description');

INSERT INTO Sub_Category VALUES('Educational','GUC'),
('Tourism','Pyramids');
INSERT INTO Users VALUES('rawan.badr@gmail.com','rawan','hassan','badr','1998/7/20','abcd',NULL,1),
('maria.bassem@gmail.com','maria','bassem','roshdy','1997/4/1','yaty',NULL,1),
('antony.ayoub@gmail.com','antony','wassem','ayoub','1997/7/15','nanana',NULL,1),
('rafeek.mazen@gmail.com','rafeek','mazen','farah','1998/11/27','mt3ytsh',NULL,1),
('dalia.medhat@gmail.com','dalia','medhat','mounir','1998/1/7','coffee',NULL,1),
('nymar.selva@gmail.com','nymar','selva','santos','1992/4/10','nymar1',NULL,1),
('morcos.adley@gmail.com','morcos','adley','haleem','1997/1/8','mtbosesh',NULL,1),
('beno.amgad@gmail.com','beno','amgad','anwar','1997/12/24','siko',NULL,1),
('mina.mamdouh@gmail.com','mina','amgad','mamdouh','1998/6/15','kski',NULL,1),
('abanoub.farah@gmail.com','abanoub','mohsen','farah','1995/3/11','ayklam',NULL,1),
('mariza.blabizo@gmail.com','mariza','seif','balabizo','1993/9/3','wsa3',NULL,1),
('mageed.marwan@gmail.com','mageed','marwan','amir','1998/10/10','idsof',NULL,1),
('nour.sany@gmail.com','nouran','sany','ali','1996/10/24','sushi',NULL,1);


INSERT INTO Viewer VALUES(1,'Apple','mobile company','fdfv'),
(4,'google','software company','dfv'),
(9,'google','software company','fv');


SET IDENTITY_INSERT Notified_Person ON ;
INSERT INTO Notified_Person(ID) VALUES(1);
SET IDENTITY_INSERT notified_person OFF;

INSERT INTO Contributor VALUES(2,3,'maria.cv.com','art',1),(6,1,'nymar.cv.com','sports',1),
(7,3,'morcos.cv.com','sports',1),(11,9,'mariza.cv.com','acting',1),(5,4,'dalia.cv.com','cooking',1);
INSERT INTO Staff VALUES(3,'2010/2/8',8.5,5,1),(8,'2012/6/15',4,2.5,1),
(10,'2015/7/21',8.5,5,1),(12,'2010/2/19',8.5,5,1),(13,'2009/6/6',4,2.5,1);

INSERT INTO Reviewer VALUES(3),(8);

INSERT INTO Content_type VALUES('logo'),('statue'),('crafts'),('sound and light');

INSERT INTO Content VALUES('www.abc.com','2010-12-1 11:11:11',2,'Educational','GUC','logo'),
('www.def.com','2010-12-1 11:12:11',5,'Educational','GUC','statue'),
('www.ghi.com','2010-12-1 11:13:11',11,'Educational','GUC','crafts');

INSERT INTO Content_manager VALUES(10,'logo'),(12,'statue'),(13,'crafts');

SET IDENTITY_INSERT Notification_object ON ;
--INSERT INTO Notification_Object(ID) VALUES((SELECT MAX(ID) FROM Notification_Object)+1);
INSERT INTO Notification_Object(ID) VALUES(3);
INSERT INTO Notification_Object(ID) VALUES(4);
INSERT INTO Notification_Object(ID) VALUES(5);
INSERT INTO Notification_Object(ID) VALUES(6);
INSERT INTO Notification_Object(ID) VALUES(7);
INSERT INTO Notification_Object(ID) VALUES(8);
INSERT INTO Notification_Object(ID) VALUES(9);
INSERT INTO Notification_Object(ID) VALUES(10);
INSERT INTO Notification_Object(ID) VALUES(11);
INSERT INTO Notification_Object(ID) VALUES(12);
INSERT INTO Notification_Object(ID) VALUES(13);

SELECT * FROM Notification_Object
SET IDENTITY_INSERT Notification_Object OFF;

INSERT INTO Notification_Object DEFAULT VALUES ;

INSERT INTO Eventt VALUES('Amr Diab Concert','nasr city','cairo','2018-6-7 06:30:00','amr diab',1,4),
('The Great Fawzy Show in Rehab','rehab','cairo','2018-10-30 09:00:00','fawzy',2,9);

INSERT INTO Original_Content VALUES(1,10,3,1,1,5),(2,12,3,1,1,1),
(3,13,8,1,1,4);

INSERT INTO Advertisement VALUES('','fifth settelment',5,1),('','new cairo',6,9);



INSERT INTO New_Request
--same contributor and accepted
VALUES(1,1, 'sphinx',1,1,2,'2018-10-30 09:00:00'),
(1,1, 'pyramids',4,1,2,'2018-10-30 09:00:00'),
--3 have another contributor and accepted and
--each has a new content related to it
(1,1, 'temple',9, 1,6,'2018-10-30 09:00:00'),
(1,1, 'mermaid painting',4, 1,6,'2018-9-10 08:10:00'),
(1,1, 'gods chess',1, 1,6,'2018-3-9 03:30:00'),
--Three new requests have different contributors and accepted
--but do not have content
(1,1,null,1, 1,2,'2018-11-6 09:15:00'),
(1,1,null,1, 1,6,'2018-12-30 12:00:00'),
(1,1,null,1, 1,7,'2018-3-6 03:00:00'),
--Three new requests donât have a certain contributor and aren’t accepted
(0,0,'pharoah',1, 1,null,null),
(0,0,'vase',1, 1,null,null),
(0,0,'plate',1, 1,null,null);


