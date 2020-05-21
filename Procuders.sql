--“AS a registered/unregistered user, I should be able to ...”
--1
CREATE PROC Original_Content_Search
@typename VARCHAR(50),
@categoryname VARCHAR(50)
AS
IF (@typename IS NULL AND @categoryname IS NULL) 
PRINT 'the inputs IS NULL'
ELSE
SELECT *
FROM Original_Content OC INNER JOIN Content C ON c.ID=OC.OC_ID
WHERE  (review_status=1 AND filter_status=1 ) AND ( C.C_type=@typename OR C.category_type=@categoryname )

GO

--2
CREATE PROC Contributor_Search 
@fullname VARCHAR(100)
AS
IF (@fullname IS NULL )
PRINT 'the input IS NULL'
ELSE  BEGIN
	SELECT * 
	FROM Contributor c INNER JOIN Users u ON c.C_ID=u.U_ID
	WHERE ((u.first_name+u.middle_name+u.last_name) = @fullname )
END

GO

--3
CREATE PROC Register_User
@usertype VARCHAR(50) , @email VARCHAR(100), @password VARCHAR(20), @firstname VARCHAR(20),
@middlename VARCHAR(20), @lastname VARCHAR(20), @birth_date DATE, @working_place_name VARCHAR(50), @working_place_type VARCHAR(50),
@wokring_place_description TEXT, @specilization VARCHAR(20), @portofolio_link VARCHAR(150), @years_experience INT, @hire_date DATE,
@working_hours FLOAT, @payment_rate decimal(10,2),
@user_id INT OUTPUT
AS
IF (@usertype IS NULL OR @email IS NULL OR @password IS NULL OR @firstname IS NULL OR @middlename IS NULL OR @lastname IS NULL OR @birth_date IS NULL)		
PRINT 'INSERT VALUES'
ELSE BEGIN
	IF (EXISTS(SELECT email FROM Users WHERE @email=email))
		PRINT 'email already EXISTS'
	ELSE BEGIN
		INSERT INTO Users VALUES(@email,@firstname,@middlename,@birth_date,@password,CURRENT_TIMESTAMP,1)
		SELECT  @user_id=U_ID
		FROM Users
		WHERE email=@email 
		END
	IF (@usertype='Viewer')
				INSERT INTO Viewer VALUES(@user_id,@working_place_name,@working_place_type,@wokring_place_description)
	ELSE IF (@usertype='Contributor')
				INSERT INTO Contributor VALUES(@user_id,@years_experience,@portofolio_link,@specilization,DEFAULT)
	ELSE IF (@usertype= 'Authorized Reviewer')BEGIN
				INSERT INTO Staff VALUES(@user_id,@hire_date,@working_hours,@payment_rate,DEFAULT)
				INSERT INTO Reviewer VALUES (@user_id)
				END
	ELSE IF (@usertype='Content Manager')BEGIN
				INSERT INTO Staff VALUES(@user_id,@hire_date,@working_hours,@payment_rate,DEFAULT)
				INSERT INTO Content_manager VALUES(@user_id,NULL)
				END
END
GO

--4

CREATE PROC Check_Type 
@typename VARCHAR(20),
@content_manager_id INT
AS
IF(@typename IS NULL OR @content_manager_id IS NULL)
PRINT ' input values missing'
ELSE BEGIN
IF(NOT EXISTS(SELECT * FROM Content_type WHERE Cont_type=@typename))BEGIN
 INSERT INTO Content_type VALUES (@typename)
 END
DECLARE @existing_id INT
UPDATE Content_manager
SET CM_type = @typename
WHERE CM_ID=@content_manager_id;
END
GO

--5
CREATE PROC Order_Contributor
AS
SELECT * FROM Contributor c INNER JOIN users u ON c.C_ID=u.U_ID  ORDER BY years_of_experience DESC;

GO
--6

CREATE PROC Show_Original_Content
@contributor_id INT
AS
IF(@contributor_id IS NULL)
BEGIN
SELECT * 
FROM Contributor  c INNER JOIN Content cont ON c.C_ID =cont.Contributor_id 
	INNER JOIN Original_Content oc ON oc.OC_ID=cont.ID
	INNER JOIN users u ON u.U_ID=c.C_ID
