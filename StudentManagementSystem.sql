CREATE DATABASE StudentManagement;
USE StudentManagement;

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) NOT NULL,
    email VARCHAR(100)UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    address TEXT
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    course_description TEXT,
    credit_hours INT NOT NULL
);

CREATE TABLE enrollment (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    CONSTRAINT
      FOREIGN KEY(student_id)REFERENCES students(student_id),
      FOREIGN KEY(course_id)REFERENCES courses(course_id)
);

CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100)UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE
);

CREATE TABLE assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
	instructor_id INT NOT NULL,
    CONSTRAINT
      FOREIGN KEY(course_id)REFERENCES courses(course_id),
      FOREIGN KEY(instructor_id)REFERENCES instructors(instructor_id)
);

SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM enrollment;
SELECT * FROM instructors;
SELECT * FROM assignments;

-- 1. full name ,email of all student enrolled in the computer science course -- 
 
SELECT concat(first_name,' ',last_name)AS fullname , email FROM students WHERE student_id IN(
SELECT e.student_id FROM enrollment e JOIN 
courses c ON e.course_id = c.course_id WHERE course_name = 'computer science');

SELECT CONCAT(first_name,' ',last_name)AS fullname ,email FROM students WHERE student_id IN(
SELECT student_id FROM enrollment WHERE course_id IN(
SELECT course_id FROM courses WHERE course_name ='computer science'));

-- 2. list all courses along with the number of students enrolled in each courses -- 

SELECT c.course_name,COUNT(*)AS tot FROM courses c 
JOIN enrollment e ON c.course_id = e.course_id GROUP BY c.course_name ;

-- 3. instructors who are teaching more than 2 courses -- 
 
SELECT i.instructor_id,i.first_name,COUNT(*)AS tot FROM assignments a 
JOIN instructors i ON i.instructor_id = a.instructor_id 
GROUP BY i.instructor_id ,first_name HAVING COUNT(*)>2;

SELECT CONCAT(first_name,' ',last_name)AS fullname , email FROM instructors 
WHERE instructor_id IN(
SELECT e.instructor_id FROM assignments e JOIN 
courses c ON e.course_id = c.course_id 
GROUP BY e.instructor_id HAVING COUNT(*)>2 );

-- 4. retrieve the details of students name , email who are enrolled in a course taught by instructor name -- 
 
SELECT s.first_name,s.email,c.course_name, e.enrollment_date,
CONCAT(i.first_name,' ',i.last_name)AS Instructor FROM students s 
JOIN enrollment e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN assignments a ON c.course_id = a.course_id
JOIN instructors i ON a.instructor_id = i.instructor_id;


-- 5. list all students who have not enrolled in any courses -- 
 
SELECT * FROM students WHERE student_id NOT IN (
  SELECT student_id FROM enrollment);
 
SELECT * FROM students s LEFT JOIN enrollment e ON s.student_id=e.student_id 
WHERE e.course_id IS NULL;
  
-- 6. get the list of the course with no assigned instructor --
 
SELECT * FROM courses WHERE course_id NOT IN (
  SELECT course_id FROM assignments);
 
-- 7. full details of the students sorted by order by alphabetical order -- 
 
SELECT * FROM students ORDER BY first_name ASC;
 
-- 8. total credit hours of student enrolled in the web development,database systems -- 
 
SELECT course_name ,SUM(c.credit_hours)AS tot FROM students s 
JOIN enrollment e ON s.student_id = e.student_id 
JOIN courses c ON e.course_id = c.course_id 
WHERE c.course_name IN("Database systems","Web Development")GROUP BY course_name;

SELECT c.course_name, COUNT(c.course_id)AS totalstudents,c.credit_hours,
SUM(c.credit_hours) AS totalhours FROM courses c 
JOIN enrollment e ON c.course_id = e.course_id
WHERE c.course_name IN('web development','database systems')GROUP BY c.course_id;

-- 9. identity the student wuth the max number of enrollments -- 

SELECT s.first_name,s.last_name, COUNT(*)AS totalenroll FROM students s
JOIN enrollment e ON s.student_id = e.student_id 
GROUP BY s.student_id ORDER BY totalenroll DESC LIMIT 1 ;

-- 10. get the details of students whose phone number are missing --

SELECT * FROM students WHERE phone_number IS NULL;
