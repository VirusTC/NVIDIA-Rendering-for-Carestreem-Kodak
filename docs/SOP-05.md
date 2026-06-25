[SOP-05] Automated Multi-Image Stitching Setup

1\. Clinical Intent & Indications

To combine consecutive anatomical views (e.g., full-spine scoliosis panels or long-leg panorex measurements) into a mathematically continuous composite frame, completely removing manual alignment errors and stitch artifacts.

2\. Infrastructure Prerequisites

-   **Hardware:** NVIDIA RTX Pro 6000 Workstation.
-   **Software:** **CS Stitching Editor Module** v3.26.

3\. Configuration Steps

```
[Module Config] ➔ [Stitching Editor Settings] ➔ [GPU Pixel-Feature Tracking]

```

1.  In the CS Imaging Suite workspace, navigate to **Tools** ➔ **Module Configuration**.
2.  Select **Stitching Editor Pro**.
3.  Under the **Alignment Algorithm Properties**, change the selector from *Manual Overlay/Marker Assist* to **Automated GPU Pixel-Feature Tracking**.
4.  Set the **Feature Extraction Grid Denseness** to **High**.
5.  Enable the checkbox for **Anatomical Boundary Edge Blending**.
6.  Click **Save System Settings**.

4\. Clinical Execution & Operator Workflow

1.  Capture the individual overlapping image sequences using your standard multi-position acquisition hardware templates.
2.  Select the raw thumbnails in the patient repository timeline while holding down the `Ctrl` key.
3.  Right-click the highlighted files and choose **Launch Stitching Editor**.
4.  Click the **Auto-Stitch** command button.
5.  **Processing Assessment:** The NVIDIA RTX Pro 6000 will instantly analyze thousands of overlapping pixel patterns, automatically alignment-locking the plates and smoothing over exposure seams within < 1 second.
6.  Verify the anatomical alignment continuity along bone borders, then click **Commit Composite Image to Chart**.
