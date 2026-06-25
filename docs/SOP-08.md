[SOP-08] Automated Tube and Line Visualization Enhancement

1\. Clinical Intent & Indications

To accelerate the clinical verification of critical bedside placements (including peripherally inserted central catheters [PICC lines], endotracheal tubes, nasogastric tubes, and chest tubes). The local GPU enhances the pixel contrast of foreign metallic/plastic lines while selectively muting high-frequency background tissue structures.

2\. Infrastructure Prerequisites

-   **Hardware:** Station configured with an NVIDIA RTX Pro 6000 GPU.
-   **Software:** Carestream **Enhanced Tube and Line Visualization Software Module**.

3\. Configuration Steps

```
[Viewer Layouts] ➔ [Enhancement Overlays] ➔ [Dynamic Tube/Line Highlighting]

```

1.  Open the Carestream workspace view options menu.
2.  Go to **Settings** ➔ **Display Preferences** ➔ **Specialized Filters**.
3.  Locate **Tube & Line Visualization**.
4.  Set the default display properties to **"Generate Companion View Side-by-Side"**.
5.  Adjust the edge-enhancement weight slider to **75%** to emphasize narrow guidewires and thin catheter borders.
6.  Select **Apply** and close the admin window.

4\. Clinical Execution & Operator Workflow

1.  Complete the chest or abdominal X-ray capture following tube placement or adjustment.
2.  Upon immediate display, review the **dual-pane view layout**:
    -   The left pane displays standard diagnostic tissue density.
    -   The right pane applies a dedicated filter that clearly tracks the path and terminal tip position of all medical tubing.
3.  Ensure the catheter tip location is plainly visible and does not conflict with adjacent critical structures before marking the study as complete for urgent ICU attending physician review.
