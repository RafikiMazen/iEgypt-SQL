CREATE database project10;
GO
USE project10
GO
CREATE TABLE users(
U_ID INT PRIMARY KEY IDENTITY,
email VARCHAR(100)UNIQUE NOT NULL,
first_name VARCHAR(20) NOT NULL,
middle_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
birth_date DATE NOT NULL,
age AS (YEAR(CURRENT_TIMESTAMP) - YEAR(birth_date)),
U_password VARCHAR(20) NOT NULL,
last_login DATE,
active BIT

);
GO
CREATE TABLE Viewer(
V_ID INT PRIMARY KEY,
working_place VARCHAR(50),
working_place_type VARCHAR(50),
working_place_description TEXT,
FOREIGN KEY (V_ID )REFERENCES users(U_ID),
);
GO
CREATE TABLE Notified_Person ( 
ID INT PRIMARY KEY IDENTITY);
GO
CREATE TABLE Contributor (
C_ID INT PRIMARY KEY ,
years_of_experience INT,
portfolio_link VARCHAR(150),
specialization VARCHAR(20), 
C_notified_id INT ,
FOREIGN KEY (C_ID )REFERENCES users(U_ID),
FOREIGN KEY (C_notified_id)REFERENCES Notified_Person(ID)
);
GO
CREATE TABLE Staff(
S_ID INT PRIMARY KEY , 
hire_date DATE , 
working_hours FLOAT , 
payment_rate DECIMAL(10,2), 
total_salary AS (payment_rate*working_hours), 
S_notified_id INT,
FOREIGN KEY (S_ID )REFERENCES users(U_ID),
FOREIGN KEY (S_notified_id) REFERENCES Notified_Person(ID));
GO
CREATE TABLE Content_type (
Cont_type VARCHAR(20) PRIMARY KEY );
GO
CREATE TABLE Content_manager ( 
CM_ID INT PRIMARY KEY, 
CM_type VARCHAR(20), 
FOREIGN KEY (CM_ID) REFERENCES Staff(S_ID),
FOREIGN KEY (CM_type)REFERENCES Content_type(Cont_type),
);
GO
CREATE TABLE Reviewer(
R_ID INT PRIMARY KEY,
FOREIGN KEY (R_ID) REFERENCES Staff(S_ID),
);
GO
CREATE TABLE Messagee (
sent_at DATETIME ,
contributer_id INT, 
viewer_id INT, 
sender_type BIT , 
read_at DATETIME , 
M_TEXT TEXT,
read_status BIT  ,
PRIMARY KEY (sent_at,contributer_id,viewer_id,sender_type),
FOREIGN KEY (contributer_id) REFERENCES contributor(C_ID),
FOREIGN KEY (viewer_id) REFERENCES Viewer(V_ID),
);
GO
CREATE TABLE Category (
CAT_type VARCHAR(20) PRIMARY KEY , 
CAT_description TEXT);
GO
CREATE TABLE Sub_Category ( 
category_type VARCHAR(20) ,
SUB_name VARCHAR(20),
PRIMARY KEY(category_type,SUB_name),
FOREIGN KEY (category_type) REFERENCES Category(CAT_type));
GO

CREATE TABLE Notification_Object ( 
ID INT PRIMARY KEY IDENTITY );
GO
CREATE TABLE Content (
ID INT PRIMARY KEY IDENTITY, 
link VARCHAR(50), 
uploaded_at DATETIME ,
Contributor_id INT ,
category_type VARCHAR(20) ,
subcategory_name VARCHAR(20)  , 
C_type VARCHAR(20) ,
FOREIGN KEY (C_type)REFERENCES Content_type(Cont_type),
FOREIGN KEY (Contributor_id)REFERENCES Contributor(C_ID),
FOREIGN KEY (category_type,subcategory_name)REFERENCES Sub_Category);
GO
CREATE TABLE Original_Content ( 
OC_ID INT PRIMARY KEY ,
content_manager_id INT, 
reviewer_id INT ,
review_status BIT ,
filter_status BIT , 
rating INT,CHECK(rating between 0 and 5),
FOREIGN KEY (OC_ID)REFERENCES Content(ID),
FOREIGN KEY (content_manager_id) REFERENCES Content_manager(CM_ID),
FOREIGN KEY (reviewer_id)REFERENCES Reviewer(R_ID));
GO
CREATE TABLE Existing_Request ( 
ER_id INT PRIMARY KEY IDENTITY,
original_content_id INT, 
viewer_id INT ,
FOREIGN KEY (original_content_id) REFERENCES Original_Content(OC_ID),
FOREIGN KEY (viewer_id)REFERENCES Viewer(V_ID));
GO

