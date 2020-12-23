
--**************************************** DROP EXISTING DATABASE AND CREATE NEW DATA WAREHOUSE ***********************************************************************

use master

alter database StayMore set single_user with rollback immediate

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'StayMore')
    DROP DATABASE [StayMore]

CREATE DATABASE [StayMore]

use StayMore

--**************************************** TABLES CREATION IN DATA WAREHOUSE ***********************************************************************


if exists (select * from sysobjects where id = object_id('stayMore.dbo.DimProperties') )
	drop table [stayMore].[dbo].[DimProperties]

CREATE TABLE DimProperties(
	[Property_Key] INT identity(1,1) NOT NULL PRIMARY KEY,
	[Property_ID] INT NOT NULL,
	[Latitude] FLOAT NOT NULL,
	[Longitude] FLOAT NOT NULL,									 --we had a typo here on longitude before (12-12-2020)
	[Accommodates] INT NOT NULL,								 --we had a typo here on accommodates before (12-12-2020)
	[Availability_365] INT NOT NULL,
	[Has_availability] INT NOT NULL,
	[Reviews_per_month] FLOAT NOT NULL,
	[Calculated_host_listings_count] FLOAT NOT NULL,
	[Instant_bookable] INT NOT NULL,
	[Property_type] NVARCHAR(40) NOT NULL,
	[Room_type] NVARCHAR(40) NOT NULL,
	[Bedrooms] INT NOT NULL,
	[Beds] INT NOT NULL,
	[Bathrooms] FLOAT NOT NULL,									 --this is where we will transform bathroom_texts string to a float
	[Bathrooms_type] NVARCHAR(20) NOT NULL,						 -- description of type of bath (transformed by bathroom_texts)
	[Neighbourhood_cleansed] NVARCHAR(40) NOT NULL,						 --this is int by default values are 0..100
	[Number_of_reviews] INT NOT NULL,
	[Number_of_reviews_l30d] INT NOT NULL,
	[Review_scores_rating] INT NOT NULL,
	[Review_scores_accuracy] FLOAT NOT NULL,
	[Review_scores_cleanliness] FLOAT NOT NULL,
	[Review_scores_checkin] FLOAT NOT NULL,
	[Review_scores_communication] FLOAT NOT NULL,
	[Review_scores_location] FLOAT NOT NULL,
	[Review_scores_value] FLOAT NOT NULL,
	[Amenity_Count] INT NOT NULL
);

if exists (select * from sysobjects where id = object_id('stayMore.dbo.DimHosts') )
	drop table [stayMore].[dbo].[DimHosts]

CREATE TABLE DimHosts(
	[Host_Key] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Host_ID] INT NOT NULL,
	[Host_url] NVARCHAR(100) NOT NULL,
	[Host_name] NVARCHAR(100) NOT NULL,
	[Host_since] NVARCHAR(20) NOT NULL,
	[Host_response_time] NVARCHAR(25) NOT NULL,	--max char count was "within a few hours" with 18 chars  , 5 NULL(can convert to 'N/A') , 11,825 'N/A' values out of 16,254 rows
	[Host_response_rate] FLOAT NOT NULL,			-- values between 0 - 1 , 11,830 NULL values -> we can convert to 0
	[Host_acceptance_rate] FLOAT NOT NULL,		-- values between 0 - 1 , 7,852 NULL values -> we can convert to 'N/A'
	[Host_is_superhost] INT NOT NULL,				-- we can transform values f,t to 0,1 ---- 5 NULL values
	[Host_total_listings_count] INT NOT NULL,		-- 5 NULL values
	[Host_identity_verified] INT NOT NULL,			-- we can transform values f,t to 0,1 ---- 5 NULL values
	[Calculated_host_listings_count] INT NOT NULL
);

if exists (select * from sysobjects where id = object_id('stayMore.dbo.DimReviewers') )
	drop table [stayMore].[dbo].[DimReviewers]

CREATE TABLE DimReviewers(
	[Reviewer_Key] INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Reviewer_ID] INT NOT NULL,
	[Reviewer_name] NVARCHAR(50) NOT NULL -- max string was 41 characters therefore nvarchar (50) seems ok

);


if exists (select * from sysobjects where id = object_id('stayMore.dbo.DimDates') )
	drop table [stayMore].[dbo].[DimDates]

