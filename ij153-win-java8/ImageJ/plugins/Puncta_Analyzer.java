/*
 * #%L
 * Puncta Analyzer is an ImageJ plugin for detecting and quantifying punctate 
 * colocalization in multi-channel images.
 * %%
 * Copyright (C) 2012, Physion Consulting LLC All rights reserved.
 * %%
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are
 * those of the authors and should not be interpreted as representing official
 * policies, either expressed or implied, of any organization.
 * #L%
 */


import ij.IJ;
import ij.ImagePlus;
import ij.Prefs;
import ij.gui.GenericDialog;
import ij.gui.MessageDialog;
import ij.gui.Roi;
import ij.measure.Measurements;
import ij.measure.ResultsTable;
import ij.plugin.filter.ParticleAnalyzer;
import ij.plugin.filter.PlugInFilter;
import ij.process.ByteProcessor;
import ij.process.ColorProcessor;
import ij.process.ImageProcessor;
import java.awt.FileDialog;
import java.awt.Rectangle;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Vector;
import javax.swing.JOptionPane;
 
/**
 * Analyze's Puncta using ImageJ
 * 
 * @author Barry Wark
 */
public class Puncta_Analyzer implements PlugInFilter {
    
   public static final int RGB_RED_CHANNEL = 1;
   public static final int RGB_GREEN_CHANNEL = 2;
   public static final int RGB_BLUE_CHANNEL = 4;
   public static final int PUNCTA_RED_CHANNEL = 0;
   public static final int PUNCTA_GREEN_CHANNEL = 1;
   public static final int PUNCTA_BLUE_CHANNEL = 2;
   public static final int PUNCTA_COLOC = 3;
   static final String COLOC_RADIUS = "ap.colocRadius";
   static final String COLOR_CHANNELS = "ap.colorChannels";
   static final String PARTICLE_ANALYZER_OPTIONS = "ap.partAnalyzerOptions";
   static final String PARTICLE_ANALYZER_MEASUREMENTS = "ap.partAnalyzerMeasurements";
   static final String PARTICLE_ANALYZER_MIN_SIZE = "ap.partAnalyzerMinSize";
   static final String PARTICLE_ANALYZER_MAX_SIZE = "ap.partAnalyzerMaxSize";
   static final String SUB_CHANNEL_BACKGROUND = "ap.subChannelBackground";
   static final String RESULTS_FILE_HEADER_WRITTEN = "ap.resultsFileHeaderWritten";
   static final String RESULTS_FILE_NAME = "ap.resultsFileName";
   static final String RESULTS_DELIMETER = "ap.resultsDelimeter";
   static final String SAVE_RESULTS = "ap.saveResults";
   static final String CONDITION = "ap.condition";
   private static int staticColorChannels = Prefs.getInt("ap.colorChannels", 3);
   private static int staticPartAnalyzerOptions = Prefs.getInt("ap.partAnalyzerOptions", 4);
   private static int staticPartAnalyzerMeasurements = Prefs.getInt("ap.partAnalyzerMeasurements", 179);
   private static int staticPartAnalyzerMinSize = Prefs.getInt("ap.partAnalyzerMinSize", 1);
   private static int staticPartAnalyzerMaxSize = Prefs.getInt("ap.partAnalyzerMaxSize", 200);
   private static int staticSubtractChannelBackground = Prefs.getInt("ap.subChannelBackground", 1);
   private static boolean staticReultsFileHeaderWritten = Prefs.getBoolean("ap.resultsFileHeaderWritten", false);
   private static boolean staticSaveResults = Prefs.getBoolean("ap.saveResults", false);
   private static String resultsFileName = Prefs.getString("ap.resultsFileName");
   private static String resultsDelimeter = "\t";
   private static String staticCondition = Prefs.getString("ap.condition");
   private static File resultsFile = null;
   protected String arg;
   protected ImagePlus imp;
   protected ParticleAnalyzer analyzer;
   protected List[] puncta;
 