WHERE (oc.review_status=1 AND oc.filter_status=1 )
END 
ELSE
BEGIN 
SELECT oc.* , cont.* 
FROM Contributor  c INNER JOIN Content cont ON c.C_ID =cont.Contributor_id 
	INNER JOIN Original_Content oc ON oc.OC_ID=cont.ID
	WHERE (oc.review_status=1 AND oc.filter_status=1 )AND c.C_ID=@contributor_id
END

GO

--“AS a registered user, I should be able to ...”
--1
CREATE PROC User_login 
@email VARCHAR(50), @password VARCHAR(20), @user_id INT OUTPUT
AS 
IF(NOT EXISTS(SELECT email FROM users WHERE email=@email ))
	SET @user_id = -1
ELSE IF  (DATEDIFF(day,CURRENT_TIMESTAMP,(SELECT last_login FROM users WHERE email=@email))>=14)BEGIN
		PRINT'can not log in, it has been at least two weeks since the last login';
END
ELSE IF (EXISTS(SELECT email FROM users WHERE email=@email AND U_password<>@password))
	PRINT'incorrect password';
ELSE BEGIN
	UPDATE users 
	SET last_login=CURRENT_TIMESTAMP,active = 1
	WHERE  email=@email;
	SELECT @user_id =U_id
	FROM users
	WHERE email=@email;
	END
GO

--2
CREATE PROC Show_Profile
@user_id INT, @email VARCHAR(100) OUTPUT, @password VARCHAR(20) OUTPUT,
@firstname VARCHAR(20) OUTPUT, @middlename VARCHAR(20) OUTPUT,
@lastname VARCHAR(20) OUTPUT, @birth_date DATE OUTPUT, @working_place_name VARCHAR(30) OUTPUT,
@working_place_type VARCHAR(20) OUTPUT, @wokring_place_description TEXT OUTPUT,
@specilization VARCHAR(20) OUTPUT,@portofolio_link VARCHAR(150) OUTPUT, @years_experience INT OUTPUT,
@hire_date DATETIME OUTPUT, @working_hours FLOAT OUTPUT, @payment_rate DECIMAL(10,2) OUTPUT
AS
IF (NOT EXISTS(SELECT U_ID FROM Users WHERE U_ID=@user_id))BEGIN
	PRINT'This usere IS NOT found'
	SET @email=NULL
	SET @password=NULL 
	SET @firstname=NULL  
	SET @middlename=NULL 
    SET @lastname=NULL 
	SET @birth_date=NULL  
	SET @working_place_name=NULL 
	SET @working_place_type =NULL
	SET @wokring_place_description=NULL 
	SET @specilization=NULL  
	SET @portofolio_link=NULL 
	SET @years_experience=NULL 
	SET @hire_date=NULL 
	SET @working_hours=NULL 
	SET @payment_rate=NULL 
	END
ELSE IF (EXISTS(SELECT U_ID FROM Users WHERE U_ID=@user_id))BEGIN
	SET @email=(SELECT email FROM Users WHERE U_ID=@user_id)
	SET @password=(SELECT U_password FROM Users WHERE U_ID=@user_id)
	SET @firstname=(SELECT first_name FROM Users WHERE U_ID=@user_id)
	SET @middlename=(SELECT middle_name FROM Users WHERE U_ID=@user_id)
	SET @lastname=(SELECT last_name FROM Users WHERE U_ID=@user_id)
	SET @birth_date=(SELECT birth_date FROM Users WHERE U_ID=@user_id)
END
IF(EXISTS(SELECT V_ID FROM Viewer WHERE V_ID=@user_id))BEGIN
	SET @working_place_name=(SELECT working_place FROM Viewer WHERE V_ID=@user_id)
	SET @working_place_type=(SELECT working_place_type FROM Viewer WHERE V_ID=@user_id)
	SET @wokring_place_description=(SELECT working_place_description FROM Viewer WHERE V_ID=@user_id)
END
ELSE IF (EXISTS(SELECT C_ID FROM Contributor WHERE C_ID=@user_id))BEGIN
	SET @portofolio_link=(SELECT portfolio_link FROM Contributor WHERE C_ID=@user_id)
	SET @specilization=(SELECT specialization FROM Contributor WHERE C_ID=@user_id)
	SET @years_experience=(SELECT years_of_experience FROM Contributor WHERE C_ID=@user_id)
