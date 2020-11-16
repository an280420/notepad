# encoding: utf-8

# Этот код необходим только при использовании русских букв на Windows
if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

# Подключаем класс пост и его дочерник классы
require_relative 'lib/post'
require_relative 'lib/link'
require_relative 'lib/memo'
require_relative 'lib/task'

# id, limit, type

require 'optparse'

# Все наши опции будут записаны сюда
options = {}

OptionParser.new do |opt|
  opt.banner = 'Usage: read.rb [options]'

  opt.on('-h', 'Prints this help') do
    puts opt
    exit
  end

  # Опция --type будет передавать тип поста, который мы хотим считать
  opt.on('--type POST_TYPE', 'какой тип постов показывать (по умолчанию любой)') { |o| options[:type] = o }

  opt.on('--id POST_ID', 'если задан id - показываем подробно только этот пост') { |o| options[:id] = o }

  opt.on('--limit NUMBER', 'сколько последних постов показать (по умолчанию все)') { |o| options[:limit] = o }

# В конце у только что созданного объекта класса OptionParser вызываем метод
# метод parse, чтобы он заполнил наш хэш options в соответствии с правилами
end.parse!

# Вызываем метод find класса Post
result = Post.find(options[:limit], options[:type], options[:id])

if result.is_a? Post
  # Если результат — это один объект класса Post, значит выводим его
  puts "Запись #{result.class.name}, id = #{options[:id]}"

  # Получим строки для поста с помощью метода to_string и выведем их на экран
  result.to_strings.each { |line| puts line }
else
  # Если результат — это не один пост, а сразу несколько, показываем таблицу
  # Сначала — напечатаем шапку таблицы с названиями полей
  print '| id                 '
  print '| @type              '
  print '| @created_at        '
  print '| @text              '
  print '| @url               '
  print '| @due_date          '
  print '|'

  # Теперь для каждой строки из результатов выведем ее в нужном формате
  result.each do |row|
    # начинаем с пустой строки
    puts

    row.each do |element|
      element_text = "| #{element.to_s.delete("\n")[0..17]}"

      element_text << ' ' * (21 - element_text.size)

      print element_text
    end

    print '|'
  end

  puts
end
