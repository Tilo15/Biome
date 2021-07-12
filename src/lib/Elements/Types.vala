namespace LibBiome.Elements {

    public enum ElementType {
        CONFIGURATION,
        RESOURCE,
        LIBRARY,
        CLI_APPLICATION,
        GUI_APPLICATION;

        public static ElementType from_string(string value) {
            switch (value) {
                case "config":
                    return CONFIGURATION;
                case "res":
                    return RESOURCE;
                case "lib":
                    return LIBRARY;
                case "cli":
                    return CLI_APPLICATION;
                case "gui":
                    return GUI_APPLICATION;
                default:
                    assert_not_reached();
            }
        }
    }

}