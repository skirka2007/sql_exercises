DROP PROCEDURE IF EXISTS test_3_tasks.num_whole_half;

DELIMITER //
CREATE PROCEDURE test_3_tasks.num_whole_half(name CHAR(30), quantity DECIMAL(17,3))
BEGIN
    SET @whole_difference = 0;
   	SET @halves_difference = 0;
    SET @num_whole = 0;
    SET @num_half = 0;
    SET @item_name = name;
   
   	# If the number is integer
	IF CEIL(quantity) = quantity THEN 
    	SET @whole_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 1) - quantity;
    
    	# If there are anough whole items to cover the order
    	IF @whole_difference >=0 THEN SET @num_whole = quantity;
    		SET @num_half = 0;
    
    	# If we need to check halves
    	ELSE SET @halves_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 0.5) + @whole_difference*2;
    		
    		#There are enough halves to cover the difference
    		IF @halves_difference >=0 THEN SET @num_whole = quantity + @whole_difference;
    			SET @num_half = -@whole_difference*2;
    								 
    		#There are no enough items to cover the order 						 
    		ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough items to cover the order';
    			SET @num_whole = quantity + @whole_difference; 
    			SET @num_half = -@whole_difference*2 + @halves_difference;
    		END IF;   	
    	END IF;
   	
    # If the number isn't integer
    ELSE SET @whole_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 1) - quantity + 0.5;
   		
   		#There are enough whole items
   		IF @whole_difference >=0 THEN 
   			SET @halves_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 0.5) - 1;
   		
   			#If there is 1 half to cover the order
   			IF @halves_difference>=0 THEN SET @num_whole = quantity - 0.5;
   				SET @num_half = 1;
   			
   			#Check if we can use the half of the additional whole item
   			ELSEIF @whole_difference >=1 THEN SET @num_whole = quantity + 0.5;
   				SET @num_half = 0;
   				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is needed to use the whole item instead of half';
   		
   			#There are no enough items to cover the order
   			ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough items to cover the order';
   				SET @num_whole = quantity - 0.5;
   				SET @num_half = 0;
   			END IF;
   		
   		#There are not enough whole items
   		ELSE SET @halves_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 0.5) 
   								  + @whole_difference*2 - 1;
    		
    		#There are enough halves to cover the order
    		If @halves_difference > 0 THEN SET @num_whole = quantity + @whole_difference - 0.5;
    			SET @num_half = -@whole_difference*2 +1;
    		
    		#There are not enough halves to cover the order
    		ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough items to cover the order';
    			SET @num_whole = quantity + @whole_difference - 0.5;
    			SET @num_half = -@whole_difference*2 + @halves_difference;
    		END IF;
    	
    	END IF;   			
   
    END IF;
    
    SET @num_whole = CONVERT(@num_whole, SIGNED);
    SET @num_half = CONVERT(@num_half, SIGNED);
   
    PREPARE stmt FROM "(SELECT * FROM test_3_tasks.items WHERE ARTICLE = ? AND VOL = 1 LIMIT ?)
		UNION ALL 
		(SELECT * FROM test_3_tasks.items WHERE ARTICLE = ? AND VOL = 0.5 LIMIT ?);";
	EXECUTE stmt USING @item_name, @num_whole, @item_name, @num_half;
	DEALLOCATE PREPARE stmt;

END //
DELIMITER ;



SET @item_name = 'A030001';
SET @item_volume = 10;

CALL num_whole_half(@item_name, @item_volume);



#to clarify the problem with the execution block
#signal errors as notification with the maximum available amount
#test the true of results