END
ELSE IF(EXISTS(SELECT S_ID FROM Staff WHERE S_ID=@user_id))BEGIN
	SET @hire_date=(SELECT hire_date FROM Staff WHERE S_ID=@user_id)
	SET @working_hours=(SELECT working_hours FROM Staff WHERE S_ID=@user_id)
	SET @payment_rate=(SELECT payment_rate FROM Staff WHERE S_ID=@user_id)
END

GO

--3
CREATE PROC Edit_Profile 
@user_id INT , @email VARCHAR(100), @password VARCHAR(20),
@firstname VARCHAR(20), @middlename VARCHAR(20), @lastname VARCHAR(20), @birth_date DATE,
@working_place_name VARCHAR(20), @working_place_type VARCHAR(20),
@wokring_place_description TEXT, @specilization VARCHAR(20), @portofolio_link VARCHAR(50),
@years_experience INT, @hire_date DATE,@working_hours FLOAT, @payment_rate DECIMAL(10,2)
AS
IF(@email IS NOT NULL)
UPDATE Users SET email=@email WHERE U_ID=@user_id
IF(@@password IS NOT NULL)
UPDATE Users SET U_password=@password WHERE U_ID=@user_id
IF(@firstname IS NOT NULL)
UPDATE Users SET first_name=@firstname WHERE U_ID=@user_id
IF(@middlename IS NOT NULL)
UPDATE Users SET middle_name=@middlename WHERE U_ID=@user_id
IF(@lastname IS NOT NULL)
UPDATE Users SET last_name=@lastname WHERE U_ID=@user_id
IF(@birth_date IS NOT NULL)
UPDATE Users SET birth_date=@birth_date WHERE U_ID=@user_id
IF(@working_place_name IS NOT NULL)
UPDATE Viewer SET working_place=@working_place_name  WHERE V_ID=@user_id
IF(@working_place_name IS NOT NULL)
UPDATE Viewer SET working_place_type=@working_place_type  WHERE V_ID=@user_id
IF(@working_place_name IS NOT NULL)
UPDATE Viewer SET working_place_description=@wokring_place_description  WHERE V_ID=@user_id
IF(@specilization IS NOT NULL)
UPDATE Contributor SET specialization=@specilization WHERE C_ID=@user_id
IF(@portofolio_link IS NOT NULL)
UPDATE Contributor SET portfolio_link=@portofolio_link WHERE C_ID=@user_id
IF(@years_experience IS NOT NULL)
UPDATE Contributor SET years_of_experience=@years_experience WHERE C_ID=@user_id
IF(@hire_date IS NOT NULL)
UPDATE Staff SET hire_date=@hire_date WHERE S_ID=@user_id
IF(@payment_rate IS NOT NULL)
UPDATE Staff SET payment_rate=@payment_rate WHERE S_ID=@user_id
IF(@working_hours IS NOT NULL)
UPDATE Staff SET working_hours=@working_hours WHERE S_ID=@user_id

GO
/*CREATE PROC Edit_Profile 
@user_id INT , @email VARCHAR(100), @password VARCHAR(20),
@firstname VARCHAR(20), @middlename VARCHAR(20), @lastname VARCHAR(20), @birth_date DATE,
@working_place_name VARCHAR(20), @working_place_type VARCHAR(20),
@wokring_place_description TEXT, @specilization VARCHAR(20), @portofolio_link VARCHAR(50),
@years_experience INT, @hire_date DATE,@working_hours FLOAT, @payment_rate DECIMAL(10,2)
AS
UPDATE Users
	SET email=@email , U_password=@password,first_name=@firstname,middle_name=@middlename,
	last_name=@lastname ,birth_date=@birth_date
	WHERE U_ID=@user_id
UPDATE Viewer
	SET working_place=@working_place_name , working_place_type=@working_place_type ,
	working_place_description=@wokring_place_description
	WHERE V_ID=@user_id
UPDATE Contributor
	SET specialization=@specilization,portfolio_link=@portofolio_link,years_of_experience=@years_experience
	WHERE C_ID=@user_id
UPDATE Staff
	SET hire_date=@hire_date,payment_rate=@payment_rate,working_hours=@working_hours
	WHERE S_ID=@user_id

GO*/

--4
CREATE PROC Deactivate_Profile 
@user_id INT
AS
UPDATE users
SET active=0
WHERE U_ID=@user_id
--DELETE FROM Users WHERE U_ID=@user_id --DELETE ON haga wla nkml bel statement??
--DELETE FROM Viewer WHERE V_ID=@user_id
--DELETE FROM Contributor WHERE C_ID=@user_id
--DELETE FROM Staff WHERE S_ID=@user_id

