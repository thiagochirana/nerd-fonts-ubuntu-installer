require 'json'
require 'net/http'
require 'uri'
require 'fileutils'
require 'zip'
require 'optparse'
require 'colorize'

# Função para ler o arquivo fonts.json
def load_fonts_json(file_path)
  file = File.read(file_path)
  JSON.parse(file)
end

# Função para seguir redirecionamentos
def follow_redirects(uri, limit = 10)
  raise 'Demasiados redirecionamentos' if limit == 0

  response = Net::HTTP.get_response(uri)
  
  case response
  when Net::HTTPSuccess then
    uri
  when Net::HTTPRedirection then
    new_uri = URI(response['location'])
    follow_redirects(new_uri, limit - 1)
  else
    raise "Erro ao acessar #{uri}: #{response.code} #{response.message}"
  end
end

# Função para baixar e descompactar os arquivos zip
def download_and_extract(url, install_dir)
  uri = URI(url)
  filename = File.join(install_dir, File.basename(uri.path))

  # Seguir redirecionamentos, se houver
  uri = follow_redirects(uri)

  puts "Baixando de: #{url} > Salvando como: #{filename}"

  # Baixar o arquivo
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Get.new(uri)
    http.request(request) do |response|
      File.open(filename, 'wb') do |file|
        response.read_body do |chunk|
          file.write(chunk) unless chunk.nil? || chunk.empty?
        end
      end
    end
  end

  # Verificar se o arquivo foi baixado corretamente
  if File.size?(filename).nil? || File.size?(filename) == 0
    puts "Erro: O arquivo #{filename} foi baixado com tamanho zero."
    return
  end

  # Descompactar o arquivo zip
  Zip::File.open(filename) do |zip_file|
    zip_file.each do |entry|
      entry.extract(File.join(install_dir, entry.name)) { true }
    end
  end

  # Remover o arquivo zip após extração
  File.delete(filename)
end

# Função para processar a escolha das fontes
def process_font_selection(selection, fonts)
  # Separar intervalos e números individuais
  selected_fonts = []
  selection.split(',').each do |part|
    if part.include?('-')
      range = part.split('-').map(&:to_i)
      selected_fonts.concat((range[0]..range[1]).to_a)
    else
      selected_fonts << part.to_i
    end
  end
  selected_fonts.uniq

  # Mostrar fontes selecionadas
  selected_fonts.map { |num| fonts.keys[num - 1] }
end

# Parsing de argumentos da linha de comando para a versão
options = { version: '3.2.1' }
OptionParser.new do |opts|
  opts.banner = "Uso: ruby install.rb [opções]"

  opts.on("-v", "--version VERSION", "Especificar versão das fontes (default: v3.2.1)") do |v|
    options[:version] = "v#{v}"
  end
end.parse!

# Carregar o JSON de fontes do arquivo fonts.json
fonts_json = load_fonts_json('fonts.json')

# Substituir VERSION no JSON pelas opções ou padrão
fonts_json["fonts"].each do |font_name, url|
  fonts_json["fonts"][font_name] = url.gsub('VERSION', options[:version])
end

# Exibir o menu de fontes
puts "Selecione as fontes que deseja instalar (ex: 1-5,7,10-12):"
puts "0. TODAS AS FONTES".yellow
fonts_json["fonts"].keys.each_with_index do |font, index|
  puts "#{index + 1}. #{font}"
end

# Capturar a seleção do usuário (usando $stdin.gets para evitar confusão com redirecionamento)
puts "Digite sua escolha:"
selection = $stdin.gets.chomp

selected_fonts = process_font_selection(selection, fonts_json["fonts"])

# Definir o diretório de instalação
install_dir = File.join(Dir.home, ".fonts")
FileUtils.mkdir_p(install_dir) unless Dir.exist?(install_dir)

# Instalar fontes selecionadas
selected_fonts.each do |font_name|
  url = fonts_json["fonts"][font_name]
  puts "Baixando e instalando #{font_name} > URL: #{url}"
  download_and_extract(url, install_dir)
end

# Atualizar o cache de fontes
puts "Atualizando o cache de fontes..."
system("fc-cache -f")

puts "Instalação concluída!"
