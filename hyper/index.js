'use strict';

const backgroundColor = '#0e1e25';
const foregroundColor = '#f7f8f8';
const borderColor = '#00ad9f';
const cursorColor = 'f7f8f8';
const colors = {
  black: '#000000',
  red: '#e8114e',
  green: '#43d860',
  yellow: '#ffad43',
  blue: '#43b4d8',
  magenta: '#ff6969',
  cyan: '#00ad9f',
  white: 'f7f8f8',
  lightBlack: '#2d3b41',
  lightRed: '#f25481',
  lightGreen: '#01df2e',
  lightYellow: '#ffd26e',
  lightBlue: '#c4e8f3',
  lightMagenta: '#ffb8b8',
  lightCyan: '#38ffee',
  lightWhite: '#ffffff',
};

exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor,
    foregroundColor,
    borderColor,
    cursorColor,
    colors,
    termCSS: `
      ${config.termCSS || ''}
    `,
    css: `
			${config.css || ''}
			.tabs_list .tab_tab.tab_active .tab_text  {
				background: ${backgroundColor};
			}
			.tab_active:before {
				border-color: ${borderColor};
			}
		`,
  });
};
