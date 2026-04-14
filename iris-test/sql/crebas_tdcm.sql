CREATE  TABLE INSTRUMENTS ( 
	INSTRUMENTID         char(36)      NOT NULL,
	INSTRUMENTNAME       varchar(100)      NOT NULL,
	INSTRUMENTSTATUS     int  CONSTRAINT DF_INSTRUMENTS_INSTRUMENTSTATUS DEFAULT 0    NOT NULL,
	ORDERFILESPREFIX     varchar(10)      NOT NULL,
	SENDERID             varchar(20)      NULL,
	SENDERNAME           varchar(100)      NULL,
	LOGDATE              datetime      NOT NULL,
	CONSTRAINT PK_INSTRUMENTS PRIMARY KEY  ( INSTRUMENTID ) 
 );
GO

insert into INSTRUMENTS(INSTRUMENTID, INSTRUMENTNAME, INSTRUMENTSTATUS, ORDERFILESPREFIX, SENDERID, SENDERNAME, LOGDATE)
values ('51922FEA-8AE3-4AD6-AA51-535B23A37A04', 'Test', 1, 'rem', 'NXL', 'VERIF', getdate());
GO

CREATE  TABLE JOBS ( 
	JOBID                varchar(36)      NOT NULL,
	INSTRUMENTID         char(36)      NOT NULL,
	CREATIONDATE         datetime      NOT NULL,
	SAMPLENUMBER         varchar(20)      NOT NULL,
	JOBSTATUS            int  CONSTRAINT DF_JOBS_JOBSTATUS DEFAULT 0    NOT NULL,
	PRIORITY             int  CONSTRAINT DF_JOBS_PRIORITY DEFAULT 0    NOT NULL,
	LOGDATE              datetime      NOT NULL,
	CONSTRAINT PK_JOBS PRIMARY KEY  ( JOBID ) 
 );
GO

CREATE  INDEX IDX_SAMPLE_STATUS ON JOBS ( SAMPLENUMBER, JOBSTATUS );
GO

CREATE  TABLE JOB_DATA ( 
	JOBID                varchar(36)      NOT NULL,
	PATNUMBER            varchar(20)      NULL,
	ALTNUMBER            varchar(20)      NULL,
	ACCESSNUMBER         varchar(20)      NULL,
	REQUESTDATE          datetime      NULL,
	COLLECTIONDATE       datetime      NULL,
	LASTNAME             varchar(100)      NULL,
	FIRSTNAME            varchar(100)      NULL,
	MAIDENNAME           varchar(100)      NULL,
	BIRTHDATE            date      NULL,
	SEX                  int      NULL,
	LOGDATE              datetime      NOT NULL,
	CONSTRAINT PK_JOB_DATA PRIMARY KEY  ( JOBID ) 
 );
GO

CREATE  TABLE JOB_TESTS ( 
	JOBTESTID            varchar(36)      NOT NULL,
	JOBID                varchar(36)      NOT NULL,
	TESTCODE             varchar(10)      NOT NULL,
	TESTTEXT             varchar(100)      NULL,
	SENDDATE             datetime      NULL,
	RESSTATUS            int  CONSTRAINT DF_JOB_TESTS_RESSTATUS DEFAULT 0    NOT NULL,
	RESVALUE             varchar(2000)      NULL,
	RESDATE              datetime      NULL,
	RESTYPE              int      NULL,
	LOGDATE              datetime      NOT NULL,
	CONSTRAINT PK_JOB_TESTS PRIMARY KEY  ( JOBTESTID ) 
 );
GO

CREATE  TABLE PROPERTIES ( 
	PROPERTYNAME         varchar(100)      NOT NULL,
	PROPERTYVALUE        varchar(2000)      NOT NULL,
	PROPERTYCOMMENT      varchar(250)      NOT NULL,
	LOGDATE              datetime      NOT NULL,
	CONSTRAINT PK_PROPERTIES PRIMARY KEY  ( PROPERTYNAME ) 
 );
GO

insert into PROPERTIES(PROPERTYNAME, PROPERTYVALUE, PROPERTYCOMMENT, LOGDATE)
values ('OrdersFolder', 'c:\inetpub\ftproot\tdcm', 'Order files  (sent by TDNexLabs) folder full path', getdate());
GO

insert into PROPERTIES(PROPERTYNAME, PROPERTYVALUE, PROPERTYCOMMENT, LOGDATE)
values ('TreatmentFrequency', '30', 'Treatment frequency (in seconds)', getdate());
GO

insert into PROPERTIES(PROPERTYNAME, PROPERTYVALUE, PROPERTYCOMMENT, LOGDATE)
values ('NbMaxLogFiles', '50', 'Maximum number of log files', getdate());
GO

insert into PROPERTIES(PROPERTYNAME, PROPERTYVALUE, PROPERTYCOMMENT, LOGDATE)
values ('MaxLogFileSize', '100', 'Maximum size for a log file (in Kb)', getdate());
GO

insert into PROPERTIES(PROPERTYNAME, PROPERTYVALUE, PROPERTYCOMMENT, LOGDATE)
values ('SenderID', 'TDCM', 'Sender ID (when sending ASTM files to TDNexLabs)', getdate());
GO

insert into PROPERTIES(PROPERTYNAME, PROPERTYVALUE, PROPERTYCOMMENT, LOGDATE)
values ('SenderName', 'TDConnectionManager', 'Sender Name (when sending ASTM files to TDNexLabs)', getdate());
GO

ALTER TABLE JOBS ADD CONSTRAINT FK_JOB_INSTRUMENT FOREIGN KEY ( INSTRUMENTID ) REFERENCES INSTRUMENTS( INSTRUMENTID );
GO

ALTER TABLE JOB_DATA ADD CONSTRAINT FK_JOB_DATA_JOB FOREIGN KEY ( JOBID ) REFERENCES JOBS( JOBID );
GO

ALTER TABLE JOB_TESTS ADD CONSTRAINT FK_JOB_TESTS_JOB FOREIGN KEY ( JOBID ) REFERENCES JOBS( JOBID );
GO