GO
--5
CREATE PROC Show_Event 
@event_id INT
AS
IF (@event_id is NULL)
	SELECT e.*,u.first_name,u.middle_name,u.last_name FROM Eventt e 
	INNER JOIN Viewer v ON e.viewer_id=v.V_ID 
	INNER JOIN Users u ON v.V_ID=u.U_ID
	WHERE E_TIME > CURRENT_TIMESTAMP
ELSE 
	SELECT e.*,u.first_name,u.middle_name,u.last_name
	FROM Eventt e 
	INNER JOIN Viewer v ON e.viewer_id=v.V_ID
	INNER JOIN Users u ON v.V_ID=u.U_ID
	WHERE e.E_id=@event_id
GO
--6
CREATE PROC Show_Notification 
@user_id INT
AS
IF(EXISTS (SELECT * FROM Contributor WHERE C_ID=@user_id))
BEGIN
SELECT notif.*
FROM Announcement notif 
INNER JOIN Contributor c ON c.C_notified_id=notif.notified_person_id
WHERE c.C_ID=@user_id
END
ELSE IF(EXISTS (SELECT * FROM Staff WHERE S_ID=@user_id))
BEGIN
SELECT notif.*
FROM Announcement notif 
INNER JOIN Staff s ON s.S_notified_id=notif.notified_person_id
WHERE S_ID=@user_id
END
ELSE
PRINT'user is not a contributor nor staff'

GO
--7
CREATE PROC Show_New_Content
@viewer_id INT , @content_id INT
AS
IF (@content_id IS NULL)BEGIN
	SELECT c.*,u.U_ID,u.first_name,u.middle_name,u.last_name
	FROM Content c
	INNER JOIN New_Request nr ON  nr.contributer_id=c.Contributor_id
	INNER JOIN Users u ON c.Contributor_id=u.U_ID WHERE nr.viewer_id=@viewer_id


END
ELSE BEGIN
	SELECT c.*,c.Contributor_id,u.first_name,u.middle_name,u.last_name
	FROM Content c
	INNER JOIN New_Content nc ON nc.NC_ID=c.ID
	INNER JOIN Contributor cont ON cont.C_ID=c.Contributor_id
	INNER JOIN New_Request nr ON nr.contributer_id=c.Contributor_id
	INNER JOIN Users u ON cont.C_ID=u.U_ID WHERE nr.viewer_id=@viewer_id
	AND cont.C_ID=@content_id
END

 
GO

--“AS a Viewer (registered user), I should be able to ...”
--1
CREATE PROC Viewer_Create_Event
@city VARCHAR(20),
 @event_date_time DATETIME,
 @description TEXT,
 @entertainer VARCHAR(20), 
 @viewer_id INT, 
 @location VARCHAR(20),
 @event_id INT OUTPUT
 AS
 IF (@event_date_time IS NULL OR @viewer_id IS NULL)
 PRINT 'no inputs entered'
 ELSE
 BEGIN
 INSERT INTO Notification_Object DEFAULT VALUES
 INSERT INTO Eventt (city,E_time,E_description,entertainer,viewer_id,E_location,notification_object_id) 
 VALUES (@city,@event_date_time,@description,@entertainer,@viewer_id,@location,(SELECT MAX(ID) FROM Notification_Object))
 
 SELECT @event_id= e.event_id FROM Eventt e WHERE 
 (e.city=@city AND e.E_time=@event_date_time AND e.E_description=@description AND e.entertainer=@entertainer AND e.viewer_id=@viewer_id)
 END

 GO
 
 --2

 CREATE PROC Viewer_Upload_Event_Photo @event_id INT, @link VARCHAR(20) 
AS
IF(@event_id IS NULL OR @link IS NULL)
PRINT 'no inputs entered'
ELSE
INSERT INTO Event_Photos_link VALUES (@event_id,@link)

GO




CREATE PROC Viewer_Upload_Event_Video @event_id INT, @link VARCHAR(20)
AS
IF(@event_id IS NULL OR @link IS NULL)
PRINT 'no inputs entered'
ELSE
INSERT INTO Event_Videos_link VALUES (@event_id,@link)

GO


--3

