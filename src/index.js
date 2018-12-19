var R = require('r-script');
var path = require('path');

const rscriptPath = path.resolve("src", "sourcerer-core", "wordcloud.R");
var out = R(rscriptPath)
.data()
.callSync();

console.log(out);