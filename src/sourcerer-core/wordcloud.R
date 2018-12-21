# wordcloud.R

# handline commandline args... 
# rem: with TRUE option below, #args[1] is the "--args" switch; skip it.
args <- commandArgs(TRUE)
BASEDIR <- (args[2])

cat(paste0("setting working dir from ", 
           getwd(), 
           "to : ", 
           BASEDIR))
setwd(BASEDIR)

# utility for checking is something is already installed, then loading.
usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1])) {
    install.packages(p, dep = TRUE)
  }
  require(p, character.only = TRUE)
}

# ensure we have needed packages
usePackage("config") # text mining
usePackage("tm") # text mining
usePackage("SnowballC") # text stemming
usePackage("wordcloud") # word-cloud generator
usePackage("RColorBrewer") #color palettes

# load local config
config <- config::get() #for datadir
text <- readLines(paste0(config$datadir, "/staging/sample.txt"))

# Load the data as a corpus of character vectors
# note: Appears to treat each line from the corpus as a separate "document"
docs <- Corpus(VectorSource(text))


# NOT RUN: testing out regexes etc for more granular, custom cleanup
# toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
# sampler <- inspect(head(docs,20))
# sampler <- tm_map(sampler, toSpace, "[.,\\/#!$%\\^&\\*;:@{}=\\-_`~()\\|]") # eg custom removal of punctation
# sampler <- tm_map(sampler, toSpace, "\\s{2,}") #collapse any ensuing multiple spaces


# text transforms and cleanup:
docs <- tm_map(docs, removePunctuation)
docs <- tm_map(docs, content_transformer(tolower))
docs <- tm_map(docs, removeWords, stopwords("english"))
docs <- tm_map(docs, stripWhitespace)

# build DTM (Document (rows) x Term (columns) Matrix (of term frequencies).
# again, remember each line is treated as a doc.
dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm) # for a peek: m[1:5,1:5]. You will see that terms are the rows now.
v <- sort(rowSums(m),decreasing=TRUE) # the row of frequencies is summed for each term.
d <- data.frame(word = names(v),freq=v) # for a peek: head(d, 10)

# create wordcloud
set.seed(1234) #for reproducibility
wordcloud(words = d$word, freq = d$freq, min.freq = 20,
          max.words=500, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Accent"))

# copy to an image.
dev.copy(pdf,paste0(config$datadir, "/outputs/canada_act_wordcloud.pdf"))
dev.off()

