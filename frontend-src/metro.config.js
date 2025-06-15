// metro.config.js
const { getDefaultConfig } = require("expo/metro-config");
const path = require("path");
const { withNativeWind } = require("nativewind/metro");

const projectRoot = __dirname;
const config = getDefaultConfig(projectRoot, {
  isCSSEnabled: false,
});

// Watch the ../docs folder for changes
config.watchFolders = [
  path.resolve(projectRoot, "../docs"),
];

// Move "md" from sourceExts to assetExts
config.resolver.assetExts = [...config.resolver.assetExts, "md"];

// Keep your existing transformer setup
config.transformer.assetPlugins = ['expo-asset/tools/hashAssetFiles'];

// Keep your existing nodeModulesPaths
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, "node_modules")
];

module.exports = withNativeWind(config, { input: "./global.css" })