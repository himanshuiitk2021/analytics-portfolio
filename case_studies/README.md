# Case studies

Three questions a marketplace product or ops team would ask, answered with SQL on the dbt marts.
Every number below comes from [`results/`](results), which `scripts/run_case_studies.py` regenerates from the `.sql` files.

---

## 1. How much does a late delivery cost us in reviews?
**SQL:** [`01_late_delivery_vs_reviews.sql`](01_late_delivery_vs_reviews.sql) · **Results:** [`results/01_late_delivery_vs_reviews.md`](results/01_late_delivery_vs_reviews.md)

**Finding: the promised date is the line customers judge you on, and the penalty starts on day one.**

| Delivered vs promise | Orders | Avg review | 1–2★ share |
|---|---|---|---|
| 7+ days early | 75,749 | 4.31 | 9.0% |
| On the promised day | 1,280 | 4.03 | 12.4% |
| 1–3 days late | 1,852 | 3.29 | 32.1% |
| 4–7 days late | 1,748 | 2.10 | 67.7% |
| 8+ days late | 2,782 | 1.70 | 79.3% |

- Only **6.7%** of delivered orders were late, but they average **2.27★ vs 4.29★** on time, and **62%** of them get a 1–2★ review (vs 9%).
- Even 1–3 days late more than triples the 1–2★ share. There is no grace period.
- Customers whose **first order arrived late came back slightly less often (2.64% vs 3.12%)**. That's directional, not causal: repeat rates are low across the board (see case 2).

**So what:** reviews here measure delivery reliability more than product quality. Two levers follow:
(1) fix the late tail at the source (see case 3: it clusters by month and region), and
(2) treat the estimated date as a product decision. Olist pads it heavily (75k orders arrived 7+ days early), which protects reviews but probably costs conversion at checkout. That trade-off is worth an experiment.

---

## 2. Do customers come back?
**SQL:** [`02_cohort_retention.sql`](02_cohort_retention.sql) · **Results:** [`results/02_cohort_retention.md`](results/02_cohort_retention.md)

**Finding: this is an acquisition business. Retention is close to zero, and it isn't driven by satisfaction.**

- **94,990** customers, of whom only **3.04%** ever placed a second order (1.03 orders per customer).
- Monthly cohorts retain **0.2–0.7%** in month 1 and **0.1–0.4%** by month 6. Bigger, later cohorts (Nov 2017 Black Friday onward) retain no better.
- **First-order review score barely moves repeat rate:** 1★ customers return at 2.99% and 5★ at 3.18%. Making a happy customer is not, on its own, a retention strategy here.
- **Category matters more than satisfaction:** customers whose first order was fashion bags & accessories (5.9%), furniture & decor (4.5%) or bed/bath/table (4.5%) return roughly 1.5–2× more than health & beauty or perfumery (~2.8%).

**So what:** re-engagement budget is better aimed by **category** (home and fashion buyers) than by satisfaction score. And growth models should assume near-zero organic repeat, so CAC payback has to work on the first order.

---

## 3. Where does fulfilment break?
**SQL:** [`03_fulfilment_ops.sql`](03_fulfilment_ops.sql) · **Results:** [`results/03_fulfilment_ops.md`](results/03_fulfilment_ops.md)

**Finding: delivery time sits with the carrier, and lateness spikes at peak months and in the North/Northeast.**

- **Funnel:** 99,441 orders placed → 97.0% delivered. Approval is near-instant (median **1h**), sellers take **~44h** to hand over to the carrier, and the carrier leg is **~170h** of the ~245h total, about 70% of the wait.
- **Seasonality:** late rate jumps from ~3% to **12.4% in Nov 2017** (Black Friday), **14.1% in Feb 2018** and **19.0% in Mar 2018**, and average reviews drop with it (4.3 → 3.8). Capacity, not process, is the constraint.
- **Geography:** Maranhão (**17.4%** late, 21.5 days), Ceará (13.8%), Bahia (12.2%) and Rio de Janeiro (12.1%, on 12k orders) are the worst. RJ stands out because it is close to the seller base in São Paulo, so its delays point to last-mile capacity rather than distance.
- **Seller concentration:** the top **1%** of 3,053 sellers drive **25%** of GMV, and the top **20%** drive **82%**. A handful of seller relationships carry the business.

**So what:** pre-book carrier capacity ahead of known peaks, set **region-specific promised dates** for the North/Northeast instead of one national buffer, investigate RJ last-mile separately, and give the top ~30 sellers dedicated ops support, since their SLA is effectively the platform's SLA.

---

### Method notes
- "Late" = delivered on a later calendar day than `order_estimated_delivery_date`; delivered orders only.
- Customers are deduplicated on `customer_unique_id` (Olist issues a new `customer_id` per order).
- Canceled and unavailable orders are excluded from customer, cohort and seller metrics.
- Payments differ from items + freight by more than R$1 on 1,021 orders (about 1%), flagged by a warn-level dbt test. GMV here is items + freight.
