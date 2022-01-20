# set workspace
setwd('F:/Workspace_ZhaoCenliang/Github/ERSOD/ERSOD_RF')

# import necessary package
library(randomForest)
# load data
metadata <- read.csv('data_test_2010_to_2014.csv')

feature <- metadata[10:28]
feature <- feature[,-17]
data_test <- feature[,-4]
# variables need to be arranged as 'data_test'
#View(data_test)
# load RF model
load('ERSOD_RF.RData')
# GPP estimation
result_RF <- data_test
GPP_pre.RF <- predict(MODEL.RF, data_test[,-16])
result_RF$gpp_RF <- GPP_pre.RF

RMSE_RF <- round(sqrt(mean((result_RF$gpp_RF - result_RF$GPP_VUT_NT)^2)),2)
sta_lm <- summary(lm(result_RF$gpp_RF ~ result_RF$GPP_VUT_NT))
R2_RF <- sta_lm$r.squared

# plot package
library(ggplot2)
library(viridis) 
library(ggpointdensity) 
library(ggpmisc)
# plot code
theme_zg <- function(..., bg='white'){
  require(grid)
  theme_classic(...) +
    theme(rect=element_rect(fill=bg),
          plot.margin=unit(rep(0.5,4), 'lines'),
          panel.background=element_rect(fill='transparent', color='black'),
          panel.border=element_rect(fill='transparent', color='transparent'),
          panel.grid=element_blank())
}

windowsFonts(Times=windowsFont("Times New Roman"))

scatter_plot = ggplot(data = result_RF,aes(x = GPP_VUT_NT, y = gpp_RF)) + 
  geom_abline(slope = 1,intercept = 0) + 
  geom_pointdensity(adjust = 0.5, size = 0.25,alpha = 0.075) + 
  scale_color_viridis() + 
  geom_smooth(method = "lm",color = 'red',size=0.5,level = 0.95,formula = y ~ x) +  
  stat_poly_eq(
    aes(label = paste(..eq.label.., ..rr.label.., sep = '~~')),
    formula = y ~ x,  parse = TRUE,
    size = 4, 
    label.x = 0.025,
    label.y = 0.975,
    family = "Times") + annotate("text", x= -Inf, y= Inf, hjust = -0.1, vjust = 4, 
                                 label=paste("RMSE =", RMSE_RF),family="Times",size = 4) + 
  theme_zg() +
  scale_y_continuous(breaks = seq(0,25,5),limits  = c(0,27.5),expand = c(0, 0)) + 
  scale_x_continuous(breaks = seq(0,25,5),limits = c(0,27.5),expand = c(0, 0)) + 
  theme(legend.position='none') + 
  theme(axis.title.y=element_text(family="Times",angle=90, colour="black",size=14),
        axis.title.x = element_text(family="Times",colour="black",size=14),
        axis.text.x = element_text(family="Times",colour="black",size=14),
        axis.text.y = element_text(family="Times",colour="black",size=14),
        title = element_text(family="Times",face = "bold",colour="black",size=14),
        legend.text= element_text(family="Times",colour="black",size=12),
        legend.position = 'none') + 
  xlab(expression(paste('GPP'[FLUXNET-EC],' [','g C m'^-2,'day'^-1,']'))) + 
  ylab(expression(paste('GPP'[ERSOD-RF],' [','g C m'^-2,'day'^-1,']')))

# show result
scatter_plot
# export result
ggsave(scatter_plot, path = 'path'
       ,file='file_name.jpg', width=4, height=4, dpi = 450)