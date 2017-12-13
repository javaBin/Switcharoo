INSERT INTO settings(key, hint, value) VALUES('twitter-search', 'Twitter-søk', '{"type": "string", "value": "Switcharoo"}');

INSERT INTO services(key, value) VALUES('program-enabled', FALSE);
INSERT INTO services(key, value) VALUES('twitter-enabled', FALSE);

INSERT INTO csses(selector, property, value, type, title) VALUES('body', 'background-color', '#ffffff', 'string', 'Background color');
INSERT INTO csses(selector, property, value, type, title) VALUES('.slide__title', 'color', '#000000', 'string', 'Slide title color');
INSERT INTO csses(selector, property, value, type, title) VALUES('.slide__body', 'color', '#000000', 'string', 'Slide text color');
INSERT INTO csses(selector, property, value, type, title) VALUES('.tweet__at', 'color', '#000000', 'string', 'Tweet text handle color');
INSERT INTO csses(selector, property, value, type, title) VALUES('.tweet__text', 'color', '#000000', 'string', 'Tweet text color');
INSERT INTO csses(selector, property, value, type, title) VALUES('.tweet__hash', 'color', '#000000', 'string', 'Tweet text hash color');
INSERT INTO csses(selector, property, value, type, title) VALUES('.tweet__handle', 'color', '#000000', 'string', 'Tweet author handle color');
INSERT INTO csses(selector, property, value, type, title) VALUES('.tweet__name', 'color', '#000000', 'string', 'Tweet author name color');

INSERT INTO slides(title, body, visible, type, index, name) VALUES('Welcome', 'Your first slide', TRUE, 'text', 10, 'welcome');
