PUNCAT™ Macro v2.4
Zachary Pranske
Rev. 9/18/22

╦╦╦╦▄╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦
╦╦╦▐██▄╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦
╦╦╦╦█████╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦
╦╦╦╦╦╦▀███╦╦╦╦╦╦╦╦╦╦╦╦╦╦█▌╦╦╦▐█╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦██╦╦╦╦╦╦╦╦╦╦╦╦╦╦██▄▄▄██╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦▐██╦╦╦╦▄▄▄▄▄▄▄▄╦╦███████▄╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦███╦█████████████████████╦╦╦╦╦╦
╦╦╦╦╦╦╦╦╦██████████████████████▀╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦╦╦██████████████████╦╦╦╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦╦████████████████████╦╦╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦▐██▀████▀▀▀▀╦╦▀███╦███▄╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦▐█▌╦██▀╦╦╦╦╦╦╦╦╦██╦╦███▌╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦▐██╦███╦╦╦╦╦╦╦╦╦▐██╦╦╦█▌╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦╦▀█▌╦██╦╦╦╦╦╦╦╦╦╦██╦╦╦▀╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦▀╦╦╦╦╦╦╦╦╦╦╦╦

INSTRUCTIONS TO USE

Notes: This code is designed to quantify synaptic puncta in a 1um radius around a cell. It relies on a
somewhat arbitrary method of setting a single linear threshold of detection and then applying
a watershed resegmentation algorithm to the resulting particles. It does NOT quantify puncta 
across multiple Z-stacks by default (although you may do this manually) or colocalize different 
puncta channels.

    0. Within your analysis folder, create 3 folders called "drawing", "measure", and "summary" (no caps)
    1. Set path where you want to save your files ("path2save" in first line below instructions) and
	   set radius around ROIs to look at (by default, band=1.03 um)
    2. Save this code as a .ijm macro
    3. Open image as tiff stack using BioFormats importer plugin (do NOT split channels using the
	   importer; this is done automatically by the macro)
    4. Run the macro
    5. Close all channels except the channel where you are drawing ROIs and the puncta channel
    6. Follow on screen prompts until done (remember to set threshold before proceeding)
    7. Files containing info about ROIs and detected particles (puncta) are saved automatically
    8. Save the binary mask and puncta outline images if desired (recommended)
    9. Done! Close all windows before opening new image
