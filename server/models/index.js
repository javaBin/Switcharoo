const Sequelize = require('sequelize');
const fs = require('fs');
const path = require('path');

const sequelize = new Sequelize(process.env.DATABASE_URL);

const nonModels = f => f.indexOf('.') !== 0 && f !== 'index.js';

const models = fs
      .readdirSync(__dirname)
      .filter(nonModels)
      .reduce((acc, file) => {
          const model = sequelize.import(path.join(__dirname, file));
          acc[model.name] = model;
          return acc;
      }, {});

models.sequelize = sequelize;
models.Sequelize = Sequelize;

module.exports = models;
