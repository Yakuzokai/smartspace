---
title: "99 — Space Compatibility Math & Reference"
tags:
  - smartspace
  - reference
  - algorithm
  - geometry
  - math
created: 2026-09-12
---

# 📐 99 — Space Compatibility Math & Reference

Back to [[00 - Home|🏠 Documentation Hub]]  
See also: [[99 - Reference/SmartSpace - System Architecture & Implementation Plan|📄 Original System Architecture Specification]]

---

## 1. Mathematical Formulation of Compatibility Score

The Space Compatibility Engine calculates a deterministic score $S \in [0, 100]$:

$$S = S_{\text{boundary}} + S_{\text{clearance}} + S_{\text{collision}} + S_{\text{utilization}} + S_{\text{fitness}}$$

### Step 1: Boundary Fit ($S_{\text{boundary}} \in \{0, 30\}$)
For every placed furniture item $i \in \{1, \dots, N\}$, define its rotated Axis-Aligned Bounding Box (AABB) in floor coordinate space:
$$\text{AABB}_i = [x_{i,\min}, x_{i,\max}] \times [z_{i,\min}, z_{i,\max}]$$
Given room width $W$ and room length $L$:
$$\text{If } \exists i \text{ such that } x_{i,\min} < 0 \lor x_{i,\max} > W \lor z_{i,\min} < 0 \lor z_{i,\max} > L \implies S_{\text{boundary}} = 0 \text{ (Total Fail)}$$
$$\text{Otherwise, } S_{\text{boundary}} = 30$$

### Step 2: Overlap & Collision ($S_{\text{collision}} \in \{0, 25\}$)
For every pair of items $(i, j)$ with $i \neq j$:
$$\text{Overlap}(i, j) = (x_{i,\min} < x_{j,\max} \land x_{i,\max} > x_{j,\min}) \land (z_{i,\min} < z_{j,\max} \land z_{i,\max} > z_{j,\min})$$
$$\text{If } \exists (i, j) \text{ with Overlap}(i, j) = \text{True} \implies S_{\text{collision}} = 0 \text{ (Total Fail)}$$
$$\text{Otherwise, } S_{\text{collision}} = 25$$

### Step 3: Functional Clearance ($S_{\text{clearance}} \in [0, 25]$)
Evaluates front and side access gaps:
* Ideal Front Clearance: $c_{\text{front}} \ge 75\text{ cm}$.
* Ideal Side Clearance: $c_{\text{side}} \ge 60\text{ cm}$.
Clearance score scales proportionally to the worst clearance deficit.

### Step 4: Circulation & Space Utilization ($S_{\text{utilization}} \in [0, 10]$)
Let $A_{\text{room}} = W \times L$, and $A_{\text{furniture}} = \sum_{i=1}^N (w_i \times d_i)$.
$$\text{Walking Ratio } R_{\text{walk}} = \frac{A_{\text{room}} - A_{\text{furniture}}}{A_{\text{room}}}$$
* $R_{\text{walk}} \ge 0.50 \implies 10\text{ pts}$
* $0.40 \le R_{\text{walk}} < 0.50 \implies 8\text{ pts}$
* $0.30 \le R_{\text{walk}} < 0.40 \implies 5\text{ pts}$
* $R_{\text{walk}} < 0.20 \implies 0\text{ pts}$

### Step 5: Room Type Fitness ($S_{\text{fitness}} \in [0, 10]$)
Rewards appropriate furniture category matching for the designated room type (e.g., beds in bedrooms, desks in home offices).

---

## 2. Verdict Categorization

| Score Range | Badge | Verdict | Description |
|:---:|:---:|:---|:---|
| **90 – 100** | 🟢 | **Excellent Fit** | Perfect layout with generous walking clearances |
| **70 – 89** | 🟢 | **Good Fit** | Fits comfortably with standard clearance |
| **50 – 69** | 🟡 | **Limited Space** | Minor clearance pinch points; tight walking flow |
| **30 – 49** | 🟠 | **Tight Fit** | Cramped layout with restricted walking paths |
| **0 – 29** | 🔴 | **Does Not Fit** | Items collide or exceed physical room boundaries |
