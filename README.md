# NVIDIA-Rendering-for-Carestream-Kodak

An enterprise-grade infrastructure optimization framework designed to force, manage, and audit local and virtualized hardware acceleration across medical imaging networks. This repository contains the complete deployment scripts, self-healing runtimes, network optimizations, and analytics tracking structures to route Carestream (CS) Imaging Suite 3.26 processing pipelines directly through dedicated NVIDIA GPU hardware pipelines.

---

## 🛠️ Repository Architecture

This repository is organized into distinct functional layers to facilitate deployment by Hospital IT and Clinical Engineering teams:

├── .github/workflows/\
│ └── psscriptanalyzer-validation.yml # CI/CD Static Code Quality Analysis Pipeline\
├── dashboards/\
│ └── VirusTC-Compliance-Dashboard.html # Intranet Fleet Monitor & Analytics UI\
├── docs/\
│ ├── nvidia-rtx6000-csimaging.md # Core Workstation HW Acceleration Mapping\
│ ├── IT-NVIDIA-NVML-Workstation.md # Low-Level VRAM Allocation & Monitoring\
│ ├── IT-Citrix-vGPU-Carestream.md # Datacenter Hypervisor & vGPU Provisioning\
│ ├── IT-Network-DICOM-QoS.md # 9000 MTU Jumbo Frames & QoS Mapping Policies\
│ ├── GIT-Version-Control-Strategy.md # Trunk-Based Change-Control Workflow\
│ └── TUF-[01-05]-Endpoint-Profiles.md # Multi-Method Remote Office Viewport Guidelines\
└── scripts/\
├── Citrix-TUF-Endpoint-Opt.ps1 # Master PVS/MCS Image Optimization Script\
├── VirusTC-SelfHealing-Auditor.ps1 # Active GPO Startup Compliance Auditor & Repair Loop\
├── VirusTC-Monthly-Report-Gen.ps1 # Automated 30-Day Executive KPI Compiler\
├── VirusTC-Monthly-Email-Sub.ps1 # CIO Office HTML Automated Delivery Engine\
├── VirusTC-API-Listener.ps1 # Centralized REST Web API Handshake Listener\
└── VirusTC-Endpoint-Scrub.ps1 # Secure Decommissioning Vault-Wiping Tool

## 📈 Operational Framework Overview

The architecture divides hospital endpoints into two primary functional categories, providing specialized optimizations for each:

### 1. Central Server / Acquisition Nodes (NVIDIA RTX Pro 6000)
Forces the offloading of raw mathematical transformations from the central CPU to dedicated GPU pipelines. This optimizes high-tier clinical processing functions:
* **Ultra-Low-Dose AI Denoising:** Utilizes specialized Tensor Cores to scrub quantum mottle, enabling up to a 40% reduction in patient exposure (kVp/mAs).
* **3D CBCT Iterative Reconstruction:** Employs CUDA Multi-Pass Iterative loops to eliminate beam hardening and metal streak artifacts.
* **Clinical Modules Acceleration:** Drives Carestream Eclipse AI extensions including Automated Bone Suppression, Virtual SmartGrid math, and Enhanced Tube/Line Visualization.

### 2. Remote Office / Endpoints (ASUS TUF GeForce RTX 50 Series)
Optimizes client machines that lack direct physical tethers to X-ray machines. These office endpoints process heavy graphical streams pushed from the datacenter over a virtualized architecture:
* **Hardware Decoding Offload:** Forces the endpoint NVDEC hardware chip to decompress incoming Citrix HDX bitstreams, preserving 4:4:4 Chroma Subsampling for crisp grayscale transitions.
* **Industrial-Grade Reliability:** Leverages over-engineered hardware properties (military-grade 20K capacitors and dual ball bearing fans) to maintain a zero-throttling display state.

## 🎛️ Carestream VuePACS & DryView 5950 Calibration Matrix

To prevent visual drift between the on-screen NVIDIA hardware acceleration rendering pipeline and physical print media outputs, clinical networks must implement rule-based media sorting profiles.

### 1. DICOM Routing Rules & Tray Allocation
Configure the Carestream VuePACS Print Client Engine (SOP Class UID `1.2.840.10008.5.1.1.18`) to separate output workflows:
* **Tray 1 (Baseline)**: Routes standard print payloads to **Blue Base DryView Laser Imaging Film (DVB)**.
* **Tray 2 (Premium)**: Routes insurance/patient-paid visual upgrades to **Clear Base Film** cartridges for maximum back-lit density on clinical light-boards.
* **Automation Hook**: Sorting rules trigger dynamically when matching the custom billing macro identifier string: `Premium_Clear_Sheet`.

### 2. FDA-Compliant Adobe Look-Up Table (LUT) Calibration
To preserve Adobe-layered vector transparency profiles and match Grayscale Standard Display Function (GSDF) limits:
* **Clear Base Profile**: Force a rigid minimum density limit of `Dmin = 0.20` to prevent background clouding under intense light-board illumination.
* **Blue Base Profile**: Force a rigid maximum density limit of `Dmax = 3.20` to ensure deep, clean black clipping boundaries.
* **Interpolation**: Enforce the `Linear Interpolation Curve` inside the DryView Web Portal console.

---

## 🚦 End-to-End Infrastructure Deployment Sequence (Updated)

