/*******************************************************************************
This file contains all the necessary commands for the analyses of the paper 
published in Ciência & Saúde Coletiva. The paper is authored by Dr Helena Mendes
Constante, Dr Gerson Luiz Marinho, and Dr João Luiz Bastos. The title is “The 
door is open, but not everyone may enter: Racial inequities in healthcare access
across three Brazilian surveys". 
DOI currently unavailable.

The paper analysed data from the 2008 National Household Sample Survey (PNAD), 
and 2013 and 2019  National Health Survey (PNS). The microdata is publicly 
through the following website: 
https://www.ibge.gov.br/estatisticas/downloadsestatisticas.html

The file runs by using "PNAD_PNS_subset_appendsvy.dta", which is a result from 
a combination of PNAD and PNS datasets using the function append.

Suggestions and questions are wellcome.
Contact Helena Mendes Constante via lenaconstante@gmail.com
*******************************************************************************/

/*******************************************************************************
1 - CLEAR MEMORY, DISABLE SCROLL LOCK, START DATASET
*******************************************************************************/

	// clear
	set more off
	// use	"~\PNAD_PNS_subset_appendsvy.dta",clear

/*******************************************************************************
2 - IDENTIFICATION OF DATASETS
The datasets were unified with the command "append" which generated a new variable 
of identification called "Dataset"

Dataset == 0 is the specific data of 2008 PNAD
Dataset == 1 is the specific data of 2013 PNS 
Dataset == 2 is the specific data of 2019 PNS

Below we generate a new variable called "banco" to name each category
*******************************************************************************/

	gen banco=Dataset
		label define banco ///
			0 "PNAD2008" ///
			1 "PNS2013" ///
			2 "PNAD2019"
		label values banco banco
	ta banco

/*******************************************************************************
3 - IDENTIFICATION AND CONTROL	
*******************************************************************************/

//	Identification
	gen ID=_n
	sum ID

// 	Labels in common
		label define noyes 0 "No" 1 "Yes"
		label define reasons 0 "No need" 1 "Various reasons"
		label define race 0 "White" 1 "Black/Brown"

// 	State and Region
	ta UF
	ta UF banco
	gen state=UF
		destring state, replace
		label define state ///
			11 "Rondônia" ///
			12 "Acre" ///
			13 "Amazonas" /// 
			14 "Roraima" ///
			15 "Pará" ///
			16 "Amapá" ///
			17 "Tocantins" /// 
			21 "Maranhão" ///
			22 "Piauí" ///
			23 "Ceará" ///
			24 "Rio Grande do Norte" ///
			25 "Paraíba" ///
			26 "Pernambuco" ///
			27 "Alagoas" ///
			28 "Sergipe" ///
			29 "Bahia" ///
			31 "Minas Gerais" ///
			32 "Espírito Santo" ///
			33 "Rio de Janeiro" ///
			35 "São Paulo" ///
			41 "Paraná" ///
			42 "Santa Catarina" ///
			43 "Rio Grande do Sul" ///
			50 "Mato Grosso do Sul" ///
			51 "Mato Grosso" ///
			52 "Goiás" ///
			53 "Distrito Federal"
		label values state state
	ta state
	ta state banco // Distribution of the sample of States by datasets
	
	gen region=state
		recode region 11/17=1 21/29=2 31/35=3 41/43=4 50/53=5
		label define region ///
			1 "North" ///
			2 "Northeast" ///
			3 "Southeast" ///
			4 "South" ///
			5 "Center-West"		
		label values region region
	ta region
	ta region banco // Distribution of the sample of regions by datasets

/*******************************************************************************
4 - Variables related to the use of health services
*******************************************************************************/

/**********************************
4a. Is your home registered in the family health unit?
**********************************/

//	PNAD2008 (Originally 1-Sim;3-Não)
	ta V0233 if banco==0
	generate registerESF2008=V0233
		recode registerESF2008 1=1 3=0
		label values registerESF2008 noyes
	ta registerESF2008
	
