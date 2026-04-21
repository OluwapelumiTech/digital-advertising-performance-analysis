# Digital Advertising Performance Analysis
## | January – February 2026

## Project Overview
An end-to-end data analysis of a digital advertising platform covering
11.5 million events across 15 ad platforms, 2,287 campaigns, and 138
traffic sources over a 59-day period.

## Business Questions Answered
- Which ad platforms deliver the best Return on Ad Spend (ROAS)?
- Where are the biggest drop-offs in the customer conversion funnel?
- Which lead quality tiers generate the most revenue?
- Where should budget be reallocated for maximum margin improvement?

## Key Findings
- Overall ROAS of 9.19x generating €123.9M margin on €15.1M spend
- Google Ads delivers 508x ROAS at only €0.20 cost per €1 revenue
- PropellerAds generated 241,482 visits but only 2 conversions — immediate pause recommended
- Tier 1 leads generate 57.2% of all revenue despite being 10.4% of lead volume
- SMS Bulk has a 33.31% cost-to-revenue ratio vs Google Ads at 0.20%

## Tools Used
- **DuckDB SQL** — data exploration, cleaning, and analysis
- **Power BI** — interactive dashboard and visualisations
- **Microsoft Word** — business report

## Files in This Repository
- `analysis.sql` — complete SQL analysis code with comments
- `Digital_Advertising_Performance_Report.docx` — full business report

## Dataset
The analysis was conducted on `events.parquet` — a proprietary dataset
provided as part of a data analyst assessment. The raw data file is not
included in this repository.

## How to Run the SQL
1. Install DuckDB: https://duckdb.org/docs/installation
2. Place `events.parquet` in your working directory
3. Open `analysis.sql` in VS Code with the DuckDB extension
4. Update the file path in the SETUP block to match your local directory
5. Run the SETUP block first, then execute queries section by section
