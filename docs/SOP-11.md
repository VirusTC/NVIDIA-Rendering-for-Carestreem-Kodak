[SOP-11] MONAI Deploy: Zero-Click Automated Quality Assurance (QA) Reject Analysis

1\. Clinical Intent & Indications

To instantly evaluate every captured X-ray for clinical quality (motion blur, contrast degradation, and artifact presence) before transmission to PACS, preventing unapproved or degraded images from reaching the radiologist's queue.

2\. Infrastructure Prerequisites

-   **Hardware:** Centralized VDI host or local edge-node running an NVIDIA RTX Pro 6000.
-   **Software:** **MONAI Deploy Application Package (MAP)** integrated via DICOM C-STORE. [[1](https://blogs.nvidia.com/blog/monai-deploy-framework-medical-imaging-ai-apps/)]

3\. Configuration Steps

```
[PACS Forwarding] ➔ [Routing Node Override] ➔ [MONAI QA Filter (Local GPU)]

```

1.  Access the **Carestream Connectivity Dashboard**.
2.  Select **PACS Destination Routing**.
3.  Insert a proxy routing hop: point the primary destination to the **Local MONAI Deploy Container Network Instance** running on port `104` or `11112`.
4.  Open the MONAI control file and set the `qa_threshold_metric` to **0.88** (rejecting any frame scoring below 88% structural confidence).
5.  Target execution explicitly to the **RTX Pro 6000 CUDA Runtime**.
6.  Select **Apply and Restart Routing Services**. [[1](https://github.com/Project-MONAI/monai-deploy/blob/main/guidelines/MONAI-Operating-Environments.md)]

4\. Clinical Execution & Operator Workflow

1.  Execute the radiographic exposure normally.
2.  Once finalized, the software automatically routes the dataset through the local MONAI pipeline. [[1](https://blogs.nvidia.com/blog/monai-deploy-framework-medical-imaging-ai-apps/)]
3.  **Automated Interception Workflow:**
    -   If the study **Passes QA**, it is forwarded to PACS silently without human intervention.
    -   If the study **Fails QA** (e.g., patient movement blurred the lung markings), a red notification banner pops up at the technologist's desk reading: `[ALERT: Motion Blur Detected - QA Score 72%]`.
4.  The technologist can adjust patient positioning immediately and repeat the exposure while the patient is still on the exam table.
