# Festive-Season-Payment-Surge-Analysis
A end-to-end data analytics project simulating the work of a Analyst at India's leading fintech platform. Built to demonstrate SQL proficiency, business insight generation, and dashboard storytelling using a custom-designed payments dataset modelled on real UPI transaction behaviour.

## Business Problem

FinTech processes 255M+ daily transactions across 39M merchants. A key challenge for their analytics team is understanding how Indian festivals impact payment behaviour — which categories surge, which cities respond first, and how transaction patterns differ across Tier 1, 2, and 3 cities.

This project answers:

Which festivals drive the highest GMV per day (efficiency metric)?
Which payment categories surge most during festivals — and by how much?
Do Tier 3 cities lag behind Tier 1 in festival spending behaviour?
What should Fintech marketing team do differently based on this data?

## Dataset

Dataset modelled on India's UPI payment ecosystem — calibrated against publicly available NPCI UPI monthly statistics.

File	Description	Rows
payments.csv	Daily transactions by city, category, festival	93,504
festival_calendar.csv	16 Indian festivals with date ranges and metadata	16

Date range: September 2022 – December 2023
Cities: 24 Indian cities — Tier 1 (Mumbai, Delhi, Bangalore, Hyderabad, Chennai, Pune, Kolkata, Ahmedabad), Tier 2 (Jaipur, Lucknow, Surat, Kanpur, Nagpur, Indore, Bhopal, Patna), Tier 3 (Agra, Varanasi, Meerut, Jodhpur, Raipur, Guwahati, Mysore, Coimbatore)
Categories: Food & Dining · Shopping · Gifting · Travel · Medical · Groceries · Entertainment · Bill Payment
Festivals: Diwali · Navratri · Dussehra · Holi · Eid ul-Fitr · Raksha Bandhan · Ganesh Chaturthi · IPL Season · Christmas · New Year and more

Note: Tier 3 cities have a built-in 2-day behavioural lag relative to Tier 1 cities — modelled on real consumer adoption patterns in non-metro India. This lag is statistically proven through SQL analysis in the project.

## Key Findings
#	Finding	Evidence
1	Festival days generate 17% higher GMV vs regular days	Avg spend ₹185 higher per transaction on festival days
2	Gifting surges 95% above average on Raksha Bandhan	Highest single-category spike across all 16 festivals
3	Entertainment and Travel grow 260% GMV on New Year	Highest GMV growth % festival in dataset
4	Tier 3 cities peak exactly 2 days after Tier 1 on Diwali	Validated across Diwali 2022 and Diwali 2023 using LAG()
5	Medical is festival-immune — near-zero variance across all festivals	Statistical control group — proves other surges are genuine demand spikes
6	Tier 1 leads in Bill Payment; Tier 2/3 lead in Groceries on non-festival days	Distinct spending behaviour between metro and non-metro India

 ## Business Recommendations
Recommendation	Based On
Start Gifting cashback 3 days before Diwali and Raksha Bandhan — not on peak day	Gifting 95% surge finding
Run a Tier 3 second wave campaign 2 days after metro launch	2-day lag validation
Prioritise OTT, ticketing, and dining cashback Dec 30–Jan 2	New Year 260% GMV growth