CREATE PROC Viewer_Create_Ad_From_Event 
@event_id INT
AS
DECLARE @description TEXT;
DECLARE @location VARCHAR(20);
DECLARE @viewer_id INT;
DECLARE @videos_link VARCHAR(50);
DECLARE @photos_link VARCHAR(50);

IF (@event_id IS NULL)
PRINT 'no inputs entered'
ELSE
BEGIN
SELECT @description=e.E_description,@location=e.E_location,@viewer_id=e.viewer_id ,@videos_link=EVL_link,@photos_link=EPL_link FROM Eventt e INNER JOIN Event_Photos_link PL ON e.E_ID=PL.EPL_event_id INNER JOIN Event_Videos_link VL ON e.E_ID=VL.EVL_event_id    WHERE e.event_id=@event_id

INSERT INTO Advertisment VALUES (@description,@location,@event_id,@viewer_id)
INSERT INTO Ads_Video_Link VALUES ((SELECT MAX(AD_id) FROM Advertisment),@videos_link)
INSERT INTO Ads_Photos_Link VALUES ((SELECT MAX(AD_id) FROM Advertisment),@photos_link)

END
GO

--4


CREATE PROC Apply_Existing_Request
@viewer_id INT,@original_content_id INT
AS
DECLARE @rate INT
IF(@viewer_id IS NULL OR @original_content_id IS NULL)
PRINT 'no inputs entered'
ELSE BEGIN
SELECT @rate=r.rate FROM Rate r WHERE (r.original_content_id=@original_content_id)
IF(@rate>=4)
INSERT INTO Existing_Request VALUES (@original_content_id,@viewer_id)
ELSE
PRINT'low rating'
END
GO

--5
CREATE PROC Apply_New_Request
@information TEXT,
@contributor_id INT, @viewer_id INT
AS
IF(@contributor_id IS NULL)BEGIN
	INSERT INTO Notification_Object DEFAULT VALUES
	INSERT INTO New_Request (information,contributer_id,viewer_id,notif_obj_id,specified)
	VALUES(@information,@contributor_id,@viewer_id,(SELECT MAX(ID) FROM Notification_Object),0)
	INSERT INTO Notified_Person DEFAULT VALUES

END
ELSE
BEGIN

END

/*INSERT INTO Notification_Object DEFAULT VALUES
INSERT INTO New_Request (information,contributer_id,viewer_id,notif_obj_id)
VALUES(@information,@contributor_id,@viewer_id,(SELECT MAX(ID) FROM Notification_Object))
DECLARE @new_request_id INT 
SET @new_request_id=(SELECT NR_id FROM New_Request WHERE information=@information AND viewer_id=@viewer_id AND contributer_id=@contributor_id)
INSERT INTO Notified_Person DEFAULT VALUES
INSERT INTO Announcement(notified_person_id,notification_object_id)
VALUES( (SELECT MAX(ID) FROM Notified_Person),(SELECT NC_ID FROM New_Content 
INNER JOIN Content ON Content.ID=New_Content.NC_ID
WHERE new_request_id=@new_request_id))
*/


GO




--6
CREATE PROC Delete_New_Request 
@request_id INT
AS
IF (NOT EXISTS (SELECT * FROM New_Request WHERE NR_id=@request_id) )BEGIN
PRINT 'request doesn"t exist'
END
ELSE IF(EXISTS (SELECT * FROM New_Request WHERE NR_id=@request_id AND accept_status =1)) BEGIN
	PRINT 'request in process'
END
ELSE
BEGIN
	DELETE New_request
	WHERE NR_id=@request_id
END

GO

--7
CREATE PROC Rating_Original_Content 
@orignal_content_id INT, 
@rating_value INT, 
@viewer_id INT
AS
IF(@viewer_id IS NULL OR @orignal_content_id IS NULL  OR @rating_value IS NULL)BEGIN
	PRINT 'missing inputs'
END
ELSE
	INSERT INTO Rate VALUES(@viewer_id,@orignal_content_id,CURRENT_TIMESTAMP,@rating_value)

GO

--8
CREATE PROC Write_Comment 
@comment_text TEXT,
@viewer_id INT, 
@original_content_id INT,
@written_time DATETIME
AS
IF(@viewer_id IS NULL OR @orignal_content_id IS NULL  OR @comment_text IS NULL)BEGIN
	PRINT 'missing inputs'
