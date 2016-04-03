

// ************************************
// MINIMUM TOKEN LENGTH
// (affects search index size)
// ************************************
var MINIMUM_TOKEN_LENGTH = 6;


var path = require('path');
var fs = require('fs');
var lunr = require('lunr');
var jsdom = require('jsdom');

var jquery = fs.readFileSync("./vendor/jquery.js", "utf-8");

var TITLE_RE = /title:\ +"([^"]+)"/;

var index = lunr(function() {
  this.ref('path');
  this.field('title', {boost: 10});
  this.field('body');
  this.pipeline.add(function (token, tokenIndex, tokens) {
    // - \d
    // - \=
    // - \-
    // - .length < 3
    // - \(
    // - \)
    // - \"
    // - \[
    // - \]
    // - \/
    // - \*
    // - \.
    if (token.length < MINIMUM_TOKEN_LENGTH || /[\d\=\-\(\)\"\[\]\/\*\.]/.test(token)) {
      return void 0; // undefined
    } else {
      return token;
    }
  });
});

contentPath = process.argv[2]

var files = fs.readdirSync(contentPath)
var pending = 0


indexFile = function(file) {
  // if (i > 2) { return; }
  if (/^[\.html]$/.test(file)) { return; }

  data = fs.readFileSync(path.join(contentPath, file))

  pending++;

  var title = TITLE_RE.exec(data);
  if (title) { title = title[2]; }

  jsdom.env(
    {
      html: '<html><body>' + data + '</body></html>',
      src: [jquery],
      done: function(err, window) {
        if (!window.$) {
          console.error('Skipping (no jQuery)'+ path.join(contentPath, file))
          return;
        }
        console.error('Indexing ' + path.join(contentPath, file))
        var text = window.$('body').text()

        index.add({
          path: 'contents/' + file.replace(/.md$/, '.html'),
          title: title,
          body: text
        });

        pending--;
        if (pending == 0) {
          index = JSON.parse(JSON.stringify(index));
          index.pipeline.pop(); // Remove our addition to the pipeline
          console.log(JSON.stringify(index));
        }

      }
    }
  );
}

for (i in files) {
  indexFile(files[i]);
}
