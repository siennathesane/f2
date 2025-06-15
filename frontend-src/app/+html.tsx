import { ScrollViewStyleReset } from 'expo-router/html';

// This file is web-only and used to configure the root HTML for every
// web page during static rendering.
// The contents of this function only run in Node.js environments and
// do not have access to the DOM or browser APIs.
export default function Root({ children }: { children: React.ReactNode }) {
    return (
        <html lang="en">
        <head>
            <meta charSet="utf-8" />
            <meta httpEquiv="X-UA-Compatible" content="IE=edge" />
            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />

            {/*
          Disable body scrolling on web. This makes ScrollView components work closer to how they do on native. 
          However, body scrolling is often nice to have for mobile web. If you want to enable it, remove this line.
        */}
            <ScrollViewStyleReset />

            {/* Using raw CSS styles as an escape-hatch to ensure the background color never flickers in dark-mode. */}
            <style dangerouslySetInnerHTML={{ __html: responsiveBackground }} />
            {/* Add any additional <head> elements that you want globally available on web... */}
        </head>
        <body>{children}</body>
        </html>
    );
}

const responsiveBackground = `
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  overflow-x: hidden;
  background-color: #fff;
}

#root, #__next {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
}

body > div:first-child {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
}

@media (prefers-color-scheme: dark) {
  html, body {
    background-color: #000;
  }
}`;