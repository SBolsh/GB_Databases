use sp;

-- ��������� ������� Users. �����, ��� login � email �� ���������, �������� ��� ���������. 

SELECT * FROM users LIMIT 100;

-- �������� ������ �������� �� ������� @ ���� 20 ��������, ���� �������� ��� ������ 20.
-- ����� 20 ����������� ������������ ���� ������� login "varchar(20)"

UPDATE users SET login = 
  CASE 
    WHEN LOCATE('@',email) < 20 THEN LEFT(email, LOCATE('@',email)-1)
    WHEN LOCATE('@',email) > 20 THEN LEFT(email, 20)
    ELSE LEFT(email, 20) END;

-- ��������� ������� User_processes. �����, ��� � ������� �������� ���� ���� ��������.
-- ���� �������� ���� � �� �� �������� ����� ���� � ������ ��������.     
   
SELECT * FROM user_processes;

-- ������ ������� company_id ������� ��������� ������� ��������� ��������-������� � ���������

ALTER TABLE user_processes DROP COLUMN company_id;

CREATE TABLE companies_processes(
  company_id INT UNSIGNED NOT NULL,
  user_process_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (company_id, user_process_id)
);

INSERT INTO companies_processes 
  SELECT
  FLOOR(1 + (RAND() * 100)),
  FLOOR(1 + (RAND() * 50))
  FROM companies;

SELECT * FROM companies_processes;

-- User_processes ��������������� �� Business_processes, ��� �������� � ����� �� ������ � users.  

ALTER TABLE user_processes RENAME business_processes;
ALTER TABLE companies_processes CHANGE user_process_id process_id INT(10) UNSIGNED NOT NULL;


SELECT * FROM business_processes;

-- �������� ���� �������� � ��������� �������� ��������� � ������������� �� ������� �����
-- �������� � ������� ����.

UPDATE business_processes SET
  created_at = DATE_SUB(NOW(), INTERVAL FLOOR(1 + (RAND() * 365)) DAY),
  updated_at = DATE_ADD(created_at, INTERVAL FLOOR(1 + (RAND() * 365)) DAY);

UPDATE users SET
  created_at = DATE_SUB(NOW(), INTERVAL FLOOR(1 + (RAND() * 365)) DAY);
 
UPDATE companies SET
  created_at = DATE_SUB(NOW(), INTERVAL FLOOR(1 + (RAND() * 365)) DAY);
 
SELECT * FROM companies LIMIT 100;

-- ������� ����� �������� ������ �������� � �������� � ������ ������ 25 �������� �� ������

UPDATE companies SET 
  industry_id = FLOOR(1+(RAND()*25));


-- ������� ����� �������� �������������� users � ��������� � ������ ������ 50 
-- �������� �� ������, � ��������� �������� ������������� � ����� ������� ����� � �� ����.

UPDATE users SET 
  company_id = FLOOR(1+(RAND()*50));


-- �������� ������� ����������� �� ����� �������� ���������� � �������.


SELECT * FROM company_types;

ALTER TABLE company_types CHANGE company_type_name name VARCHAR(100) NOT NULL;


SELECT users.id FROM 
  users
  LEFT JOIN companies ON
    users.company_id = companies.id
  LEFT JOIN company_types ON 
    companies.company_type_id = company_types.id
  WHERE
    company_types.name = 'My_Company';
    
    
-- � ��� � ����������� ������� � ������� ���� �� ������, "���������" 
-- �� ������������� � ���� ��������

UPDATE users 
  LEFT JOIN companies ON
    users.company_id = companies.id
  LEFT JOIN company_types ON 
    companies.company_type_id = company_types.id
  SET users.company_id = (
    SELECT companies.id FROM
      companies
      LEFT JOIN company_types ON 
      companies.company_type_id = company_types.id
      WHERE company_types.name = 'My_Company')
  WHERE company_types.name = 'Competitor';

 -- � ������� ��� ��������� ������������� �� ��������-�������� � ���
 
UPDATE users 
  SET users.company_id = (
    SELECT companies.id FROM
      companies
      LEFT JOIN company_types ON 
      companies.company_type_id = company_types.id
      WHERE company_types.name = 'My_Company')
  WHERE users.company_id = 1 OR users.company_id = 9 OR users.company_id = 18;
 

 -- �������� ������� dev_teams � �������� �������� ������� � id ������ �������
 
SELECT * FROM dev_teams;

ALTER TABLE dev_teams CHANGE team_leader_name team_leader_id INT UNSIGNED NOT NULL;

 -- ������� ���, ����� �������� ������ ���� ������ ���������� ����� ��������
 
UPDATE dev_teams
  SET dev_teams.team_leader_id = (
    SELECT users.id FROM 
      users 
      LEFT JOIN companies ON
      users.company_id = companies.id
      LEFT JOIN company_types ON 
      companies.company_type_id = company_types.id
      WHERE
        company_types.name = 'My_Company'
      ORDER BY RAND() LIMIT 1);
 

