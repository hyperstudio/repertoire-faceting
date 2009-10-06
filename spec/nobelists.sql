--
-- Testing data for faceting : MIT Nobel prize winners example
--

CREATE TABLE nobelists (
    id serial PRIMARY KEY,
    name text NOT NULL,
    birthdate timestamp without time zone,
    deathdate timestamp without time zone,
    birth_country text,
    birth_state text,
    birth_city text,
    url text,
    discipline text,
    shared boolean,
    last_name text NOT NULL,
    nobel_year integer NOT NULL,
    deceased boolean,
    co_winner text,
    image_url text,
    image_credit text
);

CREATE TABLE affiliations (
    id serial PRIMARY KEY,
    nobelist_id integer NOT NULL REFERENCES nobelists(id),
    detail text NOT NULL,
    degree text,
    year integer
);

---
--- TEST DATA
---
COPY nobelists (id, name, birthdate, deathdate, birth_country, birth_state, birth_city, url, discipline, shared, last_name, nobel_year, deceased, co_winner, image_url, image_credit) FROM stdin;
7	Edward M. Purcell	1912-08-30 00:00:00	1997-03-07 00:00:00	United States of America	Illinois	Taylorville	\N	Physics	t	Purcell	1952	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1952/purcell_thumb.jpg	\N
3	William Shockley	1910-02-13 00:00:00	1989-08-12 00:00:00	England	\N	London	\N	Physics	t	Shockley	1956	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1956/shockley_thumb.jpg	\N
11	Charles H. Townes	1915-07-28 00:00:00	\N	United States of America	South Carolina	Greenville	\N	Physics	t	Townes	1964	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1964/townes_thumb.jpg	\N
15	Richard P. Feynman	1918-05-11 00:00:00	1988-02-15 00:00:00	United States of America	New York	Queens	\N	Physics	t	Feynman	1965	\N	Julian Schwinger	http://nobelprize.org/nobel_prizes/physics/laureates/1965/feynman_thumb.jpg	\N
10	Hans A. Bethe	1906-06-02 00:00:00	2005-03-06 00:00:00	Germany	Alsace-Lorraine	Strasbourg	\N	Physics	f	Bethe	1967	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1967/bethe_thumb.jpg	\N
18	Har Gobind Khorana	1922-01-19 00:00:00	\N	British India	Punjab	Multan	\N	Medicine/Physiology	t	Khorana	1968	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1968/khorana_thumb.jpg	\N
17	Jack Steinberger	1921-05-25 00:00:00	\N	Germany	\N	Bad Kissingen	\N	Physics	t	Steinberger	1988	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1988/steinberger_thumb.jpg	\N
21	John Forbes Nash, Jr.	1928-06-13 00:00:00	\N	United States of America	West Virginia	Bluefield	\N	Economics	t	Nash	1994	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1994/nash_thumb.jpg	\N
12	K. Barry Sharpless	1941-04-28 00:00:00	\N	United States of America	Pennsylvania	Philadelphia	\N	Chemistry	t	Sharpless	2001	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/2001/sharpless_thumb.jpg	\N
1	Burton Richter	1931-03-22 00:00:00	\N	United States of America	New York	New York City	\N	Physics	t	Richter	1976	\N	Samuel C.C. Ting	http://nobelprize.org/nobel_prizes/physics/laureates/1976/richter_thumb.jpg	\N
4	Daniel C. Tsui	1939-02-28 00:00:00	\N	People's Republic of China	Henan	\N	\N	Physics	t	Tsui	1998	\N	Horst L. Störmer, Robert B. Laughlin	http://nobelprize.org/nobel_prizes/physics/laureates/1998/tsui_thumb.jpg	\N
5	Elias J. Corey Jr.	1928-07-12 00:00:00	\N	United States of America	Massachusetts	Methuen	\N	Chemistry	f	Corey	1990	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1990/corey_thumb.jpg	\N
6	Horst L. Störmer	1949-04-06 00:00:00	\N	Germany	\N	Frankfurt	\N	Physics	t	Störmer	1998	\N	Robert B. Laughlin, Daniel C. Tsui	http://nobelprize.org/nobel_prizes/physics/laureates/1998/stormer_thumb.jpg	\N
8	Phillip A. Sharp	1944-06-06 00:00:00	\N	United States of America	Kentucky	McKinneysburg	\N	Medicine/Physiology	t	Sharp	1993	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1993/sharp_thumb.jpg	\N
9	Lawrence R. Klein	1920-09-14 00:00:00	\N	United States of America	Nebraska	Omaha	\N	Economics	f	Klein	1980	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1980/klein_thumb.jpg	\N
16	E. Donnall Thomas	1920-03-15 00:00:00	\N	\N	\N	\N	\N	Medicine/Physiology	t	Thomas	1990	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1990/thomas_thumb.jpg	\N
28	Edwin M. McMillan	1907-09-18 00:00:00	1991-09-07 00:00:00	United State of America	California	Redondo Beach	\N	Chemistry	t	McMillan	1951	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1951/mcmillan_thumb.jpg	\N
24	Paul A. Samuelson	1915-05-15 00:00:00	\N	United States of America	Indiana	Gary	\N	Economics	f	Samuelson	1970	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1970/samuelson_thumb.jpg	\N
39	Robert Burns Woodward	1917-04-10 00:00:00	1979-07-08 00:00:00	United States of America	Massachusetts	Cambridge	\N	Chemistry	f	Woodward	1965	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1965/woodward_thumb.jpg	\N
52	Geoffrey Wilkinson	1921-07-14 00:00:00	1996-09-26 00:00:00	England	\N	Springside	\N	Chemistry	t	Wilkinson	1973	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1973/wilkinson_thumb.jpg	\N
43	Robert S. Mulliken	1896-06-07 00:00:00	1986-10-31 00:00:00	United States of America	Virginia	Arlington	\N	Chemistry	f	Mulliken	1966	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1966/mulliken_thumb.jpg	\N
42	Robert M. Solow	1924-08-23 00:00:00	\N	United States of America	New York	Brooklyn	\N	Economics	f	Solow	1987	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1987/solow_thumb.jpg	\N
22	Salvador E. Luria	1912-08-13 00:00:00	1991-02-06 00:00:00	United States of America	Massachusetts	Lexington	\N	Medicine/Physiology	t	Luria	1969	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1969/luria_thumb.jpg	\N
27	David Baltimore	1938-03-07 00:00:00	\N	United States of America	New York	New York City	\N	Medicine/Physiology	t	Baltimore	1975	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1975/baltimore_thumb.jpg	\N
23	Steven Weinberg	1933-05-03 00:00:00	\N	United States of America	New York	New York City	\N	Physics	t	Weinberg	1979	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1979/weinberg_thumb.jpg	\N
46	Samuel C.C. Ting	1936-01-27 00:00:00	\N	United States of America	Ann Arbor	Michigan	\N	Physics	t	Ting	1976	\N	Burton Richter	http://nobelprize.org/nobel_prizes/physics/laureates/1976/ting_thumb.jpg	\N
34	Franco Modigliani	1918-06-18 00:00:00	2003-09-25 00:00:00	Italy	\N	Rome	\N	Economics	f	Modigliani	1985	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1985/modigliani_thumb.jpg	\N
26	Susumu Tonegawa	1939-09-06 00:00:00	\N	Japan	\N	Nagoya	\N	Medicine/Physiology	f	Tonegawa	1987	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1987/tonegawa_thumb.jpg	\N
51	Norman F. Ramsey	1915-08-27 00:00:00	\N	United States of America	District of Columbia	Washington	\N	Physics	f	Ramsey	1989	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1989/ramsey_thumb.jpg	\N
45	Thomas R. Cech	1947-12-08 00:00:00	\N	United States of America	Illinois	Chicago	\N	Chemistry	t	Cech	1989	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1989/cech_thumb.jpg	\N
29	Myron S. Scholes	1941-07-01 00:00:00	\N	Canada	Ontario	Timmons	\N	Economics	t	Scholes	1997	\N	Robert C. Merton	http://nobelprize.org/nobel_prizes/economics/laureates/1997/scholes_thumb.jpg	\N
54	Sidney Altman	1939-05-07 00:00:00	\N	Canada	Quebec	Montreal	\N	Chemistry	t	Altman	1989	\N	Thomas R. Cech	http://nobelprize.org/nobel_prizes/chemistry/laureates/1989/altman_thumb.jpg	\N
50	Clifford G. Shull	1915-09-23 00:00:00	\N	United States of America	Pennsylvania	Pittsburgh	\N	Physics	t	Shull	1994	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1994/shull_thumb.jpg	\N
56	Henry W. Kendall	1926-12-09 00:00:00	1999-02-15 00:00:00	United States of America	Florida	Wakulla State Park	\N	Physics	t	Kendall	1990	\N	Jerome I. Friedman	http://nobelprize.org/nobel_prizes/physics/laureates/1990/kendall_thumb.jpg	\N
38	Mario J. Molina	1943-03-19 00:00:00	\N	Mexico	\N	Mexico City	\N	Chemistry	t	Molina	1995	\N	\N	http://people.csail.mit.edu/dfhuynh/projects/nobelists/images/mario-j-molina.png	http://mitworld.mit.edu/video/63/
59	Robert C. Merton	1944-07-31 00:00:00	\N	United States of America	New York	New York City	\N	Economics	t	Merton	1997	\N	Myron S. Scholes	http://nobelprize.org/nobel_prizes/economics/laureates/1997/merton_thumb.jpg	\N
40	Robert B. Laughlin	1950-11-01 00:00:00	\N	United States of America	California	Visalia	\N	Physics	t	Laughlin	1998	\N	Horst L. Störmer, Daniel C. Tsui	http://nobelprize.org/nobel_prizes/physics/laureates/1998/laughlin_thumb.jpg	\N
61	William D. Phillips	1948-11-05 00:00:00	\N	United States of America	Pennsylvania	Wilkes-Barre	\N	Physics	t	Phillips	1997	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1997/phillips_thumb.jpg	\N
63	Robert A. Mundell	1932-10-24 00:00:00	\N	Canada	Ontario	Kingston	\N	Economics	f	Mundell	1999	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1999/mundell_thumb.jpg	\N
49	Aaron Ciechanover	1947-10-01 00:00:00	\N	British Mandate of Palestine	\N	Haifa	http://nobelprize.org/chemistry/laureates/2004/index.html	Chemistry	t	Ciechanover	2004	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/2004/ciechanover_thumb.jpg	\N
32	Daniel L. McFadden	1937-07-29 00:00:00	\N	United States of America	North Carolina	Raleigh	\N	Economics	t	McFadden	2000	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2000/mcfadden_thumb.jpg	\N
31	Eric A. Cornell	1961-12-19 00:00:00	\N	United States of America	California	Palo Alto	\N	Physics	t	Cornell	2001	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2001/cornell_thumb.jpg	\N
55	Leland H. Hartwell	1939-10-30 00:00:00	\N	United States of America	California	Los Angeles	\N	Medicine/Physiology	t	Hartwell	2001	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/2001/hartwell_thumb.jpg	\N
53	Frank Wilczek	1951-05-15 00:00:00	\N	United States of America	New York	Mineola	http://web.mit.edu/newsoffice/2004/nobel-wilczek.html	Physics	t	Wilczek	2004	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2004/wilczek_thumb.jpg	\N
58	Robert J. Aumann	1930-06-08 00:00:00	\N	Germany	\N	Frankfurt Am Main	http://nobelprize.org/economics/laureates/2005/press.html	Economics	t	Aumann	2005	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2005/aumann_thumb.jpg	\N
36	Charles J. Pedersen	1904-10-03 00:00:00	1989-10-26 00:00:00	Korea	\N	Busan	\N	Chemistry	t	Pedersen	1987	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1987/pedersen_thumb.jpg	\N
41	Andrew Fire	1959-04-27 00:00:00	\N	United States of America	California	Palo Alto	http://web.mit.edu/newsoffice/2006/fire.html	Medicine/Physiology	t	Fire	2006	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/2006/fire_thumb.jpg	\N
57	George Smoot	1945-02-20 00:00:00	\N	United States of America	Florida	Yukon	http://web.mit.edu/newsoffice/2006/smoot.html	Physics	t	Smoot	2006	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2006/smoot_thumb.jpg	\N
47	Isidor Isaac Rabi	1898-07-29 00:00:00	1988-01-11 00:00:00	\N	\N	\N	\N	Physics	f	Rabi	1944	t	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1944/rabi_thumb.jpg	\N
30	Julian Schwinger	1918-02-12 00:00:00	1994-07-16 00:00:00	\N	\N	\N	\N	Physics	t	Schwinger	1965	t	Richard P. Feynman	http://nobelprize.org/nobel_prizes/physics/laureates/1965/schwinger_thumb.jpg	\N
48	Luis W. Alvarez	1913-06-13 00:00:00	1988-09-01 00:00:00	\N	\N	\N	\N	Physics	f	Alvarez	1968	t	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1968/alvarez_thumb.jpg	\N
20	Murray Gell-Mann	1929-09-15 00:00:00	\N	\N	\N	\N	\N	Physics	f	Gell-Mann	1969	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1969/gell-mann_thumb.jpg	\N
25	John Robert Schrieffer	1931-05-31 00:00:00	\N	\N	\N	\N	\N	Physics	t	Schrieffer	1972	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1972/schrieffer_thumb.jpg	\N
37	Eric S. Chivian	\N	\N	\N	\N	\N	\N	Peace	f	Chivian	1985	\N	\N	http://people.csail.mit.edu/dfhuynh/projects/nobelists/images/eric-chivian.png	http://mitworld.mit.edu/video/63/
14	Jerome I. Friedman	1930-03-28 00:00:00	\N	\N	\N	\N	\N	Physics	t	Friedman	1990	\N	Henry W. Kendall	http://nobelprize.org/nobel_prizes/physics/laureates/1990/friedman_thumb.jpg	\N
2	George A. Akerlof	1940-06-17 00:00:00	\N	United States of America	Connecticut	New Haven	\N	Economics	t	Akerlof	2001	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2001/akerlof_thumb.jpg	\N
44	Kofi Annan	1938-05-08 00:00:00	\N	\N	\N	\N	\N	Peace	t	Annan	2001	\N	\N	http://nobelprize.org/nobel_prizes/peace/laureates/2001/annan_thumb.jpg	\N
19	Joseph E. Stiglitz	1943-02-09 00:00:00	\N	\N	\N	\N	\N	Economics	t	Stiglitz	2001	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2001/stiglitz_thumb.jpg	\N
33	Wolfgang Ketterle	1957-10-21 00:00:00	\N	\N	\N	\N	\N	Physics	t	Ketterle	2001	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2001/ketterle_thumb.jpg	\N
35	Carl E. Wieman	1951-03-26 00:00:00	\N	\N	\N	\N	\N	Physics	t	Wieman	2001	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2001/wieman_thumb.jpg	\N
62	H. Robert Horvitz	1947-05-08 00:00:00	\N	\N	\N	\N	http://web.mit.edu/newsoffice/2002/horvitz-nobel.html	Medicine/Physiology	t	Horvitz	2002	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/2002/horvitz_thumb.jpg	\N
60	Robert Engle	1942-11-10 00:00:00	\N	\N	\N	\N	http://nobelprize.org/economics/laureates/2003/index.html	Economics	t	Engle	2003	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2003/engle_thumb.jpg	\N
13	Richard R. Schrock	1945-01-04 00:00:00	\N	\N	\N	\N	http://web.mit.edu/newsoffice/2005/schrock.html	Chemistry	t	Schrock	2005	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/2005/schrock_thumb.jpg	\N
\.


