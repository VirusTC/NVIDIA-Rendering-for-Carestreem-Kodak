[SOP-03] Automated Anatomic Positioning & "First-Time-Right" Scanning

1\. Clinical Intent & Indications

To completely eliminate preventable diagnostic retakes caused by improper patient alignment, tilting, or incorrect vertical positioning within the scanner head or wall stand.

2\. Infrastructure Prerequisites

-   **Hardware:** In-room optical optical tracking camera system + NVIDIA RTX Pro 6000.
-   **Software:** NVIDIA Clara Holoscan/Edge AI suite integrated with Carestream acquisition software.

3\. Configuration Steps

```
[Peripherals] ➔ [Camera Calibration] ➔ [NVIDIA Clara Positioning Engine]

```

1.  Launch the **Carestream Acquisition Console**.
2.  Open **Hardware Connections** and verify that the **In-Room Tracking Camera** is reading a green "Connected" status.
3.  Go to **Settings** ➔ **AI Integration Modules** ➔ **NVIDIA Clara Position Assist**.
4.  Check the box to **Enable Live Patient Overlays**.
5.  Set **Pose Confidence Threshold** to **92%** (ensuring the system flags any deviation greater than 8%).
6.  Select **Save and Lock Configuration**.

4\. Clinical Execution & Operator Workflow

1.  Bring the patient into the scanning bay and guide them onto the positioning markers.
2.  Step out to the operator console. Look at the live preview window inside the CS software.
3.  The NVIDIA Clara AI will project a **Green or Red bounding wireframe** over the patient's anatomical landmarks (e.g., Frankfort plane, midsagittal line) on your screen.
4.  **Action Threshold:**
    -   If the overlay is **Green**, the patient is correctly positioned. Proceed immediately to fire the exposure.
    -   If the overlay is **Red**, look at the on-screen warning text (e.g., *"Patient head tilted 4° Left"*). Step back into the room, correct the patient's position until the overlay turns Green, then fire.
