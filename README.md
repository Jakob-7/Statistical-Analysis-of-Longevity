# Is There a Cap on Human Life?
### Survival Analysis of Centenarians and Supercentenarians

This repository contains a statistics project investigating whether there exists an upper bound on human lifespan using **survival analysis and parametric extrapolation**.

The analysis is based on validated centenarian and supercentenarian data from the **International Database on Longevity (IDL)**.

---

## 🎯 Research Question

Is there a statistical limit to human life expectancy?

Rather than approaching the question from a biological or philosophical perspective, this project uses **parametric survival models** to extrapolate mortality behavior beyond observed ages.

---

## 📊 Dataset

- **Source**: International Database on Longevity (IDL)  
- **Sample**: 18,959 validated centenarians and supercentenarians  
- **Countries**: 13  
- Only observations with **“YES” validation status** were used to ensure data reliability.

Due to censoring and truncation effects, careful preprocessing and interval selection were required.

---

## 🧠 Methodology

### Data Handling
- Removed *EXHAUSTIVE* and *SAMPLE OUT* observations
- Focused on validated age-at-death records
- Applied **double interval truncation** to reduce bias from observation windows

### Statistical Models
Two parametric survival models were fitted using **maximum likelihood estimation**:

- **Weibull distribution**
- **Gamma distribution**

Both models were evaluated against a **Kaplan–Meier estimator**, which served as a nonparametric benchmark.

---

## 📈 Model Evaluation

- Survival and hazard functions were derived for both parametric models
- Quantile–quantile (Q–Q) plots were used to compare parametric survival curves against Kaplan–Meier estimates
- The **Gamma distribution** showed a slightly better fit:
  - Gamma Q–Q correlation: **0.9858**
  - Weibull Q–Q correlation: **0.9735**

---

## 🔍 Key Findings

- Survival probabilities decline steadily with age, approaching zero asymptotically
- Hazard rates increase sharply up to approximately **124 years**
- Beyond **126–127 years**, estimated hazard rates become numerically extreme, indicating an effectively negligible probability of survival

While survival functions never reach zero mathematically, the extrapolated results suggest a **practical upper bound on human lifespan** under current conditions.

---

## 📄 Project Files

- `report/Is_There_a_Cap_On_Human_Life.pdf`  
  Full written report with figures, statistical discussion, and conclusions.

- `code/survival_analysis.R`  
  Complete R code for data preprocessing, model fitting, Kaplan–Meier estimation, and diagnostics.