//	PNS2013 (Originally 1-Sim; 2-Não; 3-Não sei)
	ta B001 if banco==1 // equal for 2013 and 2019 PNS
	generate registerESF2013=B001 if banco==1
		recode registerESF2013 1=1 2=0 3=.
		label values registerESF2013 noyes
	ta registerESF2013
		
//	PNS2019 (Originally 1-Sim; 2-Não; 3-Não sei)
	ta B001 if banco==2
	generate registerESF2019=B001 if banco==2
		recode registerESF2019 1=1 2=0 3=.
		label values registerESF2019 noyes
	ta registerESF2019

/**********************************
4b. Do you have any health, medical or dental plans, private, company or from a
public agency?
**********************************/

// 	PNAD2008
	ta V1321
	gen planPNAD2008=V1321
		recode planPNAD2008 1/3=1 5=0
		label values planPNAD2008 noyes
	ta planPNAD2008
	
//	PNS2013
	ta I001
	gen planPNS2013=I001
		recode planPNS2013 1=1 2=0
		label values planPNS2013 noyes
	ta planPNS2013
	
//	PNS2019
	ta I00101
	ta I00102
	gen planPNS2019=.
	replace planPNS2019=0 if I00101==2 | I00102==2
	replace planPNS2019=1 if I00101==1 | I00102==1
		label values planPNS2019 noyes
	ta planPNS2019
	
/**********************************
4c. In the first time you sought health care, in the last two weeks, 
were you cared?
**********************************/

//	PNAD2008 (Originally 2=Sim,4=Não)
	ta V1354
	gen cared2w_PNAD2008=V1354
		recode cared2w_PNAD2008 2=1 4=0
		label values cared2w_PNAD2008 noyes
	ta cared2w_PNAD2008
	
//	PNS2013	(Originally 1=Sim,2=Não)
	ta J017
	gen cared2w_PNS2013=J017
		recode cared2w_PNS2013 1=1 2=0
		label values cared2w_PNS2013 noyes
	ta cared2w_PNS2013
	
// 	PNS2019	(Originally 1=Foi agendado para outro dia/local, 2=Não, 3=Sim)
	ta J01701
	gen cared2w_PNS2019=J01701
		recode cared2w_PNS2019 1=1 2=0 3=1 //como considerar o 1?
		label values cared2w_PNS2019 noyes
	ta cared2w_PNS2019

/**********************************
4d. In the past two weeks, why did you not seek health care?
**********************************/
	
//	PNAD2008 
	ta V3368 
	codebook V3368
	gen notseekPNAD2008=V3368
		recode notseekPNAD2008 1=0  2/11=1 12=.
		label values notseekPNAD2008 reasons
	ta notseekPNAD2008
	
//	PNS2013
	ta J036
	generate notseekPNS2013=J036
	ta notseekPNS2013,nolab
		recode notseekPNS2013 1=0 2/11=1 12=. 13=. 
		label values notseekPNS2013 reasons
	ta notseekPNS2013
	
// 	PNS2019
	ta J03602
	generate notseekPNS2019=J03602 
	ta notseekPNS2019,nolab
		recode notseekPNS2019 1=0 2/11=1
		label values notseekPNS2019 reasons
	ta notseekPNS2019

/**********************************
4e. Difficulty of access (4c + 4d)
**********************************/

// PNAD2008
	ta cared2w_PNAD2008
	ta notseekPNAD2008
	
	egen byte accessPNAD2008 = anymatch(cared2w_PNAD2008 notseekPNAD2008) ///
	if cared2w_PNAD2008==0 | notseekPNAD2008==1, values(1)
	ta accessPNAD2008 
		label value accessPNAD2008 noyes
	ta accessPNAD2008 if banco==0

// PNS2013
	ta cared2w_PNS2013
	ta notseekPNS2013
	
	egen byte accessPNS2013 = anymatch(cared2w_PNS2013 notseekPNS2013) ///
	if cared2w_PNS2013==0 | notseekPNS2013==1, values(1)
	ta accessPNS2013
		label value accessPNS2013 noyes
	ta accessPNS2013 if banco==1

