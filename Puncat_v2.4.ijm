
/*
PUNCAT™ Macro v2.4
Zachary Pranske
Rev. 9/18/22

╦╦╦╦▄╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦
╦╦╦�?██▄╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦
╦╦╦╦█████╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦
╦╦╦╦╦╦▀███╦╦╦╦╦╦╦╦╦╦╦╦╦╦█▌╦╦╦�?█╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦██╦╦╦╦╦╦╦╦╦╦╦╦╦╦██▄▄▄██╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦�?██╦╦╦╦▄▄▄▄▄▄▄▄╦╦███████▄╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦███╦█████████████████████╦╦╦╦╦╦
╦╦╦╦╦╦╦╦╦██████████████████████▀╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦╦╦██████████████████╦╦╦╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦╦████████████████████╦╦╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦�?██▀████▀▀▀▀╦╦▀███╦███▄╦╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦�?█▌╦██▀╦╦╦╦╦╦╦╦╦██╦╦███▌╦╦╦╦╦╦╦
╦╦╦╦╦╦╦╦�?██╦███╦╦╦╦╦╦╦╦╦�?██╦╦╦█▌╦╦╦╦╦╦╦
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
*/

//CHANGE THE ROOT FILEPATH TO WHERE YOU WANT THE FILES SAVED
//MUST USE FORWARD SLASHES ///
path2save = "C:/Users/Zachary_Pranske/Desktop/ZP_03 pyramidal cell reanalysis 2022-09-29"
path2savedrawing = path2save + "/drawing"
path2savemeasure = path2save + "/measure"
path2savesummary = path2save + "/summary"

filen = getTitle();
run("Split Channels");
close();
close();

//These lines can be used to merge channels before drawing ROIs (e.g. to pick GFP+ cells with good staining around them)
strkeep = "c1=C2-" + filen + " c6=C1-" + filen + " create keep";
run("Merge Channels...", strkeep);

run("Enhance Contrast", "saturated=1.15");
run("Next Slice [>]");
run("Enhance Contrast", "saturated=1.15");
run("Previous Slice [<]");

n = getNumber("Enter number of cells:", 1);
//n = 5;

run("ROI Manager...");
roiManager("Show All");

c = 0;
for(i=0;i<n;i++) {
    setTool("freehand");
    waitForUser("Draw ROI, then hit OK");
    //user makes selections of cell ROI
    name_cell = "cell_";
    Roi.setName(name_cell+i);
    roiManager("Add");
    run("Make Band...", "band=1.03");
    name_band = "band_";
    Roi.setName(name_band+i);
    roiManager("Add");
    roiManager("Deselect");
    sn0 = 2*i;
    sn1 = 2*i+1;
    roiManager("Select", newArray(sn0,sn1));
    roiManager("Measure");
    c++;
}

n = c;

//save ROIs
saveAs("Results", path2savemeasure + "/Measure of " + filen + ".csv");
close("Results")

//Change this based on which channel is the puncta channel
selectWindow("C1-" + filen);

//subtract background
run("Subtract Background...", "rolling=20 sliding stack");
run("Enhance Contrast", "saturated=0.35");

//user select and set threshold for puncta channel
run("Threshold...");
setAutoThreshold("Default dark stack");
waitForUser("Select threshold manually (set first then click OK)");

//watershed resegmentation
run("Watershed", "stack");

//count puncta around ROIs
for(i=0;i<n;i++) {
    n_i = (i*2)+1;
     if(i>0) {
         selectWindow("C1-" + filen);
    }
    roiManager("Select", n_i);
    run("Analyze Particles...", "size=0.10-10.00 circularity=0.01-1.00 show=Outlines summarize stack");
}

close("ROI Manager")

//Save summary list
selectWindow("Summary of C1-" + filen);
saveAs("Results", path2savesummary + "/Summary of " + filen + ".csv");
run("Close")

//Save Mask
selectWindow("C1-" + filen);
saveAs("Tiff", path2savedrawing + "/C1-" + filen + ".tif");
run("Close")

//Save Drawings
for(i=0;i<n;i++) {
    selectWindow("Drawing of C1-" + filen);
    saveAs("Tiff", path2savedrawing + "/Drawing of C1-" + filen + "_" + (i+1) + ".tif");
}

run("Close")
run("Close")
run("Close")
run("Close")
run("Close")
run("Close")
