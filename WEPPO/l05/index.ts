let settings = {
  setting1: true,
  anotherSetting: "server=localhost;username=admin",
};
type SettingsType = typeof settings;
function readSetting(settings: SettingsType, settingName: keyof SettingsType) {
  // już lepiej, można indeksować
  return settings[settingName];
}