// PNS2019
	ta cared2w_PNS2019
	ta notseekPNS2019
	
	egen byte accessPNS2019 = anymatch(cared2w_PNS2019 notseekPNS2019) ///
	if cared2w_PNS2019==0 | notseekPNS2019==1, values(1)
	ta accessPNS2019
		label value accessPNS2019 noyes
	ta accessPNS2019 if banco==2

/*******************************************************************************
5 - Main exploratory variable
*******************************************************************************/

/**********************************
Race
**********************************/

// 	PNAD2008
	ta V0404
	generate racePNAD2008=V0404
		recode racePNAD2008 0=. 2=0 4=1 6=. 8=1 9=.
		label values racePNAD2008 race
	ta racePNAD2008

//	PNS2013
	generate racePNS2013=C009 if banco==1 // igual para os bancos de PNS2013 e 2019
	ta racePNS2013
		recode racePNS2013 1=0 2=1 3=. 4=1 5=. 9=.
		label values racePNS2013 race
	ta racePNS2013

// 	PNS2019
	generate racePNS2019=C009 if banco==2
	ta racePNS2019
		recode racePNS2019 1=0 2=1 3=. 4=1 5=. 9=. 
		label values racePNS2019 race
	ta racePNS2019

/*******************************************************************************
6 - Restrictions
*******************************************************************************/

/*******************************************************************************
6a - Age
*******************************************************************************/

//	PNAD2008
	ta V8005
	generate agePNAD2008=V8005
	codebook agePNAD2008
	ta agePNAD2008 
	
//	PNS2013
	ta C008 if banco==1
	codebook C008 
	generate agePNS2013=C008 if banco==1
		destring agePNS2013, replace
	ta agePNS2013
		
// 	PNS2019
	ta C008 if banco==2
	generate agePNS2019=C008 if banco==2
		destring agePNS2019, replace
	ta agePNS2019 
	
/*******************************************************************************
6b - Restricting the analysis to those who answered the individual questionnaire 
Variable available in PNS2013 and PNS2019
*******************************************************************************/

//	PNS2013
	generate selected2013=V0025 if banco==1
	ta selected2013
	
//	PNS2019
	ta V0025A
	generate selected2019=V0025A
	ta selected2019
		recode selected2019 0=0 1=1 9=.

/*******************************************************************************
7 - Application of sample weights
*******************************************************************************/
	
// 	To use the same svyset, first it is necessary to check if the variables 
// 	related to the sample weights have the same format

	codebook V00291 if banco==0
	codebook V00291 if banco==1
	codebook V00291 if banco==2

	codebook V0024 if banco==0
	codebook V0024 if banco==1
	codebook V0024 if banco==2	

	codebook V00293 if banco==0
	codebook V00293 if banco==1
	codebook V00293 if banco==2	

	codebook V00292 if banco==0
	codebook V00292 if banco==1
	codebook V00292 if banco==2	

	svyset UPA_PNS [pweight=V00291], strata(V0024) poststrata(V00293) postweight(V00292) vce(linearized) singleunit(centered)

/*******************************************************************************
Table 1 – Distribution of the sample according to race and indicators of 
healthcare access. National Household Sample Survey (2008 PNAD), and Brazilian 
National Health Survey (2013 and 2019 PNS).
*******************************************************************************/

//	PNAD2008
	svy: tabulate racePNAD2008 if agePNAD2008>17 & banco==0, obs percent ci nomarginal
	svy: tabulate registerESF2008 if agePNAD2008>17 & banco==0, obs percent ci nomarginal
	svy: tabulate planPNAD2008 if agePNAD2008>17 & banco==0, obs percent ci nomarginal
	svy: tabulate accessPNAD2008 if agePNAD2008>17 & banco==0, obs percent ci nomarginal	

//	PNS2013	
	svy: tabulate racePNS2013 if agePNS2013>17 & selected2013==1 & banco==1, obs percent ci nomarginal
	svy: tabulate registerESF2013 if agePNS2013>17 & selected2013==1 & banco==1, obs percent ci nomarginal
	svy: tabulate planPNS2013 if agePNS2013>17 & selected2013==1 & banco==1, obs percent ci nomarginal
	svy: tabulate accessPNS2013 if agePNS2013>17 & selected2013==1 & banco==1, obs percent ci nomarginal
		
