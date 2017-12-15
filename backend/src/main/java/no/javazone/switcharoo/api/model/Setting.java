package no.javazone.switcharoo.api.model;

import com.google.gson.JsonObject;

public class Setting {
    public final Long id;
    public final String key;
    public final String hint;
    public final JsonObject value;

public Setting(Long id, String key, String hint, JsonObject value) {
        this.id = id;
        this.key = key;
        this.hint = hint;
        this.value = value;
    }
}