CREATE TABLE New_Request ( 
NR_id INT PRIMARY KEY IDENTITY,
accept_status BIT ,
specified BIT , 
information TEXT,
viewer_id INT ,
notif_obj_id INT ,
contributer_id INT,
accept_time DATETIME
FOREIGN KEY (viewer_id)REFERENCES Viewer(V_ID),
FOREIGN KEY (notif_obj_id)REFERENCES Notification_Object(ID),
FOREIGN KEY (contributer_id ) REFERENCES Contributor(C_ID)
);
GO
CREATE TABLE New_Content(
NC_ID INT PRIMARY KEY,
new_request_id INT ,
time_taken INT,--in hours
FOREIGN KEY (NC_ID)REFERENCES Content(ID),
FOREIGN KEY (new_request_id)REFERENCES New_Request(NR_id));
GO
CREATE TABLE comment(
Viewer_id INT,
original_content_id INT  ,
COM_date DATETIME  ,
COM_TEXT TEXT,
PRIMARY KEY(Viewer_id,original_content_id,COM_date),
FOREIGN KEY (Viewer_id) REFERENCES Viewer(V_ID),
FOREIGN KEY (original_content_id)REFERENCES Original_Content(OC_ID));
GO
CREATE TABLE Rate ( 
viewer_id INT ,
original_content_id INT,
R_date DATETIME , 
rate INT,check(rate between 0 and 5), 
PRIMARY KEY(viewer_id,original_content_id),
FOREIGN KEY (viewer_id)REFERENCES Viewer(V_ID),
FOREIGN KEY (original_content_id )REFERENCES Original_Content(OC_ID));
GO

CREATE TABLE Eventt(
E_id INT PRIMARY KEY IDENTITY ,
E_description TEXT,
E_location VARCHAR(20),
city VARCHAR(15) , 
E_time DATETIME ,
entertainer VARCHAR(20) ,
notification_object_id INT ,
viewer_id INT,
FOREIGN KEY (notification_object_id ) REFERENCES Notification_Object(ID),
FOREIGN KEY (viewer_id)REFERENCES Viewer(V_ID),
);
GO

CREATE TABLE Event_Photos_link( 
EPL_event_id INT,
EPL_link VARCHAR(50),
PRIMARY KEY(EPL_event_id,EPL_link),
FOREIGN KEY (EPL_event_id)REFERENCES Eventt(E_ID)
);
GO
CREATE TABLE Event_Videos_link(
EVL_event_id INT ,  
EVL_link VARCHAR(50),
PRIMARY KEY(EVL_event_id,EVL_link),
FOREIGN KEY (EVL_event_id)REFERENCES Eventt(E_ID)
);
GO
CREATE TABLE Advertisement(
AD_id INT PRIMARY KEY IDENTITY, 
AD_description TEXT,
AD_location VARCHAR(20),
event_id INT,
viewer_id INT ,
FOREIGN KEY (event_id)REFERENCES Eventt(E_ID),
FOREIGN KEY (viewer_id)REFERENCES Viewer(V_ID)
);
GO
CREATE TABLE Ads_Video_Link(
AVL_advertisement_id INT,
AVL_link VARCHAR(50),
PRIMARY KEY(AVL_advertisement_id,AVL_link),
FOREIGN KEY (AVL_advertisement_id)REFERENCES Advertisement(AD_id)
);
GO
CREATE TABLE Ads_Photos_Link(
APL_advertisement_id INT,
APL_link VARCHAR(50),
PRIMARY KEY(APL_advertisement_id,APL_link),
FOREIGN KEY (APL_advertisement_id)REFERENCES Advertisement(AD_id)
);
GO
CREATE TABLE Announcement ( 
ID INT PRIMARY KEY IDENTITY,
seen_at DATETIME ,
sent_at DATETIME ,
notified_person_id INT, 
notification_object_id INT,
FOREIGN KEY (notified_person_id) REFERENCES Notified_Person(ID),
FOREIGN KEY (notification_object_id) REFERENCES Notification_Object(ID),
);
GO