The updated infrastructure deployment progression must follow this strict sequence:

[1. Hypervisor / Network Setup]

➔ [2. Master PVS/MCS Image Build (Citrix-TUF-Endpoint-Opt.ps1)]

➔ [3. Standalone Hardware Provisioning (Local-TUF-Endpoint-Opt.ps1)]

➔ [4. API Listener Node Deploy]

➔ [5. Active Directory GPO & WMI Target Configuration]

---

## 🚦 End-to-End Infrastructure Deployment Sequence

To implement this optimization framework within a production hospital network, engineers should execute the setup steps in the following order:
[1. Hypervisor / Network Setup] ➔ [2. Master PVS/MCS Image Build] ➔ [3. API Listener Node Deploy] ➔ [4. AD GPO Configuration]

### Step 3: Standalone Hardware Provisioning (Non-Citrix Local Endpoints)
For physical workspace environments equipped with dedicated **ASUS TUF Gaming GeForce RTX 50 Series** hardware components:

1. Execute `scripts/Local-TUF-Endpoint-Opt.ps1` locally or via startup automation.
2. This script enforces high-performance power configurations, sets an FDA-stabilized Windows TdrDelay (`10 seconds`), pins the Carestream Vue app layer exclusively onto local NVDEC hardware bitstream decoders, and executes an automated post-deployment cleanup cycle to clear scratch files and memory logs.
3. Hook the REST function to point payloads directly back to your secure `VirusTC-API-Listener.ps1` pipeline over port `8443`.

### Step 5: Active Directory GPO & WMI Target Configuration
1. Group Policy Objects deploying local execution scripts must link the following scoping filter to prevent execution on unapproved virtual endpoints:
   ```sql
   SELECT * FROM Win32_VideoController WHERE Name LIKE "%NVIDIA%" OR Name LIKE "%ASUS%"
   ```
2. Import `NvidiaCarestreamStabilization.admx` into your Active Directory Central Store to enforce state baseline evaluations over GPO intervals.

### Step 1: Hypervisor and Network Core Configuration
1. Open your datacenter core and edge switches. Enable **Jumbo Frames** with an MTU ceiling of **9000 bytes** across all imaging VLANs.
2. In your hypervisor console (e.g., VMware vSphere), map your distributed switch MTU to **9000**. Attach your physical RTX Pro 6000 hardware units to the virtual machines via a dedicated **Q-Profile (Virtual Workstation)** tier (`NVIDIA-RTX-PRO-6000-12Q` or `24Q`).
3. Enforce **100% Locked Memory Reservation** on the guest VMs. CUDA processing will remain disabled inside a virtual instance if memory overcommitment is permitted.

### Step 2: Build the Golden Master Image
1. Boot the target Master Image VM in Private/Maintenance mode.
2. Ensure the official **NVIDIA Enterprise Production Branch Driver** (for servers) or the **NVIDIA Studio Driver** (for office endpoints) is integrated.
3. Stage the secure automation credentials inside the local Data Protection API (DPAPI) vault by running:
   ```powershell
   cmdkey /generic:"VirusTC-API-Handshake" /user:"SystemNode" /pass:"YOUR_SECURE_CLUSTER_TOKEN"
   ```
4. Execute `scripts/Citrix-TUF-Endpoint-Optimization.ps1` to apply the required registry overrides and system performance profiles. Shut down and seal the image.

### Step 3: Deploy the Central API Listener & Dashboard
1. Place `dashboards/VirusTC-Compliance-Dashboard.html` within the document root folder (`C:\inetpub\wwwroot\`) of an internal administrative IIS web server.
2. Configure a secure SSL binding certificate on port **8443**.
3. Launch `scripts/VirusTC-API-Listener.ps1` as a continuous background system service on that host to process inbound node tracking payloads.

### Step 4: Configure Active Directory Group Policy (GPO)
1. Link a new Group Policy Object to the Organizational Unit (OU) containing your diagnostic workstations.
2. Route to: `Computer Configuration` ➔ `Policies` ➔ `Windows Settings` ➔ `Scripts (Startup/Shutdown)`.
3. Add `scripts/VirusTC-SelfHealing-Auditor.ps1` as a **Computer Startup Script**. It must run in the computer context (`NT AUTHORITY\SYSTEM`) to ensure it has the administrative privileges required to repair network policies and rewrite `HKLM` registry paths.
4. Schedule `scripts/VirusTC-Monthly-Report-Generator.ps1` and `scripts/VirusTC-Monthly-Email-Subscription.ps1` on an administrative management host to deliver regular performance metrics directly to the hospital's Chief Information Officer (CIO).

---

## 🔒 Version Control and Verification Policy
All updates to the scripts or configurations in this repository must comply with the `docs/GIT-Version-Control-Strategy.md` protocol. Direct commits to the `main` branch are blocked. 

Changes must be developed in a short-lived `feature/*` branch, clear the automated testing pipeline (`.github/workflows/psscriptanalyzer-validation.yml`), and undergo verification in an isolated `staging` lab environment before a pull request can be merged into production.

---
**Disclaimer:** This framework is an optimization architecture designed for integration by certified Healthcare IT and Clinical Systems Engineering teams. Verify all rendering states in a test lab before modifying live diagnostic software.
