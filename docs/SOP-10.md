[SOP-10] AI-Powered Automated Anatomical Cropping & Collimation

1\. Clinical Intent & Indications

To prevent excess radiation exposure to peripheral organs and standardize image framing. This module uses an edge-AI segmentation network to analyze a low-dose localizer scan (or initial camera feed) and automatically mask out non-diagnostic regions before final exposure compilation.

2\. Infrastructure Prerequisites

-   **Hardware:** Local NVIDIA RTX Pro 6000 Workstation.
-   **Software:** Carestream Image Suite v3.26 with **Smart Collimation / Anatomic Masking Extension**.

3\. Configuration Steps

```
[Modality Config] ➔ [Collimation Engine] ➔ [Enable NVIDIA TensorRT Auto-Crop]

```

1.  Open the Carestream Administration menu.
2.  Select **Modality Configuration** ➔ **Collimation and Masking Options**.
3.  Toggle the selection from *Manual/Fixed Cassette Constraints* to **NVIDIA TensorRT Auto-Crop Engine**.
4.  Set the **Anatomical Boundary Margin Padding** to **5mm** (this creates a safety cushion to prevent clipping critical margins).
5.  Ensure the **Inference Pipeline Backend** points to your local **RTX Pro 6000 Tensor Cores** to keep calculation latencies below 150 milliseconds.
6.  Click **Save Settings**.

4\. Clinical Execution & Operator Workflow

1.  Align the patient within the acquisition zone.
2.  Select the designated anatomical protocol on the operator display.
3.  Fire the initial tracking sequence.
4.  **On-Screen Verification:** The software will overlay a highlighted yellow bounding box outlining the detected target anatomy.
5.  If the bounding box accurately frames the diagnostic window, authorize the final capture. The system will automatically crop and suppress unneeded peripheral noise.
