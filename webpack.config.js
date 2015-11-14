var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var webpack = require('webpack');
var path = require('path');

var exclude = /node_modules|server/;
var output = path.join(__dirname, 'dist');

module.exports = {
    entry: {
        public: './public/js/app.js',
        admin: './admin/js/app.js'
    },

    devtool: 'source-map',

    output: {
        filename: '[name]/app.js',
        path: output
    },

    module: {
        loaders: [
            { test: /\.hbs$/, exclude: exclude, loader: 'handlebars-loader'},
            { test: /\.js$/, exclude: exclude, loader: 'babel-loader' , query: {presets: ['es2015']}},
            { test: /\.less$/, exclude: exclude, loader: ExtractTextPlugin.extract('style-loader', 'css-loader?sourceMap!less-loader?sourceMap')}
        ]
    },

    plugins: [
        new webpack.HotModuleReplacementPlugin(),
        new ExtractTextPlugin('[name]/app.css'),
        new HtmlWebpackPlugin({
            template: './public/index.html',
            filename: 'public/index.html'
        }),
        new HtmlWebpackPlugin({
            template: './admin/index.html',
            filename: 'admin/index.html'
        })
    ]
};