-- �������� ������� products, ����������� product_owner �� product_owner_id, ������ ��� ����� 
-- ��� ���� ������ ���������� �������� � ���� �������� �������� � ������ �������. ���� 
-- ���������� ������� ������ ������� ���� (�� �� ������ ������)
     
SELECT * FROM products;

ALTER TABLE products CHANGE product_owner product_owner_id INT UNSIGNED NOT NULL;

UPDATE products
  SET products.product_owner_id = (
    SELECT users.id FROM 
      users 
      LEFT JOIN companies ON
      users.company_id = companies.id
      LEFT JOIN company_types ON 
      companies.company_type_id = company_types.id
      WHERE
        company_types.name = 'My_Company'
      ORDER BY RAND() LIMIT 1);

UPDATE products SET
 created_at = DATE_SUB(NOW(), INTERVAL FLOOR(1 + (RAND() * 365)) DAY);
 
 -- �������� ������� ideas, ������� ������� ����� ���������� � ������������� ��������� �������
 -- ����, ��� ���� ����������� ���������. ��������� Select ��������� ��� ���� ������������� �����������
 -- ��������-���������.
 
SELECT * FROM ideas;
 
UPDATE ideas SET 
  created_by = FLOOR(1+(RAND()*100));
 
UPDATE ideas 
  LEFT JOIN users ON 
        ideas.created_by = users.id
      LEFT JOIN companies ON 
        users.company_id = companies.id
      LEFT JOIN company_types ON 
        companies.company_type_id = company_types.id  
  SET customer_idea = 
    CASE 
      WHEN company_types.name = 'Customer'
      THEN 1
      ELSE 0 END; 
    
SELECT ideas.id, ideas.customer_idea, company_types.name FROM ideas 
  LEFT JOIN users ON 
    ideas.created_by = users.id
  LEFT JOIN companies ON 
    users.company_id = companies.id
  LEFT JOIN company_types ON 
    companies.company_type_id = company_types.id;
   
UPDATE ideas SET
 created_at = DATE_SUB(NOW(), INTERVAL FLOOR(1 + (RAND() * 365)) DAY);
 
   
-- ��������� ������� fr_statuses (feature request statuses) � fc_statuses (feature commits
-- statuses). ������ ID �� ����� �� 1 �� 5.

SELECT * FROM fr_statuses;

TRUNCATE TABLE fr_statuses;

INSERT INTO fr_statuses (status_name) VALUES
  ('New'),
  ('Description completed'),
  ('Process identified'),
  ('Product identified'),
  ('Ready for commit');

SELECT * FROM fc_statuses;
    
TRUNCATE TABLE fc_statuses;

INSERT INTO fc_statuses (status_name) VALUES
  ('New'),
  ('Scheduled'),
  ('In progress'),
  ('Completed');
 
 
-- ���������, ��� auto increment ��� id �������� �������, ��������� �� ��� ��� ���. � company_types
-- �������� �� ����� �.�. ID ���������� � 0, ���������� ��� ������� � ������� companies.

ALTER TABLE sp.fc_statuses MODIFY COLUMN id tinyint(3) unsigned auto_increment NOT NULL;
ALTER TABLE sp.roles MODIFY COLUMN id tinyint(3) unsigned auto_increment NOT NULL;
ALTER TABLE sp.industries MODIFY COLUMN id int(10) unsigned auto_increment NOT NULL;
ALTER TABLE sp.company_types MODIFY COLUMN id tinyint(3) unsigned auto_increment NOT NULL;
ALTER TABLE sp.companies_processes MODIFY COLUMN company_id int(10) unsigned auto_increment NOT NULL;

UPDATE companies SET company_type_id = 3 WHERE company_type_id = 0;

UPDATE company_types SET id = 3 WHERE id = 0;


SELECT * FROM companies;

SELECT * FROM company_types;

-- ��������� ������� feature_requests, ������ �������� �� ����� ���������


SELECT * FROM feature_requests;

UPDATE feature_requests SET 
  idea_id = FLOOR(1+(RAND()*200));

UPDATE feature_requests SET 
  product_id = FLOOR(1+(RAND()*10));
 
UPDATE feature_requests SET 
  process_id = FLOOR(1+(RAND()*50));

ALTER TABLE feature_requests CHANGE fr_status fr_status_id INT UNSIGNED NOT NULL;
 
UPDATE feature_requests SET 
  fr_status_id = FLOOR(1+(RAND()*5));
 
