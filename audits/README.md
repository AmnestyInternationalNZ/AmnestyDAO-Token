# Milestone 2 Audits
This folder stores external technical audits, reviewer responses, and verification notes for Amnesty HRDAO (Project Catalyst #1300018).

# Amnesty Human Rights DAO – Milestone 2 External Audits  
**Project Catalyst ID 1300018**  
**Milestone 2: Tokenomics Modelling & Simulation**

---

## Overview  
This folder contains the independent technical audits, verification notes, and responses for **Milestone 2** of the Amnesty Human Rights DAO (HRDAO) project.  
The audits confirm that the dual-token architecture (HRT-UTL + HRT-GOV), smart-contract logic, and tokenomics simulations meet Catalyst acceptance criteria for **accuracy, security, scalability, and transparency**.

---

## Audit Files  

| File | Author / Role | Date | Summary |
|------|----------------|------|----------|
| **01_Audit_SagarDake_AUTNZ.pdf** | Dr Sagar Dake (PhD AUT NZ) | 04 Nov 2025 | Comprehensive Aiken/Plutus review – no critical issues. Serialization & nonce validation patched; multisig & commit–reveal scheduled for M3. |
| **02_Audit_Response_SagarDake.pdf** | Project Team Response | 06 Nov 2025 | Point-by-point mitigation summary confirming fixes and upgrade path. |
| **03_Audit_ChereseEriepa.pdf** | Cherese Eriepa (Software Engineer / Ops Lead) | 06 Nov 2025 | All unit tests passed; no vulnerabilities or leakage. Execution units within protocol limits (≤ 135 K mem / 51 M CPU). Minor comment clarity notes resolved. |

---

## Audit Summary  

- **Zero critical or major vulnerabilities.**  
- All contracts executed as intended under Aiken framework tests.  
- Serialization, nonce handling, and mint policy governance verified.  
- Reward, stake, and soulbound logic match the tokenomics specifications.  
- Execution unit usage well below Cardano limits.  
- Mitigation items scheduled for Milestone 3 (multisig mint policy and commit–reveal oracle pattern).  
- Audit trail and static analysis results available in this repository’s `/audit/` and `/docs/` folders.

---



