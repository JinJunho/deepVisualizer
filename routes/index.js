var fs = require('fs');
var express = require('express');
var formidable = require('formidable');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index');
});
router.get('/quickstart', function(req, res, next) {
  res.render('quickstart');
});
router.post('/send', function(req, res, next) {
  var form = new formidable.IncomingForm(), file = null;
  
  form.on('file', function(field, inFile) {
    // field list: size, path, name, type, mtime
    // actual file is in path
    file = inFile;
    var dirname = "/tmp/" + file.path.split("_")[1];
    var filename = dirname+"/"+file.name;
    fs.mkdirSync(dirname); 
    fs.renameSync(file.path, filename);
    try {
      var exec = require('child_process').exec;
      var child = exec("/data/git/deepVisualizer/scripts/plot.sh " + filename, function(err, stdout, stderr) {
        console.log('stdout: ' + stdout);
        console.log('stderr: ' + stderr);
        if (err !== null) {
          console.log('exec error: ' + err);
        }
        else {
          console.log('request done.');
        }
      });
      res.render('grid');
    } catch (e) {
      res.send("ERROR: " + e.message);
    }
  });

  form.parse(req);
});

module.exports = router;
