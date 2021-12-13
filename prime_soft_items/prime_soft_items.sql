DROP PROCEDURE IF EXISTS test_3_tasks.num_whole_half;

DELIMITER //
CREATE PROCEDURE test_3_tasks.num_whole_half(name CHAR(30), quantity DECIMAL(17,3))
BEGIN
    SET @whole_difference = 0;
   	SET @halves_difference = 0;
    SET @num_whole = 0;
    SET @num_half = 0;
    SET @item_name = name;
    SET @error_msg = ('There are not enough items to cover the order, there is/are only ');
   
   	# If the number is integer (checked)
	IF CEIL(quantity) = quantity THEN 
    	SET @whole_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 1 AND STATUS = 0) - quantity;
    
    	# There are anough whole items to cover the order (checked)
    	IF @whole_difference >=0 THEN SET @num_whole = quantity;
    		SET @num_half = 0;
    
    	# If we need to check halves
    	ELSE SET @halves_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 0.5 AND STATUS = 0) + @whole_difference*2;
    		
    		#There are enough halves to cover the difference (checked)
    		IF @halves_difference >=0 THEN SET @num_whole = quantity + @whole_difference;
    			SET @num_half = -@whole_difference*2;
    								 
    		#There are no enough items to cover the order (checked)					 
    		ELSE 
    			SET @num_whole = quantity + @whole_difference; 
    			SET @num_half = -@whole_difference*2 + @halves_difference;
    		
    			SET @error_msg = CONCAT(@error_msg, ROUND(@num_whole,0), ' whole items and ', ROUND(@num_half,0), ' half(-ves).');
    			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_msg;
    			
    		END IF;   	
    	END IF;
   	
    # If the number isn't integer
    ELSE SET @whole_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 1 AND STATUS = 0) - quantity + 0.5;
   		
   		#If there are enough whole items
   		IF @whole_difference >=0 THEN 
   			SET @halves_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 0.5 AND STATUS = 0) - 1;
   		
   			#There is 1 half to cover the order (checked)
   			IF @halves_difference>=0 THEN SET @num_whole = quantity - 0.5;
   				SET @num_half = 1;
   			
   			#We can use the half of the additional whole item (checked)
   			ELSEIF @whole_difference >=1 THEN SET @num_whole = quantity + 0.5;
   				SET @num_half = 0;
   				SELECT('It is needed to use the whole item instead of a half');
   			
   		
   			#There are not enough items to cover the order (checked)
   			ELSE 
   				SET @num_whole = quantity - 0.5;
   				SET @num_half = 0;
   				    
   				SET @error_msg = CONCAT(@error_msg, ROUND(@num_whole,0), ' whole items.');
   				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_msg;
   				END IF;
   		
   		#If there are not enough whole items
   		ELSE SET @halves_difference = (SELECT COUNT(VOL) FROM test_3_tasks.items WHERE ARTICLE = name AND VOL = 0.5 AND STATUS = 0) 
   								  + @whole_difference*2 - 1;
    		
    		#There are enough halves to cover the order (checked)
    		If @halves_difference > 0 THEN SET @num_whole = quantity + @whole_difference - 0.5;
    			SET @num_half = -@whole_difference*2 +1;
    		
    		#There are not enough halves to cover the order (checked)
    		ELSE 
    			SET @num_whole = quantity + @whole_difference - 0.5;
    			SET @num_half = -@whole_difference*2 + @halves_difference +1;
    		
    			SET @error_msg = CONCAT(@error_msg, ROUND(@num_whole,0), ' whole items and ', ROUND(@num_half,0), ' half(-ves).');
    			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_msg;
    		END IF;
    	
    	END IF;   			
   
    END IF;
    
    SET @num_whole = CONVERT(@num_whole, SIGNED);
    SET @num_half = CONVERT(@num_half, SIGNED);
   
    PREPARE stmt FROM "(SELECT * FROM test_3_tasks.items WHERE ARTICLE = ? AND VOL = 1 AND STATUS = 0 LIMIT ?)
		UNION ALL 
		(SELECT * FROM test_3_tasks.items WHERE ARTICLE = ? AND VOL = 0.5 AND STATUS = 0 LIMIT ?);";
	EXECUTE stmt USING @item_name, @num_whole, @item_name, @num_half;
	DEALLOCATE PREPARE stmt;

END //
DELIMITER ;



SET @item_name = 'A011450';
SET @item_volume = 15.5;

CALL num_whole_half(@item_name, @item_volume);