UPDATE feature_requests AS fr
  LEFT JOIN ideas ON 
    fr.idea_id = ideas.id
  SET 
    fr.created_by = ideas.created_by,
    fr.created_at = DATE_ADD(ideas.created_at, INTERVAL FLOOR(1 + (RAND() * 30)) DAY),
    fr.updated_by = FLOOR(1+RAND()*100);

-- ������ ������� updated_by ����� �� ��� ������, ��� feature_request ����� ��������� ������
-- ���������� ����� ��������.   
   
UPDATE feature_requests SET 
  updated_by = (SELECT users.id FROM users 
    LEFT JOIN companies ON 
      users.company_id = companies.id
    LEFT JOIN company_types ON 
      companies.company_type_id = company_types.id
    WHERE        
      company_types.name = 'My_Company' 
    ORDER BY RAND() LIMIT 1);
   
-- ��������� ������� feature_commits, ������ ��� �� �������� � feature_requests. ������ ��� 
-- � ��������� � ��������� ����� ���� ���������� ��������. ID �������� ����� ����������� � 
-- ������������ � ��������� ������ ����, ���� � �������� ����� ��� �� ������ ��� ) 


ALTER TABLE features_commits RENAME feature_commits;   
   
SELECT * FROM feature_commits;

UPDATE feature_commits SET 
  fr_id = FLOOR(1+(RAND()*100));
 
UPDATE feature_commits SET 
  team_id = FLOOR(1+(RAND()*10));

ALTER TABLE feature_commits CHANGE fc_status fc_status_id INT UNSIGNED NOT NULL;
 
UPDATE feature_commits SET 
  fc_status_id = FLOOR(1+(RAND()*4))
   
UPDATE feature_commits
  LEFT JOIN feature_requests ON 
    feature_commits.fr_id = feature_requests.id
  LEFT JOIN ideas ON 
    feature_requests.idea_id = ideas.id
  LEFT JOIN users ON 
    ideas.created_by = users.id
SET
  feature_commits.company_id = users.company_id;
  
UPDATE feature_commits
  SET created_by = (
    SELECT users.id FROM 
      users 
      LEFT JOIN companies ON
      users.company_id = companies.id
      LEFT JOIN company_types ON 
      companies.company_type_id = company_types.id
      WHERE
        company_types.name = 'My_Company'
      ORDER BY RAND() LIMIT 1),
      updated_by = (
    SELECT users.id FROM 
      users 
      LEFT JOIN companies ON
      users.company_id = companies.id
      LEFT JOIN company_types ON 
      companies.company_type_id = company_types.id
      WHERE
        company_types.name = 'My_Company'
      ORDER BY RAND() LIMIT 1);  

UPDATE feature_commits AS fc
  LEFT JOIN feature_requests AS fr ON 
    fc.fr_id = fr.id
  SET 
    fc.created_at = DATE_ADD(fr.created_at, INTERVAL FLOOR(1 + (RAND() * 30)) DAY);  
   
   
  -- ��������� ������� roadmaps, products_id ������ ����� ���������. ���� ������ � ��������� ���������
  -- � ���� �����.
  
SELECT * FROM roadmaps;

UPDATE roadmaps SET 
  product_id = FLOOR(1+(RAND()*10)),
  start_date = DATE_ADD(LAST_DAY(DATE_SUB(NOW(), INTERVAL FLOOR(1 + (RAND() * 60)) DAY)), INTERVAL 1 DAY),
  finish_date = DATE_ADD(start_date, INTERVAL FLOOR(1 + (RAND() * 30)) DAY);
 
-- ��������� ������� messages.
  
SELECT * FROM messages;

UPDATE messages SET 
  from_user_id = FLOOR(1+(RAND()*100)),
  idea_id = FLOOR(1+(RAND()*200));
 
-- ��������� ������� roadmaps_features

SELECT * FROM roadmaps_features;

UPDATE roadmaps_features 
  SET 
    rm_id = (SELECT roadmaps.id 
      FROM roadmaps
        LEFT JOIN feature_requests ON 
          roadmaps.product_id = feature_requests.product_id
        LEFT JOIN feature_commits ON 
          feature_commits.fr_id = feature_requests.id
      WHERE roadmaps.product_id = feature_requests.product_id 
      AND feature_commits.id = roadmaps_features.fc_id
      ORDER BY RAND() LIMIT 1);
 
-- �������� ������� ����� � ���� ������, ��� �������� �������� ������������ ��������� � ������ ������, �������� �� ��� ����� � parent � child �������� ��� ���� ���������

DESC companies_processes;

ALTER TABLE sp.companies_processes MODIFY COLUMN company_id int(10) unsigned NOT NULL;

ALTER TABLE companies_processes DROP FOREIGN KEY comp_process_company_id_fk;
ALTER TABLE companies_processes DROP FOREIGN KEY comp_process_process_id_fk;

     
ALTER TABLE companies_processes
  ADD CONSTRAINT comp_process_company_id_fk 
    FOREIGN KEY (company_id) REFERENCES companies(id),
  ADD CONSTRAINT comp_process_process_id_fk 
    FOREIGN KEY (process_id) REFERENCES business_processes(id);
   
