# Replication package for "Habit and skill retention in recycling"

Dylan Brewer and Samantha Cameron

Conditionally accepted at *Journal of Policy Analysis and Management*

## Overview

This replication package contains all files required to reproduce results, tables, and figures using Stata, R, and Python.

The entire project can be replicated using the `01_setup_202308.do` file in Stata, which will run all Stata and R scripts.  One .pdf dataset was converted to .csv using a Python script (`a1_masspdfscrape_202308.py`), which can be implemented using the Anaconda Python distribution as described on lines 48 - 53 of `01_setup_202308.do`.  Using a 2021 PC with an AMD Ryzen 7 5800X 8-core 3801 Mhz processor with 32 Gb of RAM, the replication takes approximately 35 minutes of computation time.

## Data Sources and Files

All data used in this paper are publicly available and are archived in the Zenodo repository.  Original data files are located in the `\data\raw` directory, whereas intermediate or final data files are located in the `data\final` directory.

1. Department of Sanitation of New York City (DSNY) administrative waste data
    - Publicly available on New York City's Open Data portal: "DSNY monthly tonnage data" https://data.cityofnewyork.us/City-Government/DSNY-Monthly-Tonnage-Data/ebb7-mvp5
    - Data version last downloaded from source February 2022
    - `DSNY_Monthly_Tonnage_Data.csv`
2. Massachusetts Department of Environmental Protection administrative municipality recycling data
    - Publicly available at https://www.mass.gov/lists/recycling-solid-waste-data-for-massachusetts-cities-towns
    - Data version last downloaded from source February 2022
    - `munirate.pdf`
    - .pdf converted to .csv (`final\munirate_clean.csv`) using `a1_masspdfscrape_202308.py` Python script
3. New Jersey Department of Environmental Protection administrative county recycling data
    - Publicly available at https://www.nj.gov/dep/dshw/recycling/stats.htm
    - Data version last downloaded from source February 2022
    - Raw .pdf files available in `\NewJersey_pdfs`
    - Converted to .csv by hand in files `1995.csv`, `1996.csv`,...,`2018.csv`
4. United States Bureau of Economic Analysis Personal income, population, per capita personal income (CAINC1)
    - Publicly available at https://apps.bea.gov/regional/downloadzip.cfm
    - `CAINC1__ALL_AREAS_1969_2020.csv`
    - Data version last downloaded from source November 2021
5. United States Census county education data compiled by United States Department of Agriculture 
    - Publicly available at https://data.ers.usda.gov/reports.aspx?ID=17829
    - `Education.xls`
    - Data version last downloaded from source March 2022
6. United States Census county race data
    - Publicly available at https://repository.duke.edu/catalog/38e88069-9789-4731-980e-9e69534f0761
    - `POP1990.xlsx` and `POP2000.xlsx`
    - Data version last downloaded from source March 2022
7. MIT Election Data and Science Lab County Presidential Election Returns 2000-2020
    - Released to the public domain, available at https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ
    - `countypres_2000-2020.csv`
    - Data version last downloaded from source March 2022
8. MassGIS Data: Municipalities for municipality to county matching
    - Publicly available at https://www.mass.gov/info-details/massgis-data-municipalities
    - See files in `\townssurvey_shp` directory
    - Data version last downloaded from source March 2020

## Software Requirements

- Stata (code was last run with 4-core MP version 17)
  - `01_setup_202308.do`, lines 21-41 will install all packages and dependencies for Stata
- Python 3.8.17 via the Anaconda distribution
  - Lines 46-51 of `01_setup_202308.do` provide directions to install all packages and dependencies required for Python
- R 4.1.3
  - Commented lines 7-11 at the top of `c4_SDID_stacked_202308.R` contain code to install packages required for R
  - 'synthdid' version 0.0.9 developed by David Hirshberg: https://synth-inference.github.io/synthdid/
- Portions of the code use Powershell scripting via Stata, which may require Windows 11 or higher.

## Description of programs/code

- `01_setup_202308.do` installs Stata packages and dependencies and calls all Stata and R scripts to replicate the results.  Lines 46-51 contain instructions to run the Python script.  Pressing run will replicate all analysis, figures, and tables going from (nearly) raw data to final results.
- `a1_masspdfscrape_202308.py` converts a .pdf file of Massachusetts recycling data into a usable .csv file.  Running this is optional for the replication but is included for completeness.
- `b1_demographics_202308.do` cleans demograhpic data at the county level to use as control variables in the analyses.
- `b2_njdata_202308.do` cleans New Jersey recycling data
- `b3_massdata_202308.do` cleans Massachusetts recycling data
- `b4_dsnycleaning_202308.do` cleans New York City recycling data
- `b5_merges_202308.do` merges all recycling and demographics data, creates a balanced panel, and prepares datasets for each of the final analyses.  The code also creates 500 placebo treatments for SDID placebo inference and pre-partials out covariates for the SDID-with-covariates robustness check (appendix D1).
- `c1_scatterplots_202308.do` generates monthly time series of waste and recycling for NYC (figures 1 and 6).
- `c2_did_202308.do` examines differences in means (section 3) and performs DID and event study analyses via OLS (section 4.1) and fractional response MLE (appendix section D.4).
- `c3_sc_202308.do` implements the synthetic control analysis and creates synthetic control figures (appendix section D.3)
- `c4_SDID_stacked_202308.R` implements joint and stacked SDID
- `c5_SDID_partialed_202308.R` implements SDID on the partialed out data
- `c6_sdidplotstables_202308.do` creates parallel trends figure 3, SDID unit and time weight figure 4, and results (figure 5 and table 2 in section 5)
- `c7_cohens_202308.do` calculates Cohen's-D nonparametric measure of pre-period fit for each method
- `c8_arellanobond_202308.do` estimates the Arellano-Bond model and table 3 in section 6.

