require 'sqlite3'

module Base
  module Db
    TABLES = ["activates"]

    def load_db(db_name="./space_server.db")
      db = ::SQLite3::Database.new db_name
      TABLES.each do |table|
        result = db.execute("SELECT COUNT(*) FROM sqlite_master where type='table' and name='activates'")
        db.execute(self.send("get_"+table+"_table_sql")) if result[0][0]==0
      end
      db
    end

    def get_activates_table_sql
      sql = "create table activates(" \
                 "value_type varchar(5)," \
                 "code_port_str varchar(30)," \
                 "l_or_h varchar(5)," \
                 "value float," \
                 "action varchar(30))"
      sql
    end

  end
end