CREATE TABLE	DimDates (
		[Date_Key] INT PRIMARY KEY NOT NULL,
		[Date] DATETIME not null,
		[FullDate] CHAR(10) not null,			 -- Date in dd-MM-yyyy format
		[DayOfMonth] VARCHAR(2) not null,		 -- Field will hold day number of Month
		[DayName] VARCHAR(9) not null,			 -- Contains name of the day, Sunday, Monday 
		[DayOfWeek] INT not null,				 --CHAR(1),-- First Day Monday=1 and Sunday=7
		[DayOfWeekInMonth] INT not null,		 --VARCHAR(2), --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] INT not null,			 --VARCHAR(2),
		[DayOfQuarter] INT not null,			 --VARCHAR(3),
		[DayOfYear] INT not null,				 --VARCHAR(3),
		[WeekOfMonth] INT not null,				 --VARCHAR(1),-- Week Number of Month 
		[WeekOfQuarter] INT not null,			 --VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] INT not null,				 --VARCHAR(2),--Week Number of the Year
		[Month] INT not null,					 --VARCHAR(2), --Number of the Month 1 to 12
		[MonthName] VARCHAR(9) not null,		 --January, February etc
		[MonthOfQuarter] INT not null,			 --VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] INT not null,					 --CHAR(1),
		[Year] INT not null,					 --CHAR(4),-- Year value of Date stored in Row
		[MMYYYY] CHAR(6) not null,
		[FirstDayOfMonth] DATE not null,
		[LastDayOfMonth] DATE not null,
		[FirstDayOfQuarter] DATE not null,
		[LastDayOfQuarter] DATE not null,
		[FirstDayOfYear] DATE not null,
		[LastDayOfYear] DATE not null
	);


if exists (select * from sysobjects where id = object_id('stayMore.dbo.FactReviews') )
	drop table [stayMore].[dbo].[FactReviews]

CREATE TABLE FactReviews(
	[Reviewer_Key] INT NOT NULL,
	[Property_Key] INT NOT NULL,
	[Date_Key] INT NOT NULL,
	[Host_Key] INT NOT NULL,
	[Comments] nvarchar(4000) NOT NULL --largest comment found was 6,184 characters long. Only 10 out of almost 1 million had over 4,000 (this is the limit by our DB)	
);

if exists (select * from sysobjects where id = object_id('stayMore.dbo.FactCalendar') )
	drop table [stayMore].[dbo].[FactCalendar]

CREATE TABLE FactCalendar(
	[Property_Key] INT NOT NULL,
	[Date_Key] INT NOT NULL,
	[Host_Key] INT NOT NULL,
	[Available] INT NOT NULL,			-- all values either t,f -> transform to 1,0
	[Price] FLOAT NOT NULL,
	[Adjusted_price] INT NOT NULL,
	[Minimum_nights] INT NOT NULL,
	[Maximum_nights] INT NOT NULL
);



--**************************************** CONSTRAINTS: PRIMARY KEYS & FOREIGN KEYS ***********************************************************************


--FactCalendar Foreign Keys

alter table [StayMore].[dbo].FactCalendar
	add constraint FactCalendar_DimProperties_Property_Key_fk
		foreign key (Property_Key) references [StayMore].[dbo].DimProperties(Property_Key);

alter table [StayMore].[dbo].FactCalendar
	add constraint FactCalendar_DimHosts_Host_key_fk
		foreign key (Host_Key) references [StayMore].[dbo].DimHosts(Host_key);

alter table [StayMore].[dbo].FactCalendar
	add constraint FactCalendar_DimDates_Date_ID_fk
		foreign key (Date_Key) references [StayMore].[dbo].DimDates(Date_key);

--FactReviews Foreign Keys

alter table [StayMore].[dbo].FactReviews
	add constraint FactReviews_DimReviewers_Reviewer_Key_fk
		foreign key (Reviewer_Key) references [StayMore].[dbo].DimReviewers(Reviewer_Key);

alter table [StayMore].[dbo].FactReviews
	add constraint FactReviews_DimProperties_Property_Key_fk
		foreign key (Property_Key) references [StayMore].[dbo].DimProperties(Property_Key);

alter table [StayMore].[dbo].FactReviews
	add constraint FactReviews_DimDate_Date_ID_fk
		foreign key (Date_Key) references [StayMore].[dbo].DimDates(Date_key);

