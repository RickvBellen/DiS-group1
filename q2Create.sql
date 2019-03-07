CREATE MATERIALIZED VIEW with_grade as (
	SELECT *
	FROM CourseRegistrations
	WHERE grade > 0
);

CREATE MATERIALIZED VIEW GPA as (
	SELECT studentid, studentregistrationstodegrees.degreeid, CAST(sum(grade * ECTS) AS float) / CAST(sum(ECTS) AS float) as avgGrade
	FROM with_grade, studentregistrationstodegrees, courseoffers, courses
	WHERE studentregistrationstodegrees.studentregistrationid = with_grade.studentregistrationid
	and with_grade.courseofferid = courseoffers.courseofferid
	and courseoffers.courseid = courses.courseid
	and grade >= 5
	GROUP BY studentid, studentregistrationstodegrees.degreeid
);

CREATE VIEW student_ECTS as (
	SELECT studentregistrationstodegrees.degreeid, studentid, sum(ECTS) as ECTS
	FROM courses, courseoffers, with_grade, studentregistrationstodegrees
	WHERE courses.courseid = courseoffers.courseid
	and courseoffers.courseofferid = with_grade.CourseOfferId
	and grade >= 5
	and studentregistrationstodegrees.studentregistrationid = with_grade.studentregistrationid
	GROUP BY studentregistrationstodegrees.degreeid, studentid
);

CREATE VIEW completed_students_per_degree as (
	SELECT DISTINCT student_ECTS.studentid, degrees.degreeid
	FROM  student_ECTS, degrees
	WHERE degrees.degreeid = student_ECTS.degreeid
	and ECTS >= totalECTS
	ORDER BY degrees.degreeid, student_ECTS.studentid
);

CREATE MATERIALIZED VIEW active_students_per_degree as (
	(SELECT studentid, degreeid
	FROM studentregistrationstodegrees)
	EXCEPT
	(SELECT studentid, degreeid
	FROM completed_students_per_degree
	)
);

CREATE VIEW completed_students_per_degree_with_grades as (
	SELECT completed_students_per_degree.studentid, completed_students_per_degree.degreeid, grade
	FROM completed_students_per_degree, with_grade, studentregistrationstodegrees
	WHERE with_grade.studentregistrationid = studentregistrationstodegrees.studentregistrationid
	AND studentregistrationstodegrees.degreeid = completed_students_per_degree.degreeid
	AND studentregistrationstodegrees.studentid = completed_students_per_degree.studentid
);

CREATE MATERIALIZED VIEW degrees_where_all_passed as (
	SELECT studentid, degreeid
	FROM completed_students_per_degree_with_grades
	GROUP BY studentid, degreeid
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
	FROM with_grade, CourseOffers, studentregistrationstodegrees
	WHERE Year = 2018 and quartile = 1
	and with_grade.CourseOfferId = CourseOffers.CourseOfferId
	and studentregistrationstodegrees.studentregistrationid = with_grade.studentregistrationid
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
	SELECT courseofferid, count(distinct studentregistrationid) as value
	FROM studentassistants
	GROUP BY courseofferid
);

CREATE VIEW student_count as (
	SELECT courseofferid, count(distinct studentregistrationid) as value
	FROM CourseRegistrations
	GROUP BY courseofferid
);