package no.javazone.switcharoo.dao.model;

import com.google.gson.JsonObject;

public class DBSetting {
    public final Long id;
    public final String key;
    public final String hint;
    public final JsonObject value;

    public DBSetting(Long id, String key, String hint, JsonObject value) {
        this.id = id;
        this.key = key;
        this.hint = hint;
        this.value = value;
    }

    public DBSetting withId(Long id) {
        return new DBSetting(id, key, hint, value);
    }
}
