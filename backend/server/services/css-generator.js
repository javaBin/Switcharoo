const Css = require('../models').Css;

function css(res) {
    Css.findAll().then(rules => {
        const styleSheet = rules.map(rule => {
            return `${rule.selector} { ${rule.property}: ${rule.value}; }\n`;
        }).join('');

        res.set('Content-Type', 'text/css; charset=UTF-8');
        res.send(styleSheet);
    });
}

module.exports = {
    css: css
};