   public static void savePreferences(Properties prefs) {
      prefs.put("ap.colorChannels", Integer.toString(staticColorChannels));
      prefs.put("ap.partAnalyzerOptions", Integer.toString(staticPartAnalyzerOptions));
      prefs.put("ap.partAnalyzerMeasurements", Integer.toString(staticPartAnalyzerMeasurements));
      prefs.put("ap.partAnalyzerMinSize", Integer.toString(staticPartAnalyzerMinSize));
      prefs.put("ap.partAnalyzerMaxSize", Integer.toString(staticPartAnalyzerMaxSize));
      prefs.put("ap.subChannelBackground", Integer.toString(staticSubtractChannelBackground));
      prefs.put("ap.resultsFileHeaderWritten", new Boolean(staticReultsFileHeaderWritten).toString());
      prefs.put("ap.saveResults", new Boolean(staticSaveResults).toString());
      prefs.put("ap.resultsFileName", resultsFileName);
      prefs.put("ap.condition", staticCondition);
   }
 
   public int setup(String arg, ImagePlus imp)
   {
      this.arg = arg;
      this.imp = imp;
      IJ.register(Puncta_Analyzer.class);
      return 1424;
   }
 
   protected boolean runPrefsDialog()
   {
      GenericDialog gd = new GenericDialog("Analysis Options", IJ.getInstance());
      gd.addStringField("Condition: ", 
                        staticCondition != null ? staticCondition : new String(""));
      
      gd.addCheckboxGroup(3,
                          2, 
                          new String[] { "Red Channel", 
                                         "Green Channel", 
                                         "Blue Channel", 
                                         "Subtract Background", 
                                         "Subtract Background", 
                                         "Subtract Background" }, 
                          new boolean[] { (staticColorChannels & 0x1) != 0 ? true : false, 
                                          (staticColorChannels & 0x2) != 0 ? true : false, 
                                          (staticColorChannels & 0x4) != 0 ? true : false, 
                                          (staticSubtractChannelBackground & 0x1) != 0 ? true : false, 
                                          (staticSubtractChannelBackground & 0x2) != 0 ? true : false, 
                                          (staticSubtractChannelBackground & 0x4) != 0 ? true : false });
      gd.addCheckbox("Set results file...", !staticReultsFileHeaderWritten);
      gd.addCheckbox("Save results", staticReultsFileHeaderWritten);
      gd.addStringField("Current results file: ", resultsFile != null ? resultsFile.getPath() : "No results file selected", resultsFile != null ? resultsFile.getPath().length() : new String("No results file selected").length());
      gd.addMessage("(changing field does not change results file destination)");
      gd.showDialog();
 
      if (gd.wasCanceled())
         return false;
      
      if (gd.invalidNumber())
      {
         IJ.error("Invalid number.");
         return false;
      }
 
      staticCondition = gd.getNextString();
      
      if (gd.getNextBoolean())
         staticColorChannels |= 1;
      else
         staticColorChannels &= -2;
      
      if (gd.getNextBoolean())
         staticColorChannels |= 2;
      else
         staticColorChannels &= -3;

      if (gd.getNextBoolean())
         staticColorChannels |= 4;
      else
         staticColorChannels &= -5;

      if (gd.getNextBoolean())
         staticSubtractChannelBackground |= 1;
      else
         staticSubtractChannelBackground &= -2;

      if (gd.getNextBoolean())
         staticSubtractChannelBackground |= 2;
      else
         staticSubtractChannelBackground &= -3;

      if (gd.getNextBoolean())
         staticSubtractChannelBackground |= 4;
      else
         staticSubtractChannelBackground &= -5;
         
      if (gd.getNextBoolean())
         changeResultsFile();

      if (gd.getNextBoolean())
         staticSaveResults = true;
      else
         staticSaveResults = false;
 
      return true;
   }
 