alter table [StayMore].[dbo].FactReviews
	add constraint FactReviews_DimHosts_Host_Key_fk
		foreign key (Host_Key) references [StayMore].[dbo].DimHosts(Host_Key);




--**************************************** TRANSFORM & INSERT VALUES ***********************************************************************

--DimReviewers


INSERT INTO [stayMore].[dbo].[DimReviewers]( 
	[reviewer_ID],
	[reviewer_name]) 
SELECT
	[air2_staging].[dbo].[reviewers].[reviewer_id],
	[air2_staging].[dbo].[reviewers].[fullname]
FROM [air2_staging].[dbo].[Reviewers]


--DimProperties
INSERT INTO [stayMore].[dbo].[DimProperties] (
	[Property_ID],
	[Latitude],
	[Longitude],			
	[Accommodates],		
	[Availability_365],
	[Has_availability],
	[Reviews_per_month],	
	[Calculated_host_listings_count],
	[Instant_bookable],
	[Property_type],
	[Room_type],
	[Bedrooms],
	[Beds],
	[Bathrooms],
	[Bathrooms_type],
	[Neighbourhood_cleansed],
	[Number_of_reviews],
	[Number_of_reviews_l30d],
	[Review_scores_rating],
	[Review_scores_accuracy],
	[Review_scores_cleanliness],
	[Review_scores_checkin],
	[Review_scores_communication],
	[Review_scores_location],
	[Review_scores_value],
	[Amenity_Count]
	)
SELECT 
	[air2_staging].[dbo].[Properties].propertyId,
	[air2_staging].[dbo].[Properties].latitude,
	[air2_staging].[dbo].[Properties].longitude,
	[air2_staging].[dbo].[Properties].accommodates,
	[air2_staging].[dbo].[Properties].availability_365,
	CASE 
		WHEN [air2_staging].[dbo].[Properties].[has_availability] = 't' THEN 1
		ELSE 0
	END,
	CASE 
		WHEN reviews_per_month is null THEN 0
		ELSE reviews_per_month
	END,
	CASE 
		WHEN [calculated_host_listings_count] is null THEN 0
		ELSE [calculated_host_listings_count]
	END,
	CASE
		WHEN instant_bookable = 't' THEN 1
		ELSE 0
	END,
	[air2_staging].[dbo].[Properties].property_type,
	[air2_staging].[dbo].[Properties].room_type,
	---Cleaning nulls from bedrooms to 0
	CASE
		WHEN bedrooms IS NULL THEN 0
		ELSE bedrooms
	END,
	---Cleaning nulls from beds to 0
	CASE
		WHEN beds IS NULL THEN 0
		ELSE beds
	END,
	--bathrooms (extracting it from bathrooms_text in the staging)
	CASE 
		WHEN bathrooms_text LIKE '%half-bath%' THEN 0.5 --need to present it as a string here given the datatype
		WHEN bathrooms_text LIKE '% %' THEN CAST(LEFT(bathrooms_text, Charindex(' ', bathrooms_text) - 1) AS FLOAT) --taking the first substring before the first space which contains num of bathrooms
		WHEN bathrooms_text IS NULL THEN 0 	--only 5 values are null
		ELSE CAST(bathrooms_text AS float) 	--ensuring we have float value
	END,
	--bathrooms_type (extracting it from bathrooms_text in the staging)
	CASE
		WHEN bathrooms_text LIKE '%private%' THEN 'private bath(s)'
		WHEN bathrooms_text IS NULL THEN 'N/A'
		ELSE 'shared bath(s)'
	END,
	[air2_staging].[dbo].[Properties].neighbourhood_cleansed,
	CASE 
		WHEN number_of_reviews IS NULL THEN 0 
		ELSE number_of_reviews
	END,
	CASE 
		WHEN number_of_reviews_l30d IS NULL THEN 0 
		ELSE number_of_reviews_l30d
	END,
	CASE 
		WHEN review_scores_rating IS NULL THEN 0 
		ELSE review_scores_rating
	END,
	CASE 
		WHEN [review_scores_accuracy] IS NULL THEN 0 
		ELSE [review_scores_accuracy]
	END,
	CASE 
		WHEN [review_scores_cleanliness] IS NULL THEN 0 
		ELSE [review_scores_cleanliness]
	END,
	CASE 
		WHEN [review_scores_checkin] IS NULL THEN 0 
		ELSE [review_scores_checkin]
	END,
	CASE 
		WHEN [review_scores_communication] IS NULL THEN 0 
		ELSE [review_scores_communication]
	END,
	CASE 
		WHEN [review_scores_location] IS NULL THEN 0 
		ELSE [review_scores_location]
	END,
	CASE 
		WHEN [review_scores_value] IS NULL THEN 0 
		ELSE [review_scores_value]
	END,
	CASE 
		WHEN [AmenityCount] IS NULL THEN 0 
		ELSE [AmenityCount]
	END