ALTER TABLE business_processes 
  ADD CONSTRAINT buss_proccesses_created_by_fk
    FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT;

ALTER TABLE company_types MODIFY COLUMN id INT(10) UNSIGNED auto_increment NOT NULL;
ALTER TABLE industries MODIFY COLUMN id INT(10) UNSIGNED auto_increment NOT NULL;
   
ALTER TABLE companies 
  ADD CONSTRAINT comp_comp_type_fk
    FOREIGN KEY (company_type_id) REFERENCES company_types(id)
    ON DELETE RESTRICT,
  ADD CONSTRAINT comp_industry_fk
    FOREIGN KEY (industry_id) REFERENCES industries(id)
    ON DELETE RESTRICT;

ALTER TABLE roles MODIFY COLUMN id INT(10) UNSIGNED auto_increment NOT NULL;   
  
ALTER TABLE users 
 ADD CONSTRAINT users_roles_fk
   FOREIGN KEY (role_id) REFERENCES roles(id)
   ON DELETE RESTRICT,
 ADD CONSTRAINT users_company_fk
   FOREIGN KEY (company_id) REFERENCES companies(id)
   ON DELETE RESTRICT; 

ALTER TABLE dev_teams 
  ADD CONSTRAINT dev_teams_leader_fk
    FOREIGN KEY (team_leader_id) REFERENCES users(id)
    ON DELETE RESTRICT;

ALTER TABLE products 
  ADD CONSTRAINT prodcuts_owner_fk
    FOREIGN KEY (product_owner_id) REFERENCES users(id)
    ON DELETE RESTRICT;

ALTER TABLE roadmaps 
  ADD CONSTRAINT roadmaps_products_fk
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE RESTRICT;
   
ALTER TABLE ideas 
  ADD CONSTRAINT ideas_users_fk
    FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT;
   
ALTER TABLE messages 
  ADD CONSTRAINT messages_users_fk
    FOREIGN KEY (from_user_id) REFERENCES users(id)
    ON DELETE RESTRICT,
  ADD CONSTRAINT messages_ideas_fk
    FOREIGN KEY (idea_id) REFERENCES ideas(id)
    ON DELETE RESTRICT;
 
ALTER TABLE fr_statuses MODIFY COLUMN id INT(10) UNSIGNED auto_increment NOT NULL;     
   
ALTER TABLE feature_requests 
  ADD CONSTRAINT fr_idea_fk
    FOREIGN KEY (idea_id) REFERENCES ideas(id)
    ON DELETE RESTRICT,
  ADD CONSTRAINT fr_products_fk
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE RESTRICT,  
   ADD CONSTRAINT fr_process_fk
    FOREIGN KEY (process_id) REFERENCES business_processes(id)
    ON DELETE RESTRICT,
  ADD CONSTRAINT fr_status_fk
    FOREIGN KEY (fr_status_id) REFERENCES fr_statuses(id)
    ON DELETE RESTRICT,   
  ADD CONSTRAINT fr_created_fk
    FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT,
  ADD CONSTRAINT fr_updated_fk
    FOREIGN KEY (updated_by) REFERENCES users(id)
    ON DELETE SET NULL;   

ALTER TABLE fc_statuses MODIFY COLUMN id INT(10) UNSIGNED auto_increment NOT NULL;     
   
ALTER TABLE feature_commits 
  ADD CONSTRAINT fc_fr_fk
    FOREIGN KEY (fr_id) REFERENCES feature_requests(id)
    ON DELETE RESTRICT,
  ADD CONSTRAINT fc_team_fk
    FOREIGN KEY (team_id) REFERENCES dev_teams(id)
    ON DELETE RESTRICT,  
   ADD CONSTRAINT fc_company_fk
    FOREIGN KEY (company_id) REFERENCES companies(id)
    ON DELETE RESTRICT,
  ADD CONSTRAINT fc_status_fk
    FOREIGN KEY (fc_status_id) REFERENCES fc_statuses(id)
    ON DELETE RESTRICT,   
  ADD CONSTRAINT fc_created_fk
    FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT,
  ADD CONSTRAINT fc_updated_fk
    FOREIGN KEY (updated_by) REFERENCES users(id)
    ON DELETE RESTRICT;    
   
ALTER TABLE roadmaps_features
  ADD CONSTRAINT roadmaps_features_roadmap_fk 
    FOREIGN KEY (rm_id) REFERENCES roadmaps(id),
  ADD CONSTRAINT roadmaps_features_fc_fk 
    FOREIGN KEY (fc_id) REFERENCES feature_commits(id);   
  
