require 'sqlite3'

class Post

  @@SQLITE_DB_FILE = 'data/notepad.sqlite'

  def self.post_types
    { 'Memo' => Memo, 'Task' => Task, 'Link' => Link }
  end

  def self.create(type)
    post_types[type].new
  end

  def initialize
    @created_at = Time.now
    @text = []
  end

  def self.find_by_id(id)
    return if id.nil? # Если не передали id, возвращаем nil

    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true

    begin
    result = db.execute("SELECT * FROM posts WHERE rowid = ?", id)
    rescue SQLite3::SQLException => e
      puts "Не удалось выполнить запрос в базе #{@@SQLITE_DB_FILE}"
      abort e.message
    end

    db.close

    return nil if result.empty?

    result = result[0]

    post = create(result['type'])
    post.load_data(result)
    post
  end

  def self.find_all(limit, type)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)

    db.results_as_hash = false

    query = "SELECT rowid, * FROM posts "
    query += "WHERE type = :type " unless type.nil?
    query += "ORDER by rowid DESC "
    query += "LIMIT :limit " unless limit.nil?

    begin
    statement = db.prepare(query)
    rescue SQLite3::SQLException => e
      puts "Не удалось выполнить запрос в базе #{@@SQLITE_DB_FILE}"
      abort e.message
      end

    statement.bind_param('type', type) unless type.nil?
    statement.bind_param('limit', limit) unless limit.nil?

    begin
    result = statement.execute!
    rescue SQLite3::SQLException => e
      puts "Не удалось выполнить запрос в базе #{@@SQLITE_DB_FILE}"
      abort e.message
    end

    statement.close
    db.close

    result
  end

  def read_from_console
    #todo
  end

  def to_strings
    #todo
  end

  def file_path
    current_path = File.dirname(__FILE__ )

    file_name = @created_at.strftime("#{self.class.name}_%Y-%m-%d_%H_%M_%S.txt")

    return current_path + "/" + file_name
  end

  def save_to_db
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true

    begin
    db.execute(
      "INSERT INTO posts (" +
        to_db_hash.keys.join(',') +
        ")" +
        " VALUES (" +
        ('?,'*to_db_hash.keys.size).chomp(',') +
        ")",
      to_db_hash.values
    )

    rescue SQLite3::SQLException => e
      puts "Не удалось выполнить запрос в базе #{@@SQLITE_DB_FILE}"
      abort e.message
    end

    insert_row_id = db.last_insert_row_id
    db.close
    insert_row_id
  end

  def to_db_hash
    {
      'type' => self.class.name,
      'created_at' => @created_at.to_s
    }
  end

#  получает на вход хэш массив данных и должен заполнить свои поля
  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
    @text = data_hash['text']
  end
end
