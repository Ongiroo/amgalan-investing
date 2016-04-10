install.packages('quantmod');
# Overview of the help topics 
help(package = quantmod)
library('quantmod')

# Load and Manage Data from Multiple Sources
getSymbols('SNP', from='2004-01-02', to='2016-03-24')		#get S&P 500 index data
getSymbols("IREBY") # Bank of Ireland OHLC from yahoo 
getSymbols("JPM")
getSymbols('DTB3', src='FRED')						# 3-month T-Bill interest rates

#getSymbols.FRED(DTB3)  ### FRED changed its URL scheme for the downloads from http:// to https://.

# Returns the first of  of a vector, matrix, table, data frame or function
head(IREBY)

# adjust all columns of an OHLC object for split and dividend head
head(IREBY.a <- adjustOHLC(IREBY)) 
head(IREBY.uA <- adjustOHLC(IREBY, use.Adjusted=TRUE)) 
## less precise due to loss of precision from Yahoo using Adjusted columns of only two decimal places.
## The advantage is that this can be run offline

#obtain components of downloaded object
Cl(IREBY) 	 #closing prices
Op(IREBY)	   #open prices
Hi(IREBY)	   #daily highest price
Lo(IREBY)	   #daily lowest price
ClCl(IREBY)	 #close-to-close daily return
Ad(IREBY)	   #daily adjusted closing price

# intrada adjustments are precise across all methods
# an example with Open to Close (OpCl)
head(cbind(OpCl(IREBY),OpCl(IREBY.a),OpCl(IREBY.uA)))


## Create one data object from multiple sources
buildData(Next(OpCl(JPM)) ~ Lag(DTB3), na.rm=FALSE, return.class="ts")

# Specify Model Formula For quantmod Process
q.model <- specifyModel(Next(OpCl(IREBY)) ~ Lag(OpHi(IREBY),1:3))
# Update currently specified or built model with most recent data
getModelData(q.model)
# Create a single reusable model specification for subsequent buildModel calls.
q.build <-buildModel(q.model,method='lm',training.per=c('2014-01-02','2016-03-24'))
# 
tradeModel(q.build)


## Extract Dataset Created by specifyModel
modelData(q.build)
#################################

# the whole series 
chartSeries(IREBY, TA=NULL) 

# now - a little but of subsetting 
# (December '15 to the last observation in '16) 
candleChart(IREBY,subset='2015-12::2016') 


# slightly different syntax - after the fact. 
# also changing the x-axis labeling 
candleChart(IREBY,theme='white', type='candles') 
reChart(major.ticks='months',subset='first 16 weeks')

#####################################

# Now with some indicators applied 
chartSeries(IREBY, theme="white", 
            TA="addMACD();addROC()") 

# The same result could be accomplished a 
# bit more interactively: 

chartSeries(IREBY, type='line',theme="black", subset='last 4 months') #draw the chart 

## add Bollinger Bands to current chart
addBBands(n = 20, sd = 2, maType = "SMA", draw = 'bands', on = -1)
# SMA calculates the arithmetic mean of the series over the past n observations.
addCCI() #add Commodity Channel Index 
addRSI() # add Relative Strenght Indicator

# 
listTA()
# Used to manage the TA arguments used inside chartSeries calls. 
setTA(type = c("chartSeries"))

# a longer way to accomplish the same
setDefaults(chartSeries,TA=listTA())
setDefaults(candleChart,TA=listTA())

setDefaults(chartSeries,TA=substitute(c(addVo(),addBBands())))

#### Adding custom indicator data 
# Create A New TA Indicator For chartSeries 
addTA(EMA(Cl(IREBY)), on=1, col=6)
addTA(OpCl(IREBY), col=4, type='b', lwd=2)
# create new EMA TA function
newEMA <- newTA(EMA, Cl, on=1, col=7)
newEMA()
newEMA(on=NA, col=5)


# zoom into or out of the current chart.
zoomChart(subset, yrange=NULL)  
findPeaks(sin(1:10)) ## Find Peaks In A Series



