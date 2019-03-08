SELECT 0;
SELECT distinct studentId FROM GPA, degrees_where_all_passed, studentregistrationstodegrees WHERE GPA.avgGrade > %1% and GPA.studentregistrationid = degrees_where_all_passed.StudentregistrationId and studentregistrationstodegrees.studentregistrationid = gpa.studentregistrationid ORDER BY studentid;
SELECT degreeid, AVG(case gender when 'F' then 1 else 0 end) as percentage FROM active_students_per_degree, students, studentregistrationstodegrees WHERE studentregistrationstodegrees.studentregistrationid = active_students_per_degree.studentregistrationid and students.studentid = studentregistrationstodegrees.studentid GROUP BY DegreeId;
SELECT CAST(fem_in_dept.value AS float) / CAST(total_in_dept.value AS float) as percentage FROM fem_in_dept, total_in_dept WHERE fem_in_dept.dept = %1% and total_in_dept.dept = %1%;
SELECT courseid, AVG(case when grade >= %1% then 1 else 0 end) as percentagePassing FROM with_grade, CourseOffers WHERE with_grade.courseofferid = courseoffers.CourseOfferId GROUP BY courseid;
SELECT distinct studentid, count(studentid) as numberOfCoursesWhereExcellent FROM excellent_students_q6 GROUP BY studentid HAVING count(studentid) >= %1%;
SELECT degreeid, birthyearstudent as birthyear, gender, avg(avgGrade) as avgGrade FROM students, GPA, active_students_per_degree, studentregistrationstodegrees WHERE students.studentid = studentregistrationstodegrees.StudentId and GPA.studentregistrationid = studentregistrationstodegrees.StudentregistrationId  and studentregistrationstodegrees.studentregistrationid = active_students_per_degree.studentregistrationid GROUP BY cube(degreeid, birthyearstudent, gender);
SELECT courseName, year, quartile FROM courses, courseoffers, student_assistant_count, student_count WHERE courseoffers.courseid = courses.courseid and student_assistant_count.courseofferid = courseoffers.CourseOfferId and student_count.courseofferid = courseoffers.CourseOfferId and student_assistant_count.value*50 < student_count.value ORDER BY courseoffers.CourseOfferId;