COPY affiliations (id, nobelist_id, detail, degree, year) FROM stdin;
1	11	MIT Provost 1961-61	\N	\N
5	4	MIT researcher at MIT Magnet Lab	\N	\N
7	6	MIT researcher at MIT Magnet Lab	\N	\N
8	7	Staff, MIT Radiation Laboratory WWII (deceased)	\N	\N
9	8	MIT Institute Professor, Biology	\N	\N
12	10	MIT Radiation Laboratory WWII	\N	\N
14	13	MIT Professor of Chemistry	\N	\N
15	14	MIT Institute Professor, Physics	\N	\N
17	16	MIT postdoctoral researcher 1950	\N	\N
18	17	MIT Radiation Laboratory 1943-45	\N	\N
19	18	MIT Professor of Biology and Chemistry	\N	\N
22	21	MIT Professor of Mathematics 1951-59	\N	\N
23	22	MIT Professor of Biology (deceased)	\N	\N
24	23	Professor at MIT 1967-73	\N	\N
25	24	MIT Institute Professor Emeritus, Economics	\N	\N
27	26	MIT Professor of Biology	\N	\N
29	28	Staff, MIT Radiation Laboratory 1940-41 (deceased)	\N	\N
30	29	MIT Professor of Management 1968-73	\N	\N
31	30	MIT Radiation Laboratory WWII (deceased)	\N	\N
33	32	MIT Professor of Economics 1978-91	\N	\N
34	33	MIT Professor of Physics	\N	\N
35	34	MIT Institute Professor Emeritus, Management, Economics (deceased)	\N	\N
38	37	Retired MIT psychiatrist, Medical Department	\N	\N
39	38	MIT Institute Professor, Earth, Atmospheric and Planetary Sciences/Chemistry, 1989-2004	\N	\N
43	42	MIT Institute Professor, Economics	\N	\N
45	45	MIT postdoctoral researcher 1975-76	\N	\N
46	46	MIT Professor of Physics	\N	\N
47	47	Associate Director, MIT Radiation Laboratory 1940-45 (deceased)	\N	\N
48	48	Head, special systems, MIT Radiation Laboratory WWII (deceased)	\N	\N
49	49	MIT postdoctoral researcher 1981-84	\N	\N
50	50	MIT Professor Emeritus (deceased)	\N	\N
51	51	Leader, fundamental development group, MIT Radiation Laboratory 1940-42	\N	\N
52	52	MIT research associate, 1950 (deceased)	\N	\N
53	53	MIT Professor of Physics	\N	\N
60	60	MIT Professor of Economics 1969-77	\N	\N
57	57	MIT S.B. 1996	S.B.	1996
62	62	MIT Professor of Biology	\N	\N
59	59	MIT Professor of Management 1970-88	\N	\N
58	58	MIT Ph.D. 1955	Ph.D.	1955
68	56	MIT Professor of Physics (deceased)	\N	\N
66	59	MIT Ph.D. 1970	Ph.D.	1970
61	61	MIT Ph.D. 1976	Ph.D.	1976
70	12	MIT Professor of Chemistry, 1980-90	\N	\N
13	12	MIT Professor of Chemistry, 1970-77	\N	\N
28	27	MIT postdoctoral researcher	\N	\N
71	27	MIT Professor of Biology 1968-90	\N	\N
72	27	MIT Professor of Biology, 1994-97	\N	\N
65	62	MIT S.B. 1968	S.B.	1968
3	2	MIT Ph.D. 1966	Ph.D.	1966
4	3	MIT Ph.D. 1936 (deceased)	Ph.D.	1936
2	1	MIT S.B. 1952	S.B.	1952
64	1	MIT Ph.D. 1956	Ph.D.	1956
6	5	MIT S.B. 1948	S.B.	1948
69	5	MIT Ph.D. 1951	Ph.D.	1951
11	9	MIT Ph.D. 1944	Ph.D.	1944
16	15	MIT S.B. 1939 (deceased)	S.B.	1939
20	19	MIT Ph.D. 1966	Ph.D.	1966
21	20	MIT Ph.D. 1951	Ph.D.	1951
26	25	MIT S.B. 1953	S.B.	1953
32	31	MIT Ph.D. 1990	Ph.D.	1990
36	35	MIT S.B. 1973	S.B.	1973
37	36	MIT S.M. 1927 (deceased)	S.M.	1927
40	39	MIT S.B. 1936 (deceased)	S.B.	1936
41	40	MIT Ph.D. 1979	Ph.D.	1979
42	41	MIT Ph.D. 1983	Ph.D.	1983
44	43	MIT S.B. 1917 (deceased)	S.B.	1917
10	44	MIT S.M. 1972	S.M.	1972
54	54	MIT S.B. 1960	S.B.	1960
55	55	MIT Ph.D. 1964	Ph.D.	1964
67	56	MIT Ph.D. 1951	Ph.D.	1951
56	56	MIT S.B. 1948	S.B.	1948
63	63	MIT Ph.D. 1956	Ph.D.	1956
\.


