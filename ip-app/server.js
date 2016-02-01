'use strict';

const express = require('express');
const path = require('path');

const routes = require('./routes');

const PORT = 8080;

const app = express();
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(require('stylus').middleware(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', routes.index);

app.listen(PORT);
console.log('Running on http://localhost:' + PORT);