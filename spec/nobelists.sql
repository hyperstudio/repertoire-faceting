--
-- Testing data for faceting
--

CREATE TABLE nobelists (
    id serial PRIMARY KEY,
    name text NOT NULL,
    birthdate timestamp without time zone,
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
    relationship_detail text,
    image_ur_l text,
    image_credit text
);

CREATE TABLE relationships (
    id serial PRIMARY KEY,
    relationship_name text NOT NULL
);

---
--- TEST DATA
---

COPY nobelists (id, name, birthdate, birth_country, birth_state, birth_city, url, discipline, shared, last_name, nobel_year, deceased, co_winner, relationship_detail, image_ur_l, image_credit) FROM stdin;
1	Burton Richter	1931-03-22 00:00:00	United States of America	New York	New York City	\N	Physics	t	Richter	1976	\N	Samuel C.C. Ting	MIT S.B. 1952, Ph.D. 1956	http://nobelprize.org/nobel_prizes/physics/laureates/1976/richter_thumb.jpg	\N
2	George A. Akerlof	1940-06-17 00:00:00	United States of America	Connecticut	New Haven	\N	Economics	t	Akerlof	2001	\N	\N	MIT Ph.D. 1966	http://nobelprize.org/nobel_prizes/economics/laureates/2001/akerlof_thumb.jpg	\N
3	William Shockley	1910-02-13 00:00:00	England	\N	London	\N	Physics	t	Shockley	1956	t	\N	MIT Ph.D. 1936 (deceased)	http://nobelprize.org/nobel_prizes/physics/laureates/1956/shockley_thumb.jpg	\N
4	Daniel C. Tsui	1939-02-28 00:00:00	People's Republic of China	Henan	\N	\N	Physics	t	Tsui	1998	\N	Horst L. St\\u00F6rmer, Robert B. Laughlin	MIT researcher at MIT Magnet Lab	http://nobelprize.org/nobel_prizes/physics/laureates/1998/tsui_thumb.jpg	\N
5	Elias J. Corey Jr.	1928-07-12 00:00:00	United States of America	Massachusetts	Methuen	\N	Chemistry	f	Corey	1990	\N	\N	MIT S.B. 1948, Ph.D. 1951	http://nobelprize.org/nobel_prizes/chemistry/laureates/1990/corey_thumb.jpg	\N
6	Horst L. Störmer	1949-04-06 00:00:00	Germany	\N	Frankfurt	\N	Physics	t	Störmer	1998	\N	Robert B. Laughlin, Daniel C. Tsui	MIT researcher at MIT Magnet Lab	http://nobelprize.org/nobel_prizes/physics/laureates/1998/stormer_thumb.jpg	\N
7	Edward M. Purcell	1912-08-30 00:00:00	United States of America	Illinois	Taylorville	\N	Physics	t	Purcell	1952	t	\N	Staff, MIT Radiation Laboratory WWII (deceased)	http://nobelprize.org/nobel_prizes/physics/laureates/1952/purcell_thumb.jpg	\N
8	Phillip A. Sharp	1944-06-06 00:00:00	United States of America	Kentucky	McKinneysburg	\N	Medicine/Physiology	t	Sharp	1993	\N	\N	MIT Institute Professor, Biology	http://nobelprize.org/nobel_prizes/medicine/laureates/1993/sharp_thumb.jpg	\N
9	Lawrence R. Klein	1920-09-14 00:00:00	United States of America	Nebraska	Omaha	\N	Economics	f	Klein	1980	\N	\N	MIT Ph.D. 1944	http://nobelprize.org/nobel_prizes/economics/laureates/1980/klein_thumb.jpg	\N
10	Hans A. Bethe	1906-06-02 00:00:00	Germany	Alsace-Lorraine	Strasbourg	\N	Physics	f	Bethe	1967	\N	\N	MIT Radiation Laboratory WWII	http://nobelprize.org/nobel_prizes/physics/laureates/1967/bethe_thumb.jpg	\N
11	Charles H. Townes	\N	\N	\N	\N	\N	Physics	t	Townes	1964	\N	\N	MIT Provost 1961-61	http://nobelprize.org/nobel_prizes/physics/laureates/1964/townes_thumb.jpg	\N
12	K. Barry Sharpless	1941-04-28 00:00:00	\N	\N	\N	\N	Chemistry	t	Sharpless	2001	\N	\N	MIT Professor of Chemistry 1970-77, 1980-90	http://nobelprize.org/nobel_prizes/chemistry/laureates/2001/sharpless_thumb.jpg	\N
13	Richard R. Schrock	1945-01-04 00:00:00	\N	\N	\N	http://web.mit.edu/newsoffice/2005/schrock.html	Chemistry	t	Schrock	2005	\N	\N	MIT Professor of Chemistry	http://nobelprize.org/nobel_prizes/chemistry/laureates/2005/schrock_thumb.jpg	\N
14	Jerome I. Friedman	1930-03-28 00:00:00	\N	\N	\N	\N	Physics	t	Friedman	1990	\N	Henry W. Kendall	MIT Institute Professor, Physics	http://nobelprize.org/nobel_prizes/physics/laureates/1990/friedman_thumb.jpg	\N
15	Richard P. Feynman	1918-05-11 00:00:00	\N	\N	\N	\N	Physics	t	Feynman	1965	t	Julian Schwinger	MIT S.B. 1939 (deceased)	http://nobelprize.org/nobel_prizes/physics/laureates/1965/feynman_thumb.jpg	\N
16	E. Donnall Thomas	1920-03-15 00:00:00	\N	\N	\N	\N	Medicine/Physiology	t	Thomas	1990	\N	\N	MIT postdoctoral researcher 1950	http://nobelprize.org/nobel_prizes/medicine/laureates/1990/thomas_thumb.jpg	\N
17	Jack Steinberger	1921-05-25 00:00:00	\N	\N	\N	\N	Physics	t	Steinberger	1988	\N	\N	MIT Radiation Laboratory 1943-45	http://nobelprize.org/nobel_prizes/physics/laureates/1988/steinberger_thumb.jpg	\N
18	Har Gobind Khorana	1922-01-19 00:00:00	\N	\N	\N	\N	Medicine/Physiology	t	Khorana	1968	\N	\N	MIT Professor of Biology and Chemistry	http://nobelprize.org/nobel_prizes/medicine/laureates/1968/khorana_thumb.jpg	\N
19	Joseph E. Stiglitz	1943-02-09 00:00:00	\N	\N	\N	\N	Economics	t	Stiglitz	2001	\N	\N	MIT Ph.D. 1966	http://nobelprize.org/nobel_prizes/economics/laureates/2001/stiglitz_thumb.jpg	\N
20	Murray Gell-Mann	1929-09-15 00:00:00	\N	\N	\N	\N	Physics	f	Gell-Mann	1969	\N	\N	MIT Ph.D. 1951	http://nobelprize.org/nobel_prizes/physics/laureates/1969/gell-mann_thumb.jpg	\N
21	John Forbes Nash, Jr.	\N	\N	\N	\N	\N	Economics	t	Nash	1994	\N	\N	MIT Professor of Mathematics 1951-59	http://nobelprize.org/nobel_prizes/economics/laureates/1994/nash_thumb.jpg	\N
22	Salvador E. Luria	\N	\N	\N	\N	\N	Medicine/Physiology	t	Luria	1969	t	\N	MIT Professor of Biology (deceased)	http://nobelprize.org/nobel_prizes/medicine/laureates/1969/luria_thumb.jpg	\N
23	Steven Weinberg	\N	\N	\N	\N	\N	Physics	t	Weinberg	1979	\N	\N	Professor at MIT 1967-73	http://nobelprize.org/nobel_prizes/physics/laureates/1979/weinberg_thumb.jpg	\N
24	Paul A. Samuelson	\N	\N	\N	\N	\N	Economics	f	Samuelson	1970	\N	\N	MIT Institute Professor Emeritus, Economics	http://nobelprize.org/nobel_prizes/economics/laureates/1970/samuelson_thumb.jpg	\N
25	John Robert Schrieffer	\N	\N	\N	\N	\N	Physics	t	Schrieffer	1972	\N	\N	MIT S.B. 1953	http://nobelprize.org/nobel_prizes/physics/laureates/1972/schrieffer_thumb.jpg	\N
26	Susumu Tonegawa	\N	\N	\N	\N	\N	Medicine/Physiology	f	Tonegawa	1987	\N	\N	MIT Professor of Biology	http://nobelprize.org/nobel_prizes/medicine/laureates/1987/tonegawa_thumb.jpg	\N
27	David Baltimore	\N	\N	\N	\N	\N	Medicine/Physiology	t	Baltimore	1975	\N	\N	MIT postdoctoral researcher, MIT Professor of Biology 1968-90, 1994-97	http://nobelprize.org/nobel_prizes/medicine/laureates/1975/baltimore_thumb.jpg	\N
28	Edwin M. McMillan	\N	\N	\N	\N	\N	Chemistry	t	McMillan	1951	t	\N	Staff, MIT Radiation Laboratory 1940-41 (deceased)	http://nobelprize.org/nobel_prizes/chemistry/laureates/1951/mcmillan_thumb.jpg	\N
29	Myron S. Scholes	\N	\N	\N	\N	\N	Economics	t	Scholes	1997	\N	Robert C. Merton	MIT Professor of Management 1968-73	http://nobelprize.org/nobel_prizes/economics/laureates/1997/scholes_thumb.jpg	\N
30	Julian Schwinger	\N	\N	\N	\N	\N	Physics	t	Schwinger	1965	t	Richard P. Feynman	MIT Radiation Laboratory WWII (deceased)	http://nobelprize.org/nobel_prizes/physics/laureates/1965/schwinger_thumb.jpg	\N
31	Eric A. Cornell	\N	\N	\N	\N	\N	Physics	t	Cornell	2001	\N	\N	MIT Ph.D. 1990	http://nobelprize.org/nobel_prizes/physics/laureates/2001/cornell_thumb.jpg	\N
32	Daniel L. McFadden	\N	\N	\N	\N	\N	Economics	t	McFadden	2000	\N	\N	MIT Professor of Economics 1978-91	http://nobelprize.org/nobel_prizes/economics/laureates/2000/mcfadden_thumb.jpg	\N
33	Wolfgang Ketterle	\N	\N	\N	\N	\N	Physics	t	Ketterle	2001	\N	\N	MIT Professor of Physics	http://nobelprize.org/nobel_prizes/physics/laureates/2001/ketterle_thumb.jpg	\N
34	Franco Modigliani	\N	\N	\N	\N	\N	Economics	f	Modigliani	1985	t	\N	MIT Institute Professor Emeritus, Management, Economics (deceased)	http://nobelprize.org/nobel_prizes/economics/laureates/1985/modigliani_thumb.jpg	\N
35	Carl E. Wieman	\N	\N	\N	\N	\N	Physics	t	Wieman	2001	\N	\N	MIT S.B. 1973	http://nobelprize.org/nobel_prizes/physics/laureates/2001/wieman_thumb.jpg	\N
36	Charles J. Pedersen	\N	\N	\N	\N	\N	Chemistry	t	Pedersen	1987	t	\N	MIT S.M. 1927 (deceased)	http://nobelprize.org/nobel_prizes/chemistry/laureates/1987/pedersen_thumb.jpg	\N
37	Eric S. Chivian	\N	\N	\N	\N	\N	Peace	f	Chivian	1985	\N	\N	Retired MIT psychiatrist, Medical Department	http://people.csail.mit.edu/dfhuynh/projects/nobelists/images/eric-chivian.png	http://mitworld.mit.edu/video/63/
38	Mario J. Molina	\N	\N	\N	\N	\N	Chemistry	t	Molina	1995	\N	\N	MIT Institute Professor, Earth, Atmospheric and Planetary Sciences/Chemistry, 1989-2004	http://people.csail.mit.edu/dfhuynh/projects/nobelists/images/mario-j-molina.png	http://mitworld.mit.edu/video/63/
39	Robert Burns Woodward	\N	\N	\N	\N	\N	Chemistry	f	Woodward	1965	t	\N	MIT S.B. 1936 (deceased)	http://nobelprize.org/nobel_prizes/chemistry/laureates/1965/woodward_thumb.jpg	\N
40	Robert B. Laughlin	\N	\N	\N	\N	\N	Physics	t	Laughlin	1998	\N	Horst L. St\\u00F6rmer, Daniel C. Tsui	MIT Ph.D. 1979	http://nobelprize.org/nobel_prizes/physics/laureates/1998/laughlin_thumb.jpg	\N
41	Andrew Fire	\N	\N	\N	\N	http://web.mit.edu/newsoffice/2006/fire.html	Medicine/Physiology	t	Fire	2006	\N	\N	MIT Ph.D. 1983	http://nobelprize.org/nobel_prizes/medicine/laureates/2006/fire_thumb.jpg	\N
42	Robert M. Solow	\N	\N	\N	\N	\N	Economics	f	Solow	1987	\N	\N	MIT Institute Professor, Economics	http://nobelprize.org/nobel_prizes/economics/laureates/1987/solow_thumb.jpg	\N
43	Robert S. Mulliken	\N	\N	\N	\N	\N	Chemistry	f	Mulliken	1966	t	\N	MIT S.B. 1917 (deceased)	http://nobelprize.org/nobel_prizes/chemistry/laureates/1966/mulliken_thumb.jpg	\N
44	Kofi Annan	\N	\N	\N	\N	\N	Peace	t	Annan	2001	\N	\N	MIT S.M. 1972	http://nobelprize.org/nobel_prizes/peace/laureates/2001/annan_thumb.jpg	\N
45	Thomas R. Cech	\N	\N	\N	\N	\N	Chemistry	t	Cech	1989	\N	\N	MIT postdoctoral researcher 1975-76	http://nobelprize.org/nobel_prizes/chemistry/laureates/1989/cech_thumb.jpg	\N
46	Samuel C.C. Ting	\N	\N	\N	\N	\N	Physics	t	Ting	1976	\N	Burton Richter	MIT Professor of Physics	http://nobelprize.org/nobel_prizes/physics/laureates/1976/ting_thumb.jpg	\N
47	Isidor Isaac Rabi	\N	\N	\N	\N	\N	Physics	f	Rabi	1944	t	\N	Associate Director, MIT Radiation Laboratory 1940-45 (deceased)	http://nobelprize.org/nobel_prizes/physics/laureates/1944/rabi_thumb.jpg	\N
48	Luis W. Alvarez	\N	\N	\N	\N	\N	Physics	f	Alvarez	1968	t	\N	Head, special systems, MIT Radiation Laboratory WWII (deceased)	http://nobelprize.org/nobel_prizes/physics/laureates/1968/alvarez_thumb.jpg	\N
49	Aaron Ciechanover	\N	\N	\N	\N	http://nobelprize.org/chemistry/laureates/2004/index.html	Chemistry	t	Ciechanover	2004	\N	\N	MIT postdoctoral researcher 1981-84	http://nobelprize.org/nobel_prizes/chemistry/laureates/2004/ciechanover_thumb.jpg	\N
50	Clifford G. Shull	\N	\N	\N	\N	\N	Physics	t	Shull	1994	t	\N	MIT Professor Emeritus (deceased)	http://nobelprize.org/nobel_prizes/physics/laureates/1994/shull_thumb.jpg	\N
51	Norman F. Ramsey	\N	\N	\N	\N	\N	Physics	f	Ramsey	1989	\N	\N	Leader, fundamental development group, MIT Radiation Laboratory 1940-42	http://nobelprize.org/nobel_prizes/physics/laureates/1989/ramsey_thumb.jpg	\N
52	Geoffrey Wilkinson	\N	\N	\N	\N	\N	Chemistry	t	Wilkinson	1973	t	\N	MIT research associate, 1950 (deceased)	http://nobelprize.org/nobel_prizes/chemistry/laureates/1973/wilkinson_thumb.jpg	\N
53	Frank Wilczek	\N	\N	\N	\N	http://web.mit.edu/newsoffice/2004/nobel-wilczek.html	Physics	t	Wilczek	2004	\N	\N	MIT Professor of Physics	http://nobelprize.org/nobel_prizes/physics/laureates/2004/wilczek_thumb.jpg	\N
54	Sidney Altman	\N	\N	\N	\N	\N	Chemistry	t	Altman	1989	\N	Thomas R. Cech	MIT S.B. 1960	http://nobelprize.org/nobel_prizes/chemistry/laureates/1989/altman_thumb.jpg	\N
55	Leland H. Hartwell	\N	\N	\N	\N	\N	Medicine/Physiology	t	Hartwell	2001	\N	\N	MIT Ph.D. 1964	http://nobelprize.org/nobel_prizes/medicine/laureates/2001/hartwell_thumb.jpg	\N
56	Henry W. Kendall	\N	\N	\N	\N	\N	Physics	t	Kendall	1990	t	Jerome I. Friedman	MIT S.B. 1948, Ph.D. 1951, Professor of Physics (deceased)	http://nobelprize.org/nobel_prizes/physics/laureates/1990/kendall_thumb.jpg	\N
57	George Smoot	\N	\N	\N	\N	http://web.mit.edu/newsoffice/2006/smoot.html	Physics	t	Smoot	2006	f	\N	MIT S.B. 1996	http://nobelprize.org/nobel_prizes/physics/laureates/2006/smoot_thumb.jpg	\N
58	Robert J. Aumann	\N	\N	\N	\N	http://nobelprize.org/economics/laureates/2005/press.html	Economics	t	Aumann	2005	\N	\N	MIT Ph.D. 1955	http://nobelprize.org/nobel_prizes/economics/laureates/2005/aumann_thumb.jpg	\N
59	Robert C. Merton	\N	\N	\N	\N	\N	Economics	t	Merton	1997	\N	Myron S. Scholes	MIT Professor of Management 1970-88, MIT Ph.D. 1970	http://nobelprize.org/nobel_prizes/economics/laureates/1997/merton_thumb.jpg	\N
60	Robert Engle	\N	\N	\N	\N	http://nobelprize.org/economics/laureates/2003/index.html	Economics	t	Engle	2003	\N	\N	MIT Professor of Economics 1969-77	http://nobelprize.org/nobel_prizes/economics/laureates/2003/engle_thumb.jpg	\N
61	William D. Phillips	\N	\N	\N	\N	\N	Physics	t	Phillips	1997	\N	\N	MIT Ph.D. 1976	http://nobelprize.org/nobel_prizes/physics/laureates/1997/phillips_thumb.jpg	\N
62	H. Robert Horvitz	\N	\N	\N	\N	http://web.mit.edu/newsoffice/2002/horvitz-nobel.html	Medicine/Physiology	t	Horvitz	2002	\N	\N	MIT Professor of Biology, MIT S.B. 1968	http://nobelprize.org/nobel_prizes/medicine/laureates/2002/horvitz_thumb.jpg	\N
63	Robert A. Mundell	\N	\N	\N	\N	\N	Economics	f	Mundell	1999	\N	\N	MIT Ph.D. 1956	http://nobelprize.org/nobel_prizes/economics/laureates/1999/mundell_thumb.jpg	\N
\.

COPY relationships (id, relationship_name) FROM stdin;
\.

---
--- SET UP FACET INDICES
---

SELECT renumber_table('nobelists', '_packed_id');
SELECT recreate_table('_nobelists_nobel_year_facet', 
											'SELECT nobel_year, signature(_packed_id) FROM nobelists GROUP BY nobel_year');
SELECT recreate_table('_nobelists_discipline_facet', 
 											'SELECT discipline, signature(_packed_id) FROM nobelists GROUP BY discipline');
SELECT recreate_table('_nobelists_birth_place_facet', 
 											'SELECT ARRAY[ birth_country, birth_state, birth_city ] AS birth_place, signature(_packed_id) FROM nobelists GROUP BY birth_country, birth_state, birth_city');
SELECT recreate_table('_nobelists_birthdate_facet', 
 											'SELECT ARRAY[ EXTRACT(year FROM birthdate), EXTRACT(month FROM birthdate), EXTRACT(day FROM birthdate) ] AS birthdate, signature(_packed_id) FROM nobelists GROUP BY birthdate');
