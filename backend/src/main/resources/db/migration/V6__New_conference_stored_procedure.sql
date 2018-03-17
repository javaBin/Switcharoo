CREATE OR REPLACE FUNCTION new_conference(conference integer)
RETURNS void AS $$
BEGIN
  INSERT INTO settings(key, hint, value,conference_id) VALUES('twitter-search', 'Twitter-søk', '{"type": "string", "value": "Switcharoo"}', conference);

  INSERT INTO services(key, value, conference_id) VALUES('program-enabled', FALSE, conference);
  INSERT INTO services(key, value, conference_id) VALUES('twitter-enabled', FALSE, conference);

  INSERT INTO csses(selector, property, value, type, title, conference_id) VALUES('body', 'background-color', '#ffffff', 'string', 'Background color', conference);
  INSERT INTO csses(selector, property, value, type, title, conference_id) VALUES('.slide__title', 'color', '#000000', 'string', 'Slide title color', conference);
  INSERT INTO csses(selector, property, value, type, title, conference_id) VALUES('.slide__body', 'color', '#000000', 'string', 'Slide text color', conference);
  INSERT INTO csses(selector, property, value, type, title, conference_id) VALUES('.tweet__at', 'color', '#000000', 'string', 'Tweet text handle color', conference);
  INSERT INTO csses(selector, property, value, type, title, conference_id) VALUES('.tweet__text', 'color', '#000000', 'string', 'Tweet text color', conference);
  INSERT INTO csses(selector, property, value, type, title, conference_id) VALUES('.tweet__hash', 'color', '#000000', 'string', 'Tweet text hash color', conference);
  INSERT INTO csses(selector, property, value, type, title, conference_id) VALUES('.tweet__handle', 'color', '#000000', 'string', 'Tweet author handle color', conference);
  INSERT INTO csses(selector, property, value, type, title, conference_id) VALUES('.tweet__name', 'color', '#000000', 'string', 'Tweet author name color', conference);

  INSERT INTO slides(title, body, visible, type, index, name, conference_id) VALUES('Welcome', 'Your first slide', TRUE, 'text', 10, 'welcome', conference);

  INSERT INTO overlays(enabled, image, placement, width, height, conference_id) VALUES(false, '', 'TopLeft', '100%', '100%', conference);
END;
$$ LANGUAGE plpgsql;
