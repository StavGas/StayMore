SELECT        dbo.DimProperties.Property_Key, dbo.DimProperties.Property_ID, dbo.DimProperties.Latitude, dbo.DimProperties.Longitude, dbo.DimProperties.Accommodates, dbo.DimProperties.Availability_365, 
                         dbo.DimProperties.Has_availability, dbo.DimProperties.Reviews_per_month, dbo.DimProperties.Calculated_host_listings_count, dbo.DimProperties.Property_type, dbo.DimProperties.Instant_bookable, 
                         dbo.DimProperties.Room_type, dbo.DimProperties.Bedrooms, dbo.DimProperties.Beds, dbo.DimProperties.Bathrooms, dbo.DimProperties.Bathrooms_type, dbo.DimProperties.Neighbourhood_cleansed, 
                         dbo.DimProperties.Number_of_reviews, dbo.DimProperties.Number_of_reviews_l30d, dbo.DimProperties.Review_scores_rating, dbo.DimProperties.Review_scores_accuracy, dbo.DimProperties.Review_scores_checkin, 
                         dbo.DimProperties.Review_scores_cleanliness, dbo.DimProperties.Review_scores_communication, dbo.DimProperties.Review_scores_location, dbo.DimProperties.Review_scores_value, dbo.DimProperties.Amenity_Count, 
                         AVG(dbo.FactCalendar.Price) AS avgprice
FROM            dbo.DimProperties INNER JOIN
                         dbo.FactCalendar ON dbo.DimProperties.Property_Key = dbo.FactCalendar.Property_Key
GROUP BY dbo.DimProperties.Property_ID, dbo.DimProperties.Latitude, dbo.DimProperties.Longitude, dbo.DimProperties.Accommodates, dbo.DimProperties.Availability_365, dbo.DimProperties.Has_availability, 
                         dbo.DimProperties.Reviews_per_month, dbo.DimProperties.Calculated_host_listings_count, dbo.DimProperties.Property_type, dbo.DimProperties.Instant_bookable, dbo.DimProperties.Room_type, 
                         dbo.DimProperties.Bedrooms, dbo.DimProperties.Beds, dbo.DimProperties.Bathrooms, dbo.DimProperties.Bathrooms_type, dbo.DimProperties.Neighbourhood_cleansed, dbo.DimProperties.Number_of_reviews, 
                         dbo.DimProperties.Number_of_reviews_l30d, dbo.DimProperties.Review_scores_rating, dbo.DimProperties.Review_scores_accuracy, dbo.DimProperties.Review_scores_checkin, 
                         dbo.DimProperties.Review_scores_cleanliness, dbo.DimProperties.Review_scores_communication, dbo.DimProperties.Review_scores_location, dbo.DimProperties.Review_scores_value, dbo.DimProperties.Amenity_Count, 
                         dbo.DimProperties.Property_Key