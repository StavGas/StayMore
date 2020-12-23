use air2;
EXEC sp_changedbowner 'sa';


GO

CREATE VIEW Amenities_Count AS
SELECT        dbo.property.propertyId, COUNT(dbo.amenities.amenityid) AS AmenityCount
FROM            dbo.amenities INNER JOIN
                         dbo.amenitieslist ON dbo.amenities.amenityid = dbo.amenitieslist.amenityId INNER JOIN
                         dbo.property ON dbo.amenities.propertyId = dbo.property.propertyId
GROUP BY dbo.property.propertyId

GO

create table reviewers
( [id] int primary key,
[fullname] nvarchar(max)
);

insert into reviewers
select distinct reviewer_id id, reviewer_name fullname 
from reviews

alter table reviews drop column reviewer_name

alter table reviews add constraint review_reviewer_id
    foreign key (reviewer_id) references reviewers(id);


