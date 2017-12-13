package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Setting;

public class SettingMapper {

    public static Setting fromDb(no.javazone.switcharoo.dao.model.Setting setting) {
        return new Setting(setting.id, setting.key, setting.hint, setting.value);
    }

    public static no.javazone.switcharoo.dao.model.Setting toDb(Setting s) {
        return new no.javazone.switcharoo.dao.model.Setting(s.id, s.key, s.hint, s.value);
    }

}
