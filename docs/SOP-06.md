[SOP-06] Automated Bone Suppression & Soft-Tissue Companion Rendering

1\. Clinical Intent & Indications

To automatically isolate and suppress overriding osseous structures (specifically posterior ribs and clavicles) in digital chest radiographs. This generates a secondary companion image to improve the early detection, segmentation, and visualization of subtle lung nodules, pneumothorax boundaries, and line placements without subjecting the patient to a multi-exposure CT scan or additional radiation dose.

2\. Infrastructure Prerequisites

-   **Hardware:** Local workstation utilizing the NVIDIA RTX Pro 6000 (connected via PCIe 16x slot).
-   **Software:** Carestream Image Suite (v3.26/v4) with **ImageView Bone Suppression Software license active**.

3\. Configuration Steps

```
[Image Delivery] ➔ [Companion View Profiles] ➔ [Enable AI Osseous Suppression]

```

1.  Open **CS Image Suite Admin Panel** and navigate to **Preferences** ➔ **Image Presentation**.
2.  Select **Chest Radiography AP/PA Template**.
3.  Toggle the option labeled **"Generate Automated Bone Suppression Companion Image"** to **Enabled**.
4.  Set the **GPU Pipeline Processing Option** to **Tensor Cores (FP16 Accelerated Mode)** to reduce compilation latency.
5.  In the **Routing Matrix**, check the box to **"Automatically append companion image to PACS study folder"**.
6.  Click **Save Configuration**.

4\. Clinical Execution & Operator Workflow

1.  Execute a standard chest X-ray acquisition sequence.
2.  Once the raw exposure displays on the console, the NVIDIA GPU will simultaneously split the dataset into two processing pathways.
3.  **Image Verification Panel:**
    -   **View 1 (Primary):** Standard diagnostic chest X-ray displaying fully visible skeletal structures.
    -   **View 2 (Companion):** The AI-suppressed soft-tissue layer, leaving lung fields unobstructed by bone shadows.
4.  The operator can use the spacebar or dedicated toggle switch to flip between the views instantly before approving final transmission to the radiologist reading station.