END
ELSE
	INSERT INTO comment VALUES(@viewer_id,@orignal_content_id,@written_time,@comment_text)

GO

--9
CREATE PROC Edit_Comment 
@comment_text TEXT, 
@viewer_id INT, 
@original_content_id INT, 
@last_written_time DATETIME, 
@updated_written_time DATETIME
AS
IF(@viewer_id IS NULL OR @orignal_content_id IS NULL  OR @comment_text IS NULL OR @last_written_time IS NULL OR @updated_written_time IS NULL)BEGIN
	PRINT 'missing inputs'
END
ELSE
	UPDATE  comment
	SET COM_text =@comment_text ,COM_date=@updated_written_time
	WHERE viewer_id=@viewer_id AND original_content_id=@original_content_id AND COM_date=@last_written_time ;
	
GO

--10
CREATE PROC Delete_Comment 
@viewer_id INT, 
@original_content_id INT,
@written_time DATETIME
AS
IF (NOT EXISTS (SELECT * FROM comment WHERE viewer_id=@viewer_id AND original_content_id=@original_content_id AND COM_date=@written_time) )BEGIN
PRINT 'comment doesn"t exist'
END
ELSE
BEGIN
	DELETE comment
	WHERE viewer_id=@viewer_id AND original_content_id=@original_content_id AND COM_date=@written_time
END

GO

--11
CREATE PROC Create_Ads 
@viewer_id INT,
@description TEXT, 
@location VARCHAR(20)
AS
IF(@viewer_id IS NULL OR @description IS NULL  OR @location IS NULL)BEGIN
	PRINT 'missing inputs'
END
ELSE
	INSERT INTO Advertisement VALUES(@description,@location,NULL,@viewer_id)

GO


--12
CREATE PROC Edit_Ad
@ad_id INT,
@description TEXT,
@location VARCHAR(20)
AS
UPDATE Advertisement 
SET AD_description = @description,
AD_location= @loction
WHERE AD_id = @ad_id

GO

--13
CREATE PROC Delete_Ads 
@ad_id INT
AS
DELETE Advertisement
WHERE AD_id = @ad_id

GO
--14
CREATE PROC Send_Message 
@sent_at DATETIME ,
@contributor_id INT,
@viewer_id INT,
@sender_type BIT,
@msg_text TEXT
AS
INSERT INTO  Messagee VALUES (@sent_at,@contributor_id,@viewer_id,@sender_type,NULL,@msg_text,NULL)
 
GO 
--15
CREATE PROC Show_Message 
@contributor_id INT
AS
SELECT*
FROM Messagee
WHERE contributer_id=@contributor_id

GO




--16
CREATE PROC Highest_Rating_Original_content
AS
SELECT* FROM Original_Content HAVING rating=MAX(rating)

GO


--17
CREATE PROC Assign_New_Request @request_id INT,
@contributor_id INT
AS
IF(@request_id IS NULL AND @contributor_id IS NULL)
PRINT'no inputs entered'
ELSE BEGIN
DECLARE @accept BIT
SELECT @accept=r.accept_status FROM New_Request r WHERE r.NR_id=@request_id
IF (@accept IS NULL )BEGIN
UPDATE New_Request
SET contributor_id=@contributor_id 
WHERE NR_id =@request_id
END
ELSE
PRINT 'this request have been accepted OR rejected before'
END
GO

--“AS a contributor, I should be able to ...”
--1
CREATE PROC Receive_New_Requests 
@request_id INT ,
@contributor_id INT
AS
IF(@request_id IS NULL AND @contributor_id IS  NULL)
	SELECT * FROM New_Request WHERE  specified=0 

ELSE IF(@request_id IS NULL AND @contributor_id IS NOT NULL)BEGIN 
	SELECT * FROM New_Request WHERE (contributer_id=@contributor_id) OR specified=0 
END
ELSE
	SELECT * FROM New_Request WHERE NR_id=@request_id


GO