//	PNS2019
	svy: tabulate racePNS2019 if agePNS2019>17 & selected2019==1 & banco==2, obs percent ci nomarginal
	svy: tabulate registerESF2019 if agePNS2019>17 & selected2019==1 & banco==2, obs percent ci nomarginal
	svy: tabulate planPNS2019 if agePNS2019>17 & selected2019==1 & banco==2, obs percent ci nomarginal
	svy: tabulate accessPNS2019 if agePNS2019>17 & selected2019==1 & banco==2, obs percent ci nomarginal
	
/*******************************************************************************
Table 2 – Estimates of healthcare access according to race. National Household 
Sample Survey (2008 PNAD), and Brazilian National Health Survey (2013 and 2019 
PNS).
*******************************************************************************/

// 	PNAD2008
	svy: tabulate racePNAD2008 registerESF2008 if agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 planPNAD2008 if agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 accessPNAD2008 if agePNAD2008>17 & banco==0, row obs percent ci nomarginal

//	PNS2013	
	svy: tabulate racePNS2013 registerESF2013 if agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 planPNS2013 if agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 accessPNS2013 if agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal

//	PNS2019
	svy: tabulate racePNS2019 registerESF2019 if agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 planPNS2019 if agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 accessPNS2019 if agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal

/*******************************************************************************
Table 3 – Estimates of healthcare access according to race and Brazilian 
geographic regions. National Household Sample Survey (2008 PNAD), and Brazilian 
National Health Survey (2013 and 2019 PNS).
*******************************************************************************/
	
// 	PNAD2008
	svy: tabulate racePNAD2008 registerESF2008 if region==1 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 registerESF2008 if region==2 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 registerESF2008 if region==3 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 registerESF2008 if region==4 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 registerESF2008 if region==5 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
		
	svy: tabulate racePNAD2008 planPNAD2008 if region==1 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 planPNAD2008 if region==2 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 planPNAD2008 if region==3 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 planPNAD2008 if region==4 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 planPNAD2008 if region==5 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal

	svy: tabulate racePNAD2008 accessPNAD2008 if region==1 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 accessPNAD2008 if region==2 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 accessPNAD2008 if region==3 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 accessPNAD2008 if region==4 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	svy: tabulate racePNAD2008 accessPNAD2008 if region==5 & agePNAD2008>17 & banco==0, row obs percent ci nomarginal
	
//	PNS2013	
	svy: tabulate racePNS2013 registerESF2013 if region==1 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 registerESF2013 if region==2 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 registerESF2013 if region==3 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 registerESF2013 if region==4 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 registerESF2013 if region==5 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal

	svy: tabulate racePNS2013 planPNS2013 if region==1 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 planPNS2013 if region==2 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 planPNS2013 if region==3 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 planPNS2013 if region==4 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 planPNS2013 if region==5 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	
	svy: tabulate racePNS2013 accessPNS2013 if region==1 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 accessPNS2013 if region==2 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 accessPNS2013 if region==3 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 accessPNS2013 if region==4 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal
	svy: tabulate racePNS2013 accessPNS2013 if region==5 & agePNS2013>17 & selected2013==1 & banco==1, row obs percent ci nomarginal

//	PNS2019
	svy: tabulate racePNS2019 registerESF2019 if region==1 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 registerESF2019 if region==2 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 registerESF2019 if region==3 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 registerESF2019 if region==4 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 registerESF2019 if region==5 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	
	svy: tabulate racePNS2019 planPNS2019 if region==1 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 planPNS2019 if region==2 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 planPNS2019 if region==3 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 planPNS2019 if region==4 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 planPNS2019 if region==5 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal

	svy: tabulate racePNS2019 accessPNS2019 if region==1 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 accessPNS2019 if region==2 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 accessPNS2019 if region==3 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 accessPNS2019 if region==4 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal
	svy: tabulate racePNS2019 accessPNS2019 if region==5 & agePNS2019>17 & selected2019==1 & banco==2, row obs percent ci nomarginal

// 	END OF DO-FILE
	