# Snapmaker Artisan Repeatable CNC Origin System
### For use with Fusion 360 CAM

This guide walks you through the usage of this repeatable CNC origin tool. It uses a 3D-printed rail fixture and a cheap Amazon Z-probe, along with a custom post-processor. It should help with quick starting jobs with known stock dimensions, doing bit swaps, and just giving better general confidence when using Fusion 360 for CAD and CAM.

**Required Files:**
* **Origin Tool & Rail Design:** [Thingiverse: Snapmaker Repeatable Origin Fixture](https://www.thingiverse.com/thing:7301429)
    * Download the F3D file and modify it in Fusion to fit your probe before printing.
* **Optional: Buzzer Probe Hardware:** [Thingiverse: Simple Buzzer Device](https://www.thingiverse.com/thing:7305460)
* **Custom Post-Processor:** [snapmaker_artisan_origin_tool_post_processor.cps](fusion_files/snapmaker_artisan_origin_tool_post_processor.cps)
    * This post-processing script adds moves to clear the probe and rail fixture before moving over the stock and coming down to make the first cuts.
    * It also makes sure to move to clearance height at the end of the job.
* **Snapmaker Artisan 200W CNC Machine Profile:** [SnapmakerArtisan200WCNC_MachineProfile.mch](fusion_files/SnapmakerArtisan200WCNC_MachineProfile.mch)


**Required Hardware:**
* **Origin Tool/Rail:** 3D printed using the F3D file linked above
* **M4 Bolts:** To attach the tool to the Artisan spoilboard
* **Z Probe:** Something similar to https://a.co/d/0c7wyIx8
* **Optional: Piezo Buzzer Components:** If making the standalone buzzer you will need the components described in the Simple Buzzer Device Thingiverse link above. Otherwise you can make do with a multi-meter with a continuity setting.

---

## 0. Print the Repeatable Origin Tool

1.  **Upload to Data Panel:** Download the F3D file from the Thingiverse link above, and import it into Fusion. Open the **Data Panel** (grid icon, top left). Click the **Upload** button. In the dialog, select the `RepeatableCNCOriginTool.f3d` file from your computer and click **Upload**. Wait for the status to show "Complete."
![Upload to Data Panel](images/0.1.0.png)
![Upload to Data Panel](images/0.1.1.png)

2. **Measure Probe Dimensions:** Assuming you purchased a Z-probe similar to this one: https://a.co/d/0c7wyIx8, measure the probe height and diameter using calipers.
3. **Update Parameters:** Open the user parameters in Fusion, and update the *ProbeHeight* and *ProbeDiameter* parameters to match your probe.
> Make a note here about the new XY alignment head once this is tested
![Change parameters](images/0.3.0.png)
![Change Parameters](images/0.3.1.png)
4. **3D Print the Tool:** Export the bodies as meshes/STLs, and print them on your 3D printer.
![](images/0.4.0.png)
> Make note on printing the XY tool once that is tested also


## 1. Physical Setup: Mounting and Anchoring the Rail

1.  **Grid Alignment:** The Snapmaker spoil board has a **50mm grid** of threaded M4 sockets. (there are not holes every 50mm but they are in multiples of 50mm) The mounting holes on the 3D-printed arms are spaced every 50mm to match this layout.
2.  **Primary Anchor:** Fasten the corner hole of the origin tool with the **(50mm, 50mm)** screw hole on your spoil board.
3.  **Securing:** Insert **M4 screws** through the fixture and into the spoil board sockets where you can. 

![Rail Bolted To Spoilboard](images/1.0.jpeg)

---

## 2. Fusion 360 Design Workflow

### A. Importing the F3D Fixture

1.  **Check Design Mode:** Open your project design. If it is currently a "Part" design, right-click the top-level name in the Browser and select **Switch to Hybrid Design**. This is required to see the assembly and "Insert Component" commands.
![Switch to Hybrid Design](images/2.A.1.0.png)
![Switch to Hybrid Design](images/2.A.1.1.png)
![Switch to Hybrid Design](images/2.A.1.2.png)

2.  **Insert Component:** Go to the **Insert** menu in the top toolbar and select **Insert Component** (or search for it in the search window you can bring up with the 'S' hotkey). Navigate to the location in your Fusion 360 cloud project where you just uploaded the fixture and select it.
![Insert Component](images/2.A.2.0.png)
![Insert Component](images/2.A.2.1.png)
![Insert Component](images/2.A.2.2.png)

### B. Modeling the Stock and Alignment
1.  **Create Stock Component:** Create a new component named "Stock". Sketch and extrude a box. You can set it to the exact dimensions of your physical stock material or something that encompasses your design.
![Create Stock Component](images/2.B.1.0.png)
![Create Stock Component](images/2.B.1.1.png)
![Create Stock Component](images/2.B.1.2.png)

2.  **Align Stock to Origin Tool:** Use the **Joint** tool ($J$) to align the bottom-left corner of your "Stock" component to the inner corner of the `RepeatableCNCOriginTool`. There is a Construction point there you can use for alignment.
![Align Stock to Origin Tool](images/2.B.2.0.gif)

3.  **Align Design within the Stock:** Use the **Align**, **Joint**, or move tool to position your actual part design inside the Stock component. It may be helpful to change the opacity of the Stock component.
![Align Design within the Stock](images/2.B.3.0.gif)


---

## 3. Manufacturing Workspace & Post-Processing

### A. The Setup Tab (Machine, Fixture, & WCS)
1.  **New Setup:** Switch to the **Manufacture** workspace and click **New Setup**.
![New Setup](images/3.A.1.0.png)
![New Setup](images/3.A.1.1.png)

2.  **Machine & Post-Processor:** Click **Select** next to Machine. Choose the **Snapmaker Artisan**. Keep the operation type as **Milling**.
    * *Note: If you haven't set up the Artisan as a machine yet, you can download the machine profile in this repo in the fusion_files directory and import it.*
    * *Tip: You can edit the machine profile to use the snapmaker_artisan_origin_tool_post_processor.cps by default as its post-processor.*
![Machine & Post-Processor](images/3.A.2.0.png)
![Machine & Post-Processor](images/3.A.2.1.png)

3.  **Fixture Selection:** While still in the **Setup** tab, enable the **Fixture** checkbox and select all bodies within the `RepeatableCNCOriginTool` component.
    * **Fixture Clearance:** Set **Radial Clearance** and **Axial Clearance** (recommended: 5mm). This ensures the toolpath stays a safe distance from the printed plastic.
![Fixture Selection](images/3.A.3.0.png)
![Fixture Selection](images/3.A.3.1.png)

4.  **WCS Origin:** Still in the **Setup** tab, set the **Origin** to **Selected Point**. Select the **construction point** at the top center of the probe puck inside the origin tool component.
![WCS Origin](images/3.A.4.0.png)
![WCS Origin](images/3.A.4.1.png)

5. **Select Model:** While in the **Setup** tab, in the **Model** section, click **Select** and select the design you want to cut (within the **Stock** component)

![Select Model](images/3.A.5.0.png)

6.  **Stock from Solid:** Switch to the **Stock** tab. Change Mode to **From Solid** and select the "Stock" component you modeled in Section 2. Select **OK** when done.
![Stock from Solid](images/3.A.6.0.png)
![Stock from Solid](images/3.A.6.1.png)

### B. Programming Toolpaths & Post-Processing
1.  **Operation Setup:** Choose your toolpath strategy (e.g., Adaptive Clearing, 2D Pocket, etc.). Select your **Tool** and **Geometry**.
![Operation Setup](images/3.B.1.0.png)
![Operation Setup](images/3.B.1.1.png)

2.  **Heights Tab (CRITICAL):** * **Clearance Height:** Set to at least **10mm** from **WCS Origin**. 
    * *Reasoning:* For example, if $Z0$ is at the top of a 20mm puck, a 10mm clearance ensures the bit moves at 30mm absolute height, safely clearing any rails.
    * **Retract Height:** Set relative to **Stock Top**. Ensure it is some positive value to clear the stock between tool moves.
    * *Note:* You can check the clearance height clears the probe height by looking at the red line that appears while in the Heights tab.

![Heights Tab](images/3.B.2.0.png)
![Heights Tab](images/3.B.2.1.png)

> *Note:* At this point, you can simulate the job to see if it looks correct.

![Heights Tab](images/3.B.2.2.gif)

3.  **Generate G-Code:** Right-click the toolpath and select **Post Process**. If you linked the GitHub script to your machine in Step 2, it will already be selected. If you haven't, make sure you select the post-processing script from this repo. Click **Post** to save your `.cnc` file to a USB drive.
![Generate G-Code](images/3.B.3.0.png)
![Generate G-Code](images/3.B.3.1.png)
![Generate G-Code](images/3.B.3.2.png)
![Generate G-Code](images/3.B.3.3.png)
![Generate G-Code](images/3.B.3.4.png)

---

## 4. Physical Execution

1.  **Secure the Stock:** Place your physical material into the corner of the origin tool and secure it to the spoil board using your preferred clamps or tape.

![Attach Stock To Fixture](images/4.1.0.jpeg)

2.  **Load Job:** Insert the USB drive into the Artisan. Locate and select your `.cnc` file. 
3.  **Set Work Origin:** Once the job initializes, the Artisan will prompt you to set the work origin. 
    * Slide the **sensor puck** into the circular holster. 
    * Connect the probe alligator clip to the CNC bit.
    * If using a buzzer or multimeter, connect it (see the optional buzzer linked at Thingiverse above)

![Slide Sensor Puck into Holster](images/4.3.0.jpeg)
![Connect Alligator Clip to CNC Bit](images/4.3.1.jpeg)
![Connect Buzzer to Probe](images/4.3.2.jpeg)
![Connect Buzzer to Probe](images/4.3.3.jpeg)


4.  **Find Zero:** Jog the Z-axis down slowly until the buzzer triggers. (See the [Buzzer Design Link] for circuit details). Set **Z-Zero** and **X/Y Zero** (center of puck) on the controller.
> **[VIDEO PLACEHOLDER: Video of the physical probing step: the bit touching the puck in the holster with the buzzer clip attached and the buzzer sounding.]**

> **NOTE: The fixture may be updated soon to include a different mechanism for X/Y zeroing. Currently it is just done by eye.**

5.  **Run:** Slide the probe puck out of the holster, disconnect the clip, close the machine doors, and start the job. The post-processor will first lift the cutting head to the clearance height before moving toward the stock.
> **[VIDEO PLACEHOLDER: Video of the job running]**