--2
CREATE PROC Respond_New_Request
@contributor_id INT,
@accept_status BIT,
@request_id INT 
AS
IF( @contributor_id IS NULL OR
@accept_status IS NULL OR
@request_id IS NULL)
PRINT 'inputs are NULL'
IF ((SELECT accept_status FROM New_Request WHERE NR_id= @request_id) = 1 )
PRINT'it IS already accepted'
IF (((SELECT accept_status FROM New_Request WHERE NR_id= @request_id ) = 0 OR (SELECT accept_status FROM New_Request WHERE NR_id= @request_id ) = NULL) AND
(SELECT specified FROM New_Request WHERE NR_id= @request_id) = 0 ) BEGIN
UPDATE New_Request
SET contributer_id= @contributor_id , accept_status=@accept_status
WHERE NR_id= @request_id
IF(@accept_status=1)
UPDATE New_Request
SET accepted_time = CURRENT_TIMESTAMP WHERE NR_id=@request_id
END
 
IF (((SELECT accept_status FROM New_Request WHERE NR_id= @request_id ) = 0 OR (SELECT accept_status FROM New_Request WHERE NR_id= @request_id ) = NULL) AND
(SELECT specified FROM New_Request WHERE NR_id= @request_id) = 1 AND contributer_id= @contributor_id )
BEGIN
UPDATE New_Request
SET accept_status=@accept_status
WHERE NR_id= @request_id
IF(@accept_status=1)
UPDATE New_Request
SET accepted_time = CURRENT_TIMESTAMP WHERE NR_id=@request_id
 
END 
GO

--3
CREATE PROC Upload_Original_Content 
@type_id VARCHAR(20),
@subcategory_name VARCHAR(20),
@category_id VARCHAR(20),
@contributor_id INT,
@link VARCHAR(50)
AS
INSERT INTO content VALUES (@link,CURRENT_TIMESTAMP,@category_id,@subcategory_name,@type_id)
DECLARE @oc_id INT 
SELECT @oc_id= ID
FROM Content
WHERE link= @link  AND category_type= @category_id AND subcategory_name = @subcategory_name AND C_type= @type_id
INSERT INTO Original_Content(OC_ID) VALUES (@oc_id)
GO


--4
CREATE PROC Upload_New_Content 
@new_request_id INT, 
@contributor_id INT,
@subcategory_name VARCHAR(20), 
@category_id VARCHAR(20), 
@link VARCHAR(50)
AS
DECLARE @Current_time DATETIME
SET @Current_time=CURRENT_TIMESTAMP
IF((SELECT accept_status FROM New_Request WHERE Nr_id = @new_request_id)=1)
INSERT INTO Content VALUES(@link,@Current_time,@contributor_id,@category_id,@subcategory_name,NULL)
DECLARE @x INT
DECLARE @accept_time DATETIME
SELECT @accept_time=accept_time FROM New_Request WHERE NR_id=@new_request_id
SELECT @x=ID FROM Content WHERE link=@link AND contributor_id=@contributor_id AND category_type=@category_id AND subcategory_name=@subcategory_name
INSERT INTO New_Content VALUES(@x,@new_request_id,(DATEDIFF(HOUR,@Current_time,@accept_time)))
GO

--5

CREATE PROC Delete_Content 
@content_id INT
AS
IF((SELECT review_status FROM Original_Content WHERE OC_ID = content_id )=0)
DELETE ID FROM Content WHERE ID = @content_id

GO
--6
CREATE FUNCTION Receive_New_Request
(@contributor_id INT)
RETURNS BIT
BEGIN
DECLARE @can_recieve BIT
IF((SELECT COUNT(accept_status) FROM New_Request WHERE (contributer_id= @contributor_id AND accept_status=NULL)) < 3 )
SET @can_receive = 1
ELSE 
SET @can_receive = 0

RETURN @can_recieve
END
GO


--“AS a staff member, I should be able to ...”
--1
CREATE PROC reviewer_filter_content
@reviewer_id INT, @original_content INT,
@status BIT AS
IF (EXISTS(SELECT oc.OC_ID,r.R_ID FROM Original_Content oc
INNER JOIN Content c ON c.ID=oc.OC_ID AND oc.OC_ID=@original_content
INNER JOIN Reviewer r ON r.R_ID=oc.reviewer_id AND r.R_ID=@reviewer_id))
	UPDATE Original_Content SET review_status=@status
	WHERE OC_ID=@original_content

GO

--2
CREATE PROC content_manager_filter_content
@content_manager_id INT,
@original_content INT, @status BIT
AS
IF(EXISTS(SELECT oc.OC_ID,cm.CM_ID FROM Original_Content oc
INNER JOIN Content c ON c.ID=oc.OC_ID AND oc.OC_ID=@original_content
INNER JOIN Content_manager cm ON cm.CM_ID=@content_manager_id
INNER JOIN Content_type ct ON ct.Cont_type=cm.CM_type))
	IF(EXISTS(SELECT review_status FROM Original_Content WHERE review_status=1))
	UPDATE Original_Content SET review_status=@status
	WHERE OC_ID=@original_content

