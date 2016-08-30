var fs = require('fs');
var express = require('express');
var formidable = require('formidable');
var pythonShell = require('python-shell');
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
    fs.mkdirSync(dirname); 
    fs.renameSync(file.path, dirname+"/"+file.name);
    try {
      for (var i = 0; i < 8; i++) {
        var options = {
          mode: 'text',
          scriptPath: './scripts',
          pythonPath: '/home/junho/.miniconda2/bin/python',
          args: [i, '/tmp/' + dirname+"/"+i+".png", dirname+"/"+file.name]
        };
        
        pythonShell.run('progress_plot.py', options, function(err, results) {
          if (err) console.log(err);
          res.send(results);
        });
      }
    } catch (e) {
      res.send("ERROR: " + e.message);
    }
  });

  form.parse(req);
});

module.exports = router;
