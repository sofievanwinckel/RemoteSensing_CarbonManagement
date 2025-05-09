# compare GEDI height data and measured heights in the field
library(raster)
library(sf)
library(readxl)

#load GEDI/S2 height data
setwd("C:/Users/u0152263/OneDrive - KU Leuven/0500 Papers/0510 CarbonManagementRS/0511 data and code availability/data/input")
Bel_H <- raster("ETH_Height_Bel.tif")

#load forest plots
setwd("C:/Users/u0152263/OneDrive - KU Leuven/0500 Papers/0510 CarbonManagementRS/0511 data and code availability/plots_shp")
plot <- st_read("plots_bel_fin.shp")
plot <- st_zm(plot, what="ZM")

#load field data
setwd("C:/Users/u0152263/OneDrive - KU Leuven/0500 Papers/0510 CarbonManagementRS/0511 data and code availability/data/input")
tree_data <- read_xlsx("field_data_v1.xlsx", sheet=1)
plot_data <- read_xlsx("field_data_v1.xlsx", sheet=2)

#create buffer of 18 m radius: EPSG 31370
plot_B <- st_transform(plot, 31370)
plot_B <- st_buffer(plot_B, 18, nQuadSegs=8)
plot_B <- st_transform(plot_B, 4326)

library(ggplot2)
library(dplyr)
ggplot()+
  geom_sf(data=filter(plot_B,id=='23'))

#Calculate height for each plot
plot_B[[names(Bel_H)]] <- raster::extract(Bel_H, plot_B, fun = mean, na.rm = TRUE)
plot_B <- plot_B[order(plot_B$id),]
plot$'ETH_height' <- plot_B$ETH_Height_Bel



#Calculate the mean height measured in the field, only including trees in class C
#calculate the mean height per plotmean_heights <- tree_data %>%
mean_heights <- tree_data %>%
  filter(nested_level == 'C') %>%
  group_by(plot_ID) %>%
  summarize(mean_height = mean(`H (m)`, na.rm = TRUE))

#join the mean heights to the plot dataframe
plot <- plot %>%
  left_join(mean_heights, by = c("id" = "plot_ID"))

plot <- plot %>%
  rename(Field_height = mean_height)

#Plot both columns

ggplot(plot, aes(x = id)) +
  geom_line(aes(y = ETH_height, color = "ETH_height"), size = 1.2) +
  geom_line(aes(y = Field_height, color = "Field_height"), size = 1.2) +
  scale_color_manual(values = c("ETH_height" = "#0072B2", "Field_height" = "#FF9933"), 
                     labels=c("ETH_height" = "GEDI/Sentinel-2", "Field_height" = "Field measurements")) + # Blue and orange
  labs(
    x = "Plot ID",
    y = "Canopy height estimate (m)",
    title = "Estimation accuracy of the GEDI/Sentinel-2 canopy height product",
    color = "Legend"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 18),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_blank(),
    legend.position = c(0.2, 0.2),   # Adjust these coordinates to move the legend
    legend.background = element_rect(fill = "white", color = "black", size = 0.5),
    legend.key.size = unit(1.5, "lines"),  
    legend.text = element_text(size = 18))  

#paired t-test
t.test(plot$ETH_height, plot$Field_height, paired=TRUE)
#small value 1.07e-5 --> ETH significantly underestimates the Field measurements.

#plot: y-axis: AGB values, x-axis: difference Field-ETH
plot$ETH_Field_dif <- plot$Field_height-plot$ETH_height
plot <- merge(plot, plot_data[, c("plot_ID", "AGB_plot_conv")], by.x = "id", by.y = "plot_ID", all.x = TRUE)
plot(plot$ETH_Field_dif, plot$AGB_plot_conv)
#no outlier
plot_1 <- plot[plot$id!=62,]

ggplot(plot_1, aes(x = AGB_plot_conv, y = ETH_Field_dif)) +
  geom_point(size = 3, color = "black") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    x = "AGB (tons/ha)",
    y = "Height difference (m)",
    title = "Canopy height differences at plot level (Field-GEDI/Sentinel-2)"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    axis.text = element_text(size = 12)
  )


ggplot(plot_1, aes(x = AGB_plot_conv, y = ETH_Field_dif)) +
  geom_point(aes(fill = AGB_plot_conv), size = 3, shape = 21, color = "black") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  scale_fill_gradient(name = "AGB (tons/ha)", low = "yellow", high = "darkgreen") +
  labs(
    x = "AGB (tons/ha)",
    y = "Height difference (m)",
    title = "Canopy height differences at plot level (Field-GEDI/Sentinel-2)"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    legend.position = c(0.1, 0.8), 
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 12),
    axis.text = element_text(size = 12)
  )

#order plots by AGB
plot <- plot %>%
  arrange(AGB_plot_conv) %>%
  mutate(id_ordered = row_number()) 

ggplot(plot, aes(x = id_ordered)) +
  geom_line(aes(y = ETH_height, color = "ETH_height"), size = 1.2) +
  geom_line(aes(y = Field_height, color = "Field_height"), size = 1.2) +
  geom_point(aes(y=ETH_Field_dif, fill="AGB_plot_conv"), size=2.5)+
  scale_color_manual(values = c("ETH_height" = "#0072B2", "Field_height" = "#FF9933"), 
                     labels=c("ETH_height" = "GEDI/Sentinel-2", "Field_height" = "Field measurements")) + # Blue and orange
  scale_fill_gradient(name = "AGB (tons/ha)", low="yellow", high="darkgreen")+
   labs(
    x = "Plots with increasing AGB",
    y = "Canopy height estimate (m)",
    title = "Estimation accuracy of the GEDI/Sentinel-2 canopy height product",
    color = "Legend"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 18),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_blank(),
    legend.position = c(0.2, 0.1),   # Adjust these coordinates to move the legend
    legend.background = element_rect(fill = "white", color = "black", size = 0.5),
    legend.key.size = unit(1.5, "lines"),  
    legend.text = element_text(size = 18))  

#SCATTERPLOT
ggplot(plot_1, aes(x = Field_height , y =ETH_height )) +
  geom_point(aes(fill= AGB_plot_conv), size=4, shape=21) +
  geom_abline(slope=1, intercept=0, colour="grey")+
  labs(
    x = "Field height (m)",
    y = "GEDI/Sentinel height (m)",
    title = "Estimation accuracy of the GEDI/Sentinel-2 canopy height product"
  ) +
  scale_fill_gradient(name = "AGB (tons/ha)", low = "yellow", high = "darkgreen") +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 20),
    axis.title.x = element_text(size = 18),
    axis.title.y = element_text(size = 18),
    axis.text = element_text(size = 12),
    legend.position = c(0.1, 0.8),
  )

