'use strict';

var fs = require('fs')
  , path = require('path')
  , updateSection = require('update-section')

function inspect(obj, depth) {
  console.error(require('util').inspect(obj, false, depth || 5, true));
}
var files = fs
  .readdirSync(path.join(__dirname, '../'))
  .filter(function (x) { return path.extname(x) === '.asm' })
  .map(function (x) { return path.join(__dirname, '..', x) })

function processFile(file) {
  var src = fs.readFileSync(file, 'utf8')
    , lines = src.split('\n')
  var doc = []
    , code = []
    , example = []
    , line = lines.pop()

  //
  // docs
  //

  // find doc start
  while(!(/; *-----/).test(line)) line = lines.shift();

  // consume until doc end
  doc.push(line);
  line = lines.shift();
  while(typeof line !== 'undefined' && !(/; *-----/).test(line)) {
    doc.push(line);
    line = lines.shift();
  }
  if (typeof line !== 'undefined') doc.push(line);

  //
  // code
  //

  // find function start
  while(line && !(/\w+\:/).test(line)) line = lines.shift();

  // consume up to test indicator or EOF
  code.push(line);
  line = lines.shift();
  while(typeof line !== 'undefined' && !(/;---+\+/).test(line)) {
    code.push(line);
    line = lines.shift();
  }
  // remove empty lines
  for (var i = code.length - 1; !code[i].trim().length; i--);
  code.length = i;

  //
  // example
  //
  // find example snippets up to EOF
  var inExample = false;
  while(typeof line !== 'undefined') {
    if (/^;;;/.test(line)) inExample = !inExample;
    else if (inExample) example.push(line);
    line = lines.shift();
  }

  return {
      file    : path.basename(file)
    , fn      : path.basename(file).slice(0, -4)
    , rawurl  : 'https://raw.githubusercontent.com/thlorenz/lib.asm/' + path.basename(file)
    , doc     : doc
    , code    : code
    , example : example
  }
}

function render(info) {
  var docNcode = [
      '### [`' + info.fn + '`](' + info.file + ')'
    , ''
    , '#### documentation'
    , ''
    , '```asm'
    ]
    .concat(info.doc).concat([
      '```'
    , ''
    , '#### code'
    , ''
    , '```asm'
    ])
    .concat(info.code).concat([
      '```'
    ])

  var installation = [
      '#### installation'
    , ''
    , '```sh'
    , `curl -L ${ info.rawurl } > ${ info.file }`
    , '```'
  ]

  return !info.example.length
    ? docNcode.concat(installation).join('\n')
    : docNcode.concat([
        ''
      , '#### example'
      , ''
      , '```asm'
      ])
      .concat(info.example).concat([
        '```'
      , ''
      ])
      .concat(installation)
      .join('\n')
}

function inspect(obj, depth) {
  console.error(require('util').inspect(obj, false, depth || 5, true));
}

var res = files.map(processFile);

var rendered = res.map(render).join('\n')

var start = '<!-- START lib.asm documentation, generated via `make docs` -->';
var end = '<!-- END lib.asm documentation -->';

function matchStart(l) {
  return /<!-- START lib.asm documentation/.test(l);
}

function matchEnd(l) {
  return /<!-- END lib.asm documentation/.test(l);
}

var s = start + '\n\n' + rendered + '\n\n' + end
  , readme = path.join(__dirname, '..', 'README.md')
  , markdown = fs.readFileSync(readme, 'utf8')

var updated = updateSection(markdown, s, matchStart, matchEnd);
fs.writeFileSync(readme, updated);

console.log('Successfully updated docs!');
