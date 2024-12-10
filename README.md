# RemoteSensing_CarbonManagement
In this folder, data and coding as used in the paper: 'Assessing the effect of forest management on above-ground carbon stock by remote sensing' are available
## field-data.xlsx
In this excel file, all field measurements are provided. In the tabblad 'tree_data', all individual tree measurements is shown, with the nesting level. The appropriate coefficients for the allometric equations are noted per tree, with the obtained stem volume (m³) and resulting above-ground biomass (AGB_ton: per tree and AGB_per_ha: per ha).
The 'plot_data' tabblad contains the information per measured plot, with the AGB and AGB_per_ha aggregated from the individual tree measurements (in total and per nesting level). The location of each plot is shown with lat and long coordinates. AGB= above-ground biomass, BA=basal area, n= number of trees.
Lastly, the 'patch_data' shows the same, but now aggregated per forest patch (taken the mean of all three plots per patch). 

## CarbonManagement_code_modelAnalysis
In this R Markdown file, the code used for the model analysis is provided. The code can be run with the field-data.xlsx, and openly accessible data from Sentinel-2, Sentinel-1 and GEDI. 

## CarbonManagement_code_DBHanalysis
In this R Markdown file, the supplementary analysis as described in section 2.3.2 and appendix 1 is provided. the code can be run with the data_DBH_analysis excel file.

## data_DBH_analysis
The data that is used to run the CarbonManagement_code_DBHanalysis. Only the third tab is used, the others are provided for the sake of completenness. 
