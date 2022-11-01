
/*
PUNCAT™ Macro v3.0
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
across multiple Z-stacks by default (although this is done in the Puncat Pipeline) or colocalize different 
puncta channels.

    0. Within your analysis folder, create 3 folders called "drawing", "measure", "summary", and "rois (no caps)
    1. Set path where you want to save your files ("path2save" in first line below instructions) and
	   set radius around ROIs to look at (by default, band=1.00 um)
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

// CHECK THESE PARAMETERS BEFORE RUNNING

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// NOTE: Root filepath must use forward slashes

path2save = "C:/Users/Zachary_Pranske/Desktop/ZP_03 pyramidal cell reanalysis 2022-10-31"
path2savedrawing = path2save + "/drawing"
path2savemeasure = path2save + "/measure"
path2savesummary = path2save + "/summary"
path2saverois = path2save + "/rois"

band_width = 1.00
punctachannel = "C1-"
otherchannel = "C2-"
minthreshold = 500 			//Adjust for each round of imaging
maxthreshold = 10000000000 	//Don't change

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

filen = getTitle();
run("Split Channels");
close();
close();

//These lines can be used to merge channels before drawing ROIs (e.g. to pick GFP+ cells with good staining around them)
strkeep = "c1=" + otherchannel + filen + " c6=" + punctachannel + filen + " create keep";
run("Merge Channels...", strkeep);

//CONTRAST BOOST IMAGES TO BE ANALYZED
run("Enhance Contrast", "saturated=1.15");
run("Next Slice [>]");
run("Enhance Contrast", "saturated=1.15");
run("Previous Slice [<]");

//GET NUMBER OF CELLS, OPEN ROI MANAGER, DRAW AND MEASURE ROIS
n = getNumber("Enter number of cells:", 1);
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
    run("Make Band...", "band=" + band_width);
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

//SAVE MEASUREMENTS OF CELL ROIS
selectWindow("Results");
saveAs("Results", path2savemeasure + "/Measure of " + filen + ".csv");
close("Results")

//SAVE CELL ROIS AS ROI FILES
roiManager("Select All");
roiManager("Save", path2saverois + "/RoiSet_" + filen + ".zip");

//SUBTRACT BACKGROUND
selectWindow("Composite");
run("Subtract Background...", "rolling=50");
run("Enhance Contrast", "saturated=0.35");

//THIS IS THE BACKUP FOR QUANTIFYING PUNCTA INTENSITY LATER
//DO WE WANT TO QUANTIFY ON THE SUBTRACTED IMAGE OR NOT??? CURRENT = YES

selectWindow(punctachannel + filen);
run("Duplicate...", "title=Puncta-Subtracted");
saveAs("Tiff", path2savedrawing + "/" + punctachannel + "Puncta-Subtracted " + filen + ".tif");
run("Enhance Contrast", "saturated=0.35");

//MANUAL USER SELECT THRESHOLD FOR FILE (DEPRECATED)
//selectWindow(punctachannel + filen);
//run("Threshold...");
//setAutoThreshold("Default dark stack");
//waitForUser("Select threshold manually (set first then click OK)");

//THRESHOLD BY PREDEFINED MIN AND MAX
selectWindow(punctachannel + filen);
setThreshold(minthreshold, maxthreshold);

//CREATE AND SAVE BINARY MASK FROM THRESHOLDED IMAGE
selectWindow(punctachannel + filen);
run("Convert to Mask"); 
saveAs("Tiff", path2savedrawing + "/" + punctachannel + filen + ".tif");

//WATERSHED RESEGMENTATION OF PUNCTA IN MASK
run("Watershed", "stack");

//COUNT PUNCTA AROUND ROIS USING ANALYZE PARTICLES
for(i=0;i<n;i++) {
    n_i = (i*2)+1;
     if(i>0) {
         selectWindow(punctachannel + filen + ".tif");
    }
    roiManager("Select", n_i);
    run("Analyze Particles...", "size=0.10-10.00 circularity=0.01-1.00 show=Outlines summarize stack add");
}

//RENAME PUNCTA ROIS FOR MEASUREMENT AND SAVING
first_roi = i*2;
roi_no_in_drawing=1;
for(i=first_roi;i<RoiManager.size;i++){
    roiManager("Select", i);
    roiManager("Rename", "puncta_" + roi_no_in_drawing);
    roiManager("Measure");
    roi_no_in_drawing++;
}

//SAVE PUNCTA ROIS AS ROI SET
//FIRST DELETE CELL ROIS (They are already saved and we don't want them in our puncta ROIset)
first_roi = c*2;
for(i=0;i<first_roi;i++){
    roiManager("Select", 0);
    roiManager("Delete");
}

//SAVE MEASUREMENTS OF PUNCTA ROIs
//NOTE: The window selected below is the image you want to overlay puncta ROIs and calculate intensity from

selectWindow(punctachannel + "Puncta-Subtracted " + filen + ".tif")
roiManager("Select All");
roiManager("Measure");
selectWindow("Results");
saveAs("Results", path2savemeasure + "/ROIs from " + filen + ".csv");
close("Results")

//SAVE PUNCTA AS ROIS AS ROI SET
roiManager("Select All");
roiManager("Save", path2saverois + "/PunctaSet_" + filen + ".zip");
close("ROI Manager")

//SAVE SUMMARY LIST
selectWindow("Summary of " + punctachannel + filen + ".tif");
saveAs("Results", path2savesummary + "/Summary of " + filen + ".csv");
run("Close")

//SAVE DRAWINGS
for(i=0;i<n;i++) {
    selectWindow("Drawing of " + punctachannel + filen + ".tif");
    saveAs("Tiff", path2savedrawing + "/Puncta " + punctachannel + filen + "_" + (i+1) + ".tif");
}

//CLOSE REMAINING OPEN WINDOWS
close(punctachannel + filen + ".czi.tif")
close(punctachannel + filen + "_1.czi.tif")
close(otherchannel + filen + "_1.czi")
close(punctachannel + "Puncta-Subtracted " + filen + "_1.czi.tif")
close("Composite")

run("Close")
run("Close")
run("Close")
run("Close")
run("Close")
