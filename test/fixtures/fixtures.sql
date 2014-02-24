--
-- PostgreSQL database dump
--

--
-- Data for Name: affiliations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY affiliations (id, nobelist_id, detail, degree, year) FROM stdin;
886824740	523554692	MIT Provost 1961-61	\N	\N
64810937	898132628	MIT researcher at MIT Magnet Lab	\N	\N
450215437	815371035	MIT researcher at MIT Magnet Lab	\N	\N
768773788	54163575	Staff, MIT Radiation Laboratory WWII (deceased)	\N	\N
867572539	47937971	MIT Institute Professor, Biology	\N	\N
78719920	707551480	MIT Radiation Laboratory WWII	\N	\N
498629140	834875407	MIT Professor of Chemistry	\N	\N
717179523	350175079	MIT Institute Professor, Physics	\N	\N
973100822	512956350	MIT postdoctoral researcher 1950	\N	\N
218589063	268272662	MIT Radiation Laboratory 1943-45	\N	\N
559752675	586183727	MIT Professor of Biology and Chemistry	\N	\N
375002490	886259047	MIT Professor of Mathematics 1951-59	\N	\N
257115342	536740065	MIT Professor of Biology (deceased)	\N	\N
945058907	36465360	Professor at MIT 1967-73	\N	\N
640737786	1007855478	MIT Institute Professor Emeritus, Economics	\N	\N
288870769	650459725	MIT Professor of Biology	\N	\N
138313941	302733702	Staff, MIT Radiation Laboratory 1940-41 (deceased)	\N	\N
1060745282	348143303	MIT Professor of Management 1968-73	\N	\N
797355477	1006613575	MIT Radiation Laboratory WWII (deceased)	\N	\N
411147592	662134486	MIT Professor of Economics 1978-91	\N	\N
175142436	47252333	MIT Professor of Physics	\N	\N
1031227063	132001107	MIT Institute Professor Emeritus, Management, Economics (deceased)	\N	\N
612243215	134809693	Retired MIT psychiatrist, Medical Department	\N	\N
326707096	704115275	MIT Institute Professor, Earth, Atmospheric and Planetary Sciences/Chemistry, 1989-2004	\N	\N
220049981	920398821	MIT Institute Professor, Economics	\N	\N
974815920	192044853	MIT postdoctoral researcher 1975-76	\N	\N
588501784	716679852	MIT Professor of Physics	\N	\N
336913281	180537032	Associate Director, MIT Radiation Laboratory 1940-45 (deceased)	\N	\N
78380562	96233980	Head, special systems, MIT Radiation Laboratory WWII (deceased)	\N	\N
866963081	261646024	MIT postdoctoral researcher 1981-84	\N	\N
325797733	431231374	MIT Professor Emeritus (deceased)	\N	\N
611088376	1037237308	Leader, fundamental development group, MIT Radiation Laboratory 1940-42	\N	\N
1030039120	38379547	MIT research associate, 1950 (deceased)	\N	\N
174200537	897935197	MIT Professor of Physics	\N	\N
335971196	889316300	MIT Professor of Economics 1969-77	\N	\N
587314159	127536269	MIT S.B. 1996	S.B.	1996
973660759	760543461	MIT Professor of Biology	\N	\N
219140800	249288376	MIT Professor of Management 1970-88	\N	\N
498126675	309696094	MIT Ph.D. 1955	Ph.D.	1955
716701642	452679743	MIT Professor of Physics (deceased)	\N	\N
472568231	249288376	MIT Ph.D. 1970	Ph.D.	1970
724427060	316107204	MIT Ph.D. 1976	Ph.D.	1976
841265288	203558952	MIT Professor of Chemistry, 1980-90	\N	\N
86212639	203558952	MIT Professor of Chemistry, 1970-77	\N	\N
457643456	709643444	MIT postdoctoral researcher	\N	\N
742401325	709643444	MIT Professor of Biology 1968-90	\N	\N
894006417	709643444	MIT Professor of Biology, 1994-97	\N	\N
38683656	760543461	MIT S.B. 1968	S.B.	1968
317807001	84113118	MIT Ph.D. 1966	Ph.D.	1966
636905730	70119351	MIT Ph.D. 1936 (deceased)	Ph.D.	1936
87154920	471457249	MIT S.B. 1952	S.B.	1952
842453109	471457249	MIT Ph.D. 1956	Ph.D.	1956
725582281	500430737	MIT S.B. 1948	S.B.	1948
473477472	500430737	MIT Ph.D. 1951	Ph.D.	1951
39593215	152661120	MIT Ph.D. 1944	Ph.D.	1944
895161452	350974990	MIT S.B. 1939 (deceased)	S.B.	1939
743589328	373740587	MIT Ph.D. 1966	Ph.D.	1966
458585415	492621992	MIT Ph.D. 1951	Ph.D.	1951
199911642	693938065	MIT S.B. 1953	S.B.	1953
1022187587	86705926	MIT Ph.D. 1990	Ph.D.	1990
773632809	702332959	MIT S.B. 1973	S.B.	1973
421233586	927659372	MIT S.M. 1927 (deceased)	S.M.	1927
1233418	57839852	MIT S.B. 1936 (deceased)	S.B.	1936
924181149	506489850	MIT Ph.D. 1979	Ph.D.	1979
695301954	417204688	MIT Ph.D. 1983	Ph.D.	1983
511068075	54824727	MIT S.B. 1917 (deceased)	S.B.	1917
125769235	757913923	MIT S.M. 1972	S.M.	1972
813180550	471244306	MIT S.B. 1960	S.B.	1960
549927703	887968197	MIT Ph.D. 1964	Ph.D.	1964
398461828	452679743	MIT Ph.D. 1951	Ph.D.	1951
923239018	452679743	MIT S.B. 1948	S.B.	1948
45811	1039451971	MIT Ph.D. 1956	Ph.D.	1956
\.


