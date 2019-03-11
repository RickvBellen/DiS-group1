CREATE VIEW with_grade as (
	SELECT *
	FROM CourseRegistrations
	WHERE grade > 0
);

CREATE MATERIALIZED VIEW passed_grades as (
	SELECT studentid, degreeid, with_grade.studentregistrationid, courseofferid, grade
	FROM with_grade, studentregistrationstodegrees
	WHERE grade > 4
	and studentregistrationstodegrees.studentregistrationid = with_grade.studentregistrationid
);

CREATE INDEX idx_passed_grades on passed_grades(studentid);

CREATE MATERIALIZED VIEW GPA as (
	SELECT studentregistrationid, CAST(sum(grade * ECTS) AS float) / CAST(sum(ECTS) AS float) as avgGrade
	FROM passed_grades, courseoffers, courses
	WHERE passed_grades.courseofferid = courseoffers.courseofferid
	and courseoffers.courseid = courses.courseid
	GROUP BY studentregistrationid
);

CREATE VIEW student_ECTS as (
	SELECT studentregistrationid, sum(ECTS) as ECTS
	FROM courses, courseoffers, passed_grades
	WHERE courses.courseid = courseoffers.courseid
	and courseoffers.courseofferid = passed_grades.CourseOfferId
	GROUP BY studentregistrationid
);


CREATE VIEW completed_students_per_degree as (
	SELECT DISTINCT student_ECTS.studentregistrationid
	FROM  student_ECTS, degrees, studentregistrationstodegrees
	WHERE degrees.degreeid = studentregistrationstodegrees.degreeid
	and studentregistrationstodegrees.studentregistrationid = student_ECTS.studentregistrationid
	and ECTS >= totalECTS
);

CREATE VIEW active_students_per_degree as (
	(SELECT studentregistrationid
	FROM studentregistrationstodegrees)
	EXCEPT
	(SELECT studentregistrationid
	FROM completed_students_per_degree
	)
);

CREATE MATERIALIZED VIEW degrees_where_all_passed as (
	SELECT completed_students_per_degree.studentregistrationid
	FROM completed_students_per_degree, with_grade
	WHERE with_grade.studentregistrationid = completed_students_per_degree.studentregistrationid
	GROUP BY completed_students_per_degree.studentregistrationid
	HAVING MIN(grade) >= 5
);

CREATE VIEW fem_in_dept as (
	SELECT dept, count(distinct students.studentid) as value
	FROM students, degrees, studentregistrationstodegrees
	WHERE students.studentid = studentregistrationstodegrees.studentid
	and studentregistrationstodegrees.degreeid = degrees.degreeid
	and gender = 'F'
	GROUP BY dept
);

CREATE VIEW total_in_dept as (
	SELECT dept, count(distinct studentid) as value
	FROM studentregistrationstodegrees, degrees
	WHERE studentregistrationstodegrees.degreeid = degrees.degreeid
	GROUP BY dept
);

CREATE VIEW student_grades_2018_1 as (
	SELECT studentid, courseoffers.courseofferid, Grade
	FROM passed_grades, CourseOffers
	WHERE Year = 2018 and quartile = 1
	and passed_grades.CourseOfferId = CourseOffers.CourseOfferId
);

CREATE VIEW highest_course_grades as (
	SELECT courseofferid, max(Grade) as value
	FROM student_grades_2018_1
	GROUP BY courseofferid
);

CREATE VIEW excellent_students_q6 as (
	SELECT studentid
	FROM student_grades_2018_1, highest_course_grades
	WHERE student_grades_2018_1.courseofferid = highest_course_grades.CourseOfferId
	and student_grades_2018_1.grade = highest_course_grades.value
);

CREATE VIEW student_assistant_count as (
	SELECT courseofferid, count(*) as value
	FROM studentassistants
	GROUP BY courseofferid
);

CREATE VIEW student_count as (
	SELECT courseofferid, count(*) as value
	FROM CourseRegistrations
	GROUP BY courseofferid
);

CREATE VIEW q8 as (
	(SELECT courseofferid from courseoffers)
	EXCEPT
	(SELECT courseoffers.courseofferid from courseoffers, student_assistant_count, student_count
	WHERE student_assistant_count.courseofferid = courseoffers.CourseOfferId 
	and student_count.courseofferid = courseoffers.CourseOfferId 
	and student_assistant_count.value*50 >= student_count.value
	)
);