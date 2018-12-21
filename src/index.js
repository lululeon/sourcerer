const path = require('path');
const spawn = require("child_process").spawn;
require('dotenv').config();

const rscriptPath = path.resolve("src", "sourcerer-core", "wordcloud.R");

const callR = (path) => {
  return new Promise((resolve, reject) => {
    let err = false;
    const child = spawn(process.env.RSCRIPT, ["--vanilla", path, "--args", process.env.RBASEDIR]);
    child.stderr.on("data", (data) => {
      console.log(data.toString());
    });
    child.stdout.on("data", (data) => {
      console.log(data.toString());
    });
    child.on('error', (error) => {
      err=true;
      reject(error);
    });
    child.on('exit', () => {
      if(err) return; // debounce - already rejected
      resolve("done."); // TODO: check exit code and resolve/reject accordingly
    });
  });
}

console.log("Invoking R script... at:", rscriptPath);
callR(rscriptPath)
.then(result => {
  console.log("finished with result:", result);
})
.catch(error => {
  console.log("Finished with error:", error);
});