FROM [air2_staging].[dbo].[Properties]

--DimHosts
INSERT INTO [stayMore].[dbo].[DimHosts]( 
	[Host_ID],
	[Host_url],
	[Host_name],
	[Host_since],
	[host_response_time],
	[host_response_rate],
	[host_acceptance_rate],
	[host_is_superhost],
	[host_total_listings_count],
	[host_identity_verified],
	[Calculated_host_listings_count]
	)
SELECT
	[air2_staging].[dbo].[Hosts].[host_id],
	CASE
		WHEN [host_url] IS NULL THEN 'N/A'
		ELSE [host_url]
	END,
	CASE
		WHEN [host_name] IS NULL THEN 'N/A'
		ELSE [host_name]
	END,
	CASE
		WHEN [host_since] IS NULL THEN 'N/A'
		ELSE CAST([host_since] AS NVARCHAR(20))
	END, 
	--host_response_time, 5 null, 11,825 'N/A'
	CASE
		WHEN host_response_time IS NULL THEN 'N/A'
		ELSE host_response_time
	END,
		--CASE --that was another idea that we dropped since N/A / NULL values are quite significant
			--WHEN host_response_time = 'within a day' THEN 24
			--WHEN host_response_time = 'within an hour' THEN 1
			--WHEN host_response_time = 'within a few hours' THEN 12
			--WHEN host_response_time = 'a few days or more' THEN 72
			--ELSE 0
		--END,

	--host_response_rate generally 0-1, float with 11,830 null values, to change to 0
	CASE
		WHEN host_response_rate IS NULL THEN 0
		ELSE CAST(host_response_rate AS float)
	END,

	--host_acceptance_rate generally 0-1, float with 7,852 null values, to change to 0
	CASE
		WHEN host_acceptance_rate IS NULL THEN 0
		ELSE CAST(host_acceptance_rate AS float)
	END,

	--host is superhost, generally t or f --> will map to 1 or 0 and 5 NULL values --> map to 0
	CASE
		WHEN host_is_superhost = 't' THEN 1
		ELSE 0
	END,

	--host_total_listings_count has 5 NULL values --> make 1 (verified by data, that 4 out of 5 had 1 and the last had 51)
	CASE
		WHEN host_total_listings_count IS NULL THEN 1
		ELSE host_total_listings_count
	END,

	--host_identity_verified 5 NULL values -> 0, the rest are t or f (mapped to 1 or 0)
	CASE
		WHEN host_identity_verified = 't' THEN 1
		ELSE 0
	END,
	CASE
		WHEN [calculated_host_listings_count] IS NULL THEN 0
		ELSE [calculated_host_listings_count]
	END
FROM [air2_staging].[dbo].[Hosts]



------DIMDATES
INSERT INTO DimDates (
		[Date_Key],
		[Date],
		[FullDate],
		[DayOfMonth],
		[DayName],
		[DayOfWeek],
		[DayOfWeekInMonth],
		[DayOfWeekInYear],
		[DayOfQuarter],
		[DayOfYear],
		[WeekOfMonth],
		[WeekOfQuarter],
		[WeekOfYear],
		[Month],
		[MonthName],
		[MonthOfQuarter],
		[Quarter],
		[Year],
		[MMYYYY],
		[FirstDayOfMonth],
		[LastDayOfMonth],
		[FirstDayOfQuarter],
		[LastDayOfQuarter],
		[FirstDayOfYear],
		[LastDayOfYear])
	SELECT 
		[DateKey],
		[Date],
		[FullDateUK],
		[DayOfMonth],
		[DayName],
		[DayOfWeekUK],
		[DayOfWeekInMonth],
		[DayOfWeekInYear],
		[DayOfQuarter],
		[DayOfYear],
		[WeekOfMonth],
		[WeekOfQuarter],
		[WeekOfYear],
		[Month],
		[MonthName],
		[MonthOfQuarter],
		[Quarter],
		[Year],
		[MMYYYY],
		[FirstDayOfMonth],
		[LastDayOfMonth],
		[FirstDayOfQuarter],
		[LastDayOfQuarter],
		[FirstDayOfYear],
		[LastDayOfYear]
	FROM [air2_staging].[dbo].[Date]

