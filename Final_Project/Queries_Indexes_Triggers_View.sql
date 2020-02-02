USE sp;

-- Выведем топ 10 компаний с самым большим количеством пользователей

SELECT 
  companies.company_name AS Company_Name,
  company_types.name AS Type_of_company,
  COUNT(company_id) AS Total_Users
FROM users
  LEFT JOIN companies ON 
    users.company_id = companies.id
  LEFT JOIN company_types ON 
    companies.company_type_id = company_types.id
GROUP BY users.company_id
ORDER BY Total_Users DESC
LIMIT 10;
  
-- Выведем топ 10 пользователей по количеству идей и добавим информацию о том, сколько из 
-- их идей дошло до реализации

SELECT 
  users.first_name, 
  users.last_name, 
  (SELECT companies.company_name FROM companies 
   WHERE companies.id = users.company_id) AS Company,
  (SELECT COUNT(*) FROM ideas WHERE ideas.created_by = users.id) AS Total_ideas,
  (SELECT COUNT(*) FROM 
     feature_commits
     LEFT JOIN feature_requests ON 
       feature_commits.fr_id = feature_requests.id
     LEFT JOIN ideas ON 
       feature_requests.idea_id = ideas.id
   WHERE ideas.created_by = users.id AND feature_commits.fc_status_id =4) AS Completed_FC
FROM users
ORDER BY Total_ideas DESC
LIMIT 10;


-- Создадим дополнительные индексы по таблицам ideas (поля created_by, created_at), 
-- messages (поле idea_id), roadmaps (поле start_date).

CREATE INDEX ideas_created_by ON ideas(created_by);

CREATE INDEX ideas_created_at ON ideas(created_at);

CREATE INDEX messages_idea_id ON messages(idea_id);

CREATE INDEX roadmaps_start_date ON roadmaps(start_date);

-- Создадим триггер на добавление в таблицу ideas, который будет автоматически ставить флаг 
-- customer_idea = 1 если запись создана пользователем компании клиента.

CREATE TRIGGER set_customer_idea BEFORE INSERT ON ideas
FOR EACH ROW BEGIN 
	IF NEW.created_by IN (SELECT
	  user_id
	  FROM users
	    LEFT JOIN companies ON 
	      users.company_id = companies.id
	    LEFT JOIN company_types ON 
	      companies.company_type_id = company_types.id
	  WHERE company_types.name = 'Customer') THEN
	  SET NEW.customer_idea = 1;
	END IF;
END//

-- Создадим триггер на добавление в таблицу ideas который требует заполнения имени или описания
-- идеи.

CREATE TRIGGER validate_idea_update BEFORE UPDATE ON ideas
FOR EACH ROW BEGIN
  IF NEW.idea_name IS NULL AND NEW.idea_description IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Both name and description are NULL';
  END IF;
END//

-- Создадим view для просмотра feature_commits клиентами, без указания данных о team_id, 
-- created_by, updated_by

CREATE VIEW fc_customers AS
  SELECT id, fc_name, fr_id, fc_status_id, company_id FROM feature_commits;
 
SELECT * FROM fc_customers ;

CREATE USER 'user_read'@'localhost';
GRANT SELECT (id, fc_name, fr_id, fc_status_id, company_id) ON 
  sp.fc_customers TO 'user_read'@'localhost';





