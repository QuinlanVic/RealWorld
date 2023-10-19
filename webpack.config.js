const path = require('path');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

module.exports = {
    entry: './src/Main.elm', // Your Elm entry point
    output: {
        path: path.resolve(__dirname, 'build'), // Output directory
        filename: 'main.js', // Output filename
    },
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: 'elm-webpack-loader',
                    options: {
                        optimize: true
                    },
                },
            },
        ],
    },
    plugins: [
        new BundleAnalyzerPlugin(), // Add this line to enable the bundle analyzer
    ],
};