   protected void changeResultsFile()
   {
      FileDialog fileD = new FileDialog(IJ.getInstance(), "Results File", 1);
 
      fileD.show();
 
      if (fileD.getFile() != null) {
         resultsFileName = fileD.getFile();
         resultsFile = new File(fileD.getDirectory(), resultsFileName);
         try {
            if (resultsFile.createNewFile()) {
               PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(resultsFile)));
               writeHeaderToStream(out);
               out.close();
               staticReultsFileHeaderWritten = true;
            }
            else {
               staticReultsFileHeaderWritten = true;
            }
         } catch (IOException e) {
             MessageDialog d = new MessageDialog(IJ.getInstance(), "Error", "Could not read/create results file. Results will not be saved.");
             d.show();
             resultsFile = null;
         }
      }
      fileD.dispose();
   }
 
   public void run(ImageProcessor ip)
   {
      ResultsTable[] rTables = null;
      this.puncta = new List[4];
 
      if ((!IJ.versionLessThan("1.22")) && (runPrefsDialog())) {
         this.imp.startTiming();
         rTables = locatePuncta(this.imp);
         MessageDialog d;
         if (rTables != null) {
            IJ.showStatus("Computing Colocalization...");
            analyzePuncta(rTables);
            displayColocalizedPuncta(this.imp);
            displayPunctaStatistics();
            if ((resultsFile != null) && (staticSaveResults) && (userRequestsSaveData())) {
               if (resultsFile.canWrite()) { 
                  try { 
                     writeResultsToFile();
                  } catch (IOException e) {
                      d = new MessageDialog(IJ.getInstance(), "Error", "Could not write to results file. Results were not saved.");
                  }
                } 
                else {
                   d = new MessageDialog(IJ.getInstance(), "Error", "Could not write to results file. Results were not saved.");
                }
            }
       }
       else {
          IJ.error("Analysis failed. Keep counting, sucker.");
       }
     }
   }
 
   protected boolean userRequestsSaveData()
   {
      return JOptionPane.showOptionDialog(null, "Save analysis results to file?", "", 0, 3, null, null, null) == 0;
   }
 
   protected void displayPunctaStatistics()
   {
      if (this.puncta[0] != null) {
         IJ.write("Statistics for red channel puncta:");
         displayChannelPunctaStatistics(0);
      }
 
      if (this.puncta[1] != null) {
         IJ.write("Statistics for green channel puncta:");
         displayChannelPunctaStatistics(1);
      }
 
      if (this.puncta[2] != null) {
         IJ.write("Statistics for blue channel puncta:");
         displayChannelPunctaStatistics(2);
      }
 
      if (this.puncta[3] != null) {
         IJ.write("Statistics for colocalized puncta:");
         displayChannelPunctaStatistics(3);
      }
   }
 
   protected Puncta_Analyzer.ChannelSummaryStatistics channelSummaryStatistics(int index)
   {
      Iterator iter = this.puncta[index].iterator();
 
      double areaSum = 0.0D;
      double minSum = 0.0D;
      double maxSum = 0.0D;
      double meanSum = 0.0D;
      
      while (iter.hasNext()) {
         Puncta curr = (Puncta)iter.next();
         areaSum += curr.area();
         minSum += curr.min();
         maxSum += curr.max();
         meanSum += curr.mean();
      }
 
      int size = this.puncta[index].size();
      double areaAvg = areaSum / size;
      double minAvg = minSum / size;
      double maxAvg = maxSum / size;
      double meanAvg = meanSum / size;
 
      return new Puncta_Analyzer.ChannelSummaryStatistics(size, areaAvg, minAvg, maxAvg, meanAvg);
   }
 
   protected void displayChannelPunctaStatistics(int index)
   {
      Puncta_Analyzer.ChannelSummaryStatistics stat = channelSummaryStatistics(index);
      BigDecimal bdAreaAvg = (Double.isNaN(stat.areaAvg)) || (Double.isInfinite(stat.areaAvg)) ? null : new BigDecimal(stat.areaAvg);
      BigDecimal bdMinAvg = (Double.isNaN(stat.minAvg)) || (Double.isInfinite(stat.minAvg)) ? null : new BigDecimal(stat.minAvg);
      BigDecimal bdMaxAvg = (Double.isNaN(stat.maxAvg)) || (Double.isInfinite(stat.maxAvg)) ? null : new BigDecimal(stat.maxAvg);
      BigDecimal bdMeanAvg = (Double.isNaN(stat.meanAvg)) || (Double.isInfinite(stat.meanAvg)) ? null : new BigDecimal(stat.meanAvg);
 
      if (bdAreaAvg != null)
         bdAreaAvg = bdAreaAvg.setScale(1, 6);
      if (bdMinAvg != null)
         bdMinAvg = bdMinAvg.setScale(1, 6);
      if (bdMaxAvg != null)
         bdMaxAvg = bdMaxAvg.setScale(1, 6);
      if (bdMeanAvg != null)
         bdMeanAvg = bdMeanAvg.setScale(1, 6);
 
      IJ.write("Number: " + stat.num);
      if (bdAreaAvg != null)
         IJ.write("Avg. Area: " + bdAreaAvg + " (" + stat.areaAvg + ")");
      else
         IJ.write("Avg. Area: " + stat.areaAvg);
      if (bdMinAvg != null)
         IJ.write("Avg. Min: " + bdMinAvg + " (" + stat.minAvg + ")");
      else
         IJ.write("Avg. Min: " + stat.minAvg);

      if (bdMaxAvg != null)
         IJ.write("Avg. Max: " + bdMaxAvg + " (" + stat.maxAvg + ")");
      else
         IJ.write("Avg. Max: " + stat.maxAvg);

      if (bdMeanAvg != null)
         IJ.write("Avg. Mean: " + bdMeanAvg + " (" + stat.meanAvg + ")");
      else
         IJ.write("Avg. Mean: " + stat.meanAvg);
   }
 
   protected void writeResultsToFile() throws IOException
   {
      PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(resultsFile.getPath(), true)));
 
      if (!staticReultsFileHeaderWritten) {
         writeHeaderToStream(out);
      }
 
      writeImageDataToStream(out);
      writeChannelResultsToStream(0, out);
      writeChannelResultsToStream(1, out);
      writeChannelResultsToStream(2, out);
      writeChannelResultsToStream(3, out);
      out.println();
      out.close();
   }
 
   protected void writeHeaderToStream(PrintWriter out)
   {
      out.print("Image name");
      out.print(resultsDelimeter);
      out.print("Condition");
      out.print(resultsDelimeter);
      out.print("Channel Name");
      out.print(resultsDelimeter);
      out.print("Num puncta");
      out.print(resultsDelimeter);
      out.print("Area average");
      out.print(resultsDelimeter);
      out.print("Min intensity average");
      out.print(resultsDelimeter);
      out.print("Max intensity average");
      out.print(resultsDelimeter);
      out.print("Mean intensity average");
      out.print(resultsDelimeter);  
      out.print("...");
      out.println();
   }
 
   protected void writeImageDataToStream(PrintWriter out)
   {
      out.print(this.imp.getTitle());
      out.print(resultsDelimeter);
      out.print(staticCondition);
      out.print(resultsDelimeter);
   }
 
   protected void writeChannelResultsToStream(int index, PrintWriter out)
   {
      if (this.puncta[index] != null) {
         Puncta_Analyzer.ChannelSummaryStatistics stat = channelSummaryStatistics(index);
         out.print(channelNameForPunctaIndex(index));
         out.print(resultsDelimeter);
         out.print(stat.num);
         out.print(resultsDelimeter);
         out.print(stat.areaAvg);
         out.print(resultsDelimeter);
         out.print(stat.minAvg);
         out.print(resultsDelimeter);
         out.print(stat.maxAvg);
         out.print(resultsDelimeter);
         out.print(stat.meanAvg);
         out.print(resultsDelimeter);
      } 
      else {
         out.print(channelNameForPunctaIndex(index));   
         out.print(resultsDelimeter);
         out.print("-");
         out.print(resultsDelimeter);
         out.print("-");
         out.print(resultsDelimeter);
         out.print("-");
         out.print(resultsDelimeter);
         out.print("-");
         out.print(resultsDelimeter);
         out.print("-");
         out.print(resultsDelimeter);
     }
   }
 
   protected String channelNameForPunctaIndex(int index)
   {
      switch (index) {
      case 0:
         return "red channel puncta";
      case 1:
         return "green channel puncta";
      case 2:
         return "blue channel puncta";
      case 3:
         return "colocalized puncta";
      }
 
      return "error: no channel for index";
   }
 
   protected void analyzePuncta(ResultsTable[] rTables)
   {
      if ((staticColorChannels & 0x1) != 0) {
         IJ.showStatus("Analyzing Puncta from Red Channel...");
         if (rTables[1] == null)
            IJ.error("Data for Red Channel is null");
         else
            this.puncta[0] = toVector(rTables[1]);
      } 
      else {
         this.puncta[0] = null;
      }
 
      if ((staticColorChannels & 0x2) != 0) {
         IJ.showStatus("Analyzing Puncta from Green Channel...");
         if (rTables[2] == null)
            IJ.error("Data for Green Channel is null");
         else
            this.puncta[1] = toVector(rTables[2]);
      }
      else {
         this.puncta[1] = null;
      }
 
      if ((staticColorChannels & 0x4) != 0) {
         IJ.showStatus("Analyzing Puncta from Blue Channel...");
         if (rTables[4] == null)
            IJ.error("Data for Blue Channel is null");
         else
            this.puncta[2] = toVector(rTables[4]);
      } 
      else {
         this.puncta[2] = null;
      }
 
      this.puncta[3] = computeColocalization();
   }
 
   protected double computeRadius(Puncta p)
   {
      return Math.sqrt(p.area / 3.141592653589793D);
   }
 
   protected Vector computeTwoChannelColocalization(List c1Puncta, List c2Puncta) {
      Vector coloc = new Vector();
 
      Iterator c1Iterator = c1Puncta.iterator();
 
      while (c1Iterator.hasNext()) {
         Puncta currPuncta = (Puncta)c1Iterator.next();
         double radius = computeRadius(currPuncta);
         Iterator c2Iterator = c2Puncta.iterator();
 
         while (c2Iterator.hasNext()) {
            Puncta targetPuncta = (Puncta)c2Iterator.next();
            if (currPuncta.distanceTo(targetPuncta) > radius + computeRadius(targetPuncta))
            {
               continue;
            }
            double x = currPuncta.getX() + (targetPuncta.getX() - currPuncta.getX()) / 2.0D;
            double y = currPuncta.getY() + (targetPuncta.getY() - currPuncta.getY()) / 2.0D;
 
            double area = (currPuncta.area() + targetPuncta.area()) / 2.0D;
            double perimeter = (currPuncta.perimeter() + targetPuncta.perimeter()) / 2.0D;
            double max = (currPuncta.max() + targetPuncta.max()) / 2.0D;
            double min = (currPuncta.min() + targetPuncta.min()) / 2.0D;
            double mean = (currPuncta.mean() + targetPuncta.mean()) / 2.0D;
 
            coloc.add(new Puncta(x, y, area, perimeter, max, min, mean));
         }
      }
      return coloc;
   }
 
   protected Vector computeColocalization()
   {
      Vector coloc = null;
 
      switch (staticColorChannels) {
      case 3:
         coloc = computeTwoChannelColocalization(this.puncta[0], this.puncta[1]);
         break;
      case 5:
         coloc = computeTwoChannelColocalization(this.puncta[0], this.puncta[2]);
         break;
      case 6:
         coloc = computeTwoChannelColocalization(this.puncta[1], this.puncta[2]);
         break;
      case 7:
         coloc = computeTwoChannelColocalization(this.puncta[0], this.puncta[1]);
         coloc = computeTwoChannelColocalization(this.puncta[0], coloc);
         break;
      case 4:
         default:
         IJ.write("More than one color channel must be selected to compute colocalization.");
      }
      return coloc;
   }
 
   protected Vector toVector(ResultsTable table)
   {
      Vector vector = new Vector();
      float[] x_centroid = table.getColumn(table.getColumnIndex("X"));
      float[] y_centroid = table.getColumn(table.getColumnIndex("Y"));
      float[] area = table.getColumn(table.getColumnIndex("Area"));
      float[] max = table.getColumn(table.getColumnIndex("Max"));
      float[] min = table.getColumn(table.getColumnIndex("Min"));
      float[] mean = table.getColumn(table.getColumnIndex("Mean"));
 
      int numPuncta = table.getCounter();
 
      Roi roi = this.imp.getRoi();
      Rectangle roiRect;
      if (roi != null)
         roiRect = roi.getBoundingRect();
      else
         roiRect = null;
 
      for (int i = 0; i < numPuncta; i++) {
         if ((roi == null) || ((roi != null) && (roi.contains((int)x_centroid[i] + (int)roiRect.getX(), (int)y_centroid[i] + (int)roiRect.getY())))) {
            vector.add(new Puncta((int)x_centroid[i] + roiRect.getX(), (int)y_centroid[i] + roiRect.getY(), area[i], max[i], min[i], mean[i]));
         }
      }
      return vector;
   }
 
   protected void displayColocalizedPuncta(ImagePlus imp)
   {
      if (this.puncta[3] != null) {
         Iterator iter = this.puncta[3].iterator();
         while (iter.hasNext())
            drawPuncta((Puncta)iter.next(), imp);
      }
   }
 
   protected void drawPuncta(Puncta p, ImagePlus imp)
   {
      ImageProcessor ip = imp.getProcessor();
 
      ip.setLineWidth(2);
      ip.drawDot((int)p.getX(), (int)p.getY());
 
      imp.updateAndDraw();
   }
 
   public ResultsTable[] locatePuncta(ImagePlus imp)
   {
      ResultsTable[] rTables = new ResultsTable[5];
 
      if (imp.getType() != 4) {
         IJ.error("RGB image required.");
         return null;
      }
 
      ColorProcessor cp = (ColorProcessor)imp.getProcessor();
      int arrayLength = imp.getHeight() * imp.getWidth();
      byte[] rBytes = new byte[arrayLength];
      byte[] gBytes = new byte[arrayLength];
      byte[] bBytes = new byte[arrayLength];
 
      cp.getRGB(rBytes, gBytes, bBytes);
 
      IJ.showStatus("Ready to analyze."); IJ.wait(1000);
 
      if ((staticColorChannels & 0x1) != 0) {
         IJ.showStatus("Analyzing Red...");
         rTables[1] = locatePunctaInColorBand(imp, rBytes, "Red", (staticSubtractChannelBackground & 0x1) != 0 ? true : false);
         if (rTables[1] == null) {
            return null;
         }
      }
      
      if ((staticColorChannels & 0x2) != 0) {
         IJ.showStatus("Analyzing Green...");
         rTables[2] = locatePunctaInColorBand(imp, gBytes, "Green", (staticSubtractChannelBackground & 0x2) != 0 ? true : false);
         if (rTables[2] == null) {
            return null;
         }
      }

      if ((staticColorChannels & 0x4) != 0) {
         IJ.showStatus("Analyzing Blue...");
         rTables[4] = locatePunctaInColorBand(imp, bBytes, "Blue", (staticSubtractChannelBackground & 0x4) != 0 ? true : false);
         if (rTables[4] == null) {
            return null;
         }
      }
      
      return rTables;
   }
 
   protected ResultsTable locatePunctaInColorBand(ImagePlus imp, byte[] bytes, String color, boolean subtractBackground)
   {
      Rectangle roi = imp.getProcessor().getRoi();
      ResultsTable rTable = new ResultsTable();
 
      ByteProcessor bp = new ByteProcessor(imp.getWidth(), imp.getHeight());
      bp.setPixels(bytes);
 
      if (roi != null) {
         bp.setRoi(roi);
         bp = (ByteProcessor)bp.crop();
      }
 
      ImagePlus byteImp = new ImagePlus(color + " Channel Image", bp);
 
      Puncta_Analyzer.ScopeImageUtils.contractHistogram(byteImp);
 
      byteImp.show();
      byteImp.updateAndDraw();
 
      if (subtractBackground) {
         IJ.run("Subtract Background...");
      }
 
      PunctaMaskerFactory.getMasker().mask();
 
      byteImp.updateAndDraw();
 
      IJ.showStatus("Running Particle Analyzer on " + imp.getTitle());
 
      this.analyzer = new ParticleAnalyzer(staticPartAnalyzerOptions, staticPartAnalyzerMeasurements, rTable, staticPartAnalyzerMinSize, staticPartAnalyzerMaxSize);
 
      this.analyzer.setup(this.arg, byteImp);
      this.analyzer.run(bp);
 
      byteImp.hide();
 
      return rTable;
   }
 
   protected class ChannelSummaryStatistics {
       
      public double areaAvg;
      public double minAvg;
      public double maxAvg;
      public double meanAvg;
      public int num;
 
      public ChannelSummaryStatistics(int num, double areaAvg, double minAvg, double maxAvg, double meanAvg) {
         this.num = num;
         this.areaAvg = areaAvg;
         this.minAvg = minAvg;
         this.maxAvg = maxAvg;
         this.meanAvg = meanAvg;
      }
   }
 
   protected static class ScopeImageUtils implements Measurements {
       
      public static void contractHistogram(ImagePlus imp) {
          
         ImageProcessor ip = imp.getProcessor();
         int minUsedValue = 0;
         ip.setMask(imp.getMask());
         int[] histogram = imageHistogram(ip);
         int maxUsedValue = histogram.length - 1;
 
         while (histogram[minUsedValue] == 0) {
            minUsedValue++;
         }
 
         while (histogram[maxUsedValue] == 0) {
            maxUsedValue--;
         }
      }
 
      public static int[] imageHistogram(ImageProcessor ip) {
        
         if (!(ip instanceof ByteProcessor)) {
            double min = ip.getMin();
            double max = ip.getMax();
            ip.setMinAndMax(min, max);
            ip = new ByteProcessor(ip.createImage());
         }
 
         return ip.getHistogram();
      }
   }
}

