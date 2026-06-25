[SOP-02] Accelerated 3D/CBCT Iterative Reconstruction Protocol

1\. Clinical Intent & Indications

To eliminate beam hardening, scatter shadows, and metal streak artifacts in high-density regions (e.g., dental implants, surgical hardware, dense bone structures) through high-speed iterative reconstruction mathematical loops.

2\. Infrastructure Prerequisites

-   **Hardware:** Workstation equipped with NVIDIA RTX Pro 6000 connected via PCIe Gen 4/5.
-   **Software:** CS 3D Imaging Software module (integrated with Suite 3.26).

3\. Configuration Steps

```
[3D Preferences] ➔ [Reconstruction Engine] ➔ [CUDA Multi-Pass Iterative]

```

1.  Open the **CS 3D Imaging Software** application.
2.  Select **Tools** from the top menu bar ➔ **Preferences** ➔ **Advanced Reconstruction Settings**.
3.  Locate the **Reconstruction Engine** options matrix.
4.  Change the processing method from *FDK (Feldkamp-Davis-Kress) Filtered Back-Projection* to **Multi-Pass Iterative Reconstruction (IR)**.
5.  Set the **Iteration Count Loop** to **5 Passes** (this maximizes artifact cleanup without bottlenecking pipeline speeds).
6.  Toggle **Scatter Correction Algorithm** to **On (GPU Accelerated)**.
7.  Click **Test Hardware Path**. Ensure a success status returns, confirming CUDA core binding. Click **Save**.

4\. Clinical Execution & Operator Workflow

1.  Execute the 3D/CBCT scan sequence normally.
2.  The software will process the raw projection frames automatically.
3.  **Quality Assurance Check:** Verify that the dense metal-to-bone margins do not exhibit radiating black/white streaks (blooming artifacts).
4.  If artifacts persist due to massive surgical hardware, manually toggle the viewer's **CS MAR (Metal Artifact Reduction)** slider to **High**, which routes extra compute cycles directly through the RTX 6000.
