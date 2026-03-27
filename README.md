# Leaving Terrorism Behind? The Role of Terrorist Attacks in Shaping Migration Intentions Around the World

## Replication Code

This repository contains the Stata replication code for:

**Foubert, K. & Ruyssen, I. (2024).** Leaving terrorism behind? The role of terrorist attacks in shaping migration intentions around the world. *Journal of Ethnic and Migration Studies*. [https://doi.org/10.1080/1369183X.2024.2332742](https://doi.org/10.1080/1369183X.2024.2332742)

## Abstract

This paper uses a multilevel approach to empirically investigate the role of terrorist attacks in shaping internal and international migration intentions for 133 countries between 2007 and 2015. Using geo-localised indicators of terrorist activity at the region-month level combined with individual survey data from the Gallup World Polls, we find that terrorist attacks spur international migration intentions, though the effect is small and primarily linked to the intensity of attacks rather than their frequency. The impact varies based on individual characteristics (migration history, education, urban residence) and across countries, with significant effects appearing mostly in sub-Saharan Africa, the Middle East, Southeast Asia, and Europe.

## Data Sources

The analysis combines data from the following sources. **The datasets are not included in this repository** as most require licences or registration:

| Source | Variable(s) | Access |
|--------|-------------|--------|
| Gallup World Polls (GWP) | Migration intentions, individual controls | [Gallup](https://www.gallup.com/analytics/318875/global-research.aspx) (licence required) |
| Global Terrorism Database (GTD) | Terrorist attacks (geo-localised, region-month) | [START, University of Maryland](https://www.start.umd.edu/gtd/) |
| GADM | Administrative region boundaries (level 1) | [GADM](https://gadm.org/) |
| World Development Indicators (WDI) | GNI per capita, income group thresholds | [World Bank](https://databank.worldbank.org/) |
| Polity IV Project | Democracy level, political instability | [Center for Systemic Peace](https://www.systemicpeace.org/) |
| UCDP/PRIO Armed Conflict Dataset | Conflict occurrence | [UCDP](https://ucdp.uu.se/) |
| World Values Survey (WVS) | Trust indicators | [WVS](https://www.worldvaluessurvey.org/) |

## Repository Structure

```
code/
├── 01_data_cleaning/              # Data preparation (one do-file per source)
│   ├── 00_create_iso_codes.do             # ISO3 codes from GADM shapefile
│   ├── 01_clean_iso_codes.do              # ISO3 code harmonisation
│   ├── 02_clean_GADM_codes.do             # GADM region codes cleaning
│   ├── 03_GADM_cleaning_GWP.do            # Match GWP regions to GADM level-1
│   ├── 04_GWP_cleaning.do                 # Gallup World Poll individual data
│   ├── 05_migration_intentions.do         # Internal vs international intentions
│   ├── 06_terrorism_GTD.do                # Region-month GTI construction
│   ├── 07_WDI_GNI.do                     # GNI per capita & income thresholds
│   ├── 08_polity_IV.do                    # Democracy & political instability
│   ├── 09_conflicts_UCDP.do              # Armed conflict occurrence
│   ├── 10_regions_identifiers.do          # World region classification
│   └── 11_trust_WVS.do                   # Trust index (World Values Survey)
│
├── 02_merge/
│   └── 12_merge_final.do                  # Merges all sources into final panel
│
├── 03_estimations/
│   └── 13_estimations_and_descriptives.do # Multinomial logit (Tables 1–4)
│
└── 04_country_by_country/                 # Country-specific regressions (Appendix)
    ├── 14_cbc_GTI_benchmark.do            # Country-by-country with GTI
    ├── 15_cbc_victims_index.do            # Country-by-country with victims index
    ├── 16_cbc_by_skill_level.do           # Country-by-country by education level
    └── 17_cbc_other_push_factors.do       # Country-by-country for other push factors
```

## Execution Order

Scripts are numbered to indicate execution order:

1. **Run `00`–`01`** — create and clean ISO3 country codes (prerequisite).
2. **Run `02`–`03`** — prepare GADM region identifiers and match with GWP regions.
3. **Run `04`–`05`** — clean Gallup World Poll data and construct migration intention variables.
4. **Run `06`** — construct region-month GTI and alternative terrorism indicators from GTD.
5. **Run `07`–`11`** — clean control variables (WDI, Polity IV, UCDP, regions, trust).
6. **Run `12`** — merge all cleaned datasets into the final panel.
7. **Run `13`** — produce all estimation results (Tables 1–4 and appendix).
8. **Run `14`–`17`** — produce country-by-country results (online appendix A.4).

**Note:** File paths in the do-files reference the authors' local Dropbox directories. Users will need to adjust the `cd` commands at the top of each file to match their own directory structure.

## Software Requirements

- Stata 16 or later
- Required Stata packages: `estout`, `wbopendata`, `spmap`, `shp2dta`, `spshape2dta`, `carryforward`

To install all packages:
```stata
ssc install estout
ssc install wbopendata
ssc install spmap
ssc install shp2dta
ssc install carryforward
```

## Methods

- Multinomial logit with country and year fixed effects
- Dependent variable: migration intentions (stay / migrate internally / migrate internationally)
- Region-month GTI constructed at GADM level-1 with 5-year time-decaying weights
- Robustness checks: alternative terrorism indicators, sample restrictions, non-linearity tests
- Heterogeneity analysis by individual characteristics and country-specific regressions

## Citation

```bibtex
@article{foubert2024leaving,
  title={Leaving terrorism behind? {T}he role of terrorist attacks in shaping migration intentions around the world},
  author={Foubert, Killian and Ruyssen, Ilse},
  journal={Journal of Ethnic and Migration Studies},
  year={2024},
  publisher={Taylor \& Francis},
  doi={10.1080/1369183X.2024.2332742}
}
```

## Authors

- **Killian Foubert** — Ghent University / UNU-CRIS
- **Ilse Ruyssen** — Ghent University / UNU-CRIS
