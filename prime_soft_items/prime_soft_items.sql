DELIMITER //
CREATE PROCEDURE num_whole_half(IN name VARCHAR, IN quantity DECIMAL, OUT num_whole INT, OUT num_half INT)
BEGIN
    SET @whole_difference = 0;
   	SET @halves_difference = 0;
   
   	# If the number is integer
	IF CEIL(quantity) = quantity THEN 
    	@whole_difference = (SELECT COUNT(VOL) FROM srv43968_test.items WHERE ARTICLE = name AND VOL = 1) - quantity;
    
    	# If there are anough whole items to cover the order
    	IF @whole_difference >=0 THEN num_whole = quantity AND num_half = 0;
    
    	# If we need to check halves
    	ELSE @halves_difference = (SELECT COUNT(VOL) FROM srv43968_test.items WHERE ARTICLE = name AND VOL = 0.5) + @whole_difference)*2;
    		
    		#There are enough halves to cover the difference
    		IF @halves_difference >=0 THEN num_whole = quantity + @whole_difference AND 
    								  num_half = -@whole_difference*2;
    								 
    		#There are no enough items to cover the order 						 
    		ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough items to cover the order';
    			num_whole = quantity + @whole_difference; 
    			num_half = -@whole_difference*2 + @halves_difference;
    		END IF;   	
    	END IF;
   	
    # If the number isn't integer
    ELSE @whole_difference = (SELECT COUNT(VOL) FROM srv43968_test.items WHERE ARTICLE = name AND VOL = 1) - quantity + 0.5;
   		
   		#There are enough whole items
   		IF @whole_difference >=0 THEN 
   			@halves_difference = (SELECT COUNT(VOL) FROM srv43968_test.items WHERE ARTICLE = name AND VOL = 0.5) - 1;
   		
   			#If there is 1 half to cover the order
   			IF @halves_difference>=0 THEN num_whole = quantity - 0.5 AND num_half = 1;
   			
   			#Check if we can use the half of the additional whole item
   			ELSEIF @whole_difference >=1 THEN num_whole = quantity + 0.5 AND num_half = 0;
   				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is needed to use the whole item instead of half';
   		
   			#There are no enough items to cover the order
   			ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough items to cover the order';
   				num_whole = quantity - 0.5;
   				num_half = 0;
   			END IF;
   		
   		#There are not enough whole items
   		ELSE @halves_difference = (SELECT COUNT(VOL) FROM srv43968_test.items WHERE ARTICLE = name AND VOL = 0.5) 
   								  + @whole_difference*2 - 1;
    		
    		#There are enough halves to cover the order
    		If @halves_difference > 0 THEN num_whole = quantity + @whole_difference - 0.5 AND 
    								  num_half = -@whole_difference*2 +1;
    		
    		#There are not enough halves to cover the order
    		ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough items to cover the order';
    			num_whole = quantity + @whole_difference - 0.5;
    			num_half = -@whole_difference*2 + @halves_difference;
    		END IF;
    	
    	END IF;   			
   
    END IF;
END //
DELIMITER ;


SET @item_whole = 0;
SET @item_half = 0;
SET @item_name = 'A030001';
SET @item_volume = 2.5;

num_whole_half(@item_name, @item_volume, @item_whole, @item_half);

SELECT *
FROM srv43968_test.items
WHERE ARTICLE = @item_name AND VOL = 1
LIMIT @item_whole

UNION ALL 

SELECT *
FROM srv43968_test.items
WHERE ARTICLE = @item_name AND VOL = 0.5
LIMIT @item_half;


