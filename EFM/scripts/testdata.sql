CREATE TABLE dept (
    deptno           NUMERIC(2) NOT NULL CONSTRAINT dept_pk PRIMARY KEY,
    dname            VARCHAR(14) CONSTRAINT dept_dname_uq UNIQUE,
    loc              VARCHAR(13)
);
CREATE TABLE emp (
    empno            NUMERIC(4) NOT NULL CONSTRAINT emp_pk PRIMARY KEY,
    ename            VARCHAR(10),
    job              VARCHAR(9),
    mgr              NUMERIC(4),
    hiredate         DATE,
    sal              NUMERIC(7,2) CONSTRAINT emp_sal_ck CHECK (sal > 0),
    comm             NUMERIC(7,2),
    deptno           NUMERIC(2) CONSTRAINT emp_ref_dept_fk
                         REFERENCES dept(deptno)
);
--GRANT ALL ON emp TO PUBLIC;
--GRANT ALL ON dept TO PUBLIC;
INSERT INTO dept VALUES (10,'ACCOUNTING','NEW YORK');
INSERT INTO dept VALUES (20,'RESEARCH','DALLAS');
INSERT INTO dept VALUES (30,'SALES','CHICAGO');
INSERT INTO dept VALUES (40,'OPERATIONS','BOSTON');

INSERT INTO emp VALUES (7369,'SMITH','CLERK',7902,'17-DEC-80',800,NULL,20);
INSERT INTO emp VALUES (7499,'ALLEN','SALESMAN',7698,'20-FEB-81',1600,300,30);
INSERT INTO emp VALUES (7521,'WARD','SALESMAN',7698,'22-FEB-81',1250,500,30);
INSERT INTO emp VALUES (7566,'JONES','MANAGER',7839,'02-APR-81',2975,NULL,20);
INSERT INTO emp VALUES (7654,'MARTIN','SALESMAN',7698,'28-SEP-81',1250,1400,30);
INSERT INTO emp VALUES (7698,'BLAKE','MANAGER',7839,'01-MAY-81',2850,NULL,30);
INSERT INTO emp VALUES (7782,'CLARK','MANAGER',7839,'09-JUN-81',2450,NULL,10);
INSERT INTO emp VALUES (7788,'SCOTT','ANALYST',7566,'19-APR-87',3000,NULL,20);
INSERT INTO emp VALUES (7839,'KING','PRESIDENT',NULL,'17-NOV-81',5000,NULL,10);
INSERT INTO emp VALUES (7844,'TURNER','SALESMAN',7698,'08-SEP-81',1500,0,30);
INSERT INTO emp VALUES (7876,'ADAMS','CLERK',7788,'23-MAY-87',1100,NULL,20);
INSERT INTO emp VALUES (7900,'JAMES','CLERK',7698,'03-DEC-81',950,NULL,30);
INSERT INTO emp VALUES (7902,'FORD','ANALYST',7566,'03-DEC-81',3000,NULL,20);
INSERT INTO emp VALUES (7934,'MILLER','CLERK',7782,'23-JAN-82',1300,NULL,10);


INSERT INTO emp VALUES (1234,'NIELSEN','ERIN',7902,'26-JAN-24',1300,NULL,10);