PUNCAT™ Macro v3.0
Zachary Pranske
Rev. 11/02/2022

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

Notes: This code is designed to quantify synaptic puncta in a given radius around a hand-drawn cell. 
It relies on a somewhat arbitrary method of setting a single linear threshold of detection and then applying
a watershed resegmentation algorithm to the resulting particles. It does NOT quantify puncta 
across multiple Z-stacks by default (although you may do this manually) or colocalize different 
puncta channels.

    0. Within your analysis folder, create 3 folders called "drawing", "measure", "summary", and "rois" (no caps).
    1. Set path where you want to save your files ("path2save" in first line below instructions) and
	   set radius around ROIs to look at (by default, band=1.00 um).
    2. Download and save Puncat_v3.0.ijm macro from this repo.
    3. Open image as tiff stack using BioFormats importer plugin (do NOT split channels using the
	   importer; this is done automatically by the macro).
    4. For each set of images, subtract background with same rolling ball radius as in macro; 
           use a few images to empirically determine threshold for each image set.
    5. Update the threshold in the macro.
    6. Run the macro and follow on screen prompts until done.
           Files containing info about ROIs and detected particles (puncta) are saved automatically.
    7. Repeat step 6 with all images in the dataset. Adjust the threshold for each new set of images.
    8. Create an Excel file with columns "Image#", "Condition", and "Region" and add decoding information.
    9. Run the Puncat Pipeline in Matlab R2020a or later. Remember to specify graphs and stats.
    10. Done! Puncat Pipeline should automatically process, collate, plot, and run stats on your dataset.
    
