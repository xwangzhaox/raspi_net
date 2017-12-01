module Base
  module CmdQuota
    def update_cmd_quota
      respond = _get(@setting["interface"]["update_cmd_quota"]+"?space_code="+@setting["space_code"])
      store = YAML::Store.new self.class::SETTING_PATH
      store.transaction do
        store["cmd_quota_timestamp"] = respond["cmd_quota_timestamp"]
        store["cmd_quota"] = respond["cmd_quota"]
      end
    end
  end
end