--
-- Data for Name: nobelists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY nobelists (id, name, birthdate, deathdate, birth_country, birth_state, birth_city, url, discipline, shared, last_name, nobel_year, deceased, co_winner, image_url, image_credit) FROM stdin;
471457249	Burton Richter	1931-03-22 00:00:00	\N	United States of America	New York	New York City	\N	Physics	t	Richter	1976	\N	Samuel C.C. Ting	http://nobelprize.org/nobel_prizes/physics/laureates/1976/richter_thumb.jpg	\N
84113118	George A. Akerlof	1940-06-17 01:00:00	\N	United States of America	Connecticut	New Haven	\N	Economics	t	Akerlof	2001	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2001/akerlof_thumb.jpg	\N
70119351	William Shockley	1910-02-13 00:00:00	1989-08-12 01:00:00	England	\N	London	\N	Physics	t	Shockley	1956	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1956/shockley_thumb.jpg	\N
898132628	Daniel C. Tsui	1939-02-28 00:00:00	\N	People's Republic of China	Henan	\N	\N	Physics	t	Tsui	1998	\N	Horst L. Störmer, Robert B. Laughlin	http://nobelprize.org/nobel_prizes/physics/laureates/1998/tsui_thumb.jpg	\N
500430737	Elias J. Corey Jr.	1928-07-12 01:00:00	\N	United States of America	Massachusetts	Methuen	\N	Chemistry	f	Corey	1990	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1990/corey_thumb.jpg	\N
815371035	Horst L. Störmer	1949-04-06 01:00:00	\N	Germany	\N	Frankfurt	\N	Physics	t	Störmer	1998	\N	Robert B. Laughlin, Daniel C. Tsui	http://nobelprize.org/nobel_prizes/physics/laureates/1998/stormer_thumb.jpg	\N
54163575	Edward M. Purcell	1912-08-30 00:00:00	1997-03-07 00:00:00	United States of America	Illinois	Taylorville	\N	Physics	t	Purcell	1952	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1952/purcell_thumb.jpg	\N
47937971	Phillip A. Sharp	1944-06-06 02:00:00	\N	United States of America	Kentucky	Falmouth	\N	Medicine/Physiology	t	Sharp	1993	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1993/sharp_thumb.jpg	\N
152661120	Lawrence R. Klein	1920-09-14 01:00:00	\N	United States of America	Nebraska	Omaha	\N	Economics	f	Klein	1980	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1980/klein_thumb.jpg	\N
707551480	Hans A. Bethe	1906-06-02 00:00:00	2005-03-06 00:00:00	Germany	Alsace-Lorraine	Strasbourg	\N	Physics	f	Bethe	1967	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1967/bethe_thumb.jpg	\N
523554692	Charles H. Townes	1915-07-28 00:00:00	\N	United States of America	South Carolina	Greenville	\N	Physics	t	Townes	1964	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1964/townes_thumb.jpg	\N
203558952	K. Barry Sharpless	1941-04-28 01:00:00	\N	United States of America	Pennsylvania	Philadelphia	\N	Chemistry	t	Sharpless	2001	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/2001/sharpless_thumb.jpg	\N
834875407	Richard R. Schrock	1945-01-04 01:00:00	\N	\N	\N	\N	http://web.mit.edu/newsoffice/2005/schrock.html	Chemistry	t	Schrock	2005	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/2005/schrock_thumb.jpg	\N
350175079	Jerome I. Friedman	1930-03-28 00:00:00	\N	\N	\N	\N	\N	Physics	t	Friedman	1990	\N	Henry W. Kendall	http://nobelprize.org/nobel_prizes/physics/laureates/1990/friedman_thumb.jpg	\N
350974990	Richard P. Feynman	1918-05-11 01:00:00	1988-02-15 00:00:00	United States of America	New York	Queens	\N	Physics	t	Feynman	1965	\N	Julian Schwinger	http://nobelprize.org/nobel_prizes/physics/laureates/1965/feynman_thumb.jpg	\N
512956350	E. Donnall Thomas	1920-03-15 00:00:00	\N	\N	\N	\N	\N	Medicine/Physiology	t	Thomas	1990	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1990/thomas_thumb.jpg	\N
268272662	Jack Steinberger	1921-05-25 01:00:00	\N	Germany	\N	Bad Kissingen	\N	Physics	t	Steinberger	1988	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1988/steinberger_thumb.jpg	\N
586183727	Har Gobind Khorana	1922-01-19 00:00:00	\N	British India	Punjab	Multan	\N	Medicine/Physiology	t	Khorana	1968	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1968/khorana_thumb.jpg	\N
373740587	Joseph E. Stiglitz	1943-02-09 01:00:00	\N	\N	\N	\N	\N	Economics	t	Stiglitz	2001	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2001/stiglitz_thumb.jpg	\N
492621992	Murray Gell-Mann	1929-09-15 01:00:00	\N	\N	\N	\N	\N	Physics	f	Gell-Mann	1969	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1969/gell-mann_thumb.jpg	\N
886259047	John Forbes Nash, Jr.	1928-06-13 01:00:00	\N	United States of America	West Virginia	Bluefield	\N	Economics	t	Nash	1994	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1994/nash_thumb.jpg	\N
536740065	Salvador E. Luria	1912-08-13 00:00:00	1991-02-06 00:00:00	United States of America	Massachusetts	Lexington	\N	Medicine/Physiology	t	Luria	1969	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1969/luria_thumb.jpg	\N
36465360	Steven Weinberg	1933-05-03 01:00:00	\N	United States of America	New York	New York City	\N	Physics	t	Weinberg	1979	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1979/weinberg_thumb.jpg	\N
1007855478	Paul A. Samuelson	1915-05-15 00:00:00	\N	United States of America	Indiana	Gary	\N	Economics	f	Samuelson	1970	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1970/samuelson_thumb.jpg	\N
693938065	John Robert Schrieffer	1931-05-31 01:00:00	\N	\N	\N	\N	\N	Physics	t	Schrieffer	1972	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1972/schrieffer_thumb.jpg	\N
650459725	Susumu Tonegawa	1939-09-06 01:00:00	\N	Japan	\N	Nagoya	\N	Medicine/Physiology	f	Tonegawa	1987	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1987/tonegawa_thumb.jpg	\N
709643444	David Baltimore	1938-03-07 00:00:00	\N	United States of America	New York	New York City	\N	Medicine/Physiology	t	Baltimore	1975	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/1975/baltimore_thumb.jpg	\N
302733702	Edwin M. McMillan	1907-09-18 00:00:00	1991-09-07 01:00:00	United States of America	California	Redondo Beach	\N	Chemistry	t	McMillan	1951	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1951/mcmillan_thumb.jpg	\N
348143303	Myron S. Scholes	1941-07-01 02:00:00	\N	Canada	Ontario	Timmons	\N	Economics	t	Scholes	1997	\N	Robert C. Merton	http://nobelprize.org/nobel_prizes/economics/laureates/1997/scholes_thumb.jpg	\N
1006613575	Julian Schwinger	1918-02-12 00:00:00	1994-07-16 01:00:00	\N	\N	\N	\N	Physics	t	Schwinger	1965	t	Richard P. Feynman	http://nobelprize.org/nobel_prizes/physics/laureates/1965/schwinger_thumb.jpg	\N
86705926	Eric A. Cornell	1961-12-19 00:00:00	\N	United States of America	California	Palo Alto	\N	Physics	t	Cornell	2001	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2001/cornell_thumb.jpg	\N
662134486	Daniel L. McFadden	1937-07-29 01:00:00	\N	United States of America	North Carolina	Raleigh	\N	Economics	t	McFadden	2000	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2000/mcfadden_thumb.jpg	\N
47252333	Wolfgang Ketterle	1957-10-21 00:00:00	\N	\N	\N	\N	\N	Physics	t	Ketterle	2001	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2001/ketterle_thumb.jpg	\N
132001107	Franco Modigliani	1918-06-18 01:00:00	2003-09-25 01:00:00	Italy	\N	Rome	\N	Economics	f	Modigliani	1985	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1985/modigliani_thumb.jpg	\N
702332959	Carl E. Wieman	1951-03-26 00:00:00	\N	\N	\N	\N	\N	Physics	t	Wieman	2001	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2001/wieman_thumb.jpg	\N
927659372	Charles J. Pedersen	1904-10-03 00:00:00	1989-10-26 01:00:00	Korea	\N	Busan	\N	Chemistry	t	Pedersen	1987	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1987/pedersen_thumb.jpg	\N
134809693	Eric S. Chivian	\N	\N	\N	\N	\N	\N	Peace	f	Chivian	1985	\N	\N	http://people.csail.mit.edu/dfhuynh/projects/nobelists/images/eric-chivian.png	http://mitworld.mit.edu/video/63/
704115275	Mario J. Molina	1943-03-19 01:00:00	\N	Mexico	\N	Mexico City	\N	Chemistry	t	Molina	1995	\N	\N	http://people.csail.mit.edu/dfhuynh/projects/nobelists/images/mario-j-molina.png	http://mitworld.mit.edu/video/63/
57839852	Robert Burns Woodward	1917-04-10 01:00:00	1979-07-08 01:00:00	United States of America	Massachusetts	Cambridge	\N	Chemistry	f	Woodward	1965	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1965/woodward_thumb.jpg	\N
506489850	Robert B. Laughlin	1950-11-01 00:00:00	\N	United States of America	California	Visalia	\N	Physics	t	Laughlin	1998	\N	Horst L. Störmer, Daniel C. Tsui	http://nobelprize.org/nobel_prizes/physics/laureates/1998/laughlin_thumb.jpg	\N
417204688	Andrew Fire	1959-04-27 01:00:00	\N	United States of America	California	Palo Alto	http://web.mit.edu/newsoffice/2006/fire.html	Medicine/Physiology	t	Fire	2006	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/2006/fire_thumb.jpg	\N
920398821	Robert M. Solow	1924-08-23 01:00:00	\N	United States of America	New York	Brooklyn	\N	Economics	f	Solow	1987	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1987/solow_thumb.jpg	\N
54824727	Robert S. Mulliken	1896-06-07 01:00:00	1986-10-31 00:00:00	United States of America	Virginia	Arlington	\N	Chemistry	f	Mulliken	1966	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1966/mulliken_thumb.jpg	\N
757913923	Kofi Annan	1938-05-08 01:00:00	\N	\N	\N	\N	\N	Peace	t	Annan	2001	\N	\N	http://nobelprize.org/nobel_prizes/peace/laureates/2001/annan_thumb.jpg	\N
192044853	Thomas R. Cech	1947-12-08 00:00:00	\N	United States of America	Illinois	Chicago	\N	Chemistry	t	Cech	1989	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1989/cech_thumb.jpg	\N
716679852	Samuel C.C. Ting	1936-01-27 00:00:00	\N	United States of America	Michigan	Ann Arbor	\N	Physics	t	Ting	1976	\N	Burton Richter	http://nobelprize.org/nobel_prizes/physics/laureates/1976/ting_thumb.jpg	\N
180537032	Isidor Isaac Rabi	1898-07-29 01:00:00	1988-01-11 00:00:00	\N	\N	\N	\N	Physics	f	Rabi	1944	t	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1944/rabi_thumb.jpg	\N
96233980	Luis W. Alvarez	1913-06-13 00:00:00	1988-09-01 01:00:00	\N	\N	\N	\N	Physics	f	Alvarez	1968	t	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1968/alvarez_thumb.jpg	\N
261646024	Aaron Ciechanover	1947-10-01 01:00:00	\N	British Mandate of Palestine	\N	Haifa	http://nobelprize.org/chemistry/laureates/2004/index.html	Chemistry	t	Ciechanover	2004	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/2004/ciechanover_thumb.jpg	\N
431231374	Clifford G. Shull	1915-09-23 00:00:00	\N	United States of America	Pennsylvania	Pittsburgh	\N	Physics	t	Shull	1994	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1994/shull_thumb.jpg	\N
1037237308	Norman F. Ramsey	1915-08-27 00:00:00	\N	United States of America	District of Columbia	Washington	\N	Physics	f	Ramsey	1989	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1989/ramsey_thumb.jpg	\N
38379547	Geoffrey Wilkinson	1921-07-14 01:00:00	1996-09-26 01:00:00	England	\N	Springside	\N	Chemistry	t	Wilkinson	1973	\N	\N	http://nobelprize.org/nobel_prizes/chemistry/laureates/1973/wilkinson_thumb.jpg	\N
897935197	Frank Wilczek	1951-05-15 01:00:00	\N	United States of America	New York	Mineola	http://web.mit.edu/newsoffice/2004/nobel-wilczek.html	Physics	t	Wilczek	2004	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2004/wilczek_thumb.jpg	\N
471244306	Sidney Altman	1939-05-07 01:00:00	\N	Canada	Quebec	Montreal	\N	Chemistry	t	Altman	1989	\N	Thomas R. Cech	http://nobelprize.org/nobel_prizes/chemistry/laureates/1989/altman_thumb.jpg	\N
887968197	Leland H. Hartwell	1939-10-30 01:00:00	\N	United States of America	California	Los Angeles	\N	Medicine/Physiology	t	Hartwell	2001	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/2001/hartwell_thumb.jpg	\N
452679743	Henry W. Kendall	1926-12-09 00:00:00	1999-02-15 00:00:00	United States of America	Massachusetts	Boston	\N	Physics	t	Kendall	1990	\N	Jerome I. Friedman	http://nobelprize.org/nobel_prizes/physics/laureates/1990/kendall_thumb.jpg	\N
127536269	George Smoot	1945-02-20 01:00:00	\N	United States of America	Florida	Yukon	http://web.mit.edu/newsoffice/2006/smoot.html	Physics	t	Smoot	2006	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/2006/smoot_thumb.jpg	\N
309696094	Robert J. Aumann	1930-06-08 01:00:00	\N	Germany	\N	Frankfurt Am Main	http://nobelprize.org/economics/laureates/2005/press.html	Economics	t	Aumann	2005	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2005/aumann_thumb.jpg	\N
249288376	Robert C. Merton	1944-07-31 02:00:00	\N	United States of America	New York	New York City	\N	Economics	t	Merton	1997	\N	Myron S. Scholes	http://nobelprize.org/nobel_prizes/economics/laureates/1997/merton_thumb.jpg	\N
889316300	Robert Engle	1942-11-10 01:00:00	\N	\N	\N	\N	http://nobelprize.org/economics/laureates/2003/index.html	Economics	t	Engle	2003	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/2003/engle_thumb.jpg	\N
316107204	William D. Phillips	1948-11-05 00:00:00	\N	United States of America	Pennsylvania	Wilkes-Barre	\N	Physics	t	Phillips	1997	\N	\N	http://nobelprize.org/nobel_prizes/physics/laureates/1997/phillips_thumb.jpg	\N
760543461	H. Robert Horvitz	1947-05-08 02:00:00	\N	\N	\N	\N	http://web.mit.edu/newsoffice/2002/horvitz-nobel.html	Medicine/Physiology	t	Horvitz	2002	\N	\N	http://nobelprize.org/nobel_prizes/medicine/laureates/2002/horvitz_thumb.jpg	\N
1039451971	Robert A. Mundell	1932-10-24 00:00:00	\N	Canada	Ontario	Kingston	\N	Economics	f	Mundell	1999	\N	\N	http://nobelprize.org/nobel_prizes/economics/laureates/1999/mundell_thumb.jpg	\N
\.


--
-- PostgreSQL database dump complete
--