ALTER TABLE [staymore].[dbo].[DimDates] ALTER COLUMN Date date not null


----FactReviews

truncate table [staymore].[dbo].[FactReviews]

INSERT INTO [stayMore].[dbo].[FactReviews](
		[Reviewer_Key],
		[Property_Key],
		[Date_Key],
		[Host_Key],
		[Comments])
	SELECT 
		[StayMore].[dbo].[DimReviewers].Reviewer_Key,
		[StayMore].[dbo].[DimProperties].Property_Key,
		[StayMore].[dbo].[DimDates].Date_Key,
		[StayMore].[dbo].[DimHosts].Host_Key,
		CASE 
			WHEN [air2_staging].[dbo].[Reviews].[comments] IS NULL THEN 'N/A'   -- we have 250 null prices in comments
			WHEN [air2_staging].[dbo].[Reviews].[comments] = 'N/a' THEN 'N/A' 
			ELSE CAST([air2_staging].[dbo].[Reviews].[comments]	AS nvarchar(4000))	 -- maximum of 4,000 chars for unicode nvarchar type. Only 10 out of half a million reviews have over 4,000 chars
		END
FROM [air2_staging].[dbo].[Reviews]
join [StayMore].[dbo].[DimReviewers]
on [air2_staging].[dbo].[Reviews].reviewer_id=[StayMore].[dbo].[DimReviewers].Reviewer_ID
join [StayMore].[dbo].[DimProperties]
on [air2_staging].[dbo].[Reviews].listing_id = [StayMore].[dbo].[DimProperties].Property_Id
join [StayMore].[dbo].[DimDates]
on [air2_staging].[dbo].[Reviews].date = [StayMore].[dbo].[DimDates].Date
join [StayMore].[dbo].[DimHosts]
on [StayMore].[dbo].[DimHosts].[Host_ID] = [air2_staging].[dbo].[Reviews].[host_id]

----FactCalendar

truncate table [staymore].[dbo].FactCalendar

INSERT INTO [staymore].[dbo].FactCalendar(
		[Property_Key],
		[Date_key],
		[Host_key],
		[Available],			-- all values either t,f -> transform to 1,0
		[Price],
		[Adjusted_price],
		[Minimum_nights],
		[Maximum_nights])
	SELECT 
		[StayMore].[dbo].[DimProperties].Property_Key,
		[StayMore].[dbo].[DimDates].Date_Key,
		[StayMore].[dbo].[DimHosts].[Host_Key],
		CASE
			WHEN [air2_staging].[dbo].[Calendar].[available]='t' then 1
			ELSE 0
		END,			-- all values either t,f -> transform to 1,0
		[air2_staging].[dbo].[Calendar].[Price],
		CASE 
			WHEN [air2_staging].[dbo].[Calendar].[adjusted_price] IS NULL THEN 0   -- we eliminate nulls with 0
			ELSE [adjusted_price]								 
		END,
		CASE 
			WHEN [air2_staging].[dbo].[Calendar].[minimum_nights] IS NULL THEN 0   -- we eliminate nulls with 0
			ELSE [air2_staging].[dbo].[Calendar].[minimum_nights]								 
		END,
		CASE 
			WHEN [air2_staging].[dbo].[Calendar].[maximum_nights] IS NULL THEN 0   -- we eliminate nulls with 0
			ELSE [air2_staging].[dbo].[Calendar].[maximum_nights]								 
		END
	FROM [air2_staging].[dbo].[Calendar]
	join [StayMore].[dbo].[DimDates] 
	on [air2_staging].[dbo].[Calendar].[date] = [StayMore].[dbo].[DimDates].[Date]
	join [StayMore].[dbo].[DimProperties]
	on [air2_staging].[dbo].[Calendar].[listing_id] = [StayMore].[dbo].[DimProperties].Property_Id
	join [StayMore].[dbo].[DimHosts]
	on [air2_staging].[dbo].[Calendar].[host_id] = [StayMore].[dbo].[DimHosts].[Host_ID]