GO
--3
CREATE PROC Staff_Create_Category
@category_name VARCHAR(20)
AS
INSERT INTO Category (CAT_type) VALUES (@category_name)

GO

--4
CREATE PROC Staff_Create_Subcategory 
@category_name VARCHAR(20),
@subcategory_name VARCHAR(20)
AS
IF(EXISTS(SELECT CAT_type FROM Category WHERE CAT_type=@category_name))
	INSERT INTO Sub_Category VALUES (@category_name,@subcategory_name)

GO
--5
CREATE PROC Staff_Create_Type 
@type_name VARCHAR(20)
AS
INSERT INTO Content_type VALUES (@type_name)

GO

--6
CREATE PROC Most_Requested_Content
AS
SELECT er.original_content_id,COUNT(er.ER_id) 
FROM Existing_Request er
INNER JOIN Original_Content oc ON oc.OC_ID=er.original_content_id
ORDER BY COUNT(er.ER_id) DESC

GO

--7
 CREATE PROC Workingplace_Category_Relation
AS
SELECT COUNT(NR_id) FROM New_Request nr
INNER JOIN Viewer v ON v.V_ID=nr.NR_id
INNER JOIN New_Content nc ON nc.new_request_id=nr.NR_id
INNER JOIN Content c ON c.ID=nc.NC_ID
	GROUP BY c.category_type
	ORDER BY v.working_place

SELECT COUNT(ER_id)FROM Existing_Request er
INNER JOIN Viewer v ON v.V_ID=er.viewer_id
INNER JOIN Original_Content oc ON oc.OC_ID=er.original_content_id
INNER JOIN Content c ON c.ID=oc.OC_ID
	GROUP BY c.category_type
	ORDER BY v.working_place
GO
--8

CREATE PROC Delete_Comment
@viewer_id INT , 
@original_content_id INT,@comment_time DATETIME
AS
IF(EXISTS(SELECT oc.OC_ID,com.Viewer_id FROM Original_Content oc
INNER JOIN content c ON c.ID=oc.OC_ID AND oc.OC_ID=@original_content_id
INNER JOIN comment com ON com.Viewer_id=@viewer_id
INNER JOIN comment com ON com.COM_date=@comment_time))
	DELETE comment WHERE (Viewer_id=@viewer_id AND COM_date=@comment_time AND original_content_id=@original_content_id)

GO 
--9
CREATE PROC Delete_Original_Content
@content_id INT
AS
IF(EXISTS(SELECT oc.OC_ID FROM Original_Content oc
INNER JOIN Content c ON c.ID=oc.OC_ID))
	DELETE Original_Content WHERE OC_ID=@content_id

GO
--10
CREATE PROC Delete_New_Content 
@content_id INT 
AS
IF(EXISTS(SELECT nc.NC_ID FROM New_Content nc
INNER JOIN Content c ON c.ID=nc.NC_ID))
	DELETE New_Content WHERE NC_ID=@content_id

GO
--11
CREATE PROC Assign_Contributor_Request
@contributor_id INT, @new_request_id INT
AS
IF((SELECT contributer_id FROM New_Request WHERE NR_id=@new_request_id)IS NULL)
	UPDATE New_Request SET contributer_id=@contributor_id
	WHERE NR_id=@new_request_id

GO


--12
CREATE PROC  Show_Possible_Contributors
@contributor_id INT OUTPUT,
@NO_OF_REQUESTS INT OUTPUT
AS
SELECT @contributor_id=C.C_ID,@NO_OF_REQUESTS=COUNT(NR.NR_id) FROM Contributor C
LEFT JOIN New_Request NR ON C.C_ID=NR.contributer_id AND NR.accept_status=1 
LEFT JOIN Content CON ON CON.Contributor_id=C.C_ID INNER JOIN New_Content NC ON NC.NC_ID=CON.ID
WHERE Receive_New_Request(C.C_ID)=1 GROUP BY C.C_ID ORDER BY NC.time_taken ASC, COUNT(NR.NR_id) DESC

GO



--****