## Instructions to Replicators

- To reproduce all tables, figures, and analyses by running `01_setup_202308.do`
  - Change working directory on line 13
  - Change path to your R installation on line 19
  - If line 15 `local install = 1`, all packages and Stata display settings will be altered.  You then must specify a directory for ado files to be installed on line 25.  Type sysdir to see where new ado files are installed by default (PLUS).  Computation time: ~20s.
  - If line 16 `local clean = 1`, all data will be reassembled from raw data files to datasets ready for analysis. Computation time: ~25s.
  - If line 17 `local analysis = 1`, all tables, figures, and analyses will be replicated. Computation time: ~33m.
  - Install R packages on lines 7-11 of `c4_SDID_stacked_202308.R`
  - After setting these options, you should be able to run this .do file to replicate the entire paper.
- To replicate conversion of `munirate.pdf` to `munirate_clean.csv` (Optional)
    1. Install Python via the Anaconda distribution: https://www.anaconda.com/
    2. Open the Anaconda Prompt and run the following commands (changing your file paths as necessary):
   
        >`conda create -n "recyclinghabits" python=3.8.17 tabula-py pandas pathlib`

        >`conda activate recyclinghabits`
        
        >`python C:\Users\brewe\Dropbox\PaperIdeas\RecyclingHabits\code\a1_masspdfscrape_202308.py`

- To compile the pre-publication manuscript, use `latex\_FINAL_manuscript_202308.tex` and `latex\ref.bib` using Overleaf.

## List of tables, figures, results, and programs

The provided code reproduces all numbers, results, tables, and figures in the paper.

| Figure/Table/Result    | Program                  | Line Number | Output files                 |
|-------------------|--------------------------|-------------|----------------------------------|
| Table 1           | `c2_did_202308.do` | 30 - 62 | `differencemeans.tex` |
| Table 2           | `c6_sdidplotstables_202308.do` |173| `estimatestable.tex` |
| Table 3           | `c8_arellanobond_202308.do`|98| `arellanobond.tex` |
| Table 4           | `c6_sdidplotstables_202308.do`|291| `robustnesstable.tex` |
| Figure 1          | `c1_scatterplots_202308.do` || `rrtrends.pdf`, `mgptrends.pdf`, `othertrends.pdf`, `refusetrends.pdf` |
| Figure 2          | `c2_did_202308.do` | 64 - 72 | `rawparalleltrends.pdf` |
| Figure 3          | `c6_sdidplotstables_202308.do` |253 - 287| `comparison.pdf`, `comparisonrecentered.pdf` |
| Figure 4          | `c6_sdidplotstables_202308.do` |227 - 238| `regionweights.pdf`, `timeweights.pdf` |
| Figure 5          | `c6_sdidplotstables_202308.do` | 167 | `estimates.pdf` |
| Figure 6          | `c1_scatterplots_202308.do` || `rr_level.pdf`, `mgp_level.pdf`, `other_level.pdf`, `refuse_level.pdf` |
| Figure 7          | `c3_sc_202308.do` |27 - 35| `scrawoutcomes.pdf`, `sctreatcontrol.pdf`, `scplacebos.pdf` |
| Event study DID (equation 2) | `c2_did_202308.do` | 74 - 84 | |
| Footnote 9 (omitted pre-period robustness checks) | `c2_did_202308.do` | 88 - 96 | |
| Stacked SDID event study (equation 3) | `c4_SDID_stacked_202308.R`|| |
| Cohen's D (section 5) | `c7_cohens_202308.do` || |
| Arellano-Bond (equation 4) | `c8_arellanobond_202308.do` |52 - 96| |
| SDID with controls (appendix D.1) | `c5_SDID_partialed_202308.R` || |
| Joint SDID (appendix D.2) | `c4_SDID_stacked_202308.R` || |
| Synthetic control (appendix D.3) | `c3_sc_202308.do` | 16 - 36 | |
| Footnote 21 (synthetic control no controls) | `c3_sc_202308.do` | 38 - 49| |
| Fractional response model (appendix D.4) | `c2_did_202308.do` | 98 - 109 | |

## Acknowledgements

This code is based on AEA data editor's readme guidelines. (https://aeadataeditor.github.io/posts/2020-12-08-template-readme).  Some content on this page was copied from [Hindawi](https://www.hindawi.com/research.data/#statement.templates). Other content was adapted from [Fort (2016)](https://doi.org/10.1093/restud/rdw057) and [Hollingsworth, Wing, and Bradford (2022)](https://doi.org/10.5281/zenodo.6626309).
