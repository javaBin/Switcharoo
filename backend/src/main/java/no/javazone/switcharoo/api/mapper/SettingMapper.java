package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Setting;
import no.javazone.switcharoo.dao.model.DBSetting;

public class SettingMapper {

    public static Setting fromDb(DBSetting setting) {
        return new Setting(setting.id, setting.key, setting.hint, setting.value);
    }

    public static DBSetting toDb(Setting s) {
        return new DBSetting(s.id, s.key, s.hint, s.value);
    }

}
