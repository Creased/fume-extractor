# Soldering Fume Extraction System

This project provides a complete set of 3D printable adapters and components to build a custom, high-efficiency fume extractor and filtration system. It integrates a VIVOSUN inline fan, a MANN-FILTER cabin air filter, and a standard 2-1/2" flexible dust collection hose.

## Bill of Materials (BOM)

### Commercial Components

| Component | Amazon FR |
| :--- | :--- |
| **VIVOSUN Inline Duct Fan Kit** (100mm, 357m³/h, Speed Controller, Carbon Filter & 240cm Duct, AeroZesh T4) | [Link](https://www.amazon.fr/dp/B0CBPDTSKS) |
| **MANN-FILTER FP 21 000-2** Cabin Air Filter (150x158x32mm) | [Link](https://www.amazon.fr/dp/B011KJG19S) |
| **PowerTec 70208V** 2-1/4" Flexible Dust Collection Hose Kit (Black, 5.7cm) | [Link](https://www.amazon.fr/dp/B09T2B5ZM2) |
| **POWERTEC 70149-P2** 4-Inch Key Hose Clamps (2 Pack) | [Link](https://www.amazon.fr/dp/B09NR8172H) |

*Note: You do not need to buy the PowerTec nozzle separately, as a customized 3D printable rectangular nozzle is provided in this repository.*

### Hardware
* **M3 Screws & Threaded Inserts**: For assembling the filter box and adapters. [Bolt Nut BT3 on AliExpress](https://fr.aliexpress.com/item/1005007615031481.html) (Requires M3x14mm Socket Head Cap Screws and M3x5mm Threaded Inserts with 4.16mm OD).

### 3D Printed Parts

The system requires the following 3D printed components:

1. **Duct Adapters** (`duct_adapter_direct.scad` & `duct_adapter.scad`)
   - **Quantity**: 2
   - **Usage**: You will generally use two **direct** variants (`duct_adapter_direct.scad`). The first adapter connects directly to the inline fan. The second adapter connects the filter box to the duct reducer. (Note: use the **threaded** variant `duct_adapter.scad` only if you wish to detach the pre-filter box from the fan and add a flexible duct section in between them).
   - Both adapters clamp around the filter box flanges using the split capture rings, providing a robust surface for the flexible hose clamps.
2. **Duct Reducer** (`duct_reducer.scad`)
   - Steps down the dimension from the 4" (100mm) top adapter to the 2-1/2" flex hose.
3. **Rectangular Nozzle & Grid** (`rectangular_nozzle.scad`)
   - Replicates the PowerTec opening but features an integrated friction-fit anti-debris grid that stops large particles without catching soldering fumes.
4. **Inline Filter Box** (`inline_filter_box.scad`)
   - The central two-part housing for the MANN-FILTER FP 21 000-2.

## Assembly Instructions

> **Tip:** Open `assembly.scad` in OpenSCAD for an exploded 3D view of how all components stack together!

1. **Print**: 3D print all `.scad` components (exporting to STL/3MF).
2. **Filter Box**: Insert the MANN-FILTER into the inline filter box housing and secure the lid with M3 hardware.
3. **Adapters**: Attach the split capture ring halves behind the filter flanges, and bolt on the adapter sleeves over them.
4. **Main Connections**: Use the POWERTEC flex hose clamps to securely connect the adapters to the duct reducer (top) and the Vivosun inline fan (bottom).
5. **Hose & Nozzle**: Push the 2-1/2" flexible hose onto the top of the duct reducer. Attach the rectangular nozzle (with its grid insert pushed into the base) to the other end of the hose.