---
--- SET UP FACET INDICES
---

SELECT renumber_table('nobelists', '_packed_id');

-- facet values in entity table column
SELECT recreate_table('_nobelists_nobel_year_facet', 
											'SELECT nobel_year, signature(_packed_id) FROM nobelists GROUP BY nobel_year');
SELECT recreate_table('_nobelists_discipline_facet', 
 											'SELECT discipline, signature(_packed_id) FROM nobelists GROUP BY discipline');

-- computed facet values
SELECT recreate_table('_nobelists_birthdate_facet', 
 											'SELECT birthdate, signature(_packed_id) FROM (SELECT (EXTRACT(year FROM birthdate)::integer / 10::integer) * 10 AS birthdate, _packed_id from nobelists) AS computed GROUP by birthdate');
											

-- nested, computed facet values  											
SELECT recreate_table('_nobelists_birth_place_facet', 
 											'SELECT ARRAY[ birth_country, birth_state, birth_city ] AS birth_place, signature(_packed_id) FROM nobelists GROUP BY birth_country, birth_state, birth_city');
 											
-- facet values in linked table (multivalued)
SELECT recreate_table('_nobelists_degree_facet', 
 											'SELECT degree, signature(_packed_id) FROM nobelists JOIN affiliations ON (nobelist_id = nobelists.id) GROUP BY degree');
